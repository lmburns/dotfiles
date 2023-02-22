local M = {}

-- TODO: Change quickfix view to show mark in first column

local D = require("dev")
local marks = D.npcall(require, "marks")
if not marks then
    return
end

local wk = require("which-key")

function M.setup()
    marks.setup {
        -- whether to map keybinds or not. default true
        default_mappings = true,
        -- which builtin marks to show. default {}
        -- builtin_marks = {},
        builtin_marks = {".", "^"},
        -- builtin_marks = {".", "<", ">", "^"},
        -- builtin_marks = {"<", ">", "'", '"', "^", "."},
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
        excluded_filetypes = _t(BLACKLIST_FT):filter(
            function(i)
                return not _t({"markdown", "vimwiki"}):contains(i)
            end
        ),
        -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
        -- sign/virttext. Bookmarks can be used to group together positions and quickly move
        -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
        -- default virt_text is "".
        bookmark_0 = {sign = "", virt_text = " Bookmark 0 ", annotate = false},
        bookmark_1 = {sign = "", virt_text = " Bookmark 1 "},
        bookmark_2 = {sign = "○", virt_text = "○ Bookmark 2 ○"},
        bookmark_3 = {sign = "◉", virt_text = "◉ Bookmark 3 ◉"},
        bookmark_4 = {sign = "✿", virt_text = "✿ Bookmark 4 ✿"},
        bookmark_5 = {sign = "", virt_text = " Bookmark 5 "},
        bookmark_6 = {sign = "", virt_text = " Bookmark 6 "},
        bookmark_7 = {sign = "", virt_text = " Bookmark 7 "},
        bookmark_8 = {sign = "󰸕", virt_text = "󰸕 Bookmark 8 󰸕"},
        bookmark_9 = {sign = "", virt_text = " Bookmark 9 "},
        bookmark_10 = {sign = "󰫢", virt_text = "󰫢 Bookmark 10 󰫢"},
        mappings = {
            annotate = "m'"
        }
    }
end

local function init()
    M.setup()

    wk.register(
        {
            m = {
                name = "+marks",
                -- ["la"] = {"<Cmd>MarksListBuf<CR>", "List buffer marks"},
                ["m"] = {"<Cmd>MarksListBuf<CR>", "List buffer marks"},
                ["lg"] = {"<Cmd>MarksQFListGlobal<CR>", "List global marks"},
                ["fD"] = {"<Cmd>delm a-zA-Z0-9<CR>", "Delete all marks in buffer"},
                ["fd"] = {"<Cmd>delm A-Z<CR><Cmd>wshada!<CR>", "Delete all capital marks"}
            }
        },
        {prefix = "<Leader>"}
    )

    wk.register(
        {
            ["qm"] = {"<Cmd>MarksListBuf<CR>", "List buffer marks"},
            ["qM"] = {"<Cmd>MarksQFListGlobal<CR>", "List global marks"},
            ["q0"] = {"<Cmd>BookmarksQFListAll<CR>", "List bookmarks"},
            ["dm="] = "Marks: delete mark under cursor",
            ["dm-"] = "Marks: delete all marks on line",
            ["dm<Space>"] = "Marks: delete all marks in buffer",
            ["m,"] = "Marks: set next alphabetically",
            ["m;"] = "Marks: toggle next alphabetically",
            ["m]"] = "Marks: go to next",
            ["m["] = "Marks: go to prev",
            ["m:"] = "Marks: show preview",
            ["m/"] = {"<Plug>(Marks-preview)", "Marks: show preview"},
            ["m}"] = "Marks: go to next bookmark",
            ["m{"] = "Marks: go to prev bookmark",
            ["m'"] = "Marks: annotate bookmark",
            ["m0"] = "Marks: set bookmark0",
            ["m1"] = "Marks: set bookmark1",
            ["m2"] = "Marks: set bookmark2",
            ["m3"] = "Marks: set bookmark3",
            ["m4"] = "Marks: set bookmark4",
            ["m5"] = "Marks: set bookmark5",
            ["m6"] = "Marks: set bookmark6",
            ["m7"] = "Marks: set bookmark7",
            ["m8"] = "Marks: set bookmark8",
            ["m9"] = "Marks: set bookmark9",
            ["m10"] = "Marks: set bookmark10",
        }
    )

    -- map("n", "<Leader>mld", ":delmarks a-z<CR>")
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
