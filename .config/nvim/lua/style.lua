local M = {}

M.border = {
    line = {"🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏"},
    rectangle = {"┌", "─", "┐", "│", "┘", "─", "└", "│"},
    rounded = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
    double = {"╔", "═", "╗", "║", "╝", "═", "╚", "║"},
}

M.icons = {}

M.icons.lsp = {
    error = "", -- ✗    ••
    error_full = "",
    error_alt = "",
    warn = "", -- 
    warn_full = "",
    info = "", --   󱧣 
    info_full = "",
    hint = "",
    -- statusbar
    sb = {
        error = " ",
        warn = " ",
        info = " ", --  
        hint = " ", -- 
    },
}
M.icons.separators = {
    vert_bottom_half_block = "▄",
    vert_top_half_block = "▀",
}
M.icons.git = {
    add = " ",  -- + '',
    mod = " ",  -- ~
    remove = " ", -- - '',
    ignore = "",
    rename = "",
    diff = "",
    repo = "",
    logo = "",
    branch = "", -- 
}
M.icons.type = {
    array = "",
    number = "",
    object = "",
    string = "",
    boolean = "蘒",
    null = "[]",
    float = "",
}
M.icons.lang = {
    lua = "",
}
M.icons.misc = {
    -- ellipsis = utf8.char(0x2026), -- "…"
    block = "▌",
    bug = "", -- 'ﴫ'
    code = "", -- 
    comment = "",
    dashboard = "",
    fire = "",
    gear = "",
    history = "",
    flower = "✿",
    keyboard = "⌨",
    lightbulb = "",
    list_alt = "",
    lock = "",
    lock_alt = "",
    loclist = "",
    note = "",
    package = "",
    pencil = "",
    project = "",
    question_round = "",
    question_bold = "",
    quickfix = "",
    robot = "ﮧ",
    sign_in = "",
    spell = "",
    table = "",
    tools = "",
    watch = "",

    ellipsis = "…",
    fold = "",
    indent = "Ξ",
    line = "ℓ", -- ''
    list = "",
    star = "", -- 
    star_o = "",
    star_small = "󰫢",
    tab = "⇥",
    tag = "󰓹", -- 
    pentagon = "󰜁",
    pentagon_o = "󰜀",
    square = "",
    square_o = "",
    square_r = "󱓻",
    square_r_o = "󱓼",
    squaure_c = "󰆢",

    bracket = {
        w = {
            lparen = "⦅",
            rparen = "⦆",
            lbrace = "〚",
            rbrace = "〛",
            lcbrace = "⦃",
            rcbrace = "⦄",
        },
        a = {
            tl = "「",
            br = "」",
            -- 〈 〉 《 》 【 】
        },
        -- wa = 『 』 〖 〗 〘 〙
        m = {
            lparen = "⟮",
            rparen = "⟯",
            lbrace = "⟦",
            rbrace = "⟧",
            tl = "⌈",
            br = "⌊",
            tr = "⌉",
            bl = "⌋",
        },
        -- ⟨ ⟩ ⟪ ⟫ ⟬ ⟭ ⦇ ⦈ ⦉ ⦊
    },
}
M.icons.ui = {
    up = "⇡",
    down = "⇣",
    arrow_swap = "",
    bookmark = "",
    bookmark_o = "",
    bookmark_double = "󰸕",
    bookmark_star = "",
    bug = "",
    calculator = "",
    calendar = "",
    check_thin = "",
    check_thick = "",
    check_box = "",
    check_circle = "",
    circle = "", --  
    circle_o = "", -- ○ 
    circle_bullseye = "◉", -- ⵙ Ꙩ ꙩ 󰪥
    circle_slash = "", -- 
    circle_lines = "",
    clock = "",
    close = "",
    close_thick = "",
    cloud_download = "",
    dashboard = "",
    dot = "", -- •
    fire = "",
    gear = "",
    history = "",
    list = "",
    note = "",
    package = "",
    pencil = "",
    plus = "",
    project = "",
    search = "",
    search_alt = "",
    signin = "",
    signout = "",
    table = "",
    telescope = "",
    text_outline = "",
    tip = "",
    warning = M.icons.lsp.warn,

    file = "",
    file_o = "",
    files = "",
    folder = "",
    open_folder = "",
}
-- 
M.icons.ui.chevron = {
    left = "",
    right = "",
    up = "",
    down = "",
    right_small = "‣",
    right_small_play = "輪",
    right_big_play = "淪",
    double = {
        left = "",
        right = "",
        up = "",
        down = "",
    },
    thin = {
        left = "",
        right = "",
        up = "",
        down = "",
    },
}

--  ══════════════════════════════════════════════════════════════════════

M.icons.non_nerd = {
    wait = "☕",  -- W
    build = "⛭", -- b
    success = "✓", -- ✓ -- ✔ -- 
    fail = "✗",
    bug = "B",
    todo = "⦿",
    hack = "☠",
    perf = "✈",
    note = "🗈",
    test = "⏲",
    virtual_text = "❯",
    readonly = "🔒",
    bar = "|",
    sep_triangle_left = ">",
    sep_triangle_right = "<", -- ⟪
    sep_circle_right = "(",
    sep_circle_left = ")",
    sep_arrow_left = ">",
    sep_arrow_right = "<",
}
M.icons.non_nerd.lsp = {
    error = "×",
    warn = "!",
    info = "I",
    hint = "H",
}
M.icons.non_nerd.git = {
    add = "+ ",
    mod = "~ ",
    remove = "- ",
    ignore = "I",
    branch = "",
}
M.icons.non_nerd.chevron = {
    double = {
        left = "«",
        right = "»",
    },
}

--  ══════════════════════════════════════════════════════════════════════

M.plugins = {}

M.plugins.dap = {
    stopped = "", --  =>
    breakpoint = "", --  <>
    rejected = "", --  !>  M.icons.misc.bug
    condition = "", --  ?>
    log_point = "◉", -- ◉ .> ◍ 󰪥 󰪥 󰻂
}
M.plugins.notify = {
    ERROR = " ",
    WARN = " ",
    INFO = " ",
    DEBUG = ("%s "):format(M.icons.misc.bug),
    TRACE = " ",
}
M.plugins.lualine = {
    bar = "▋",
    sep = {
        tri_left = "",
        tri_right = "",
        tri_left_up = "",
        circle_left = "",
        circle_right = "",
        arrow_left = "",
        arrow_right = "",
        slant = "",
    },
}

--  ══════════════════════════════════════════════════════════════════════

M.lsp = {}

M.lsp.kind_highlights = {
    Text = "String",
    Method = "Method",
    Function = "Function",
    Constructor = "TSConstructor",
    Field = "Field",
    Variable = "Variable",
    Class = "Class",
    Interface = "Constant",
    Module = "Include",
    Property = "Property",
    Unit = "Constant",
    Value = "Variable",
    Enum = "Type",
    Keyword = "Keyword",
    File = "Directory",
    Reference = "PreProc",
    Constant = "Constant",
    Struct = "Type",
    Snippet = "Label",
    Event = "Variable",
    Operator = "Operator",
    TypeParameter = "Type",
}

M.lsp.kinds = {
    Text = "",        -- 
    Method = "",      -- 
    Function = "",    -- ƒ
    Constructor = "", -- 
    Field = "",       -- 料  
    Variable = "",    --  
    Class = "",       -- ﴯ 
    Interface = "",   -- 
    Module = "",      -- 
    Property = "",    -- ﰠ
    Unit = "",        --  塞
    Value = "",
    Enum = "",        -- 
    Keyword = "",     -- 
    Snippet = "",     --    
    Color = "",
    File = "",        -- 
    Reference = "",   --  渚
    Folder = "",      -- 
    EnumMember = "",  -- 
    Constant = "",    -- 
    Struct = "פּ",      -- 
    Event = "",       -- 鬒
    Operator = "Ψ",     -- 
    TypeParameter = "", --   
}

--  ══════════════════════════════════════════════════════════════════════

---Add alternative names for icons
M.icons.lsp.err = M.icons.lsp.error
M.icons.lsp.information = M.icons.lsp.info
M.icons.lsp.warning = M.icons.lsp.warn
M.icons.lsp.message = M.icons.lsp.hint
M.icons.lsp.msg = M.icons.lsp.hint

M.icons.file = {
    -- modified = "[+]",
    modified = ("[%s]"):format(M.icons.ui.dot),
    readonly = ("[%s]"):format(M.icons.misc.lock),
    unnamed = "[No Name]",
    newfile = "[New]",
}

--  ══════════════════════════════════════════════════════════════════════

M.current = {
    border = M.border.rounded,
}

return M
