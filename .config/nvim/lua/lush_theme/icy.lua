local lush = require('lush')
local hsl = lush.hsl

---@diagnostic disable
local theme = lush(function()
  local c = {
    bg         = hsl(229, 20, 11),
    bg1        = hsl(225, 24, 7),
    bg2        = hsl(233, 16, 25),
    bg3        = hsl(225, 15, 30),
    bg4        = hsl(235, 10, 40),

    gray       = hsl(231, 9, 55),
    white      = hsl(225, 10, 80),

    red        = hsl(0, 70, 65),
    blue       = hsl(215, 37, 65),
    yellow     = hsl(40, 71, 73),
    orange     = hsl(14, 51, 63),
    green      = hsl(92, 28, 65),
    aqua       = hsl(191, 32, 65),
    purple     = hsl(255, 33, 68),

    green_alt  = hsl(70, 15, 16),
    orange_alt = hsl(14, 51, 16),
    red_alt    = hsl(0, 65, 16),
    yellow_alt = hsl(40, 71, 16),
    blue_alt   = hsl(191, 62, 14),
  }
  return {
    Comment      { bg = "NONE", fg = c.gray,  gui = "italic" },
    Normal       { bg = c.bg, fg = c.white, gui = "NONE"   },
    CursorLine   { bg = c.bg1.li(8),  fg = "NONE",  gui = "NONE"   },
    CursorColumn { CursorLine },
    ColorColumn  { CursorLine },
    Conceal      { bg = "NONE", fg = c.blue, gui = "NONE"     },
    Cursor       { fg = "NONE", bg = "NONE", gui = "reverse"  },
    lCursor      { Cursor },
    CursorIM     { Cursor },
    Directory    { bg = "NONE",       fg = c.blue, gui = "NONE" },
    DiffAdd      { bg = c.blue_alt,   fg = "NONE", gui = "NONE" },
    DiffChange   { bg = c.blue_alt,   fg = "NONE", gui = "NONE" },
    DiffDelete   { bg = c.red_alt,    fg = "NONE", gui = "NONE" },
    DiffText     { bg = c.blue_alt.li(8), fg = "NONE", gui = "NONE" },
    EndOfBuffer  { bg = "NONE",       fg = c.bg2,  gui = "NONE" },
    TermCursor   { Cursor },
    TermCursorNC { Cursor },
    ErrorMsg     { bg = c.red_alt, fg = c.red, gui = "NONE" },
    VertSplit    { bg = "NONE",    fg = c.bg2, gui = "NONE" },
    Folded       { bg = c.bg1,     fg = c.bg4, gui = "NONE" },
    FoldColumn   { Normal, fg = c.gray, gui = "NONE"        },
    SignColumn   { Normal },
    Search       { bg = c.gray, fg = c.bg },
    IncSearch    { Search },
    Substitute   { Search },
    LineNr       { bg = "NONE", fg = c.gray, gui = "NONE" },
    CursorLineNr { bg = "NONE", fg = c.blue, gui = "bold" },
    MatchParen   { CursorLine,  fg = "NONE", gui = "underline" },
    ModeMsg      { Normal },
    MsgArea      { Normal },
    MsgSeparator { Normal },
    MoreMsg      { bg = "NONE", fg = c.aqua, gui = "NONE" },
    NonText      { EndOfBuffer },
    NormalFloat  { bg = c.bg2.da(30), fg = "NONE", gui = "NONE" },
    FloatBorder  { bg = c.bg2.da(30), fg = c.gray, gui = "NONE" },
    NormalNC     { Normal },
    Pmenu        { bg = c.bg1,        fg = c.gray.da(20), gui = "NONE" },
    PmenuSel     { bg = c.bg2.da(50), fg = c.blue.li(20), gui = "NONE" },
    PmenuSbar    { bg = c.bg2.da(50), fg = "NONE",        gui = "NONE" },
    PmenuThumb   { bg = c.bg2.da(30), fg = "NONE",        gui = "NONE" },
    Question     { MoreMsg },
    QuickFixLine { CursorLine },
    SpecialKey   { bg = "NONE", fg = c.blue,   gui = "bold" },
    SpellBad     { bg = "NONE", fg = c.white,  gui = "underline", sp = c.red    },
    SpellCap     { bg = "NONE", fg = c.white,  gui = "underline", sp = c.yellow },
    SpellLocal   { bg = "NONE", fg = c.white,  gui = "underline", sp = c.green  },
    SpellRare    { bg = "NONE", fg = c.white,  gui = "underline", sp = c.blue   },
    Title        { bg = "NONE", fg = c.blue,   gui = "bold" },
    Visual       { bg = c.bg2.da(25),  fg = "NONE",   gui = "NONE" },
    VisualNOS    { Visual },
    WarningMsg   { bg = "NONE", fg = c.red,         gui = "NONE" },
    Whitespace   { bg = "NONE", fg = c.gray.da(35), gui = "NONE" },
    WildMenu     { PmenuSel },

    -- Non Defaults

    Constant       { fg = c.orange },
    String         { fg = c.green },
    Character      { Constant },
    Number         { fg = c.orange },
    Boolean        { fg = c.orange },
    Float          { fg = c.orange },

    Identifier     { fg = c.white },
    Function       { fg = c.aqua  },

    Statement      { fg = c.purple  },
    Conditional    { fg = c.purple  },
    Repeat         { fg = c.purple  },
    Label          { fg = c.purple  },
    Operator       { fg = c.aqua },
    Keyword        { fg = c.purple  },
    Exception      { fg = c.purple  },

    PreProc        { fg = c.aqua  },
    Include        { PreProc },
    Define         { PreProc },
    Macro          { PreProc },
    PreCondit      { PreProc },

    Type           { fg = c.yellow },
    StorageClass   { fg = c.orange },
    Structure      { fg = c.aqua },
    Typedef        { Type },

    Special        { fg = c.orange },
    SpecialChar    { Character },
    Tag            { fg = c.red },
    Delimiter      { fg = c.white.da(25) },
    SpecialComment { fg = c.red },
    Debug          { fg = c.red },

    Underlined     { fg = "NONE", gui = "underline" },
    Bold           { fg = "NONE", gui = "bold" },
    Italic         { fg = "NONE", gui = "italic" },

    -- ("Ignore", below, may be invisible...)
    Ignore         { fg = c.white },
    Error          { bg = c.red_alt, fg = c.red },
    Todo           { bg = "NONE", fg = c.red, gui = "bold" },

    -- These groups are for the native LSP client. Some other LSP clients may
    -- use these groups, or use their own. Consult your LSP client's
    -- documentation.

    LspReferenceText                     { Visual, fg = "NONE", gui = "underline" },
    LspReferenceRead                     { Visual, fg = "NONE", gui = "underline" },
    LspReferenceWrite                    { Visual, fg = "NONE", gui = "underline" },
    LspSignatureActiveParameter          { Visual, fg = c.purple, gui = "underline,bold" },

    LspCodeLens { fg = Comment.fg.li(20) },
    LspCodeLensSeparator { fg = Comment.fg.li(20) },

    LspDiagnosticsDefaultError           { bg = "NONE", fg = c.red,    gui = "underline" },
    LspDiagnosticsDefaultWarning         { bg = "NONE", fg = c.yellow, gui = "underline" },
    LspDiagnosticsDefaultInformation     { bg = "NONE", fg = c.blue,   gui = "underline" },
    LspDiagnosticsDefaultHint            { bg = "NONE", fg = c.green,  gui = "underline" },

    LspDiagnosticsVirtualTextError       { LspDiagnosticsDefaultError },
    LspDiagnosticsVirtualTextWarning     { LspDiagnosticsDefaultWarning },
    LspDiagnosticsVirtualTextInformation { LspDiagnosticsDefaultInformation },
    LspDiagnosticsVirtualTextHint        { LspDiagnosticsDefaultHint },

    LspDiagnosticsUnderlineError         { fg = "NONE", gui = "underline", sp = c.red },
    LspDiagnosticsUnderlineWarning       { fg = "NONE", gui = "underline", sp = c.yellow },
    LspDiagnosticsUnderlineInformation   { fg = "NONE", gui = "underline", sp = c.blue },
    LspDiagnosticsUnderlineHint          { fg = "NONE", gui = "underline", sp = c.green },

    LspDiagnosticsFloatingError          { fg = c.red,    gui = "NONE" },
    LspDiagnosticsFloatingWarning        { fg = c.yellow, gui = "NONE" },
    LspDiagnosticsFloatingInformation    { fg = c.blue,   gui = "NONE" },
    LspDiagnosticsFloatingHint           { fg = c.green,  gui = "NONE" },

    LspDiagnosticsSignError              { fg = c.red,    gui = "NONE" },
    LspDiagnosticsSignWarning            { fg = c.yellow, gui = "NONE" },
    LspDiagnosticsSignInformation        { fg = c.blue,   gui = "NONE" },
    LspDiagnosticsSignHint               { fg = c.green,  gui = "NONE" },

    -- Tree-Sitter

    TSAnnotation          { bg = "NONE", fg = c.blue }, -- For C++/Dart attributes, annotations that can be attached to the code to denote some kind of meta information.
    TSAttribute           { bg = "NONE", fg = c.aqua }, -- (unstable) TODO: docs
    TSBoolean             { Boolean   }, -- booleans.
    TSCharacter           { Character }, -- characters.
    TSComment             { Comment   }, -- comment blocks.
    luaTSConstructor      { bg = "NONE", fg = c.white.da(25) }, -- override Lua curly braces
    TSConstructor         { bg = "NONE", fg = c.orange },       -- For constructor calls and definitions: `{ }` in Lua, and Java constructors.
    TSConditional         { Conditional }, -- keywords related to conditionnals.
    TSConstant            { Constant    }, -- constants
    TSConstBuiltin        { Constant    }, -- constant that are built in the language: `nil` in Lua.
    TSConstMacro          { Macro       }, -- constants that are defined by macros: `NULL` in C.
    TSException           { Exception   }, -- exception related keywords.
    TSError               { bg = "NONE", fg = "NONE" }, -- For syntax/parser errors.
    TSField               { bg = "NONE", fg = c.blue }, -- For fields.
    TSFloat               { Float    }, -- floats.
    TSFunction            { Function }, -- function (calls and definitions).
    TSFuncBuiltin         { Function }, -- builtin functions: `table.insert` in Lua.
    TSFuncMacro           { Macro    }, -- macro defined fuctions (calls and definitions): each `macro_rules` in Rust.
    TSInclude             { Include  }, -- includes: `#include` in C, `use` or `extern crate` in Rust, or `require` in Lua.
    TSKeyword             { Keyword  }, -- keywords that don't fall in previous categories.
    TSKeywordFunction     { Keyword  }, -- keywords used to define a fuction.
    TSLabel               { Label    }, -- labels: `label:` in C and `:label:` in Lua.
    TSMethod              { Function }, -- method calls and definitions.
    TSNamespace           { bg = "NONE", fg = c.blue  },    -- For identifiers referring to modules and namespaces.
    -- TSNone                { },    -- TODO: docs
    TSNumber              { Number      }, -- all numbers
    TSOperator            { Operator    }, -- any operator: `+`, but also `->` and `*` in C.
    TSParameter           { TSField     }, -- parameters of a function.
    TSParameterReference  { TSParameter }, -- references to parameters of a function.
    TSProperty            { TSField     }, -- Same as `TSField`.
    TSPunctDelimiter      { Delimiter   }, -- delimiters ie: `.`
    TSPunctBracket        { Delimiter   }, -- brackets and parens.
    TSPunctSpecial        { Delimiter   }, -- special punctutation that does not fall in the catagories before.
    TSRepeat              { Repeat      }, -- keywords related to loops.
    TSString              { String      }, -- strings.
    TSStringRegex         { TSString    }, -- regexes.
    TSStringEscape        { Character   }, -- escape characters within a string.
    TSSymbol              { Identifier  }, -- identifiers referring to symbols or atoms.
    TSType                { Type        }, -- types.
    TSTypeBuiltin         { Type        }, -- builtin types.
    TSVariable            { bg = "NONE", fg = c.white },    -- Any variable name that does not have another highlight.
    TSVariableBuiltin     { bg = "NONE", fg = c.orange },    -- Variable names that are defined by the languages, like `this` or `self`.
    TSWarning             { bg = "NONE", fg = c.red, gui = "bold" },    -- todo highlight
    TSDanger              { bg = "NONE", fg = c.red, gui = "bold" },    -- todo highlight

    TSTag                 { Tag       }, -- Tags like html tag names.
    TSTagDelimiter        { Delimiter }, -- Tag delimiter like `<` `>` `/`
    TSText                { fg = c.white          }, -- strings considered text in a markup language.
    TSEmphasis            { gui = "italic"        }, -- text to be represented with emphasis.
    TSUnderline           { gui = "underline"     }, -- text to be represented with an underline.
    TSStrike              { gui = "strikethrough" }, -- strikethrough text.
    TSTitle               { Title  }, -- Text that is part of a title.
    TSLiteral             { String }, -- Literal text.
    TSURI                 { fg = "NONE", gui = "underline" },    -- Any URI like a link or email.

    -- gitsigns.nvim
    SignAdd               { fg = c.blue },    -- Any URI like a link or email.
    SignChange            { fg = c.orange },    -- Any URI like a link or email.
    SignDelete            { fg = c.red },    -- Any URI like a link or email.

    -- telescope.nvim
    TelescopeSelection    { bg = "NONE", fg = c.aqua },
    TelescopeMatching     { bg = "NONE", fg = c.red, gui = "bold" },
    TelescopeBorder       { bg = "NONE", fg = c.bg3 },

    -- nvim-tree.lua
    NvimTreeFolderIcon          { fg = c.aqua },
    NvimTreeIndentMarker        { fg = c.gray },
    NvimTreeNormal              { fg = c.white.da(5), bg = c.bg1 },
    NvimTreeVertSplit           { fg = c.bg, bg = c.bg},
    NvimTreeFolderName          { fg = c.blue },
    NvimTreeOpenedFolderName    { fg = c.aqua.da(10), gui = "italic" },
    NvimTreeOpenedFile          { NvimTreeOpenedFolderName },
    NvimTreeRootFolder          { fg = c.blue.da(20) },
    NvimTreeExecFile            { fg = c.blue },
    NvimTreeImageFile           { fg = c.purple },
    NvimTreeSpecialFile         { fg = c.aqua },
    NvimTreeGitStaged           { fg = c.green },
    NvimTreeGitRenamed          { fg = c.orange },

    -- some fix for html related stuff
    htmlH1                  { Title },

    -- markdown stuff
    mkdLink                   { fg = c.blue, gui = "underline" },
    mkdLineBreak              { bg = "NONE", fg = "NONE", gui = "NONE" },
    mkdHeading                { fg = c.white },
    mkdInlineURL              { mkdLink },
    mkdEscape                 { Delimiter },
    markdownUrl               { mkdLink },
    markdownCode              { fg = c.orange, bg = "NONE" },
    markdownLinkTextDelimiter { Delimiter },
    markdownLinkDelimiter     { Delimiter },
    markdownIdDelimiter       { Delimiter },
    markdownLinkText          { fg = c.aqua },
    markdownItalic            { fg = "NONE", gui = "italic" },

    -- flutter-tools.nvim
    FlutterWidgetGuides     { fg = c.bg4.li(10) },

    -- statusline
    StatusLine          { bg = c.bg1.li(12), fg = c.gray.li(15) },
    StatusLineAccent    { StatusLine, fg = c.white },
    StatusLineNC        { bg = c.bg1.li(5), fg = c.gray },

    -- lsp-trouble.nvim
    LspTroubleIndent    { fg = c.bg4.li(10) },

    -- tabline stuff
    TabLine               { bg = c.bg1, fg = c.white, gui = "NONE" },
    TabLineFill           { bg = c.bg1, fg = c.white, gui = "NONE" },
    TabLineSel            { bg = c.blue, fg = c.bg1,  gui = "NONE" },

    -- tabline diagnostic
    TabLineError          { LspDiagnosticsSignError },
    TabLineWarning        { LspDiagnosticsSignWarning },
    TabLineHint           { LspDiagnosticsSignHint },
    TabLineInformation    { LspDiagnosticsSignInformation },

    -- which-key.nvim
    WhichKeyFloat       { bg = c.bg1 },

    -- nvim-compe
    CmpDocumentation        { Pmenu, fg = "NONE" },
    CmpDocumentationBorder  { Pmenu, fg = "NONE" },

    -- diffview
    DiffviewNormal              { NvimTreeNormal },
    DiffviewVertSplit           { fg = c.bg, bg = c.bg },
    DiffviewStatusAdded         { SignAdd },
    DiffviewStatusModified      { SignChange },
    DiffviewStatusRenamed       { SignChange },
    DiffviewStatusDeleted       { SignDelete },
    DiffviewFilePanelInsertion  { SignAdd },
    DiffviewFilePanelDeletion   { SignDelete },

    -- nvim-notify
    NotifyERROR      { fg = c.red    },
    NotifyWARN       { fg = c.orange },
    NotifyINFO       { fg = c.green  },
    NotifyDEBUG      { fg = c.blue   },
    NotifyTRACE      { fg = c.white  },
    NotifyERRORTitle { fg = c.red  },
    NotifyWARNTitle  { fg = c.orange  },
    NotifyINFOTitle  { fg = c.green  },
    NotifyDEBUGTitle { fg = c.blue  },
    NotifyTRACETitle { fg = c.white  },

    -- HOP
    HopNextKey { fg = "#ff007c" },
    HopNextKey1 { fg = "#00dfff" },
    HopNextKey2 { fg = "#2b8db3" },
    HopUnmatched { fg = c.bg3 },
  }
end)

---@diagnostic enable

-- return our parsed theme for extension or use else where.
return theme
