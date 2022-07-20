local lush = require("lush")
local hsl = lush.hsl

---@diagnostic disable
local theme =
    lush(
    function()
        local c = {
            bg = hsl(195, 6, 12),
            bg1 = hsl(20, 5, 22),
            bg2 = hsl(22, 7, 29),
            bg3 = hsl(27, 10, 36),
            bg4 = hsl(28, 11, 44),
            gray = hsl(30, 12, 51),
            white = hsl(43, 45, 78),
            blue = hsl(177, 20, 58),
            red = hsl(6, 82, 59),
            orange = hsl(27, 85, 55),
            yellow = hsl(42, 85, 58),
            green = hsl(75, 40, 55),
            aqua = hsl(124, 32, 60),
            purple = hsl(344, 47, 68),
            green_alt = hsl(80, 58, 13),
            orange_alt = hsl(34, 58, 16),
            red_alt = hsl(6, 58, 14),
            yellow_alt = hsl(42, 65, 14),
            blue_alt = hsl(180, 46, 14)
        }
        return {
            -- The following are all the Neovim default highlight groups from the docs
            -- as of 0.5.0-nightly-446, to aid your theme creation. Your themes should
            -- probably style all of these at a bare minimum.
            --
            -- Referenced/linked groups must come before being referenced/lined,
            -- so the order shown ((mostly) alphabetical) is likely
            -- not the order you will end up with.
            --
            -- You can uncomment these and leave them empty to disable any
            -- styling for that group (meaning they mostly get styled as Normal)
            -- or leave them commented to apply vims default colouring or linking.

            Comment {fg = c.gray, gui = "italic"}, -- any comment
            Normal {bg = "NONE", fg = c.white}, -- normal text
            CursorLine {bg = c.bg1}, -- Screen-line at the cursor, when 'cursorline' is set.  Low-priority if foreground (ctermfg OR guifg) is not set.
            CursorColumn {CursorLine}, -- Screen-column at the cursor, when 'cursorcolumn' is set.
            ColorColumn {CursorLine}, -- used for the columns set with 'colorcolumn'
            Conceal {fg = c.blue}, -- placeholder characters substituted for concealed text (see 'conceallevel')
            Cursor {fg = "NONE", bg = "NONE", gui = "reverse"}, -- character under the cursor
            lCursor {Cursor}, -- the character under the cursor when |language-mapping| is used (see 'guicursor')
            CursorIM {Cursor}, -- like Cursor, but used when in IME mode |CursorIM|
            Directory {bg = "NONE", fg = c.orange}, -- directory names (and other special names in listings)
            DiffAdd {bg = c.green_alt, fg = "NONE"}, -- diff mode: Added line |diff.txt|
            DiffChange {bg = c.orange_alt, fg = "NONE"}, -- diff mode: Changed line |diff.txt|
            DiffDelete {bg = c.red_alt, fg = c.red_alt.li(25)}, -- diff mode: Deleted line |diff.txt|
            DiffText {bg = "NONE", fg = "NONE"}, -- diff mode: Changed text within a changed line |diff.txt|
            EndOfBuffer {fg = c.bg2}, -- filler lines (~) after the end of the buffer.  By default, this is highlighted like |hl-NonText|.
            TermCursor {Cursor}, -- cursor in a focused terminal
            TermCursorNC {Cursor}, -- cursor in an unfocused terminal
            ErrorMsg {bg = c.red_alt, fg = c.red}, -- error messages on the command line
            VertSplit {bg = "NONE", fg = c.bg2}, -- the column separating vertically split windows
            Folded {bg = c.bg1}, -- line used for closed folds
            FoldColumn {Folded}, -- 'foldcolumn'
            SignColumn {Normal}, -- column where |signs| are displayed
            Search {bg = c.gray, fg = c.bg}, -- Last search pattern highlighting (see 'hlsearch').  Also used for similar items that need to stand out.
            IncSearch {Search}, -- 'incsearch' highlighting, also used for the text replaced with ":s///c"
            Substitute {Search}, -- |:substitute| replacement text highlighting
            LineNr {bg = "NONE", fg = c.gray}, -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
            CursorLineNr {LineNr, fg = c.yellow}, -- Like LineNr when 'cursorline' or 'relativenumber' is set for the cursor line.
            MatchParen {bg = c.bg2, fg = "NONE", gui = "underline"}, -- The character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
            ModeMsg {Normal}, -- 'showmode' message (e.g., "-- INSERT -- ")
            MsgArea {Normal}, -- Area for messages and cmdline
            MsgSeparator {Normal}, -- Separator for scrolled messages, `msgsep` flag of 'display'
            MoreMsg {bg = "NONE", fg = c.yellow}, -- |more-prompt|
            NonText {EndOfBuffer}, -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text (e.g., ">" displayed when a double-wide character doesn't fit at the end of the line). See also |hl-EndOfBuffer|.
            NormalFloat {bg = c.bg1.ro(200), fg = "NONE"}, -- Normal text in floating windows.
            FloatBorder {bg = c.bg1.ro(200), fg = c.gray}, -- Normal text in floating windows.
            NormalNC {Normal}, -- normal text in non-current windows
            Pmenu {bg = c.bg1, fg = c.gray.li(20)}, -- Popup menu: normal item.
            PmenuSel {bg = c.bg3.da(30), fg = c.yellow.li(20)}, -- Popup menu: selected item.
            PmenuSbar {bg = c.bg2, fg = "NONE"}, -- Popup menu: scrollbar.
            PmenuThumb {bg = c.bg3, fg = "NONE"}, -- Popup menu: Thumb of the scrollbar.
            Question {MoreMsg}, -- |hit-enter| prompt and yes/no questions
            QuickFixLine {CursorLine}, -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
            SpecialKey {bg = "NONE", fg = c.blue, gui = "bold"}, -- Unprintable characters: text displayed differently from what it really is.  But not 'listchars' whitespace. |hl-Whitespace|
            SpellBad {bg = "NONE", fg = c.white, gui = "underline", sp = c.red}, -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
            SpellCap {bg = "NONE", fg = c.white, gui = "underline", sp = c.yellow}, -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
            SpellLocal {bg = "NONE", fg = c.white, gui = "underline", sp = c.green}, -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
            SpellRare {bg = "NONE", fg = c.white, gui = "underline", sp = c.blue}, -- Word that is recognized by the spellchecker as one that is hardly ever used.  |spell| Combined with the highlighting used otherwise.
            TabLine {bg = c.bg1, fg = c.white}, -- tab pages line, not active tab page label
            TabLineFill {bg = "NONE", fg = c.white}, -- tab pages line, where there are no labels
            TabLineSel {bg = c.bg1, fg = c.yellow}, -- tab pages line, active tab page label
            Title {bg = "NONE", fg = c.aqua, gui = "bold"}, -- titles for output from ":set all", ":autocmd" etc.
            Visual {bg = c.bg2, fg = "NONE"}, -- Visual mode selection
            VisualNOS {gui = "reverse"}, -- Visual mode selection when vim is "Not Owning the Selection".
            WarningMsg {bg = "NONE", fg = c.red}, -- warning messages
            Whitespace {Comment}, -- "nbsp", "space", "tab" and "trail" in 'listchars'
            WildMenu {PmenuSel}, -- current match in 'wildmenu' completion
            -- These groups are not listed as default vim groups,
            -- but they are defacto standard group names for syntax highlighting.
            -- commented out groups should chain up to their "preferred" group by
            -- default,
            -- Uncomment and edit if you want more specific syntax highlighting.

            Constant {bg = "NONE", fg = c.purple}, -- (preferred) any constant
            String {bg = "NONE", fg = c.green}, --   a string constant: "this is a string"
            Character {Constant}, --  a character constant: 'c', '\n'
            Number {bg = "NONE", fg = c.purple}, --   a number constant: 234, 0xff
            Boolean {bg = "NONE", fg = c.purple}, --  a boolean constant: TRUE, false
            Float {bg = "NONE", fg = c.purple}, --    a floating point constant: 2.3e10
            Identifier {bg = "NONE", fg = c.blue}, -- (preferred) any variable name
            Function {bg = "NONE", fg = c.aqua}, -- function name (also: methods for classes)
            Statement {bg = "NONE", fg = c.red}, -- (preferred) any statement
            Conditional {bg = "NONE", fg = c.red}, --  if, then, else, endif, switch, etc.
            Repeat {bg = "NONE", fg = c.red}, --   for, do, while, etc.
            Label {bg = "NONE", fg = c.red}, --    case, default, etc.
            Operator {bg = "NONE", fg = c.aqua}, -- "sizeof", "+", "*", etc.
            Keyword {bg = "NONE", fg = c.red}, --  any other keyword
            Exception {bg = "NONE", fg = c.red}, --  try, catch, throw
            PreProc {bg = "NONE", fg = c.aqua}, -- (preferred) generic Preprocessor
            Include {PreProc}, --  preprocessor #include
            Define {PreProc}, --  preprocessor #define
            Macro {PreProc}, --  same as Define
            PreCondit {PreProc}, --  preprocessor #if, #else, #endif, etc.
            Type {bg = "NONE", fg = c.yellow}, -- (preferred) int, long, char, etc.
            StorageClass {bg = "NONE", fg = c.orange}, -- static, register, volatile, etc.
            Structure {bg = "NONE", fg = c.aqua}, --  struct, union, enum, etc.
            Typedef {Type}, --  A typedef
            Special {bg = "NONE", fg = c.orange}, -- (preferred) any special symbol
            SpecialChar {Character}, --  special character in a constant
            Tag {bg = "NONE", fg = c.red}, --    you can use CTRL-] on this
            Delimiter {bg = "NONE", fg = c.orange}, --  character that needs attention
            SpecialComment {bg = "NONE", fg = c.red}, -- special things inside a comment
            Debug {bg = "NONE", fg = c.red}, --    debugging statements
            Underlined {fg = "NONE", gui = "underline"}, -- (preferred) text that stands out, HTML links
            Bold {fg = "NONE", gui = "bold"},
            Italic {fg = "NONE", gui = "italic"},
            -- ("Ignore", below, may be invisible...)
            Ignore {fg = c.white}, -- (preferred) left blank, hidden  |hl-Ignore|
            Error {bg = c.red_alt, fg = c.red}, -- (preferred) any erroneous construct
            Todo {bg = "NONE", fg = c.red, gui = "bold"}, -- (preferred) anything that needs extra attention, mostly the keywords TODO FIXME and XXX
            -- These groups are for the native LSP client. Some other LSP clients may
            -- use these groups, or use their own. Consult your LSP client's
            -- documentation.

            LspReferenceText {bg = c.bg1, fg = "NONE", gui = "underline"}, -- used for highlighting "text" references
            LspReferenceRead {bg = c.bg1, fg = "NONE", gui = "underline"}, -- used for highlighting "read" references
            LspReferenceWrite {bg = c.bg1, fg = "NONE", gui = "underline"}, -- used for highlighting "write" references
            LspDiagnosticsDefaultError {bg = c.red_alt, fg = c.red}, -- Used as the base highlight group. Other LspDiagnostic highlights link to this by default (except Underline)
            LspDiagnosticsDefaultWarning {bg = c.yellow_alt, fg = c.yellow}, -- Used as the base highlight group. Other LspDiagnostic highlights link to this by default (except Underline)
            LspDiagnosticsDefaultInformation {bg = c.blue_alt, fg = c.blue}, -- Used as the base highlight group. Other LspDiagnostic highlights link to this by default (except Underline)
            LspDiagnosticsDefaultHint {bg = c.green_alt, fg = c.green}, -- Used as the base highlight group. Other LspDiagnostic highlights link to this by default (except Underline)
            LspDiagnosticsVirtualTextError {LspDiagnosticsDefaultError}, -- Used for "Error" diagnostic virtual text
            LspDiagnosticsVirtualTextWarning {LspDiagnosticsDefaultWarning}, -- Used for "Warning" diagnostic virtual text
            LspDiagnosticsVirtualTextInformation {LspDiagnosticsDefaultInformation}, -- Used for "Information" diagnostic virtual text
            LspDiagnosticsVirtualTextHint {LspDiagnosticsDefaultHint}, -- Used for "Hint" diagnostic virtual text
            LspDiagnosticsUnderlineError {fg = "NONE", gui = "underline", sp = c.red}, -- Used to underline "Error" diagnostics
            LspDiagnosticsUnderlineWarning {fg = "NONE", gui = "underline", sp = c.yellow}, -- Used to underline "Warning" diagnostics
            LspDiagnosticsUnderlineInformation {fg = "NONE", gui = "underline", sp = c.blue}, -- Used to underline "Information" diagnostics
            LspDiagnosticsUnderlineHint {fg = "NONE", gui = "underline", sp = c.green}, -- Used to underline "Hint" diagnostics
            LspDiagnosticsFloatingError {bg = "NONE", fg = c.red, gui = "NONE"}, -- Used to color "Error" diagnostic messages in diagnostics float
            LspDiagnosticsFloatingWarning {bg = "NONE", fg = c.yellow, gui = "NONE"}, -- Used to color "Warning" diagnostic messages in diagnostics float
            LspDiagnosticsFloatingInformation {bg = "NONE", fg = c.blue, gui = "NONE"}, -- Used to color "Information" diagnostic messages in diagnostics float
            LspDiagnosticsFloatingHint {bg = "NONE", fg = c.green, gui = "NONE"}, -- Used to color "Hint" diagnostic messages in diagnostics float
            LspDiagnosticsSignError {bg = "NONE", fg = c.red, gui = "NONE"}, -- Used for "Error" signs in sign column
            LspDiagnosticsSignWarning {bg = "NONE", fg = c.yellow, gui = "NONE"}, -- Used for "Warning" signs in sign column
            LspDiagnosticsSignInformation {bg = "NONE", fg = c.blue, gui = "NONE"}, -- Used for "Information" signs in sign column
            LspDiagnosticsSignHint {bg = "NONE", fg = c.green, gui = "NONE"}, -- Used for "Hint" signs in sign column
            -- These groups are for the neovim tree-sitter highlights.
            -- As of writing, tree-sitter support is a WIP, group names may change.
            -- By default, most of these groups link to an appropriate Vim group,
            -- TSError -> Error for example, so you do not have to define these unless
            -- you explicitly want to support Treesitter's improved syntax awareness.

            TSAnnotation {bg = "NONE", fg = c.blue}, -- For C++/Dart attributes, annotations that can be attached to the code to denote some kind of meta information.
            TSAttribute {bg = "NONE", fg = c.aqua}, -- (unstable) TODO: docs
            TSBoolean {Boolean}, -- For booleans.
            TSCharacter {Character}, -- For characters.
            TSComment {Comment}, -- For comment blocks.
            TSConstructor {bg = "NONE", fg = c.orange}, -- For constructor calls and definitions: ` { }` in Lua, and Java constructors.
            TSConditional {Conditional}, -- For keywords related to conditionnals.
            TSConstant {Constant}, -- For constants
            TSConstBuiltin {Constant}, -- For constant that are built in the language: `nil` in Lua.
            TSConstMacro {Macro}, -- For constants that are defined by macros: `NULL` in C.
            TSError {bg = "NONE", fg = "NONE"}, -- For syntax/parser errors.
            TSException {Exception}, -- For exception related keywords.
            TSField {bg = "NONE", fg = c.blue}, -- For fields.
            TSFloat {Float}, -- For floats.
            TSFunction {Function}, -- For function (calls and definitions).
            TSFuncBuiltin {Function}, -- For builtin functions: `table.insert` in Lua.
            TSFuncMacro {Macro}, -- For macro defined fuctions (calls and definitions): each `macro_rules` in Rust.
            TSInclude {Include}, -- For includes: `#include` in C, `use` or `extern crate` in Rust, or `require` in Lua.
            TSKeyword {Keyword}, -- For keywords that don't fall in previous categories.
            TSKeywordFunction {Keyword}, -- For keywords used to define a fuction.
            TSLabel {Label}, -- For labels: `label:` in C and `:label:` in Lua.
            TSMethod {Function}, -- For method calls and definitions.
            TSNamespace {bg = "NONE", fg = c.blue}, -- For identifiers referring to modules and namespaces.
            -- TSNone                { },    -- TODO: docs
            TSNumber {Number}, -- For all numbers
            TSOperator {Operator}, -- For any operator: `+`, but also `->` and `*` in C.
            TSParameter {TSField}, -- For parameters of a function.
            TSParameterReference {TSParameter}, -- For references to parameters of a function.
            TSProperty {TSField}, -- Same as `TSField`.
            TSPunctDelimiter {Delimiter}, -- For delimiters ie: `.`
            TSPunctBracket {Delimiter}, -- For brackets and parens.
            -- TSPunctSpecial        { },    -- For special punctutation that does not fall in the catagories before.
            TSRepeat {Repeat}, -- For keywords related to loops.
            TSString {String}, -- For strings.
            TSStringRegex {TSString}, -- For regexes.
            TSStringEscape {Character}, -- For escape characters within a string.
            TSSymbol {Identifier}, -- For identifiers referring to symbols or atoms.
            TSType {Type}, -- For types.
            TSTypeBuiltin {Type}, -- For builtin types.
            TSVariable {bg = "NONE", fg = c.white}, -- Any variable name that does not have another highlight.
            TSVariableBuiltin {bg = "NONE", fg = c.orange}, -- Variable names that are defined by the languages, like `this` or `self`.
            TSTag {Tag}, -- Tags like html tag names.
            TSTagDelimiter {Delimiter}, -- Tag delimiter like `<` `>` `/`
            TSText {bg = "NONE", fg = c.white}, -- For strings considered text in a markup language.
            TSEmphasis {gui = "italic"}, -- For text to be represented with emphasis.
            TSUnderline {gui = "underline"}, -- For text to be represented with an underline.
            TSStrike {gui = "strikethrough"}, -- For strikethrough text.
            TSTitle {fg = c.blue, gui = "bold"}, -- Text that is part of a title.
            TSLiteral {String}, -- Literal text.
            TSURI {fg = "NONE", gui = "underline"}, -- Any URI like a link or email.
            -- gitsigns.nvim
            SignAdd {fg = c.blue}, -- Any URI like a link or email.
            SignChange {fg = c.orange}, -- Any URI like a link or email.
            SignDelete {fg = c.red}, -- Any URI like a link or email.
            -- telescope.nvim
            TelescopeSelection {bg = "NONE", fg = c.yellow, gui = "bold"},
            TelescopeMatching {bg = "NONE", fg = c.red, gui = "bold"},
            TelescopeBorder {bg = "NONE", fg = c.bg3, gui = "bold"},
            -- nvim-tree.lua
            NvimTreeFolderIcon {fg = c.yellow},
            NvimTreeIndentMarker {fg = c.gray},
            NvimTreeNormal {fg = c.white.da(5)},
            NvimTreeFolderName {fg = c.yellow, gui = "bold"},
            NvimTreeOpenedFolderName {fg = c.yellow.li(10), gui = "bold"},
            NvimTreeRootFolder {fg = c.yellow.da(20)},
            NvimTreeExecFile {fg = c.blue},
            -- some fix for html related stuff
            htmlH1 {Title},
            -- markdown stuff
            mkdLink {fg = c.blue, gui = "underline"},
            mkdLineBreak {bg = "NONE", fg = "NONE", gui = "NONE"},
            mkdHeading {fg = c.white},
            mkdInlineURL {mkdLink},
            -- flutter-tools.nvim
            FlutterWidgetGuides {fg = c.bg4.li(10)},
            -- statusline
            StatusLine {bg = c.bg1, fg = c.white},
            StatusLineNC {bg = c.bg1, fg = c.gray},
            StatusLineMode {bg = c.bg4, fg = c.bg, gui = "bold"},
            StatusLineDeco {bg = c.bg2, fg = c.yellow},
            StatusLineLCol {bg = c.bg2, fg = c.white},
            StatusLineLColAlt {bg = c.bg1, fg = c.white},
            StatusLineFT {bg = c.bg2, fg = c.white},
            StatusLineFTAlt {bg = c.bg2, fg = c.white},
            StatusLineGit {bg = c.bg4, fg = c.bg},
            StatusLineGitAlt {bg = c.bg4, fg = c.bg},
            StatusLineLSP {bg = c.bg1, fg = c.gray.li(25)},
            StatusLineFileName {bg = c.bg1, fg = c.white, gui = "bold"},
            -- lsp-trouble.nvim
            LspTroubleIndent {fg = c.bg4.li(10)},
            -- bufferline diagnostic
            TabLineError {LspDiagnosticsSignError},
            TabLineWarning {LspDiagnosticsSignWarning},
            TabLineHint {LspDiagnosticsSignHint},
            TabLineInformation {LspDiagnosticsSignInformation},
            -- vim-illuminate
            illuminatedWord {Visual}
        }
    end
)

---@diagnostic enable

-- return our parsed theme for extension or use else where.
return theme

-- vi:nowrap
