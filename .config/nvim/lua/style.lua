local M = {}

-- local utf8 = require("utf8")

M.border = {
    line = {"🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏"},
    rectangle = {"┌", "─", "┐", "│", "┘", "─", "└", "│"},
    rounded = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
    double = {"╔", "═", "╗", "║", "╝", "═", "╚", "║"}
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
        }
    },
    git = {
        add = " ", -- + '',
        mod = " ", -- ~
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
      boolean = "蘒"
    },
    misc = {
        -- ellipsis = utf8.char(0x2026), -- "…"
        ellipsis = "…",
        up = "⇡",
        down = "⇣",
        line = "ℓ", -- ''
        indent = "Ξ",
        tab = "⇥",
        bug = "", -- 'ﴫ'
        question = "",
        lock = "",
        circle = "",
        project = "",
        dashboard = "",
        history = "",
        comment = "",
        robot = "ﮧ",
        lightbulb = "",
        search = "",
        code = "",
        telescope = "",
        gear = "",
        package = "",
        list = "",
        sign_in = "",
        check = "",
        fire = "",
        note = "",
        bookmark = "",
        pencil = "",
        tools = "",
        chevron_right = "",
        double_chevron_right = "»",
        table = "",
        calendar = "",
        block = "▌",
        Tag = "",
        Watch = "",
        modified = "[+]",
        readonly = "[]",
        unnamed = "[No Name]",
        quickfix = "",
        loclist = "",
        spell = ""
    },
    ui = {
        ArrowClosed = "",
        ArrowOpen = "",
        Lock = "",
        Circle = "",
        BigCircle = "",
        BigUnfilledCircle = "",
        Close = "",
        NewFile = "",
        Search = "",
        Lightbulb = "",
        Project = "",
        Dashboard = "",
        History = "",
        Comment = "",
        Bug = "",
        Code = "",
        Telescope = "",
        Gear = "",
        Package = "",
        List = "",
        SignIn = "",
        SignOut = "",
        Check = "",
        Fire = "",
        Note = "",
        BookMark = "",
        Pencil = "",
        -- ChevronRight = "",
        ChevronRight = ">",
        Table = "",
        Calendar = "",
        CloudDownload = ""
    }
}

M.plugins = {
    dap = {
        stopped = "=>",
        breakpoint = "<>",
        rejected = M.icons.misc.bug, -- "!>",
        condition = "?>",
        log_point = ".>"
    }
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
        Text = "", -- 
        Method = "", -- 
        Function = "", -- ƒ
        Constructor = "", -- 
        Field = "", -- 料  
        Variable = "", --  
        Class = "", -- ﴯ 
        Interface = "", -- 
        Module = "", -- 
        Property = "", -- ﰠ
        Unit = "", --  塞
        Value = "",
        Enum = "", -- 
        Keyword = "", -- 
        Snippet = "", --    
        Color = "",
        File = "", -- 
        Reference = "", --  渚
        Folder = "", -- 
        EnumMember = "", -- 
        Constant = "", -- 
        Struct = "פּ", -- 
        Event = "", -- 鬒
        Operator = "Ψ", -- 
        TypeParameter = "" --   
    }
}

M.current = {
    border = M.border.rounded
}

return M
