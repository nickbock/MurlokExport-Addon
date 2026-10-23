-- Kept lenient on purpose: WoW code runs against hundreds of game globals, so this
-- mainly catches syntax errors and accidental new globals in our own files.
std = "lua51"
max_line_length = false
allow_defined_top = true
exclude_files = { "MurlokExport/Libs/", "MurlokExport/Data/" }
globals = {
  "SlashCmdList",
  "SLASH_RELOADUI1",
  "SLASH_ME1",
  "SLASH_ME2",
  "UIMurlokExport",
}
ignore = {
  "113", -- reading a game global (CreateFrame, C_ClassTalents, ...)
  "131", -- unused global: locale strings are read from the XML files
  "21.", -- unused variable, argument or loop variable
  "311", -- value assigned to a variable is unused
  "411", -- variable redefined in the same scope
  "6..", -- whitespace
}
