---@module 'plugs.wilder'
local M = {}

local shared = require("usr.shared")
local F = shared.F
local wilder = F.npcall(require, "wilder")
if not wilder then
    return
end

local style = require("usr.style")
local icons = style.icons
local mpi = require("usr.api")
local autocmd = mpi.autocmd
local map = mpi.map

local fn = vim.fn

function M.wilder_disable(e)
    local cmd = fn["wilder#cmdline#parse"](e).cmd
    return (cmd == "Man" or cmd:match("Git fetch origin.*")) and true or false
end

function M.setup()
    wilder.setup({
        modes = {":", "/", "?"},
        next_key = "<Tab>",
        previous_key = "<S-Tab>",
        -- accept_key = "<A-,>",
        -- reject_key = "<A-.>",
        -- enable_cmdline_enter = 1
    })

    wilder.set_option("pipeline", {
        wilder.debounce(10),
        wilder.branch(
            {
                wilder.check(function(_ctx, _x)
                    return fn.getcmdtype() == ":"
                end),
                function(_ctx, x)
                    return M.wilder_disable(x)
                end,
            },
            wilder.python_file_finder_pipeline({
                file_command = {"fd", "-tf", "-H"},
                dir_command = {"fd", "-td", "-H"},
                filters = {"fuzzy_filter", "difflib_sorter"},
                -- filters = {
                --     {name = "clap_filter", opts = {use_rust = true}},
                --     {name = "difflib_sorter"},
                -- },
            }),
            wilder.substitute_pipeline({
                pipeline = wilder.python_search_pipeline({
                    skip_cmdtype_check = 1,
                    pattern = wilder.python_fuzzy_pattern({
                        start_at_boundary = 0,
                    }),
                }),
            }),
            {
                wilder.check(function(_ctx, x)
                    return x == ""
                end),
                wilder.history(50, ":"),
            },
            wilder.cmdline_pipeline({
                set_pcre2_pattern = 1,
                sort_buffers_lastused = 1,
                fuzzy = 2,
                -- fuzzy_filter = wilder.lua_fzy_filter(),
                -- language = "python",
            }),
            {
                wilder.check(function(_ctx, x)
                    return x == ""
                end),
                wilder.history(50, "/"),
            },
            wilder.python_search_pipeline({
                -- pattern = "fuzzy",
                pattern = wilder.python_fuzzy_pattern(),
                sorter = wilder.python_difflib_sorter(),
                engine = "re2",
                skip_cmdtype_check = 1,
            })
        -- wilder.vim_search_pipeline()
        ),
    })

    -- local highlighters = {
    --     wilder.pcre2_highlighter(),
    --     wilder.lua_fzy_highlighter()
    -- }

    local popupmenu_renderer = wilder.popupmenu_renderer(
        wilder.popupmenu_border_theme({
            -- highlighter = highlighters,
            -- highlighter = wilder.lua_fzy_highlighter(),
            highlighter = wilder.lua_pcre2_highlighter(),
            border = "rounded",
            max_height = 15,
            pumblend = 10,
            -- empty_message = wilder.popupmenu_empty_message_with_spinner(),
            highlights = {
                border = "FloatBorder",
                default = "Normal",
                accent = wilder.make_hl("PopupmenuAccent", "Normal",
                    {{a = 1}, {a = 1}, {foreground = "#EF1D55"}}),
            },
            left = {
                " ",
                wilder.popupmenu_devicons(),
                -- wilder.popupmenu_buffer_flags({
                --     flags = " a + ",
                --     icons = {["+"] = "", a = "", h = ""},
                -- }),
            },
            right = {
                " ",
                wilder.popupmenu_scrollbar({thumb_hl = "Type"}),
            },
        })
    )

    local wildmenu_renderer = wilder.wildmenu_renderer({
        -- highlighter = wilder.lua_fzy_highlighter(),
        highlighter = wilder.lua_pcre2_highlighter(),
        separator = (" %s "):format(icons.bar.single.thick),
        left = {" ", wilder.wildmenu_spinner(), " "},
        right = {" ", wilder.wildmenu_index()},
        highlights = {
            accent = wilder.make_hl("WildmenuAccent", "StatusLine",
                {{a = 1}, {a = 1}, {foreground = "#EF1D55"}}),
        },
    })

    -- ["/"] = wilder.popupmenu_renderer(
    --     wilder.popupmenu_palette_theme(
    --         {
    --             border = "single",
    --             max_height = "75%",
    --             min_height = 0,
    --             prompt_position = "top",
    --             reverse = 0
    --         }
    --     )
    -- ),

    wilder.set_option("renderer",
        wilder.renderer_mux({
            [":"] = popupmenu_renderer,
            ["/"] = wildmenu_renderer,
            substitute = wildmenu_renderer,
        })
    )
end

local function init()
    M.setup()

    nvim.autocmd.lmb__TelescopeFixes = {
        {
            event = "FileType",
            pattern = "Telescope*",
            command = function()
                autocmd({
                    event = "CmdlineEnter",
                    pattern = ":",
                    once = true,
                    command = function()
                        require("wilder").disable()
                    end,
                })

                -- map("i", "<Leader>", " ", {nowait = true})
                mpi.reset_keymap("i", "<C-r>", {buffer = true})
            end,
            desc = "Disable Wilder in Telescope",
        },
        {
            event = "BufLeave",
            pattern = "*",
            command = function(a)
                if vim.bo[a.buf].ft:find("Telescope") then
                    require("wilder").enable()
                end
            end,
            desc = "Disable Wilder in Telescope",
        },
    }

    -- See: autocmds.lua for Telescope disabling
    nvim.autocmd.lmb__WilderEnable = {
        event = "CmdlineEnter",
        pattern = "*",
        once = false, -- Needed for coming back out of Telescope
        command = function()
            if not vim.b.visual_multi then
                require("wilder").enable()
            end
        end,
        desc = "Enable wilder manually",
    }

    -- Allow both Tab/S-Tab and Ctrl{j,k} to rotate through completions
    map("c", "<C-j>", [[wilder#in_context() ? wilder#next() : "\<Tab>"]],
        {noremap = false, expr = true})
    map("c", "<C-k>", [[wilder#in_context() ? wilder#previous() : "\<S-Tab>"]],
        {noremap = false, expr = true})
end

init()

return M
