---@module 'plugs.markdown'
local M = {}

local map = Rc.api.map
local augroup = Rc.api.augroup

local wk = require("which-key")

local g = vim.g
local api = vim.api

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Markdown                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.markdown()
    -- g.vim_markdown_folding_disabled = 1
    g.vim_markdown_conceal = 0
    g.vim_markdown_conceal_code_blocks = 0
    g.vim_markdown_fenced_languages = g.markdown_fenced_languages
    g.vim_markdown_folding_level = 10
    g.vim_markdown_folding_style_pythonic = 1
    g.vim_markdown_follow_anchor = 1
    g.vim_markdown_frontmatter = 1
    g.vim_markdown_strikethrough = 1
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                        TableMode                         │
-- ╰──────────────────────────────────────────────────────────╯
function M.table_mode()
    augroup(
        "lmb__MarkdownAdditions",
        {
            event = "FileType",
            pattern = {"markdown", "vimwiki"},
            command = function(args)
                -- Expand snippets/pum item in VimWiki
                map(
                    "i",
                    "<Right>",
                    [[coc#pum#visible() ? coc#pum#confirm() : "\<Right>"]],
                    {expr = true, silent = true, buffer = args.buf}
                )
            end,
        }
    )

    -- g.loaded_table_mode = 1 -- enable/disable plugin
    -- g.table_mode_always_active = 1 -- permanently enable the table mode

    g.table_mode_disable_mappings = 1
    g.table_mode_disable_tableize_mappings = 1 -- disables mappings for tableize

    -- g.table_mode_map_prefix = "<Leader>t"
    -- g.table_mode_realign_map = "<Leader>tr"
    -- g.table_mode_delete_row_map = "<Leader>tdd"
    -- g.table_mode_delete_column_map = "<Leader>tdc"
    -- g.table_mode_insert_column_after_map = "<Leader>tic"
    -- g.table_mode_add_formula_map = "<Leader>tfa"
    -- g.table_mode_eval_formula_map = "<Leader>tfe"
    -- g.table_mode_echo_cell_map = "<Leader>t?"
    -- g.table_mode_sort_map = "<Leader>ts"
    -- g.table_mode_tableize_map = "<Leader>tt"
    -- g.table_mode_tableize_d_map = "<Leader>T"
    -- g.table_mode_motion_up_map = "<LocalLeader>K"    -- move up a cell vertically
    -- g.table_mode_motion_down_map = "<LocalLeader>J"  -- move down a cell vertically
    -- g.table_mode_motion_left_map = "<LocalLeader>H"  -- move to the left cell
    -- g.table_mode_motion_right_map = "<LocalLeader>L" -- move to the right cell
    -- g.table_mode_cell_text_object_a_map = "ax"       -- text object for around cell object
    -- g.table_mode_cell_text_object_i_map = "ix"       -- text object for inner cell object

    g.table_mode_syntax = 0     -- should define table syntax definitions or not
    g.table_mode_auto_align = 1 -- auto align as you type when table mode is active

    g.table_mode_corner = "+"   -- "|"
    g.table_mode_corner_corner = "|"
    g.table_mode_fillchar = "-"
    g.table_mode_header_fillchar = "-" -- "="
    g.table_mode_separator = "|"
    g.table_mode_separator_map = "|"
    g.table_mode_align_char = ":"


    g.table_mode_tableize_auto_border = 1 -- add row borders to when using tableize

    wk.register({
        ["<LocalLeader>H"] = {"<Plug>(table-mode-motion-right)", "Move to previous cell"},
        ["<LocalLeader>L"] = {"<Plug>(table-mode-motion-left)", "Move to next cell"},
        ["<LocalLeader>K"] = {"<Plug>(table-mode-motion-up)", "Move to the cell above"},
        ["<LocalLeader>J"] = {"<Plug>(table-mode-motion-down)", "Move to the cell below"},
        ["<Leader>tm"] = {"<Cmd>TableModeToggle<CR>", "Toggle TableMode"},
        ["<Leader>tS"] = {"<Cmd>TableModeDisable<CR>", "Disable TableMode"},
        ["<Leader>tt"] = {"<Plug>(table-mode-tableize)", "Tableize"},
        ["<Leader>tr"] = {"<Plug>(table-mode-realign)", "Realign table columns"},
        ["<Leader>t?"] = {"<Plug>(table-mode-echo-cell)", "Echo cell representation"},
        ["<Leader>tdd"] = {"<Plug>(table-mode-delete-row)", "Delete table row"},
        ["<Leader>tdc"] = {"<Plug>(table-mode-delete-column)", "Delete table column]"},
        ["<Leader>tiC"] = {"<Plug>(table-mode-insert-column-before)", "Insert column before"},
        ["<Leader>tic"] = {"<Plug>(table-mode-insert-column-after)", "Insert column after"},
        ["<Leader>tfa"] = {"<Plug>(table-mode-add-formula)", "Add formula for cell"},
        ["<Leader>tfe"] = {"<Plug>(table-mode-eval-formula)", "Eval formula"},
        ["<Leader>ts"] = {"<Plug>(table-mode-sort)", "Sort column"},
    })

    wk.register({
        ["<Leader>tt"] = {"<Plug>(table-mode-tableize)", "Tableize"},
        ["<Leader>T"] = {"<Plug>(table-mode-tableize-delimiter)", "Tableize, ask for delimiter"},
        ["ax"] = {"<Plug>(table-mode-cell-text-object-a)", "Around cell"},
        ["ix"] = {"<Plug>(table-mode-cell-text-object-i)", "Inside cell"},
        ["<Leader>ts"] = {":TableSort<CR>", "Sort column"},
    }, {mode = "x"})

    wk.register({
        ["ax"] = {"<Plug>(table-mode-cell-text-object-a)", "Around cell"},
        ["ix"] = {"<Plug>(table-mode-cell-text-object-i)", "Inside cell"},
    }, {mode = "o"})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         VimWiki                          │
-- ╰──────────────────────────────────────────────────────────╯

function M.vimwiki_setup()
    local index_name = "_index"

    -- g.vimwiki_filetypes = {"markdown", "pandoc"}
    -- g.vimwiki_filetypes = {"markdown"}
    g.vimwiki_folding = "expr" -- '', 'expr', 'list', 'syntax', 'custom'
    g.vimwiki_conceallevel = 2
    g.vimwiki_conceal_onechar_markers = 1
    g.vimwiki_conceal_pre = 1           -- conceal preformatted text
    g.vimwiki_hl_headers = 1            -- highlight headers with VimWikiHeader1...
    g.vimwiki_hl_cb_checked = 0         -- highlight checked list items -- (1, 2) (can SLOW)
    g.vimwiki_listsyms = " .oOX"        -- text used for checkbox items -- ( ○◐●X)
    g.vimwiki_listsym_rejected = "-"    -- text used for checkbox items not to be done
    g.vimwiki_url_maxsave = 15          -- max length of URL before shortened
    g.vimwiki_markdown_header_style = 1 -- number of lines to insert after header
    -- g.vimwiki_markdown_link_ext = 1 -- append .wiki to .md files (can SLOW)
    g.vimwiki_auto_header = 1           -- auto gen level 1 header
    g.vimwiki_dir_link = index_name        -- open index.md if given a direcory
    g.vimwiki_map_prefix = "<Leader>w"
    g.vimwiki_commentstring = "%% %s"
    g.vimwiki_table_auto_fmt = 0
    g.vimwiki_table_reduce_last_col = 0                     -- enable autoformat for last table col

    g.vimwiki_links_header = "Generated Links"              -- where to generated links are located
    g.vimwiki_links_header_level = 1                        -- header level of generated links
    g.vimwiki_tags_header = "Generated Tags"                -- where to generated tags are located
    g.vimwiki_tags_header_level = 1                         -- header level of generated tags
    g.vimwiki_toc_header = "Contents"                       -- where TOC is located
    g.vimwiki_toc_header_level = 1                          -- header level of TOC
    g.vimwiki_toc_link_format = 1                           -- 0 = extended, 1 = brief (links in TOC)
    g.vimwiki_html_header_numbering = 1                     -- auto number headers in HTML
    g.vimwiki_html_header_numbering_sym = "."               -- end in '.' or ')' in HTML
    g.vimwiki_list_ignore_newline = 1                       -- convert \n to <br> for HTML multi-line
    g.vimwiki_text_ignore_newline = 1                       -- convert \n to <br> for HTML text
    g.vimwiki_valid_html_tags = "b,i,s,u,sub,sup,kbd,br,hr" -- allowed HTML tags in vimwiki syntax

    g.vimwiki_global_ext = 0                                -- enable temporary wikis

    g.vimwiki_ext2syntax = {
        [".Rmd"] = "markdown",
        [".rmd"] = "markdown",
        [".md"] = "markdown",
        [".markdown"] = "markdown",
        [".mdown"] = "markdown",
    }
    g.vimwiki_list = {
        {
            name = "My Wiki",
            path = "/home/lucas/Documents/wiki/vimwiki",
            index = index_name,
            path_html = "/home/lucas/Documents/wiki/vimwiki-html",
            syntax = "markdown",
            ext = ".md",
            bullet_types = {"-", "*", "+"},
            automatic_nested_syntaxes = 1,
            nested_syntax = {
                python = "python",
                ["c++"] = "cpp",
                cpp = "cpp",
                rust = "rust",
                zsh = "zsh",
            },
            exclude_files = {
                "**/README.md",
                "**/.gitattributes",
                "**/.gitignore",
                "**/.git/**",
                "**/_ignore/**",
            },
            auto_toc = 0,
            auto_tags = 1,           -- update tag metadata when saved
            auto_generate_tags = 1,  -- update generated tags when saved
            auto_diary_index = 1,    -- update diary index when opened
            auto_generate_links = 0, -- update generated links when saved
            generated_links_caption = 0,
            links_space_char = "_",  -- spaces replaced with '_' for URL
            maxhi = 0,               -- highlight non-existent files (SLOW)
        },
    }
    g.vimwiki_key_mappings = {
        all_maps = 1,
        global = 1,
        headers = 0,
        text_objs = 0,
        table_format = 0,
        table_mappings = 1,
        lists = 0,
        links = 0,
        html = 0,
        mouse = 0,
    }
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                          FeMaco                          │
--  ╰──────────────────────────────────────────────────────────╯
function M.femaco()
    cmd.packadd("femaco")
    local fem = F.npcall(require, "femaco")
    if not fem then
        return
    end

    fem.setup()
    -- fem.setup({
    --     -- by default opens a floating window
    --     -- @param opts: the return value from float_opts
    --     prepare_buffer = function(opts)
    --         local buf = api.nvim_create_buf(false, false)
    --         return api.nvim_open_win(buf, true, opts)
    --     end,
    --     -- should return options passed to nvim_open_win
    --     -- float_opts = function(code_block)
    --     --     return {
    --     --         relative = "cursor",
    --     --         width = clip_val(5, 120, api.nvim_win_get_width(0) - 10),
    --     --         height = clip_val(5, #code_block.lines, api.nvim_win_get_height(0) - 6),
    --     --         anchor = "NW",
    --     --         row = 0,
    --     --         col = 0,
    --     --         style = "minimal",
    --     --         border = Rc.style.border,
    --     --         zindex = 1,
    --     --     }
    --     -- end,
    --     -- return filetype to use for a given lang
    --     -- lang can be nil
    --     ft_from_lang = function(lang)
    --         return lang
    --     end,
    --     -- what to do after opening the float
    --     post_open_float = function(winnr)
    --         vim.wo.signcolumn = "no"
    --     end,
    --     -- create the path to a temporary file
    --     create_tmp_filepath = function(filetype)
    --         return os.tmpname()
    --     end,
    --     -- if a newline should always be used, useful for multiline injections
    --     -- which separators needs to be on separate lines such as markdown, neorg etc
    --     -- @param base_filetype: The filetype which FeMaco is called from, not the
    --     -- filetype of the injected language (this is the current buffer so you can
    --     -- get it from vim.bo.filetyp).
    --     ensure_newline = function(base_filetype)
    --         return false
    --     end,
    -- })
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Pandoc                          │
--  ╰──────────────────────────────────────────────────────────╯
-- function M.pandoc()
--     g["pandoc#filetypes#handled"] = {"pandoc", "markdown"}
--     g["pandoc#after#modules#enabled"] = {"vim-table-mode"}
--     g["pandoc#syntax#codeblocks#embeds#langs"] = {"c", "python", "sh", "html", "css"}
--     g["pandoc#formatting#mode"] = "h"
--     g["pandoc#modules#disabled"] = {"folding", "formatting"}
--     g["pandoc#syntax#conceal#cchar_overrides"] = {codelang = " "}
-- end

return M
