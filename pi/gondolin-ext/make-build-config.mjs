#!/usr/bin/env node
// Writes build-config.local.json for this host:
//   gondolin's own defaults (`build --init-config`)
//   + the packages and env from build-config.base.json
//   + arch from the hardware (not from Node, which may be an x86_64 build under Rosetta).
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const base = JSON.parse(fs.readFileSync(path.join(here, "build-config.base.json"), "utf8"));

const gondolin = path.join(here, "node_modules", ".bin", "gondolin");
const defaults = JSON.parse(execFileSync(gondolin, ["build", "--init-config"], { cwd: here, encoding: "utf8" }));

// Under Rosetta, uname -m reports x86_64 on Apple Silicon; ask the hardware instead.
const appleSilicon =
	process.platform === "darwin" &&
	execFileSync("sysctl", ["-in", "hw.optional.arm64"], { encoding: "utf8" }).trim() === "1";
const machine = appleSilicon ? "arm64" : execFileSync("uname", ["-m"], { encoding: "utf8" }).trim();
const arch = { arm64: "aarch64", aarch64: "aarch64", x86_64: "x86_64", amd64: "x86_64" }[machine];
if (!arch) throw new Error(`unsupported machine type: ${machine}`);

const out = { ...defaults, ...base, arch };
out.alpine = { ...defaults.alpine, ...base.alpine };
out.alpine.rootfsPackages = [
	...new Set([...(defaults.alpine?.rootfsPackages ?? []), ...(base.alpine?.rootfsPackages ?? [])]),
];
out.env = { ...(defaults.env ?? {}), ...(base.env ?? {}) };

const target = path.join(here, "build-config.local.json");
fs.writeFileSync(target, JSON.stringify(out, null, 2) + "\n");
console.log(`wrote ${target} (arch ${arch}, ${out.alpine.rootfsPackages.length} packages)`);
