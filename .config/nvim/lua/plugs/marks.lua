---@module 'plugs.marks'
local M = {}

-- TODO: Change quickfix view to show mark in first column

local D = require("dev")
local marks = D.npcall(require, "marks")
if not marks then
    return
end

local mpi = require("common.api")
local map = mpi.map
local icons = require("style").icons
local wk = require("which-key")

---
---@param sign string
---@param num number
---@return {sign: string, virt_text: string, annotate: boolean}
local function bookmark_vt(sign, num)
    return {
        sign = sign,
        virt_text = ("%s Bookmark %d %s"):format(sign, num, sign),
        annotate = false,
    }
end

function M.setup()
    marks.setup{
        -- whether to map keybinds or not. default true
        default_mappings = true,
        -- which builtin marks to show. default {}
        builtin_marks = {
            "<", -- first char/line of last selected with visual
            ">", -- last char/line of last selected with visual
            "'", -- last position before latest jump
            -- "`", -- last position before latest jump
            '"', -- cursor position when last exiting buf
            "^", -- cursor position when last in insert
            ".", -- position where last change
            -- "[", -- cursor position of last changed/yanked
            -- "]" -- cursor position of last changed/yanked
            -- "(", -- start of current sentence
            -- ")", -- end of current sentence
            -- "{", -- start of current paragraph
            -- "}" -- end of current paragraph
        },
        -- whether movements cycle back to the beginning/end of buffer. default true
        cyclic = true,
        -- whether the shada file is updated after modifying uppercase marks. default false
        force_write_shada = false,
        -- how often (in ms) to redraw signs/recompute mark positions.
        -- higher values will have better performance but may cause visual lag,
        -- while lower values may cause performance penalties. default 150.
        refresh_interval = 250,
        -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
        -- marks, and bookmarks.
        -- can be either a table with all/none of the keys, or a single number, in which case
        -- the priority applies to all marks.
        -- default 10.
        sign_priority = {lower = 10, upper = 15, builtin = 9, bookmark = 20},
        -- disables mark tracking for specific filetypes. default {}
        excluded_filetypes = BLACKLIST_FT:filter(function(i)
            return not _t({"markdown", "vimwiki"}):contains(i)
        end),
        -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
        -- sign/virttext. Bookmarks can be used to group together positions and quickly move
        -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
        -- default virt_text is "".
        bookmark_0 = bookmark_vt(icons.misc.star, 0),
        bookmark_1 = bookmark_vt(icons.ui.bookmark, 1),
        bookmark_2 = bookmark_vt(icons.ui.circle_o, 2),
        bookmark_3 = bookmark_vt(icons.ui.circle_bullseye, 3),
        bookmark_4 = bookmark_vt(icons.misc.flower, 4),
        bookmark_5 = bookmark_vt(icons.misc.lilst, 5),
        bookmark_6 = bookmark_vt(icons.misc.star_o, 6),
        bookmark_7 = bookmark_vt(icons.ui.bookmark_o, 7),
        bookmark_8 = bookmark_vt(icons.ui.bookmark_double, 8),
        bookmark_9 = bookmark_vt(icons.ui.bookmark_star, 9),
        bookmark_10 = bookmark_vt(icons.misc.star_small, 10),
        mappings = {
            annotate = "m?",
        },
    }
end

---Open a QF list with only lettered marks
function M.lettered_marks_qf()
    local builtin = marks.mark_state.builtin_marks
    local curbuf = marks.mark_state.buffers[1]
    local old_state = curbuf.placed_marks
    local new_state = {}
    for mark, value in pairs(curbuf.placed_marks) do
        if not vim.tbl_contains(builtin, mark) then
            new_state[mark] = value
        end
    end
    if #vim.tbl_keys(new_state) > 0 then
        curbuf.placed_marks = new_state
    end
    marks.mark_state:buffer_to_list("quickfixlist")
    cmd.copen()
    curbuf.placed_marks = old_state
    marks.refresh()
end

local function init()
    M.setup()

    map("n", "v", "m`v")
    map("n", "V", "m`V")
    map("n", "<C-v>", "m`<C-v>")

    -- Remap mark jumping to jump to column instead of start of line
    map({"n", "x", "o"}, [[']], [[`]])
    map({"n", "x", "o"}, [[`]], [[']])

    wk.register(
        {
            m = {
                name = "+marks",
                -- ["la"] = {"<Cmd>MarksListBuf<CR>", "List buffer marks"},
                ["m"] = {"<Cmd>MarksQFListBuf<CR>", "List buffer marks"},
                ["lg"] = {"<Cmd>MarksQFListGlobal<CR>", "List global marks"},
                ["fD"] = {"<Cmd>delm a-zA-Z0-9<CR>", "Delete all marks in buffer"},
                ["fd"] = {"<Cmd>delm A-Z<CR><Cmd>wshada!<CR>", "Delete all capital marks"},
            },
        },
        {prefix = "<Leader>"}
    )

    -- map("n", "<Leader>mld", ":delmarks a-z<CR>")
    wk.register({
        ["qm"] = {
            "<Cmd>lua require('plugs.marks').lettered_marks_qf()<CR>",
            "List lettered buf marks",
        },
        ["qM"] = {"<Cmd>MarksQFListBuf<CR>", "List buf marks"},
        ["qg"] = {"<Cmd>MarksQFListGlobal<CR>", "List global marks"},
        ["q0"] = {"<Cmd>BookmarksQFListAll<CR>", "List bookmarks"},
        ["dm="] = "Mark: delete mark under cursor",
        ["dm-"] = "Mark: delete all marks on line",
        ["dm<Space>"] = "Mark: delete all marks in buffer",
        ["m,"] = "Mark: set next alphabetically",
        ["m;"] = "Mark: toggle next alphabetically",
        ["m:"] = "Mark: show preview",
        ["m/"] = {"<Plug>(Marks-preview)", "Mark: show preview"},
        ["[`"] = {"<Plug>(Marks-prev)", "Prev mark"},
        ["]`"] = {"<Plug>(Marks-next)", "Next mark"},
        -- ["[m"] = {"<Plug>(Marks-prev)", "Prev mark"},
        -- ["]m"] = {"<Plug>(Marks-next)", "Next mark"},
        ["[M"] = {"<Plug>(Marks-prev-bookmark)", "Prev bookmark"},
        ["]M"] = {"<Plug>(Marks-next-bookmark)", "Next bookmark"},
        ["m?"] = "Mark: annotate bookmark",
        ["m0"] = "Mark: set bookmark10",
        ["m1"] = "Mark: set bookmark1",
        ["m2"] = "Mark: set bookmark2",
        ["m3"] = "Mark: set bookmark3",
        ["m4"] = "Mark: set bookmark4",
        ["m5"] = "Mark: set bookmark5",
        ["m6"] = "Mark: set bookmark6",
        ["m7"] = "Mark: set bookmark7",
        ["m8"] = "Mark: set bookmark8",
        ["m9"] = "Mark: set bookmark9",
    })
end

init()

-- mx              Set mark x
-- m,              Set the next available alphabetical (lowercase) mark
-- m;              Toggle the next available mark at the current line
-- dmx             Delete mark x
-- dm=             Delete the bookmark under the cursor.
-- dm-             Delete all marks on the current line
-- dm<space>       Delete all marks in the current buffer
-- m]              Move to next mark
-- m[              Move to previous mark
-- m:              Preview mark. This will prompt you for a specific mark to
--                 preview; press <cr> to preview the next mark.
--
-- m[0-9]          Add a bookmark from bookmark group[0-9].
-- dm[0-9]         Delete all bookmarks from bookmark group[0-9].
-- m}              Move to the next bookmark having the same type as the bookmark under
--                 the cursor. Works across buffers.
-- m{              Move to the previous bookmark having the same type as the bookmark under
--                 the cursor. Works across buffers.

return M
