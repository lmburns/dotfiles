local M = {}

local api = vim.api
local fn = vim.fn

local utils = require("common.utils")

local ultisnips = nvim.plugins.ultisnips

local lspkind = require("lspkind")
local cmp = require("cmp")
local compare = require("cmp.config.compare")
local ls = require("luasnip")

---Check if there are words before where the snippet expansion is to take place
---@return boolean
local function has_words_before()
    local line, col = unpack(api.nvim_win_get_cursor(0))
    return col ~= 0 and api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- Select item next/prev, taking into account whether the cmp window is
-- top-down or bottom-up so that the movement is always in the same direction.
local function select_item_smart(dir)
    return function(fallback)
        if cmp.visible() then
            if cmp.core.view.custom_entries_view:is_direction_top_down() then
                ({next = cmp.select_next_item, prev = cmp.select_prev_item})[dir]()
            else
                ({prev = cmp.select_next_item, next = cmp.select_prev_item})[dir]()
            end
        else
            fallback()
        end
    end
end

---Move to the next item
---@param fallback function
local function next_item(fallback)
    if cmp.visible() then
        cmp.select_next_item()
    elseif ls.jumpable(1) then
        ls.jump(1)
    elseif ultisnips and fn["UltiSnips#CanJumpForwards"]() == 1 then
        fn["UltiSnips#JumpForwards"]()
    elseif has_words_before() then
        cmp.complete()
    else
        fallback()
    end
end

---Move to the previous item
---@param fallback function
local function prev_item(fallback)
    if cmp.visible() then
        cmp.select_prev_item()
    elseif ls.jumpable(-1) then
        ls.jump(-1)
    elseif ultisnips and fn["UltiSnips#CanJumpBackwards"]() == 1 then
        fn["UltiSnips#JumpBackwards"]()
    else
        fallback()
    end
end

---Expand current item
---@param fallback function
local function enter_item(fallback)
    if ls.expandable() then
        ls.expand()
    elseif ultisnips and fn["UltiSnips#CanExpandSnippet"]() == 1 then
        fn["UltiSnips#ExpandSnippet"]()
    elseif cmp.visible() then
        if not cmp.get_selected_entry() then
            cmp.close()
        else
            cmp.confirm {behavior = cmp.ConfirmBehavior.Replace, select = false}
        end
    else
        fallback()
    end
end

local function close(fallback)
    if ls.choice_active() then
        ls.change_choice(1)
    elseif cmp.visible() then
        cmp.close()
    else
        fallback()
    end
end

local mapping =
    cmp.mapping.preset.insert(
    {
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-y>"] = cmp.mapping.confirm({behavior = cmp.SelectBehavior.Insert, select = true}),
        ["<C-g>"] = cmp.mapping.abort(),
        ["<C-e>"] = cmp.mapping(close, {"i", "s"}),
        ["<CR>"] = cmp.mapping(enter_item, {"i", "s"}),
        ["<Tab>"] = cmp.mapping(next_item, {"i", "s"}),
        ["<S-Tab>"] = cmp.mapping(prev_item, {"i", "s"}),
        -- ["<C-n>"] = cmp.mapping.select_next_item {behavior = cmp.SelectBehavior.Insert},
        -- ["<C-p>"] = cmp.mapping.select_prev_item {behavior = cmp.SelectBehavior.Insert},
        ["<C-j>"] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Select}),
        ["<C-k>"] = cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Select}),
        ["<Up>"] = cmp.mapping(
            function(_)
                if cmp.visible() then
                    cmp.select_prev_item({behavior = cmp.SelectBehavior.Select})
                else
                    vim.api.nvim_feedkeys(utils.t("<Up>"), "n", true)
                end
            end,
            {"i"}
        ),
        ["<Down>"] = cmp.mapping(
            function(_)
                if cmp.visible() then
                    cmp.select_next_item({behavior = cmp.SelectBehavior.Select})
                else
                    api.nvim_feedkeys(utils.t("<Down>"), "n", true)
                end
            end,
            {"i"}
        )
        -- ["<C-n>"] = select_item_smart("next"),
        -- ["<C-p>"] = select_item_smart("prev")
    }
)

local cmp_window = {
    border = require("style").current.border,
    winhighlight = table.concat(
        {
            "Normal:NormalFloat",
            "FloatBorder:FloatBorder",
            "CursorLine:Visual",
            "Search:None"
        },
        ","
    )
}

cmp.setup(
    {
        preselect = cmp.PreselectMode.None,
        window = {
            completion = cmp.config.window.bordered(cmp_window),
            documentation = cmp.config.window.bordered(cmp_window)
        },
        snippet = {
            expand = function(args)
                if ultisnips then
                    vim.fn["UltiSnips#Anon"](args.body)
                elseif ls then
                    require("luasnip").lsp_expand(args.body)
                end
            end
        },
        completion = {
            -- keyword_length = 0,
            -- autocomplete = false,
            completeopt = "menu,menuone,noselect",
            get_trigger_characters = function(trigger_characters)
                return vim.tbl_filter(
                    function(char)
                        return char ~= " "
                    end,
                    trigger_characters
                )
            end
        },
        mapping = mapping,
        formatting = {
            format = lspkind.cmp_format(
                {
                    mode = "symbol",
                    symbol_map = {
                        Class = " ",
                        Color = " ",
                        Constant = " ",
                        Constructor = " ",
                        Enum = " ",
                        EnumMember = " ",
                        Event = "",
                        Field = " ",
                        File = " ",
                        Folder = " ",
                        Function = " ",
                        Interface = " ",
                        Keyword = " ",
                        Method = " ",
                        Module = " ",
                        Operator = " ",
                        Property = " ",
                        Reference = " ",
                        Snippet = " ",
                        Struct = " ",
                        Text = " ",
                        Unit = "塞",
                        Value = " ",
                        Variable = " "
                    },
                    menu = {
                        buffer = "[B]",
                        treesitter = "[TS]",
                        nvim_lsp = "[LSP]",
                        nvim_lua = "[Lua]",
                        path = "[Path]",
                        luasnip = "[SN]",
                        ultisnips = "[SN]",
                        cmdline = "[Cmd]",
                        cmdline_history = "[Hist]",
                        rg = "[Rg]",
                        git = "[Git]"
                    }
                }
            )
        },
        sources = cmp.config.sources(
            {
                {name = "cmp_tabnine", priority = 30},
                {name = "nvim_lsp_signature_help", priority = 80},
                {name = "nvim_lsp", priority = 100},
                {name = "nvim_lua", priority = 80},
                {name = "treesitter"},
                {name = "luasnip"},
                {name = "buffer", keyword_length = 5},
                {name = "path"}
            },
            {
                {name = "buffer"},
                {name = "treesitter", priority = 30}
            }
        ),
        experimental = {
            native_menu = false,
            ghost_text = true
        },
        -- view = {
        --     entries = {name = "custom", selection_order = "bottom_up"}
        -- },
        sorting = {
            priority_weight = 100,
            comparators = {
                function(...)
                    return require("cmp_buffer"):compare_locality(...)
                end,
                require("clangd_extensions.cmp_scores"),
                compare.offset,
                compare.exact,
                compare.score,
                require("cmp-under-comparator").under,
                compare.recently_used,
                compare.kind,
                compare.sort_text,
                compare.length,
                compare.order,
            }
        }
    }
)

-- cmp.setup.cmdline(
--     "/",
--     {
--         mapping = cmp.mapping.preset.cmdline(),
--         sources = cmp.config.sources(
--             {
--                 -- { name = "cmdline_history" },
--                 {name = "nvim_lsp_document_symbol"},
--                 {name = "buffer"},
--                 {name = "nvim_lsp"},
--                 {name = "treesitter"}
--             },
--             {}
--         )
--     }
-- )
--
-- cmp.setup.cmdline(
--     ":",
--     {
--         mapping = {
--             ["<Tab>"] = cmp.mapping(
--                 function(fallback)
--                     if cmp.visible() then
--                         cmp.select_next_item()
--                     else
--                         fallback()
--                     end
--                 end,
--                 {"c"}
--             ),
--             ["<S-Tab>"] = cmp.mapping(
--                 function(fallback)
--                     if cmp.visible() then
--                         cmp.select_prev_item()
--                     else
--                         fallback()
--                     end
--                 end,
--                 {"c"}
--             ),
--             ["<C-y>"] = {
--                 c = cmp.mapping.confirm({select = false})
--             },
--             ["<C-q>"] = {
--                 c = cmp.mapping.abort()
--             }
--         },
--         sources = cmp.config.sources({{name = "path"}}, {{name = "cmdline"}, {{name = "cmdline_history"}}})
--     }
-- )

cmp.setup.filetype(
    {"gitcommit", "markdown"},
    {
        sources = cmp.config.sources(
            {
                {name = "copilot", priority = 90}, -- For luasnip users.
                {name = "nvim_lsp", priority = 100},
                {name = "cmp_tabnine", priority = 30},
                {name = "luasnip", priority = 80}, -- For luasnip users.
                {name = "rg", priority = 70},
                {name = "path", priority = 100}
            },
            {
                {name = "buffer", priority = 50},
                {name = "calc", priority = 50},
                {name = "treesitter", priority = 30},
                {name = "mocword", priority = 60},
                {name = "dictionary", keyword_length = 2, priority = 10}
            }
        )
    }
)

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({map_char = {tex = ""}}))

return M
