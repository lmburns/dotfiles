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
    -- Α Β Γ Δ Ε Ζ Η Θ Ι Κ Λ Μ Ν Ξ Ο Π Ρ Σ Τ Υ Φ Χ Ψ Ω
    -- α β γ δ ε ζ η θ ι κ λ μ ν ξ ο π ρ σ τ υ φ χ ψ ω

    -- 𝚨 𝚩 𝚪 𝚫 𝚬 𝚭 𝚮 𝚯 𝚰 𝚱 𝚲 𝚳 𝚴 𝚵 𝚶 𝚷 𝚸 𝚺 𝚻 𝚼 𝚽 𝚾 𝚿 𝛀
    -- 𝛂 𝛃 𝛄 𝛅 𝛆 𝛇 𝛈 𝛉 𝛊 𝛋 𝛌 𝛍 𝛎 𝛏 𝛐 𝛑 𝛒 𝛔 𝛕 𝛖 𝛗 𝛘 𝛙 𝛚

    -- 𝛢 𝛣 𝛤 𝛥 𝛦 𝛧 𝛨 𝛩 𝛪 𝛫 𝛬 𝛭 𝛮 𝛯 𝛰 𝛱 𝛲 𝛴 𝛵 𝛶 𝛷 𝛸 𝛹 𝛺
    -- 𝛼 𝛽 𝛾 𝛿 𝜀 𝜁 𝜂 𝜃 𝜄 𝜅 𝜆 𝜇 𝜈 𝜉 𝜊 𝜋 𝜌 𝜎 𝜏 𝜐 𝜑 𝜒 𝜓 𝜔

    -- 𝜜 𝜝 𝜞 𝜟 𝜠 𝜡 𝜢 𝜣 𝜤 𝜥 𝜦 𝜧 𝜨 𝜩 𝜪 𝜫 𝜬 𝜮 𝜯 𝜰 𝜱 𝜲 𝜳 𝜴
    -- 𝜶 𝜷 𝜸 𝜹 𝜺 𝜻 𝜼 𝜽 𝜾 𝜿 𝝀 𝝁 𝝂 𝝃 𝝄 𝝅 𝝆 𝝈 𝝉 𝝊 𝝋 𝝌 𝝍 𝝎

    -- 𝝖 𝝗 𝝘 𝝙 𝝚 𝝛 𝝜 𝝝 𝝞 𝝟 𝝠 𝝡 𝝢 𝝣 𝝤 𝝥 𝝦 𝝨 𝝩 𝝪 𝝫 𝝬 𝝭 𝝮
    -- 𝝰 𝝱 𝝲 𝝳 𝝴 𝝵 𝝶 𝝷 𝝸 𝝹 𝝺 𝝻 𝝼 𝝽 𝝾 𝝿 𝞀 𝞂 𝞃 𝞄 𝞅 𝞆 𝞇 𝞈

    -- 𝞐 𝞑 𝞒 𝞓 𝞔 𝞕 𝞖 𝞗 𝞘 𝞙 𝞚 𝞛 𝞜 𝞝 𝞞 𝞟 𝞠 𝞢 𝞣 𝞤 𝞥 𝞦 𝞧 𝞨
    -- 𝞪 𝞫 𝞬 𝞭 𝞮 𝞯 𝞰 𝞱 𝞲 𝞳 𝞴 𝞵 𝞶 𝞷 𝞸 𝞹 𝞺 𝞼 𝞽 𝞾 𝞿 𝟀 𝟁 𝟂

    -- 𝔸 𝔹 ℂ 𝔻 𝔼 𝔽 𝔾 ℍ 𝕀 𝕁 𝕂 𝕃 𝕄 ℕ 𝕆 ℙ ℚ ℝ 𝕊 𝕋 𝕌 𝕍 𝕎 𝕏 𝕐 ℤ
    -- 𝕒 𝕓 𝕔 𝕕 𝕖 𝕗 𝕘 𝕙 𝕚 𝕛 𝕜 𝕝 𝕞 𝕟 𝕠 𝕡 𝕢 𝕣 𝕤 𝕥 𝕦 𝕧 𝕨 𝕩 𝕪 𝕫
    -- 𝟘 𝟙 𝟚 𝟛 𝟜 𝟝 𝟞 𝟟 𝟠 𝟡

    -- 𝐀 𝐁 𝐂 𝐃 𝐄 𝐅 𝐆 𝐇 𝐈 𝐉 𝐊 𝐋 𝐌 𝐍 𝐎 𝐏 𝐐 𝐑 𝐒 𝐓 𝐔 𝐕 𝐖 𝐗 𝐘 𝐙
    -- 𝐚 𝐛 𝐜 𝐝 𝐞 𝐟 𝐠 𝐡 𝐢 𝐣 𝐤 𝐥 𝐦 𝐧 𝐨 𝐩 𝐪 𝐫 𝐬 𝐭 𝐮 𝐯 𝐰 𝐱 𝐲 𝐳
    -- 𝟎 𝟏 𝟐 𝟑 𝟒 𝟓 𝟔 𝟕 𝟖 𝟗

    -- 𝑨 𝑩 𝑪 𝑫 𝑬 𝑭 𝑮 𝑯 𝑰 𝑱 𝑲 𝑳 𝑴 𝑵 𝑶 𝑷 𝑸 𝑹 𝑺 𝑻 𝑼 𝑽 𝑾 𝑿 𝒀 𝒁
    -- 𝒂 𝒃 𝒄 𝒅 𝒆 𝒇 𝒈 𝒉 𝒊 𝒋 𝒌 𝒍 𝒎 𝒏 𝒐 𝒑 𝒒 𝒓 𝒔 𝒕 𝒖 𝒗 𝒘 𝒙 𝒚 𝒛

    -- 𝗔 𝗕 𝗖 𝗗 𝗘 𝗙 𝗚 𝗛 𝗜 𝗝 𝗞 𝗟 𝗠 𝗡 𝗢 𝗣 𝗤 𝗥 𝗦 𝗧 𝗨 𝗩 𝗪 𝗫 𝗬 𝗭
    -- 𝗮 𝗯 𝗰 𝗱 𝗲 𝗳 𝗴 𝗵 𝗶 𝗷 𝗸 𝗹 𝗺 𝗻 𝗼 𝗽 𝗾 𝗿 𝘀 𝘁 𝘂 𝘃 𝘄 𝘅 𝘆 𝘇
    -- 𝟬 𝟭 𝟮 𝟯 𝟰 𝟱 𝟲 𝟳 𝟴 𝟵

    -- 𝘼 𝘽 𝘾 𝘿 𝙀 𝙁 𝙂 𝙃 𝙄 𝙅 𝙆 𝙇 𝙈 𝙉 𝙊 𝙋 𝙌 𝙍 𝙎 𝙏 𝙐 𝙑 𝙒 𝙓 𝙔 𝙕
    -- 𝙖 𝙗 𝙘 𝙙 𝙚 𝙛 𝙜 𝙝 𝙞 𝙟 𝙠 𝙡 𝙢 𝙣 𝙤 𝙥 𝙦 𝙧 𝙨 𝙩 𝙪 𝙫 𝙬 𝙭 𝙮 𝙯

    -- 𝙰 𝙱 𝙲 𝙳 𝙴 𝙵 𝙶 𝙷 𝙸 𝙹 𝙺 𝙻 𝙼 𝙽 𝙾 𝙿 𝚀 𝚁 𝚂 𝚃 𝚄 𝚅 𝚆 𝚇 𝚈 𝚉
    -- 𝚊 𝚋 𝚌 𝚍 𝚎 𝚏 𝚐 𝚑 𝚒 𝚓 𝚔 𝚕 𝚖 𝚗 𝚘 𝚙 𝚚 𝚛 𝚜 𝚝 𝚞 𝚟 𝚠 𝚡 𝚢 𝚣
    -- 𝟶 𝟷 𝟸 𝟹 𝟺 𝟻 𝟼 𝟽 𝟾 𝟿

    -- ℂ ℍ ℕ ℙ ℚ ℝ ℤ
    -- ⅅ ⅆ ⅇ ⅈ ⅉ ℾ ℽ ℿ ℼ ⅀ ℓ
    -- ⋿

    -- Ͱ ͱ Ⲳ ⲳ Ϟ Ⲷ ⲷ
    -- Ⳏ ⳏ Ⳗ ⳗ Ⳬ ⳬ Ⳮ ⳮ
    -- ‼ ⁑
    -- №

    -- ᛴ
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
    check = "",
    pi = "󰐀",
    line = "󰿦",
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
    error_d = "󱟂",
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
    star = "",        -- 
    star_o = "",
    star_sm = "󰫢",
    tri_up_o = "∆",
    tri_down_o = "∇",
    tri_r_o = "🛆 ", -- ⛛

    -- ● ■ ◆ ◀ ▶
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
    wide = {
        tall_o = "⫿",
        short = "▮",
        short_o = "▯",
    },
    -- ┫ ⸡ ⸠ ╋ ┼ ⟊
    -- 🞣 🞤 ✚ 🞦 🞥
    -- ⦚ ╠ ╬
    -- Ͱ ͱ ͳ
    -- ꜋ ꜊ ꜉
    -- ࠼ 🮮 ⋿ ⩤ ⩥ ∾ © ® ™
}

---@class Styles.Icons.Symbols
M.icons.symbols = {
    hash = "", -- 
    num = "№",
    dbl_exclam = "‼",
    dbl_asterisk = "⁑",
    section = "§",
    paragraph = "¶",
    cmd = "⌘",
    meta = "⌥",
    backspace = "⌫",
    delete = "⌦",
    eject = "⏏",
}

---@class Styles.Icons.UI
M.icons.ui = {
    arrow_swap = "",
    bug = "",
    calculator = "",
    calendar = "",
    check_box = M.icons.box.check,
    check_circle = M.icons.round.check,
    check_long = "✓",
    check_thick = "",
    check_thin = "",
    clipboard = "",
    clock = "",
    close = "",
    close_box = "󱍯",
    close_sm = "×",
    close_thick = "",
    cloud_download = "", -- 
    dashboard = "",
    fire = "",
    gear = "",
    gift = "",
    globe = "", -- 󰽚
    history = "",
    input = "",
    lightbulb = "", -- 
    lightbulb_o = "",
    lightbulb_sm = "󱧣",
    list = M.icons.box.lines,
    list_alt = "",
    package = "",
    pencil = "",
    search = "",
    search_alt = "",
    search_check = "",
    search_code = "",
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
    warning = "",
    warning_o = "",
    info = M.icons.round.info,
    info_o = M.icons.round.info_o,
    -- 󱟃 󰏃 󰳧 󰝧 󰀩 

    zap = "⚡",
    tip = "",
    bookmark = "",
    bookmark_o = "",
    bookmark_dbl = "󰸕",

    paperclip = "",
    beaker = "",
    pause = "",
    apps = "",
    trash = "󰧧",
    trash_alt = "",
    drawer = "",
    pin = "",
    moon = "",
    home = "",
    home_o = "",
    heart = "",
    heart_o = "♥",
    grabber = "",
    sign = "",
    copy = "",
    duplicate = "",
    cpu = "",
    database = "",

    -- † ‡ ⦁ ⦂ ⨾ ⨟ • ‣ ⋄ ⫶
    --     
    --       
    --         
    -- 

    link = "",
    link_rm = "",

    file = {
        n = "",
        o = "", --  
        multi_o = "",
        code = "",
        bin = "",
        add = "",
        rm = "",
        diff = "",
        zip = "",
        moved = "",

        link = "",
        alt = "", -- 
        rm_x = "󰮘",
    },
    folder = {
        n = "",  --  
        o = "",  -- 
        open = "", -- 
        open_o = "",
        link_o = "",
    },
}

---@class Styles.Icons.Misc
M.icons.misc = {
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
    list_alt = "",
    lock = "", -- 
    lock_alt = "",
    loclist = "",
    package = "",
    pencil = "",
    question_round = M.icons.round.question,
    question_bold = "",
    quickfix = "",
    robot = "ﮧ",
    sign_in = "",
    sign_out = "",
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
    untab = "⇤",
    tag = "󰓹", -- 
    shell = "",
    shell_o = "",
}

---@class Styles.Icons.Arrow
M.icons.arrow = {
    left = "←",
    right = "→", -- 
    up = "↑",
    down = "↓",

    tag = {left = "🠴", right = "🠶", up = "🠵", down = "🠷"},
    med = {left = "🠨", right = "🠪", up = "🠩", down = "🠫"},
    lg = {left = "🠬", right = "🠮", up = "🠭", down = "🠯"},
    xl = {left = "🠰", right = "🠲", up = "🠱", down = "🠳"},

    dash = {
        left = "⇠",
        right = "⇢",
        up = "⇡",
        down = "⇣",
        sm = {left = "⭪", right = "⭬", up = "⭫", down = "⭭"},
    },
    tri = {
        sm = {left = "🠄", right = "🠆", up = "🠅", down = "🠇"},
        lg = {left = "🠜", right = "🠞", up = "🠝", down = "🠟"},
        xl = {left = "🠈", right = "🠊", up = "🠉", down = "🠋"},
    },
    bar = {
        sm = {left = "⭰", right = "⭲", up = "⭱", down = "⭳"},
        lg = {left = "⇤", right = "⇥", up = "", down = ""},
        half = {left = "⟻", right = "⟼"},
    },
    double = {
        sm = {left = "↞", right = "↠", up = "↟", down = "↡"},
        lg = {left = "⯬", right = "⯮", up = "⯭", down = "⯯"},
    },
    -- 󰦸 󰦺
    -- ⮠ ⮡ ⮢ ⮣ ⮤ ⮥ ⮦ ⮧ ↰ ↱ ↲ ↳
    -- ab = {left = "🢘", right = "🢚", up = "🢙", down = "🢛"},
    -- ab = {left = "⇷", right = "⇸", up = "⤉", down = "⤈"},
    -- ab = {left = "⇺", right = "⇻", up = "⇞", down = "⇟"},
    -- ab = {left = "⭾", right = "⭿"},
    -- ab = {left = "⬱", right = "⇶"},
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
    diff_mod = "",

    -- ♦ 

    repo = "󰳏",
    repo_alt = "",
    repo_multi = "󰳐",
    clone = "",
    pull = "",
    push = "",
    commit = "",
    commit_alt = "", -- 
    versions = "",
    fork = "󰙁", -- 
    merge = "",
    merge_queue = "",
    pullreq = "", -- 
    pullreq_done = "",
    pullreq_draft = "",
    compare = "",
    branch_rm = "󱓋",
    branch_add = "󱓊",
    branch = "", --  
    logo = "", --  󰊢
    git = "",
    git_box = "",
    github = "", -- 󰊤
    non_nerd = {
        add = "+ ",
        mod = "~ ",
        remove = "- ",
        ignore = "I",
        branch = "",
    },
}

M.icons.type = {
    ["array"]               = M.icons.box.array,    -- 󱡠 󰅪 
    ["boolean"]             = "蘒",                -- 󰨙
    ["class"]               = "",                -- 󰆧 ﴯ  
    ["key"]                 = "󰌋",
    ["null"]                = "",                -- 󰟢
    ["number"]              = "",                --  󰎠
    ["object"]              = M.icons.symbols.hash, --  
    ["operator"]            = "Ψ",                 -- 
    ["string"]              = "",                --   
    ["func"]                = "",
    ["function"]            = "",                -- 󰊕 ƒ
    ["functions"]           = "",
    ["funcdef"]             = "δ",
    ["function_definition"] = "δ",
    ["subroutine"]          = "𝟋",
    ["var"]                 = "",
    ["variable"]            = "", -- α 󰀫  
    ["variables"]           = "",
    ["const"]               = "",
    ["constant"]            = "", --    󰐀
    ["constructor"]         = "", --  
    ["method"]              = "", -- 
    ["type"]                = "ͳ",
    ["typedef"]             = "ͳ",
    ["types"]               = "ͳ",
    ["typeParameter"]       = "Ͳ", -- 󰗴 Ͳ    
    ["enum"]                = "練", --  
    ["enumMember"]          = "", -- 
    ["enumerator"]          = "練",
    ["struct"]              = "󰆼", --   פּ
    ["union"]               = "󰕤",
    ["implementation"]      = "Δ",
    ["member"]              = "",
    ["field"]               = "",
    ["fields"]              = "",
    ["property"]            = "", -- ﰠ 
    ["interface"]           = "", -- 
    ["macro"]               = "ϟ", -- 
    ["macros"]              = "ϟ",
    ["namespace"]           = "󰦮",
    ["reference"]           = "", --  渚
    ["keyword"]             = "", -- 󰕤 
    ["package"]             = "", -- 
    ["packages"]            = "",
    ["module"]              = "ℤ", --   
    ["modules"]             = "ℤ",
    --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ["map"]                 = "ⳮ", -- ⳮ  ⁑
    ["augroup"]             = "󰕐",
    ["target"]              = "󰓾",
    ["value"]               = "",
    ["event"]               = "", -- 鬒
    --  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ["file"]                = "", -- 
    ["collapsed"]           = "▸",
    ["folder"]              = M.icons.ui.folder.n,
    ["unit"]                = "", --  塞
    ["snippet"]             = "", --    
    ["color"]               = "",
    ["default"]             = "θ",
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
    File = M.icons.ui.file.alt,                 -- 
    Reference = M.icons.ui.file.link,           --  渚
    Folder = M.icons.ui.folder.n,               -- 
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
