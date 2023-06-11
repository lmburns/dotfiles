local wk = require("which-key")

local mpi = require("usr.api")
local bmap0 = mpi.bmap0

local fn = vim.fn
local cmd = vim.cmd
local o = vim.opt_local

-- o.bufhidden = "wipe"
o.buflisted = false

-- NetrwSettings
-- Nr   Nread
-- Nw   Nwrite
-- Ns   Nsource

wk.register({
    ["<F1>"] = "Causes Netrw to issue help",
    ["<cr>"] = "Netrw will enter the dir or read the file",
    ["<del>"] = "Netrw will attempt to remove the file/dir",
    ["<c-h>"] = "Edit file hiding list",
    ["<c-l>"] = "Causes Netrw to refresh the dir listing",
    ["<c-r>"] = "Browse using a gvim server",
    ["<c-tab>"] = "Shrink/expand a netrw/explore window",
    ["-"] = "Makes Netrw go up one dir",
    ["a"] = "Cycles between normal display,",
    ["cd"] = "Make browsing dir the curr dir",
    ["C"] = "Setting the editing window",
    ["d"] = "Make a directory",
    ["D"] = "Attempt to remove the file/dir(s)",
    ["gb"] = "Go to prev bookmarked dir",
    ["gd"] = "Force treatment as dir",
    ["gf"] = "Force treatment as file",
    ["gh"] = "Quick hide/unhide of dot-files",
    ["gn"] = "Make top of tree the dir below cursor",
    ["gp"] = "Change local-only file permissions",
    ["i"] = "Cycle between thin, long, wide, and tree listings",
    ["I"] = "Toggle the displaying of the banner",
    ["mb"] = "Bookmark current directory",
    ["mc"] = "Copy marked files to marked-file target dir",
    ["md"] = "Apply diff to marked files (up to 3)",
    ["me"] = "Place marked files on arg list and edit them",
    ["mf"] = "Mark a file",
    ["mF"] = "Unmark files",
    ["mg"] = "Apply vimgrep to marked files",
    ["mh"] = "Toggle marked file suffices' presence on hiding list",
    ["mm"] = "Move marked files to marked-file target dir",
    ["mp"] = "Print marked files",
    ["mr"] = "Mark files using a shell-style",
    ["mt"] = "Current browsing dir becomes markfile target",
    ["mT"] = "Apply ctags to marked files",
    ["mu"] = "Unmark all marked files",
    ["mv"] = "Apply vim command to marked files",
    ["mx"] = "Apply shell command to marked files",
    ["mX"] = "Apply shell command to marked files en bloc",
    ["mz"] = "Compress/decompress marked files",
    ["o"] = "Enter entry under cursor in horiz browser win",
    ["O"] = "Obtain a file specified by cursor",
    ["p"] = "Preview the file",
    ["P"] = "Browse in the prevly used window",
    ["qb"] = "List bookmarked dirs and history",
    ["qf"] = "Display information on file",
    ["qF"] = "Mark files using a quickfix list",
    ["qL"] = "Mark files using a",
    ["r"] = "Reverse sorting order",
    ["R"] = "Rename the designated file/dir(s)",
    ["s"] = "Select sorting style: by name, time, or file size",
    ["S"] = "Specify suffix priority for name-sorting",
    ["t"] = "Enter the file/dir under the cursor in a new tab",
    ["u"] = "Change to recently-visited dir",
    ["U"] = "Change to subsequently-visited dir",
    ["v"] = "Enter entry under cursor in vert browser win",
    ["x"] = "View file with an associated program",
    ["X"] = "Execute filename under cursor via",
    ["%"] = "Open a new file in netrw's current dir",
}, {mode = "n", buffer = 0})

local function close_netrw()
    for _, buf in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_valid(buf) and vim.bo[buf].ft == "netrw" then
            cmd(("silent! exec 'bw %d'"):format(buf))
        end
    end
end

bmap0("n", "qq", close_netrw, {desc = "Close netrw"})
bmap0("n", "<C-l>", "<C-w>l", {desc = "Go to right window"})
