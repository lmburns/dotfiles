---@module 'usr.style'
---@class Styles
local M = {}

local function pad(icn)
    return ("%s "):format(icn)
end

---@class Styles.Border
M.border = {
    line = {"🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏"},
    rectangle = {"┌", "─", "┐", "│", "┘", "─", "└", "│"},
    rounded = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
    double = {"╔", "═", "╗", "║", "╝", "═", "╚", "║"},
}

---@class Styles.Icons
M.icons = {}

---@class Styles.Icons.Letters
M.icons.letter = {
    greek = {
        l = {
            alpha = "α",
            beta = "β",
            beta_thk = "",
            gamma = "γ",
            delta = "δ",
            epsilon = "ε",
            zeta = "ζ",
            eta = "η",
            theta = "θ",
            iota = "ι",
            kappa = "κ",
            lambda = "λ",
            mu = "μ",
            nu = "ν",
            xi = "ξ",
            omicron = "ο",
            pi = "π",
            pi_thk = "", -- 
            rho = "ρ",
            sigma_final = "ς",
            sigma = "σ",
            tau = "τ",
            upsilon = "υ",
            phi = "φ",
            chi = "χ",
            psi = "ψ",
            omega = "ω",

            stigma = "ϛ",
            koppa = "ϟ",
            koppa_archaic = "ϙ",
            sampi = "ϡ",
            sampi_archaic = "ͳ",
            digamma = "ϝ",
            digamma_alt = "ͷ",
            heta = "ͱ",
            san = "ϻ",
            sho = "ϸ",
        },
        symbol = {
            -- ℾ 𝜞 𝞒 𝚪 𝝘 ᴦ 𝛤
            l = {
                beta = "ϐ",
                theta = "ϑ",
                kappa = "ϰ",
                phi = "ϕ",
                pi = "ϖ",
                kai = "ϗ",
                rho = "ϱ",
                lunate_sigma = "ϲ",
                lunate_epsilon = "ϵ",
                digamma = "𝟋",
            },
            u = {
                upsilon = "ϒ",
                kai = "Ϗ",
                theta = "ϴ",
                digamma = "𝟊",
            },
            vocal6 = "𝈅",
            vocal7 = "𝈆",
            vocal9 = "𝈈",
            vocal11 = "𝈊",
            vocal20 = "𝈓",
            vocal21 = "𝈔",
            vocal22 = "𝈕",
        },


        forall = "∀", -- 𝈗
        exists = "∃",

        u = {
            alpha = "Α",
            beta = "Β",
            gamma = "Γ",
            delta = "Δ",
            epsilon = "Ε",
            zeta = "Ζ",
            eta = "Η",
            theta = "Θ",
            iota = "Ι",
            kappa = "Κ",
            lambda = "Λ",
            mu = "Μ",
            nu = "Ν",
            xi = "Ξ",
            omicron = "Ο",
            pi = "Π",
            rho = "Ρ",
            sigma = "Σ",
            tau = "Τ",
            upsilon = "Υ",
            phi = "Φ",
            chi = "Χ",
            psi = "Ψ",
            omega = "Ω",

            stigma = "Ϛ",
            koppa = "Ϟ",
            koppa_archaic = "Ϙ",
            sampi = "Ϡ",
            sampi_archaic = "Ͳ",
            digamma = "Ϝ",
            digamma_alt = "Ͷ",
            heta = "Ͱ",
            san = "Ϻ",
            sho = "Ϸ",
        },
    },
}

---@class Styles.Icons.Box
M.icons.box = {
    plus = "",
    plus_o = "",
    minus = "",
    minus_o = "",
    dot = "󱗜",
    dot_o = "", -- 󱔀
    lines = "",
    array = "",
}

---@class Styles.Icons.Round
M.icons.round = {
    full = "",   --    
    empty = "",  --  ○   
    bullseye = "", -- ◉ ◉ ◍ ◉ 󰪥 󰻂
    lines = "",
    lines_multi = "◍",
    up = "",
    up_o = "",
    down = "",
    down_o = "",
    left = "",
    left_o = "",
    right = "",
    right_o = "",
    error = "",
    error_o = "", -- 󰅚  󰅙
    error_alt = "", -- 
    info = "",
    info_o = "",
    play = "",
    play_o = "",
    pause = "",
    pause_o = "",
    stop = "", -- 󰙦
    stop_o = "",
    exclamation = "",
    exclamation_o = "",
    question = "",
    question_o = "",
    check = "", -- 
    check_o = "",
    flame = "󱠇",
    half = "",
    half_sm = "󱎕",
    half_full_sm = "󱎖",
    double = "󰬸",
    double_o = "󰚕",
    opacity = "󱡓",
    plus = "", -- 󰐗
    minus = "",
    moon_left = "",
    moon_right = "",
}

---@class Styles.Icons.Shape
M.icons.shape = {
    dot = "", -- •
    circle = M.icons.round.full,
    circle_o = M.icons.round.empty,
    circle_bullseye = M.icons.round.bullseye,
    circle_lines = M.icons.round.lines,
    circle_lines_multi = M.icons.round.lines_multi,
    pentagon = "󰜁",
    pentagon_o = "󰜀",
    square = "",
    square_o = "",
    square_r = "󱓻",
    square_r_o = "󱓼",
    square_c = "󰆢",
    triangle_r_o = "🛆 ", -- ⛛
    star = "",        -- 
    star_o = "",
    star_sm = "󰫢",
}

---@class Styles.Icons.Sep
M.icons.separators = {
    vert_bottom_half_block = "▄",
    vert_top_half_block = "▀",
    tri_left = "",
    tri_right = "",
    tri_left_up = "",
    tri_right_up = "",
    circle_left = "",
    circle_right = "",
    arrow_left = "", -- 
    arrow_right = "", -- 
    slant = "",
    slant_thick = "𝈏",
}

---@class Styles.Icons.Bracket
M.icons.bracket = {
    w = {
        lparen = "⦅",
        rparen = "⦆",
        lbrace = "〚",
        rbrace = "〛",
        lcbrace = "⦃",
        rcbrace = "⦄",
    },
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
    a = {
        tl = "「",
        br = "」",
    },
    -- ⟨ ⟩ ⟪ ⟫ ⟬ ⟭ ⦇ ⦈ ⦉ ⦊
    -- 〈 〉 《 》 【 】
    -- 『 』 〖 〗 〘 〙
}

---@class Styles.Icons.Bar
M.icons.bar = {
    single = {
        thin = "⎸",
        thick = "┃",
        thick_s = "ǀ",
        thick_m = "|",
        thin_t = "▏",
    },
    double = {
        thin = "║",
        thick = "‖",
        thick_s = "ǁ",
    },
    triple = {
        thin = "⫼",
    },
    dashed = {
        thin2 = "╎",
        thin2_s = "¦",
        thick2 = "╏",
        thin3 = "┆",
        thick3 = "┇",
        thin4 = "┊", -- ┊
        thick4 = "┋",
        thin6 = "",
        thick6 = "⸽",
    },

    -- ⫿ ▮ ▯
    -- ┫ ⸡ ⸠ ╋ ┼ ⟊
    -- 🞣 🞤 ✚ 🞦 🞥
    -- ⦚ ╠ ╬
    -- Ͱ ͱ ͳ
    -- ꜋ ꜊ ꜉
    -- ࠼
    -- 🮮
}

---@class Styles.Icons.Symbols
M.icons.symbols = {
    hash = "",
}

---@class Styles.Icons.UI
M.icons.ui = {
    arrow_swap = "",
    bug = "",
    calculator = "",
    calendar = "",
    check_box = "",
    check_circle = M.icons.round.check,
    check_thick = "",
    check_thin = "",
    clock = "",
    close = "",
    close_sm = "×",
    close_thick = "",
    cloud_download = "",
    dashboard = "",
    fire = "",
    gear = "",
    history = "",
    lightbulb = "",
    lightbulb_o = "",
    lightbulb_sm = "󱧣",
    list = M.icons.box.lines,
    list_alt = "",
    package = "",
    pencil = "",
    search = "",
    search_alt = "",
    signin = "",
    signout = "",
    table = "",
    telescope = "",
    text_outline = "",
    wrench_left = "󰖷",
    wrench_right = "",

    error = M.icons.round.error,
    error_o = M.icons.round.error_o,
    error_alt = M.icons.round.error_alt,
    warning = "", -- 
    warning_o = "",
    info = M.icons.round.info,
    info_o = M.icons.round.info_o,

    up = "⇡",
    down = "⇣",
    tip = "",
    bookmark = "",
    bookmark_o = "",
    bookmark_double = "󰸕",
    bookmark_star = "",

    files_o = "",
    file = "",
    file_o = "",
    file_alt = "", -- 
    folder = "",
    folder_o = "",
    folder_open_o = "",
}

---@class Styles.Icons.Misc
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
    package = "",
    pencil = "",
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
    indent = M.icons.letter.greek.u.xi,
    line = "ℓ",
    line_alt = "",
    tab = "⇥",
    tag = "󰓹", -- 
}

---@class Styles.Icons.Chevron
M.icons.chevron = {
    left             = "",
    right            = "",
    up               = "",
    down             = "",
    small            = {left = "◂", right = "▸", up = "▴", down = "▾"},
    med              = {left = "◀", right = "▶", up = "▲", down = "▼"},
    double           = {left = "", right = "", up = "", down = ""},
    circle           = {left = "", right = "", up = "", down = ""},
    thin             = {left = "", right = "", up = "", down = ""},
    big              = {left = "", right = "", up = "", down = ""},
    red              = {left = "", right = "", up = "🔺", down = "🔻"},
    arrow            = {left = "←", right = "→", up = "↑", down = "↓"},
    -- double           = {left = "«", right = "»"},

    right_smaller    = "‣",
    right_small_play = "輪",
    right_big_play   = "淪",
}

--  ══════════════════════════════════════════════════════════════════════

M.icons.lsp = {
    error = M.icons.ui.error,
    warning = M.icons.ui.warning,
    information = M.icons.ui.lightbulb_o,
    hint = M.icons.ui.wrench_right,

    -- statusbar
    sb = {
        error = pad(M.icons.ui.close_thick),
        warn = pad(M.icons.ui.warning),
        info = pad(M.icons.ui.lightbulb_o),
        hint = pad(M.icons.ui.wrench_right),
    },
}

M.icons.git = {
    add = pad(M.icons.box.plus),
    remove = pad(M.icons.box.minus),
    mod = pad(M.icons.box.dot),
    ignore = "",
    rename = "",
    diff = "",
    repo = "",
    logo = "",
    branch = "",
    non_nerd = {
        add = "+ ",
        mod = "~ ",
        remove = "- ",
        ignore = "I",
        branch = "",
    },
}

M.icons.type = {
    array = M.icons.box.array,
    number = M.icons.symbols.hash,
    object = "",
    string = "",
    boolean = "蘒",
    null = "",
    float = "",
}

M.icons.lang = {
    lua = "",
}

--  ══════════════════════════════════════════════════════════════════════

M.plugins = {}

M.plugins.dap = {
    stopped = "",                           --  =>
    breakpoint = M.icons.shape.circle,         --  <>
    rejected = M.icons.shape.circle_o,         --  !>  M.icons.misc.bug
    condition = M.icons.shape.circle_lines,    --  ?>
    log_point = M.icons.shape.circle_bullseye, -- ◉ .> ◍ 󰪥 ◉ 󰻂
}

M.plugins.notify = {
    ERROR = pad(M.icons.round.error),
    WARN = pad(M.icons.round.exclamation),
    INFO = pad(M.icons.round.info),
    DEBUG = pad(M.icons.misc.bug),
    TRACE = pad(M.icons.round.pause),
}

M.plugins.lualine = {
    bar = "▋",
    sep = M.icons.separators,
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
    Text = "",                               -- 
    Method = "",                             -- 
    Function = "",                           -- ƒ
    Constructor = "",                        -- 
    Field = "",                              -- 料  
    Variable = M.icons.letter.greek.l.beta_thk, --  
    Class = "",                              -- ﴯ 
    Interface = "",                          -- 
    Module = "",                             -- 
    Property = "",                           -- ﰠ
    Unit = "",                               --  塞
    Value = "",
    Enum = "",                               -- 
    Keyword = "",                            -- 
    Snippet = "",                            --    
    Color = "",
    File = M.icons.ui.file_alt,                 -- 
    Reference = "",                          --  渚
    Folder = "",                             -- 
    EnumMember = "",                         -- 
    Constant = M.icons.letter.greek.l.pi_thk,   -- 
    Struct = "פּ",                             -- 
    Event = "",                              -- 鬒
    Operator = M.icons.letter.greek.u.psi,      -- 
    TypeParameter = "",                      --   
}

--  ══════════════════════════════════════════════════════════════════════

---Add alternative names for icons
M.icons.lsp.err = M.icons.lsp.error
M.icons.lsp.warn = M.icons.lsp.warning
M.icons.lsp.info = M.icons.lsp.information
M.icons.lsp.message = M.icons.lsp.hint
M.icons.lsp.msg = M.icons.lsp.hint

M.icons.file = {
    -- modified = "[+]",
    modified = ("[%s]"):format(M.icons.shape.dot),
    readonly = ("[%s]"):format(M.icons.misc.lock),
    unnamed = "[No Name]",
    newfile = "[New]",
}

--  ══════════════════════════════════════════════════════════════════════

M.current = {
    border = M.border.rounded,
    border_t = "rounded",
}

return M
