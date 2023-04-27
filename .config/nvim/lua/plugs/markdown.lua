local M = {}

local mpi = require("common.api")
local map = mpi.map
local augroup = mpi.augroup

local wk = require("which-key")

local g = vim.g

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

    g.markdown_fenced_languages = {
        "bash=sh",
        "c",
        "console=sh",
        "go",
        "help",
        "html",
        "javascript",
        "js=javascript",
        "json",
        "lua",
        "py=python",
        "python",
        "rs=rust",
        "rust",
        "sh",
        "shell=sh",
        "toml",
        "ts=typescript",
        "typescript",
        "vim",
        "yaml"
    }
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

    wk.register(
        {
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
            ["<Leader>ts"] = {"<Plug>(table-mode-sort)", "Sort column"}
        }
    )

    wk.register(
        {
            ["<Leader>tt"] = {"<Plug>(table-mode-tableize)", "Tableize"},
            ["<Leader>T"] = {"<Plug>(table-mode-tableize-delimiter)", "Tableize, ask for delimiter"},
            ["ax"] = {"<Plug>(table-mode-cell-text-object-a)", "Around cell"},
            ["ix"] = {"<Plug>(table-mode-cell-text-object-i)", "Inside cell"},
            ["<Leader>ts"] = {":TableSort<CR>", "Sort column"}
        },
        {mode = "x"}
    )

    wk.register(
        {
            ["ax"] = {"<Plug>(table-mode-cell-text-object-a)", "Around cell"},
            ["ix"] = {"<Plug>(table-mode-cell-text-object-i)", "Inside cell"},
        },
        {mode = "o"}
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         VimWiki                          │
-- ╰──────────────────────────────────────────────────────────╯
function M.vimwiki()
    augroup(
        "VimwikiMarkdownFix",
        {
            event = "FileType",
            pattern = {"vimwiki"},
            command = function(args)
                local bufnr = args.buf
                map("i", "<S-CR>", "<Plug>VimwikiFollowLink", {buffer = bufnr})

                mpi.del_keymap("n", "<Leader>whh", {buffer = bufnr})

                wk.register(
                    {
                        ["<CR>"] = {"<Plug>VimwikiFollowLink", "Follow link"},
                        ["<S-CR>"] = {"<Plug>VimwikiSplitLink", "Split link"},
                        ["<BS>"] = {"<Plug>VimwikiGoBackLink", "Go to previously visited link"},
                        ["<Leader>wH"] = {"<Plug>Vimwiki2HTML", "Convert page to HTML"},
                        ["<Leader>w<Leader>i"] = {"<Plug>VimwikiDiaryGenerateLinks", "Update diary"},
                        ["<Leader>ww"] = {"<Plug>VimwikiIndex", "Goto current index"},
                        ["]u"] = {"<Plug>VimwikiNextLink", "Goto next link"},
                        ["[u"] = {"<Plug>VimwikiPrevLink", "Goto prev link"},
                        ["]h"] = {"<Plug>VimwikiGoToParentHeader", "Goto header parent"},
                        ["[h"] = {"<Plug>VimwikiGoToParentHeader", "Goto header parent"},
                        ["="] = {"<Plug>VimwikiAddHeaderLevel", "Add header level"},
                        ["-"] = {"<Plug>VimwikiRemoveHeaderLevel", "Remove header level"},
                        ["]]"] = {"<Plug>VimwikiGoToNextHeader", "Goto next header"},
                        ["[["] = {"<Plug>VimwikiGoToPrevHeader", "Goto prev header"},
                        ["}"] = {
                            "<Plug>VimwikiGoToNextSiblingHeader",
                            "Goto prev header with same level"
                        },
                        ["{"] = {
                            "<Plug>VimwikiGoToPrevSiblingHeader",
                            "Goto prev header with same level"
                        },
                        ["gli"] = {"<Plug>VimwikiToggleListItem", "Toggle checkbox of list"},
                        ["glx"] = {
                            "<Plug>VimwikiToggleRejectedListItem",
                            "Toggle checkbox status list"
                        },
                        ["gl<Space>"] = {"<Plug>VimwikiRemoveSingleCB", "Remove checkbox from item"},
                        ["gL<Space>"] = {
                            "<Plug>VimwikiRemoveCBInList",
                            "Remove checkbox from item + sibling"
                        },
                        ["gll"] = {"<Plug>VimwikiIncreaseLvlSingleItem", "Increase item level"},
                        ["gLl"] = {
                            "<Plug>VimwikiIncreaseLvlWholeItem",
                            "Increase item + child level"
                        },
                        ["glh"] = {"<Plug>VimwikiDecreaseLvlSingleItem", "Decrease item level"},
                        ["gLh"] = {
                            "<Plug>VimwikiDecreaseLvlWholeItem",
                            "Decrease item + child level"
                        },
                        ["gnt"] = {"<Plug>VimwikiNextTask", "Goto next unfinished task"},
                        ["glr"] = {"<Plug>VimwikiRenumberList", "Renumber list"},
                        ["gLr"] = {"<Plug>VimwikiRenumberAllLists", "Renumber all lists"},
                        ["gl,"] = {":VimwikiChangeSymbolTo *<CR>", "Create '*' item"},
                        ["gL,"] = {":VimwikiChangeSymbolInListTo *<CR>", "Change list to '*'"},
                        ["gl."] = {":VimwikiChangeSymbolTo -<CR>", "Create '-' item"},
                        ["gL."] = {":VimwikiChangeSymbolInListTo -<CR>", "Change list to '-'"},
                        ["gl1"] = {":VimwikiChangeSymbolTo 1.<CR>", "Create '1.' item"},
                        ["gL1"] = {":VimwikiChangeSymbolInListTo -<CR>", "Change list to '1.'"},
                        ["gla"] = {":VimwikiChangeSymbolTo a)<CR>", "Create 'a)' item"},
                        ["gLa"] = {":VimwikiChangeSymbolInListTo a)<CR>", "Change list to 'a)'"},
                        ["glA"] = {":VimwikiChangeSymbolTo A)<CR>", "Create 'A)' item"},
                        ["gLA"] = {":VimwikiChangeSymbolInListTo A)<CR>", "Change list to 'A)'"},
                        ["gqq"] = {"<Plug>VimwikiTableAlignQ", "Align table (gq)"},
                        ["gww"] = {"<Plug>VimwikiTableAlignW", "Align table (gw)"},
                        ["<Leader>t["] = {"<Plug>VimwikiTableMoveColumnLeft", "Move column left"},
                        ["<Leader>t]"] = {"<Plug>VimwikiTableMoveColumnRight", "Move column right"},
                        -- ["o"] = {"<Plug>VimwikiListo"},
                        -- ["O"] = {"<Plug>VimwikiListO"},
                        ["<Tab>"] = {">>", "Indent line"},
                        ["<S-Tab>"] = {"<<", "De-indent line"},
                    },
                    {mode = "n", buffer = bufnr}
                )

                wk.register(
                    {
                        -- ["<S-CR>"] = "Don't continue list format",
                        ["<S-CR>"] = {"<C-]><Esc>:VimwikiReturn 1 5<CR>", "Create list item"},
                        ["<C-t>"] = {"<Plug>VimwikiIncreaseLvlSingleItem", "Increase list level"},
                        ["<C-d>"] = {"<Plug>VimwikiDecreaseLvlSingleItem", "Decrease list level"},
                        ["<C-s><C-j>"] = {"<Plug>VimwikiListNextSymbol", "Change to next list type"},
                        ["<C-s><C-k>"] = {"<Plug>VimwikiListPrevSymbol", "Change to next list type"},
                        ["<C-s><C-m>"] = {"<Plug>VimwikiListToggle", "Toggle list item"},
                    },
                    {mode = "i", buffer = bufnr}
                )

                wk.register(
                    {
                        ["aj"] = {"<Plug>VimwikiTextObjHeader", "Around header"},
                        ["ij"] = {"<Plug>VimwikiTextObjHeaderContent", "Inside header"},
                        ["ak"] = {"<Plug>VimwikiTextObjHeaderSub", "Around header+child"},
                        ["ik"] = {"<Plug>VimwikiTextObjHeaderSubContent", "Inside header+child"},
                        ["ax"] = {"<Plug>VimwikiTextObjTableCell", "Around table cell"},
                        ["ix"] = {"<Plug>VimwikiTextObjTableCellInner", "Inner table cell"},
                        ["ac"] = {"<Plug>VimwikiTextObjColumn", "Around table column"},
                        ["ic"] = {"<Plug>VimwikiTextObjColumnInner", "Inner table column"},
                        ["al"] = {"<Plug>VimwikiTextObjListChildren", "List item + children"},
                        ["il"] = {"<Plug>VimwikiTextObjListSingle", "List item"},
                    },
                    {mode = "o", buffer = bufnr}
                )

                wk.register(
                    {
                        ["aj"] = {"<Plug>VimwikiTextObjHeaderV", "Around header"},
                        ["ij"] = {"<Plug>VimwikiTextObjHeaderContentV", "Inside header"},
                        ["ak"] = {"<Plug>VimwikiTextObjHeaderSubV", "Around header+child"},
                        ["ik"] = {"<Plug>VimwikiTextObjHeaderSubContentV", "Inside header+child"},
                        ["ax"] = {"<Plug>VimwikiTextObjTableCellV", "Around table cell"},
                        ["ix"] = {"<Plug>VimwikiTextObjTableCellInnerV", "Inner table cell"},
                        ["ac"] = {"<Plug>VimwikiTextObjColumnV", "Around table column"},
                        ["ic"] = {"<Plug>VimwikiTextObjColumnInnerV", "Inner table column"},
                        ["al"] = {"<Plug>VimwikiTextObjListChildrenV", "List item + children"},
                        ["il"] = {"<Plug>VimwikiTextObjListSingleV", "List item"},
                        ["<Tab>"] = {">><Esc>gv", "Indent line"},
                        ["<S-Tab>"] = {"<<<Esc>gv", "De-indent line"},
                    },
                    {mode = "x", buffer = bufnr}
                )
            end,
        }
    )
end

function M.vimwiki_setup()
    -- g.vimwiki_filetypes = {"markdown", "pandoc"}
    -- g.vimwiki_filetypes = {"markdown"}
    g.vimwiki_folding = "expr" -- '', 'expr', 'list', 'syntax', 'custom'
    g.vimwiki_conceallevel = 0
    g.vimwiki_conceal_onechar_markers = 1
    g.vimwiki_conceal_pre = 0           -- conceal preformatted text
    g.vimwiki_hl_headers = 1            -- highlight headers with VimWikiHeader1...
    g.vimwiki_hl_cb_checked = 0         -- highlight checked list items -- (1, 2) (can SLOW)
    g.vimwiki_listsyms = " .oOX"        -- text used for checkbox items -- ( ○◐●X)
    g.vimwiki_listsym_rejected = "-"    -- text used for checkbox items not to be done
    g.vimwiki_url_maxsave = 15          -- max length of URL before shortened
    g.vimwiki_markdown_header_style = 1 -- number of lines to insert after header
    -- g.vimwiki_markdown_link_ext = 1 -- append .wiki to .md files (can SLOW)
    g.vimwiki_auto_header = 1           -- auto gen level 1 header
    g.vimwiki_dir_link = "index"        -- open index.md if given a direcory
    g.vimwiki_map_prefix = "<Leader>w"
    -- g.vimwiki_commentstring = "<!--%s-->"
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
        [".mdown"] = "markdown"
    }
    g.vimwiki_list = {
        {
            name = "My Wiki",
            path = "~/vimwiki",
            path_html = "~/Documents/vimwiki-html",
            syntax = "markdown",
            ext = ".md",
            bullet_types = {"-", "*", "+"},
            automatic_nested_syntaxes = 1,
            nested_syntax = {
                python = "python",
                ["c++"] = "cpp",
                cpp = "cpp",
                rust = "rust"
            },
            exclude_files = {
                "**/README.md",
                "**/.git/**"
            },
            auto_toc = 0,
            auto_tags = 0,           -- update tag metadata when saved
            auto_generate_tags = 0,  -- update generated tags when saved
            auto_diary_index = 1,    -- update diary index when opened
            auto_generate_links = 0, -- update generated links when saved
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
--  │                          Pandoc                          │
--  ╰──────────────────────────────────────────────────────────╯
function M.pandoc()
    g["pandoc#filetypes#handled"] = {"pandoc", "markdown"}
    g["pandoc#after#modules#enabled"] = {"vim-table-mode"}
    g["pandoc#syntax#codeblocks#embeds#langs"] = {"c", "python", "sh", "html", "css"}
    g["pandoc#formatting#mode"] = "h"
    g["pandoc#modules#disabled"] = {"folding", "formatting"}
    g["pandoc#syntax#conceal#cchar_overrides"] = {codelang = " "}
end

return M
