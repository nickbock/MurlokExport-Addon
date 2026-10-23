-- Kept lenient on purpose: WoW code runs against hundreds of game globals, so this
-- mainly catches syntax errors, shadowing and accidental new globals in our own files.
std = "lua51"
max_line_length = false
allow_defined_top = true
exclude_files = { "MurlokExport/Libs/", "MurlokExport/Data/" }
ignore = {
  "113", -- reading a game global (CreateFrame, C_ClassTalents, ...)
  "212", -- unused argument, common in event handlers and mixins
  "6..", -- whitespace
}
