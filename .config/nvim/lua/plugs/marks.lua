local M = {}

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
        sign_priority = {lower = 10, upper = 15, builtin = 8, bookmark = 20},
        -- disables mark tracking for specific filetypes. default {}
        excluded_filetypes = BLACKLIST_FT,
        -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
        -- sign/virttext. Bookmarks can be used to group together positions and quickly move
        -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
        -- default virt_text is "".
        bookmark_0 = {sign = "⚑", virt_text = "Group0"},
        bookmark_1 = {sign = "", virt_text = "Group0"},
        mappings = {}
        -- mappings = {
        --   set_next = "m,",
        --   next = "m]",
        --   preview = "m;",
        --   set_bookmark0 = "m0",
        --   prev = "m[",
        -- },
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
            ["q0"] = {"<Cmd>BookmarksQFListAll<CR>", "List bookmarks"}
        }
    )

    -- map("n", "<Leader>mld", ":delmarks a-z<CR>")
end

init()

-- mx              Set mark x
-- m,              Set the next available alphabetical (lowercase) mark
-- m;              Toggle the next available mark at the current line
-- dmx             Delete mark x
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
-- dm=             Delete the bookmark under the cursor.

return M
