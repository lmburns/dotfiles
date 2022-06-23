local M = {}

local D = require("dev")
local hs = D.npcall(require, "high-str")
if not hs then
    return
end

local utils = require("common.utils")
local map = utils.map

function M.setup()
    hs.setup(
        {
            verbosity = 0,
            highlight_colors = {
                color_0 = {"#F06431", "smart"},
                color_1 = {"#DC3958", "smart"},
                color_2 = {"#088649", "smart"},
                color_3 = {"#F79A32", "smart"},
                color_4 = {"#889B4A", "smart"},
                color_5 = {"#98676A", "smart"},
                color_6 = {"#7E5053", "smart"},
                color_7 = {"#418292", "smart"},
                color_8 = {"#8AB1B0", "smart"},
                color_9 = {"#7d5c34", "smart"}
            }
        }
    )
end

local function init()
    M.setup()

    map("v", "<F3>", ":<C-u>HSHighlight 1<CR>", {silent = true})
    map("v", "<F4>", ":<C-u>HSRmHighlight 1<CR>", {silent = true})
end

init()

return M
