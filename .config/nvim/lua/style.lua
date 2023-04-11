local M = {}

M.border = {
    line = {"🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏"},
    rectangle = {"┌", "─", "┐", "│", "┘", "─", "└", "│"},
    rounded = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
    double = {"╔", "═", "╗", "║", "╝", "═", "╚", "║"},
}

M.icons = {
    lsp = {
        error = "", -- ✗   ••
        warn = "", -- 
        info = "", --  
        hint = "",
        -- I like differing icons in the statusbar
        sb = {
            error = " ",
            warn = " ",
            info = " ", --  
            hint = " " -- 
        },
    },
    separators = {
        vert_bottom_half_block = "▄",
        vert_top_half_block = "▀"
    },
    git = {
        add = " ",  -- + '',
        mod = " ",  -- ~
        remove = " ", -- - '',
        ignore = "",
        rename = "",
        diff = "",
        repo = "",
        logo = "",
        branch = "" -- 
    },
    documents = {
        file = "",
        files = "",
        folder = "",
        open_folder = ""
    },
    type = {
        array = "",
        number = "",
        object = "",
        string = "",
        boolean = "蘒",
        null = "[]",
        float = ""
    },
    lang = {
        lua = "",
    },
    misc = {
        -- ellipsis = utf8.char(0x2026), -- "…"
        block = "▌",
        bug = "", -- 'ﴫ'
        code = "",
        comment = "",
        dashboard = "",
        ellipsis = "…",
        fire = "",
        gear = "",
        history = "",
        flower = "✿",
        fold = "",
        indent = "Ξ",
        keyboard = "⌨",
        lightbulb = "",
        line = "ℓ", -- ''
        list = "",
        list_alt = "",
        lock = "",
        lock_alt = "",
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
        star = "",
        star_unfilled = "",
        star_small = "󰫢",
        tab = "⇥",
        table = "",
        tag = "",
        tools = "",
        watch = "",

        modified = "[+]",
        readonly = "[]",
        unnamed = "[No Name]",

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
                br = "」"
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
            }
            -- ⟨ ⟩ ⟪ ⟫ ⟬ ⟭ ⦇ ⦈ ⦉ ⦊
        }
    },
    ui = {
        up = "⇡",
        down = "⇣",

        chevron = {
            left = "",
            right = "",
            up = "",
            down = "",
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
        },

        arrow_swap = "",
        bookmark_unfilled = "",
        bookmark_filled = "",
        bookmark_double = "󰸕",
        bookmark_star = "",
        bug = "",
        calculator = "",
        calendar = "",
        check_thin = "",
        check_thick = "",
        check_box = "",
        check_circle = "",
        circle = "",
        circle_hollow = "", -- ○
        circle_bullseye = "◉",
        clock = "",
        close = "",
        close_thick = "",
        cloud_download = "",
        dashboard = "",
        fire = "",
        gear = "",
        history = "",
        list = "",
        lock = "",
        new_file = "",
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
        warning = ""
    },
    non_nerd = {
        lsp = {
            error = "×",
            warn = "!",
            info = "I",
            hint = "H"
        },
        git = {
            add = "+ ",
            mod = "~ ",
            remove = "- ",
            ignore = "I",
            branch = ""
        },
        chevron = {
            double = {
                left = "«",
                right = "»"
            },
        },
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
        sep_arrow_right = "<"
    },
}

M.plugins = {
    dap = {
        stopped = "=>",
        breakpoint = "<>",
        rejected = M.icons.misc.bug, -- "!>",
        condition = "?>",
        log_point = ".>"
    },
    notify = {
        ERROR = " ",
        WARN = " ",
        INFO = " ",
        DEBUG = ("%s "):format(M.icons.misc.bug),
        TRACE = " "
    },
    lualine = {
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
        --
    },
}

M.lsp = {
    kind_highlights = {
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
        TypeParameter = "Type"
    },
    kinds = {
        Text = "",       -- 
        Method = "",     -- 
        Function = "",   -- ƒ
        Constructor = "", -- 
        Field = "",      -- 料  
        Variable = "",   --  
        Class = "",      -- ﴯ 
        Interface = "",  -- 
        Module = "",     -- 
        Property = "",   -- ﰠ
        Unit = "",       --  塞
        Value = "",
        Enum = "",       -- 
        Keyword = "",    -- 
        Snippet = "",    --    
        Color = "",
        File = "",       -- 
        Reference = "",  --  渚
        Folder = "",     -- 
        EnumMember = "", -- 
        Constant = "",   -- 
        Struct = "פּ",     -- 
        Event = "",      -- 鬒
        Operator = "Ψ",    -- 
        TypeParameter = "" --   
    },
}

---Add alternative names for icons
M.icons.lsp.err = M.icons.lsp.error
M.icons.lsp.information = M.icons.lsp.info
M.icons.lsp.warning = M.icons.lsp.warn
M.icons.lsp.message = M.icons.lsp.hint
M.icons.lsp.msg = M.icons.lsp.hint

M.current = {
    border = M.border.rounded,
}

return M
