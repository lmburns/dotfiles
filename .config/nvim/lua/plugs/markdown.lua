local M = {}

local utils = require("common.utils")
local map = utils.map
local augroup = utils.augroup

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
            end
        }
    )

    -- g.loaded_table_mode = 1 -- enable/disable plugin
    -- g.table_mode_always_active = 1 -- permanently enable the table mode
    -- g.table_mode_disable_mappings = 0 -- disable all mappings

    g.table_mode_delete_column_map = "<Leader>tdc"
    g.table_mode_sort_map = "<Leader>ts"

    g.table_mode_tableize_map = "<Leader>tt"
    g.table_mode_tableize_d_map = "<Leader>T"
    g.table_mode_realign_map = "<Leader>tr"
    g.table_mode_echo_cell_map = "<Leader>t?"
    g.table_mode_map_prefix = "<Leader>t"
    g.table_mode_delete_row_map = "<Leader>tdd"
    g.table_mode_insert_column_after_map = "<Leader>tic"

    g.table_mode_tableize_auto_border = 1 -- add row borders to when using tableize
    g.table_mode_disable_tableize_mappings = 0 -- disables mappings for tableize

    g.table_mode_syntax = 1 -- should define table syntax definitions or not
    g.table_mode_auto_align = 1 -- auto align as you type when table mode is active

    g.table_mode_corner = "|"
    g.table_mode_fillchar = "-"
    g.table_mode_separator = "|"
    g.table_mode_separator_map = "|"
    g.table_mode_header_fillchar = "="
    g.table_mode_align_char = ":" -- alignments for cols in table header border

    g.table_mode_motion_up_map = "{|" -- move up a cell vertically
    g.table_mode_motion_down_map = "}|" -- move down a cell vertically
    g.table_mode_motion_left_map = "[|" -- move to the left cell
    g.table_mode_motion_right_map = "]|" -- move to the right cell
    g.table_mode_cell_text_object_a_map = "a|" -- text object for around cell object
    g.table_mode_cell_text_object_i_map = "i|" -- text object for inner cell object

    wk.register(
        {
            ["[|"] = "Move to previous cell",
            ["]|"] = "Move to next cell",
            ["{|"] = "Move to the cell above",
            ["}|"] = "Move to the cell below",
            ["<Leader>tm"] = "Toggle table mode for the current buffer",
            ["<Leader>tS"] = {
                "<Cmd>TableModeDisable<CR>",
                "Disable table mode for the current buffer"
            },
            ["<Leader>tt"] = "Triggers 'tableize' on visually selected content",
            ["<Leader>T"] = "Triggers 'tableize' on visually selected asking for input of the delimiter",
            ["<Leader>tr"] = "Realigns table columns",
            ["<Leader>t?"] = "Echo current table cells representation for defining formulas",
            ["<Leader>tdd"] = "Delete entire table row you are on or multiple `[count]`",
            ["<Leader>tdc"] = "Delete entire table column you are within, can use `[count]",
            ["<Leader>tiC"] = "Insert a table column before the column you are within, can use `[count]`",
            ["<Leader>tic"] = "Insert a table column after the column you are within, can use `[count]`",
            ["<Leader>tfa"] = "Add formula for current table cell. Invokes `TableAddFormula`",
            ["<Leader>tfe"] = "Evaluate formula line commented after table beginning with 'tmf:'",
            ["<Leader>ts"] = "Sort a column under the cursor. Invokes `TableSort`"
        }
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
            pattern = {"markdown", "vimwiki"},
            command = function(args)
                local bufnr = args.buf
                map("i", "<S-CR>", "<Plug>VimwikiFollowLink", {buffer = bufnr})

                utils.del_keymap("n", "<Leader>whh", {buffer = bufnr})

                wk.register(
                    {
                        ["<Leader>wh"] = {"<Plug>Vimwiki2HTML", "Convert page to HTML"},
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
                        ["glx"] = {"<Plug>VimwikiToggleRejectedListItem", "Toggle checkbox status list"},
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
                        ["<Tab>"] = {">>", "Indent line"},
                        ["<S-Tab>"] = {"<<", "De-indent line"}
                    },
                    {mode = "n", buffer = bufnr}
                )

                wk.register(
                    {
                        ["<S-CR>"] = "Don't continue list format",
                        ["<C-t>"] = {"<Plug>VimwikiIncreaseLvlSingleItem", "Increase list level"},
                        ["<C-d>"] = {"<Plug>VimwikiDecreaseLvlSingleItem", "Decrease list level"},
                        ["<C-s><C-j>"] = {"<Plug>VimwikiListNextSymbol", "Change to next list type"},
                        ["<C-s><C-k>"] = {"<Plug>VimwikiListPrevSymbol", "Change to next list type"},
                        ["<C-s><C-m>"] = {"<Plug>VimwikiListToggle", "Toggle list item"}
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
                        ["il"] = {"<Plug>VimwikiTextObjListSingle", "List item"}
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
                        ["<S-Tab>"] = {"<<<Esc>gv", "De-indent line"}
                    },
                    {mode = "x", buffer = bufnr}
                )
            end
        }
    )
end

function M.vimwiki_setup()
    -- g.vimwiki_filetypes = {"markdown", "pandoc"}
    g.vimwiki_folding = ""
    g.vimwiki_hl_headers = 1 -- Highlight headers with VimWikiHeader1...
    g.vimwiki_global_ext = 1 -- Enable/disable temporary wikis
    g.vimwiki_auto_header = 1 -- Auto gen level 1 header
    g.vimwiki_conceallevel = 0
    g.vimwiki_conceal_onechar_markers = 1
    g.vimwiki_dir_link = "index" -- Open index.md if given a direcory
    g.vimwiki_map_prefix = "<Leader>w"
    g.vimwiki_commentstring = "<!--%s-->"
    g.vimwiki_toc_header = "Table of Contents"
    g.vimwiki_toc_header_level = 1
    g.vimwiki_toc_link_format = 0 -- 0 = Extended, 1 = Brief
    g.vimwiki_html_header_numbering_sym = "." -- End in '.' or ')'

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
            syntax = "markdown",
            ext = ".md",
            bullet_types = {"-", "*", "+"},
            nested_syntax = {python = "python", ["c++"] = "cpp"},
            auto_toc = 0
        }
    }
    g.vimwiki_key_mappings = {
        all_maps = 1,
        global = 1,
        headers = 1,
        text_objs = 1,
        table_format = 1,
        table_mappings = 0,
        lists = 1,
        links = 1,
        html = 1,
        mouse = 0
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
