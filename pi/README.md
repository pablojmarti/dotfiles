# Pi + Gondolin config

Shared by macOS (`macbook2024-redux`) and Arch (`arch2025`).

```sh
./pi/install.sh          # links ~/.pi/agent/{settings.json,prompts,.i-have-adhd-always} and ~/.pi/gondolin-ext
$EDITOR ~/.pi/agent/models.json   # put the real apiKey in (never committed)
pi-vm-rebuild            # builds ~/.pi/gondolin-image from build-config.local.json
```

- `agent/`: Pi settings, the 10 prompt commands, and `models.json.example`.
- `gondolin-ext/`: the VM extension (`index.ts`). The VM packages go in `build-config.base.json`; edit that file, then rerun `install.sh` (or `node gondolin-ext/make-build-config.mjs`) and `pi-vm-rebuild`.
- `kit/`: the check scripts from rally-test `brief/seed` (check-bug, check-refs, play-check, mutate-check, and others).

Not in git: `auth.json`, `models.json`, `models-store.json`, `sessions/`, `install/`, `bin/`, `git/`, herdr's extension, and the built image.

## Arch Linux prerequisites

```sh
sudo pacman -S nodejs npm qemu-base qemu-system-x86 e2fsprogs   # qemu-system-aarch64 on ARM
sudo usermod -aG kvm "$USER"   # log out and back in
```
Node must be 23.6 or newer. Install Pi itself as on the Mac.
