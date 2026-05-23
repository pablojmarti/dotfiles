-- Darkmatrix colorscheme — exported from iTerm2-Color-Schemes
-- https://github.com/mbadolato/iTerm2-Color-Schemes
-- Generated at: 2026-05-18 (updated with brighter foreground for readability)

-- Color map (hex values from Darkmatrix.itermcolors, brighter fg)
local M = {
  -- Base
  base      = "#070c0e",
  surface   = "#0f1910",
  overlay   = "#222627",
  muted     = "#2f2c2c",
  fg        = "#a5e86c",  -- bright green (readable on dark bg)
  bg        = "#070c0e",

  -- ANSI 0–15
  black       = "#091013",
  red         = "#006536",
  green       = "#6fa64c",
  yellow      = "#7e8000",
  blue        = "#2c9a84",
  magenta     = "#452c53",
  cyan        = "#114d53",
  white       = "#006536",
  bright_black  = "#333333",
  bright_red    = "#007336",
  bright_green  = "#8fd770",
  bright_yellow = "#e4e500",
  bright_blue   = "#46d9ff",
  bright_magenta= "#4b3058",
  bright_cyan   = "#12555b",
  bright_white  = "#006536",

  -- Extended
  badge       = "#ff2600",
  bold        = "#00ce69",
  cursor      = "#b5c4a1",
  cursor_text = "#00ff87",
  link        = "#6fa64c",
  tab         = "#292727",
}

-- Set a highlight group.
-- Accepts a 'style' string that gets converted to Neovim boolean flags.
local function hl(name, attrs)
  local style = attrs.style
  if style then
    attrs.style = nil
    for flag in string.gmatch(style, "([^,]+)") do
      flag = flag:match("^%s*(.-)%s*$")  -- trim
      if flag then
        attrs[flag] = true
      end
    end
  end
  pcall(vim.api.nvim_set_hl, 0, name, attrs)
end

function M.setup()
  vim.g.colors_name = "darkermatrix"

  -- ── UI ──────────────────────────────────────────────
  hl("Normal",         { fg = M.fg, bg = M.bg })
  hl("Cursor",         { fg = M.cursor, bg = M.bg })
  hl("vCursor",        { fg = M.cursor_text, bg = M.bg })
  hl("CursorColumn",   { fg = M.fg, bg = M.surface })
  hl("CursorLine",     { bg = M.surface })
  hl("lCursor",        { fg = M.bright_blue, bg = M.surface })

  hl("StatusLine",     { fg = M.fg, bg = M.tab })
  hl("StatusLineNC",   { fg = M.bright_black, bg = M.tab })
  hl("WinBar",         { fg = M.fg, bg = M.tab })
  hl("WinBarNC",       { fg = M.bright_black, bg = M.tab })

  hl("LineNr",         { fg = M.bright_black, bg = M.bg })
  hl("CursorLineNr",   { fg = M.fg, bg = M.bg })
  hl("SignColumn",     { fg = M.bright_black, bg = M.bg })

  hl("VertSplit",      { bg = M.muted })
  hl("TabLine",        { fg = M.bright_black, bg = M.overlay })
  hl("TabLineFill",    { bg = M.overlay })
  hl("TabLineSel",     { fg = M.bright_blue, bg = M.tab })

  hl("Pmenu",          { fg = M.fg, bg = M.surface })
  hl("PmenuSel",       { fg = M.bg, bg = M.bright_blue })
  hl("PmenuSbar",      { bg = M.surface })
  hl("PmenuThumb",     { bg = M.overlay })

  hl("Search",         { fg = M.bg, bg = M.bright_yellow })
  hl("IncSearch",      { fg = M.bright_blue, bg = M.bright_yellow, style = "underline" })
  hl("CurSearch",      { fg = M.bg, bg = M.bright_green })
  hl("MatchParen",     { fg = M.bright_blue, style = "underline" })

  hl("DiffAdd",        { bg = M.surface })
  hl("DiffChange",     { bg = "#1a2e1a" })
  hl("DiffDelete",     { bg = "#2e1a1a" })
  hl("DiffText",       { bg = "#2e2e1a" })

  hl("Folded",         { fg = M.bright_black, bg = M.surface })
  hl("FoldColumn",     { fg = M.bright_black, bg = M.surface })
  hl("EndOfBuffer",    { fg = M.bg })

  hl("ErrorMsg",       { fg = M.bg, bg = M.bright_red })
  hl("WarningMsg",     { fg = M.bright_yellow })
  hl("ModeMsg",        { fg = M.bright_blue, style = "bold" })
  hl("MoreMsg",        { fg = M.bright_blue })
  hl("Question",       { fg = M.bright_blue })

  -- ── Syntax ──────────────────────────────────────────
  hl("Keyword",        { fg = M.bright_blue, style = "italic" })
  hl("String",         { fg = M.bright_green })
  hl("Number",         { fg = M.bright_yellow })
  hl("Comment",        { fg = M.fg })
  hl("Function",       { fg = M.bright_magenta })
  hl("Type",           { fg = M.bright_green })
  hl("Constant",       { fg = M.bright_yellow })
  hl("Operator",       { fg = M.bright_cyan })
  hl("Identifier",     { fg = M.fg })
  hl("Boolean",        { fg = M.bright_blue })
  hl("Conditional",    { fg = M.bright_blue })
  hl("Repeat",         { fg = M.bright_blue })
  hl("Exception",      { fg = M.bright_red })
  hl("Label",          { fg = M.bright_magenta })
  hl("PreProc",        { fg = M.bright_cyan })
  hl("Include",        { fg = M.bright_cyan })
  hl("Define",         { fg = M.bright_magenta })
  hl("Macro",          { fg = M.bright_cyan })
  hl("Special",        { fg = M.bright_yellow })
  hl("SpecialChar",    { fg = M.bright_yellow })
  hl("Title",          { fg = M.bright_green, style = "bold" })
  hl("Todo",           { fg = M.bright_yellow, style = "bold" })

  -- ── Treesitter ─────────────────────────────────────
  hl("@comment",       { fg = M.bright_black })
  hl("@string",        { fg = M.bright_green })
  hl("@string.escape", { fg = M.bright_yellow })
  hl("@string.special", { fg = M.bright_yellow })
  hl("@number",        { fg = M.bright_yellow })
  hl("@boolean",       { fg = M.bright_blue })
  hl("@keyword",       { fg = M.bright_blue, style = "italic" })
  hl("@keyword.control", { fg = M.bright_blue, style = "italic" })
  hl("@keyword.function", { fg = M.bright_blue, style = "italic" })
  hl("@keyword.operator", { fg = M.bright_cyan, style = "italic" })
  hl("@function",      { fg = M.bright_magenta })
  hl("@function.call", { fg = M.bright_magenta })
  hl("@function.builtin", { fg = M.bright_magenta })
  hl("@function.method", { fg = M.bright_magenta })
  hl("@type",          { fg = M.bright_green })
  hl("@type.definition", { fg = M.bright_green })
  hl("@type.builtin",  { fg = M.bright_green })
  hl("@constant",      { fg = M.bright_yellow })
  hl("@constant.builtin", { fg = M.bright_yellow })
  hl("@variable",      { fg = M.fg })
  hl("@variable.builtin", { fg = M.fg })
  hl("@variable.parameter", { fg = M.bright_cyan })
  hl("@parameter",     { fg = M.bright_cyan })
  hl("@property",      { fg = M.fg })
  hl("@field",         { fg = M.bright_magenta })
  hl("@attribute",     { fg = M.bright_magenta })
  hl("@operator",      { fg = M.bright_cyan })
  hl("@punctuation",   { fg = M.fg })
  hl("@punctuation.bracket", { fg = M.bright_black })
  hl("@punctuation.delimiter", { fg = M.bright_black })
  hl("@punctuation.special", { fg = M.bright_black })
  hl("@tag",           { fg = M.bright_green })
  hl("@tag.attribute", { fg = M.bright_yellow })
  hl("@tag.delimiter", { fg = M.bright_black })
  hl("@text",          { fg = M.fg })
  hl("@text.title",    { fg = M.bright_green })
  hl("@text.emphasis", { fg = M.bright_yellow, style = "italic" })
  hl("@text.strong",   { fg = M.bright_blue, style = "bold" })
  hl("@text.literal",  { fg = M.bright_green })
  hl("@text.uri",      { fg = M.link, style = "underline" })

  -- ── LSP / Diagnostics ──────────────────────────────
  hl("DiagnosticError",    { fg = M.bright_red, style = "undercurl" })
  hl("DiagnosticWarn",     { fg = M.bright_yellow, style = "undercurl" })
  hl("DiagnosticInfo",     { fg = M.bright_green, style = "undercurl" })
  hl("DiagnosticHint",     { fg = M.bright_blue, style = "undercurl" })
  hl("DiagnosticUnderlineError", { undercurl = true, sp = M.bright_red })
  hl("DiagnosticUnderlineWarn",  { undercurl = true, sp = M.bright_yellow })
  hl("DiagnosticUnderlineInfo",  { undercurl = true, sp = M.bright_green })
  hl("DiagnosticUnderlineHint",  { undercurl = true, sp = M.bright_blue })
  hl("LspInfoBorder",      { fg = M.bright_blue })
  hl("LspDocumentBorder",  { fg = M.muted })
  hl("LspFloatWinBorder",  { fg = M.muted, bg = M.surface })
  hl("LspInlayHint",       { fg = M.bright_black, bg = M.surface })

  -- ── Telescope ──────────────────────────────────────
  hl("TelescopeBorder",    { fg = M.bright_blue })
  hl("TelescopeMatching",  { fg = M.bright_yellow, style = "bold" })
  hl("TelescopeMulti",     { fg = M.fg })
  hl("TelescopePreview",   { fg = M.bright_black })
  hl("TelescopeResults",   { fg = M.fg })

  -- ── NvimTree / NeoTree ─────────────────────────────
  hl("NvimTreeNormal",      { fg = M.fg, bg = M.bg })
  hl("NvimTreeDirectory",   { fg = M.bright_blue })
  hl("NvimTreeGitStaged",   { fg = M.bright_green })
  hl("NvimTreeGitDirty",    { fg = M.bright_yellow })
  hl("NvimTreeGitDeleted",  { fg = M.bright_red })
  hl("NvimTreeSpecialFile", { fg = M.bright_yellow, style = "bold" })
  hl("NeoTreeNormal",       { fg = M.fg, bg = M.bg })
  hl("NeoTreeDirectory",    { fg = M.bright_blue })
  hl("NeoTreeFile",         { fg = M.fg })
  hl("NeoTreeIndentMarker", { fg = M.bright_black })

  -- ── Git ────────────────────────────────────────────
  hl("GitSignsAdd",      { fg = M.bright_green })
  hl("GitSignsChange",   { fg = M.bright_yellow })
  hl("GitSignsDelete",   { fg = M.bright_red })
  hl("GitAdd",           { fg = M.bright_green })
  hl("GitChange",        { fg = M.bright_yellow })
  hl("GitDelete",        { fg = M.bright_red })

  -- ── WhichKey ───────────────────────────────────────
  hl("WhichKey",          { fg = M.bright_blue })
  hl("WhichKeyGroup",     { fg = M.fg })
  hl("WhichKeySeperator", { fg = M.bright_black })
  hl("WhichKeyValue",     { fg = M.bright_magenta })
  hl("WhichKeyFloat",     { fg = M.fg, bg = M.bg })

  -- ── Dashboard ──────────────────────────────────────
  hl("DashboardHeader",   { fg = M.bright_green })
  hl("DashboardKey",      { fg = M.bright_blue })
  hl("DashboardShortcut", { fg = M.bright_yellow })
  hl("DashboardFooter",   { fg = M.fg })
  hl("DashboardCenter",   { fg = M.fg })
  hl("DashboardIcons",    { fg = M.bright_green })

  -- ── Flash / Hop ────────────────────────────────────
  hl("FlashPrompt",       { fg = M.bright_blue, style = "bold" })
  hl("FlashLabel",        { fg = M.bright_blue })
  hl("FlashMatch",        { fg = M.bright_green, style = "bold" })
  hl("FlashCurrent",      { fg = M.bright_blue, style = "bold" })
  hl("FlashCurrentLabel", { fg = M.bright_blue, style = "bold" })
  hl("HopNextKey",        { fg = M.bright_blue })
  hl("HopNextKey2",       { fg = M.bright_magenta })
  hl("HopUnmatched",      { fg = M.bright_black })

  -- ── Noice ──────────────────────────────────────────
  hl("NoiceLine",            { fg = M.fg, bg = M.tab })
  hl("NoiceLspProgress",     { fg = M.bright_blue })
  hl("NoiceLspProgressDone", { fg = M.bright_green })
  hl("NoiceLspProgressError",{ fg = M.bright_red })
  hl("NoiceLspProgressWarn", { fg = M.bright_yellow })

  -- ── Mini suite ─────────────────────────────────────
  hl("MiniAnimateCursorGutter", { fg = M.bright_cyan })
  hl("MiniClue",                { fg = M.bright_blue })
  hl("MiniCompletion",          { fg = M.fg })
  hl("MiniCursorline",         { fg = M.fg, bg = M.surface })
  hl("MiniDiffs",              { fg = M.bright_blue })
  hl("MiniIcons",              { fg = M.fg })
  hl("MiniIndentscope",        { fg = M.fg })
  hl("MiniIndentscopeSymbol",  { fg = M.bright_black })
  hl("MiniJump",               { fg = M.bright_blue })
  hl("MiniJump2ndSel",         { fg = M.bright_blue })
  hl("MiniStarter",            { fg = M.fg })
  hl("MiniStarterFooter",      { fg = M.bright_blue })
  hl("MiniStarterHeader",      { fg = M.bright_blue })
  hl("MiniStarterSection",     { fg = M.bright_green })
  hl("MiniSurround",           { fg = M.fg })
  hl("MiniTabline",            { fg = M.fg })
  hl("MiniTablineModified",    { fg = M.bright_black })
  hl("MiniTablineTarget",      { fg = M.bright_magenta })
  hl("MiniTest",               { fg = M.bright_blue })
  hl("MiniTestPassed",         { fg = M.bright_green })
  hl("MiniTestFail",           { fg = M.bright_red })
  hl("MiniTestInError",        { fg = M.bright_yellow })
  hl("MiniTestSkipped",        { fg = M.fg })
  hl("MiniWrap",               { fg = M.fg })

  -- ── Bufferline ─────────────────────────────────────
  hl("BufferLineFill",        { fg = M.bright_black, bg = M.bg })
  hl("BufferLineBuffer",      { fg = M.fg, bg = M.surface })
  hl("BufferLineBufferVisible", { fg = M.bright_black, bg = M.surface })
  hl("BufferLineSelected",    { fg = M.bright_blue, bg = M.tab })
  hl("BufferLineCloseButton", { fg = M.bright_black })
  hl("BufferLineModified",    { fg = M.bright_blue })

  -- ── nvim-cmp ───────────────────────────────────────
  hl("CmpMenu",              { fg = M.fg, bg = M.bg })
  hl("CmpDoc",               { fg = M.bright_black, bg = M.bg })
  hl("CmpItemAbbr",          { fg = M.fg })
  hl("CmpItemAbbrMatch",     { fg = M.bright_yellow })
  hl("CmpItemMenu",          { fg = M.bright_black })
  hl("CmpItemKind",          { fg = M.bright_magenta })
  hl("CmpItemKindFunction",  { fg = M.bright_magenta })
  hl("CmpItemKindMethod",    { fg = M.bright_magenta })
  hl("CmpItemKindKeyword",   { fg = M.bright_blue })
  hl("CmpItemKindOperator",  { fg = M.bright_cyan })
  hl("CmpItemKindConstant",  { fg = M.bright_yellow })
  hl("CmpItemKindClass",     { fg = M.bright_green })
  hl("CmpItemKindType",      { fg = M.bright_green })

  -- ── Misc ───────────────────────────────────────────
  hl("IndentLine",           { fg = M.bright_black })
  hl("IndentBlanklineChar",  { fg = M.bright_black })
  hl("NormalNC",             { fg = M.bright_black, bg = M.bg })
end

return M
