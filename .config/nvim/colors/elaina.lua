
-- Elaina Neovim Color Scheme

-- Set the background to dark
vim.o.background = "dark"

-- Color Palette
local colors = {
  none = "NONE",
  bg = "#2C2A35",
  fg = "#E0E2F0",
  selection = "#7cb7ff33",
  comment = "#a0a1a7cc",
  red = "#ee5d43",
  orange = "#f39c12",
  yellow = "#FFE66D",
  green = "#96E072",
  cyan = "#00e8c6",
  blue = "#7cb7ff",
  purple = "#c74ded",
  pink = "#ff00aa",
  white = "#E0E2F0",
  black = "#211f28",
  grey = "#778b8a",
  -- VSCode Specific
  title_bar_active_bg = "#2C2A35",
  activity_bar_bg = "#26242e",
  activity_bar_fg = "#ffb7c5",
  activity_bar_inactive_fg = "#778b8a",
  activity_bar_badge_bg = "#ffb7c5",
  activity_bar_badge_fg = "#26242e",
  side_bar_bg = "#2f2d39",
  side_bar_fg = "#778b8a",
  side_bar_section_header_bg = "#2C2A35",
  side_bar_title_fg = "#ffb7c5",
  list_hover_bg = "#2a2833",
  list_inactive_selection_bg = "#282631",
  list_active_selection_bg = "#26242e",
  list_drop_bg = "#26242e",
  focus_border = "#ffb7c580",
  editor_group_drop_bg = "#495061d7",
  editor_group_header_tabs_bg = "#34313f",
  tab_active_bg = "#2C2A35",
  tab_inactive_bg = "#34313f",
  tab_active_fg = "#00e8c6",
  tab_inactive_fg = "#778b8a",
  status_bar_bg = "#211f28",
  status_bar_debugging_bg = "#FC644D",
  status_bar_no_folder_bg = "#23262E",
  editor_line_highlight_border = "#ffb7c533",
  editor_cursor = "#ffb7c5cc",
  terminal_red = "#ee5d43",
  terminal_green = "#96E072",
  terminal_yellow = "#FFE66D",
  terminal_blue = "#7cb7ff",
  terminal_magenta = "#ff00aa",
  terminal_cyan = "#00e8c6",
  git_decoration_ignored = "#778b8abf",
}

-- Highlight Groups
local highlights = {
  -- Default
  Normal = { fg = colors.fg, bg = colors.none },
  Visual = { bg = colors.selection },
  CursorLine = { bg = colors.list_active_selection_bg },
  CursorLineNr = { fg = colors.activity_bar_fg, bg = colors.list_active_selection_bg },
  SignColumn = { bg = colors.bg },
  LineNr = { fg = colors.grey },
  TabLine = { fg = colors.tab_inactive_fg, bg = colors.tab_inactive_bg },
  TabLineSel = { fg = colors.tab_active_fg, bg = colors.tab_active_bg },
  TabLineFill = { bg = colors.tab_inactive_bg },
  Pmenu = { fg = colors.fg, bg = colors.status_bar_bg },
  PmenuSel = { bg = colors.list_active_selection_bg },
  PmenuSbar = { bg = colors.side_bar_bg },
  PmenuThumb = { bg = colors.grey },
  VertSplit = { fg = colors.black, bg = colors.black },
  StatusLine = { fg = colors.fg, bg = colors.status_bar_bg },
  StatusLineNC = { fg = colors.grey, bg = colors.status_bar_bg },
  WildMenu = { fg = colors.fg, bg = colors.list_active_selection_bg },

  -- Syntax
  Comment = { fg = colors.comment, italic = true },
  Constant = { fg = colors.orange },
  String = { fg = colors.green },
  Character = { fg = colors.green },
  Number = { fg = colors.blue },
  Boolean = { fg = colors.blue },
  Float = { fg = colors.blue },
  Identifier = { fg = colors.cyan },
  Function = { fg = colors.yellow },
  Statement = { fg = colors.pink },
  Conditional = { fg = colors.pink },
  Repeat = { fg = colors.pink },
  Label = { fg = colors.pink },
  Operator = { fg = colors.red },
  Keyword = { fg = colors.pink },
  Exception = { fg = colors.red },
  PreProc = { fg = colors.purple },
  Include = { fg = colors.purple },
  Define = { fg = colors.purple },
  Macro = { fg = colors.purple },
  PreCondit = { fg = colors.purple },
  Type = { fg = colors.cyan },
  StorageClass = { fg = colors.pink },
  Structure = { fg = colors.cyan },
  Typedef = { fg = colors.cyan },
  Special = { fg = colors.purple },
  SpecialChar = { fg = colors.purple },
  Tag = { fg = colors.pink },
  Delimiter = { fg = colors.fg },
  SpecialComment = { fg = colors.comment, italic = true },
  Debugging = { fg = colors.red },
  Todo = { fg = colors.yellow, bg = colors.bg, bold = true },
  Error = { fg = colors.red, bg = colors.bg },
  Title = { fg = colors.blue, bold = true },
  Underlined = { underline = true },

  -- LSP
  LspDiagnosticsDefaultError = { fg = colors.red },
  LspDiagnosticsDefaultWarning = { fg = colors.yellow },
  LspDiagnosticsDefaultInformation = { fg = colors.blue },
  LspDiagnosticsDefaultHint = { fg = colors.cyan },

  -- Treesitter
  ["@text"] = { fg = colors.fg },
  ["@text.strong"] = { bold = true },
  ["@text.emphasis"] = { italic = true },
  ["@text.underline"] = { underline = true },
  ["@text.title"] = { fg = colors.blue, bold = true },
  ["@text.literal"] = { fg = colors.green },
  ["@text.uri"] = { fg = colors.blue, underline = true },
  ["@comment"] = { fg = colors.comment, italic = true },
  ["@punctuation.delimiter"] = { fg = colors.fg },
  ["@punctuation.bracket"] = { fg = colors.fg },
  ["@punctuation.special"] = { fg = colors.purple },
  ["@constant"] = { fg = colors.orange },
  ["@constant.builtin"] = { fg = colors.blue },
  ["@constant.macro"] = { fg = colors.purple },
  ["@string"] = { fg = colors.green },
  ["@string.escape"] = { fg = colors.purple },
  ["@string.regex"] = { fg = colors.blue },
  ["@character"] = { fg = colors.green },
  ["@number"] = { fg = colors.blue },
  ["@boolean"] = { fg = colors.blue },
  ["@float"] = { fg = colors.blue },
  ["@function"] = { fg = colors.yellow },
  ["@function.builtin"] = { fg = colors.blue },
  ["@function.macro"] = { fg = colors.purple },
  ["@method"] = { fg = colors.yellow },
  ["@method.call"] = { fg = colors.yellow },
  ["@constructor"] = { fg = colors.cyan },
  ["@keyword"] = { fg = colors.pink },
  ["@keyword.function"] = { fg = colors.pink },
  ["@keyword.operator"] = { fg = colors.red },
  ["@operator"] = { fg = colors.red },
  ["@conditional"] = { fg = colors.pink },
  ["@repeat"] = { fg = colors.pink },
  ["@label"] = { fg = colors.pink },
  ["@include"] = { fg = colors.purple },
  ["@exception"] = { fg = colors.red },
  ["@type"] = { fg = colors.cyan },
  ["@type.builtin"] = { fg = colors.blue },
  ["@structure"] = { fg = colors.cyan },
  ["@namespace"] = { fg = colors.cyan },
  ["@variable"] = { fg = colors.cyan },
  ["@variable.builtin"] = { fg = colors.blue },
  ["@parameter"] = { fg = colors.cyan },
  ["@property"] = { fg = colors.purple },
  ["@field"] = { fg = colors.purple },
  ["@tag"] = { fg = colors.pink },
  ["@tag.attribute"] = { fg = colors.purple },
  ["@tag.delimiter"] = { fg = colors.fg },
}

-- Apply Highlights
for group, properties in pairs(highlights) do
  local cmd = "highlight " .. group
  local gui_attrs = ""
  for key, value in pairs(properties) do
    if key == "fg" then
      cmd = cmd .. " guifg=" .. value
    elseif key == "bg" then
      cmd = cmd .. " guibg=" .. value
    elseif key == "sp" then
      cmd = cmd .. " guisp=" .. value
    elseif key == "italic" or key == "bold" or key == "underline" then
      if value then
        if gui_attrs == "" then
          gui_attrs = key
        else
          gui_attrs = gui_attrs .. "," .. key
        end
      end
    end
  end
  if gui_attrs ~= "" then
    cmd = cmd .. " gui=" .. gui_attrs
  end
  vim.cmd(cmd)
end
