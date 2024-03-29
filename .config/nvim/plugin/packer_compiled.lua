-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = true
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/lucas/.cache/nvim/packer_hererocks/2.1.1692716794/share/lua/5.1/?.lua;/home/lucas/.cache/nvim/packer_hererocks/2.1.1692716794/share/lua/5.1/?/init.lua;/home/lucas/.cache/nvim/packer_hererocks/2.1.1692716794/lib/luarocks/rocks-5.1/?.lua;/home/lucas/.cache/nvim/packer_hererocks/2.1.1692716794/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/lucas/.cache/nvim/packer_hererocks/2.1.1692716794/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["Comment.nvim"] = {
    config = { "require('plugs.comment')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/Comment.nvim",
    url = "https://github.com/numToStr/Comment.nvim"
  },
  ["FixCursorHold.nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/FixCursorHold.nvim",
    url = "https://github.com/antoinemadec/FixCursorHold.nvim"
  },
  ScratchPad = {
    commands = { "ScratchPad" },
    config = { "require('plugs.config').scratchpad()" },
    keys = { { "n", "<Leader>sc" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/ScratchPad",
    url = "https://github.com/FraserLee/ScratchPad"
  },
  ["aerial.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/aerial.nvim",
    url = "https://github.com/stevearc/aerial.nvim"
  },
  ["arshlib.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/arshlib.nvim",
    url = "https://github.com/arsham/arshlib.nvim"
  },
  ["better-escape.nvim"] = {
    config = { "require('plugs.config').better_esc()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/better-escape.nvim",
    url = "https://github.com/max397574/better-escape.nvim"
  },
  ["bufferize.vim"] = {
    commands = { "Bufferize" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/bufferize.vim",
    url = "https://github.com/AndrewRadev/bufferize.vim"
  },
  ["bufferline.nvim"] = {
    config = { "require('plugs.bufferline')" },
    load_after = {
      ["lualine.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  catppuccin = {
    config = { "plugs.kimbox.catpuccin" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["close-buffers.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/close-buffers.nvim",
    url = "https://github.com/kazhala/close-buffers.nvim"
  },
  ["coc-code-action-menu"] = {
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/coc-code-action-menu",
    url = "/home/lucas/projects/nvim/coc-code-action-menu"
  },
  ["coc-fzf"] = {
    after_files = { "/home/lucas/.local/share/nvim/site/pack/packer/opt/coc-fzf/after/plugin/coc_fzf.vim" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/coc-fzf",
    url = "https://github.com/antoinemadec/coc-fzf"
  },
  ["coc-kvs"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/coc-kvs",
    url = "https://github.com/kevinhwang91/coc-kvs"
  },
  ["coc.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/coc.nvim",
    url = "https://github.com/neoclide/coc.nvim"
  },
  ["codeium.vim"] = {
    commands = { "Codium", "CodiumEnable" },
    config = { "require('plugs.config').codium()" },
    keys = { { "i", "<C-M-'>" }, { "i", "<M-g>" }, { "i", "<M-[>" }, { "i", "<M-]>" }, { "i", "<M-\\>" }, { "i", "<C-M-->" }, { "i", "<C-M-=>" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/codeium.vim",
    url = "https://github.com/Exafunction/codeium.vim"
  },
  ["comment-box.nvim"] = {
    config = { "require('plugs.comment').comment_box()" },
    keys = { { "n", "<Leader>bb" }, { "n", "<Leader>bs" }, { "n", "<Leader>bd" }, { "n", "<Leader>blc" }, { "n", "<Leader>bll" }, { "n", "<Leader>blr" }, { "n", "<Leader>br" }, { "n", "<Leader>bR" }, { "n", "<Leader>bc" }, { "n", "<Leader>ba" }, { "n", "<Leader>be" }, { "n", "<Leader>bA" }, { "n", "<Leader>cc" }, { "n", "<Leader>cb" }, { "n", "<Leader>ce" }, { "n", "<Leader>ca" }, { "n", "<Leader>cn" }, { "n", "<Leader>ct" }, { "n", "<Leader>cT" }, { "i", "<M-w>" }, { "i", "<C-M-w>" }, { "i", "<M-S-w>" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/comment-box.nvim",
    url = "https://github.com/LudoPinelli/comment-box.nvim"
  },
  ["crates.nvim"] = {
    after_files = { "/home/lucas/.local/share/nvim/site/pack/packer/opt/crates.nvim/after/plugin/cmp_crates.lua" },
    config = { "require('plugs.ft.rust').crates()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/crates.nvim",
    url = "https://github.com/Saecki/crates.nvim"
  },
  ["desktop-notify.nvim"] = {
    config = { "vim.cmd('command! Notifications :lua require(\"notify\")._print_history()<CR>')" },
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/desktop-notify.nvim",
    url = "https://github.com/simrat39/desktop-notify.nvim"
  },
  ["dial.nvim"] = {
    config = { "require('plugs.dial')" },
    keys = { { "n", "+" }, { "n", "_" }, { "v", "+" }, { "v", "_" }, { "v", "g+" }, { "v", "g_" }, { "n", "s-" }, { "n", "s=" }, { "n", "s[" }, { "n", "s]" }, { "n", "s'" }, { "n", 's"' }, { "n", "s`" }, { "n", "s~" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/dial.nvim",
    url = "https://github.com/monaqa/dial.nvim"
  },
  ["diffview.nvim"] = {
    commands = { "DiffviewClose", "DiffviewFileHistory", "DiffviewFocusFiles", "DiffviewLog", "DiffviewOpen", "DiffviewRefresh", "DiffviewToggleFiles" },
    config = { "require('plugs.diffview')" },
    keys = { { "n", "<Leader>g;" }, { "n", "<Leader>g." }, { "n", "<Leader>gh" }, { "n", "<LocalLeader>gd" }, { "x", "<LocalLeader>gd" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/diffview.nvim",
    url = "https://github.com/sindrets/diffview.nvim"
  },
  ["dressing.nvim"] = {
    config = { "require('plugs.dressing')" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/dressing.nvim",
    url = "https://github.com/stevearc/dressing.nvim"
  },
  ["eregex.vim"] = {
    commands = { "E2v", "S", "M", "V" },
    config = { "require('plugs.config').eregex()" },
    keys = { { "n", "<Leader>es" }, { "n", "<Leader>S" }, { "n", ",/" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/eregex.vim",
    url = "https://github.com/ZSaberLv0/eregex.vim"
  },
  ["flatten.nvim"] = {
    config = { "require('plugs.neoterm').flatten()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/flatten.nvim",
    url = "https://github.com/willothy/flatten.nvim"
  },
  fzf = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf",
    url = "https://github.com/junegunn/fzf"
  },
  ["fzf-lua"] = {
    config = { "require('plugs.fzf-lua')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf-lua",
    url = "https://github.com/ibhagwan/fzf-lua"
  },
  ["fzf.vim"] = {
    config = { "require('plugs.fzf')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf.vim",
    url = "https://github.com/junegunn/fzf.vim"
  },
  ["fzy-lua-native"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzy-lua-native",
    url = "https://github.com/romgrk/fzy-lua-native"
  },
  ["git-conflict.nvim"] = {
    config = { "require('plugs.git').git_conflict()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/git-conflict.nvim",
    url = "https://github.com/akinsho/git-conflict.nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "require('plugs.gitsigns')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim",
    wants = { "nvim-scrollbar" }
  },
  ["helpful.vim"] = {
    commands = { "HelpfulVersion" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/helpful.vim",
    url = "https://github.com/tweekmonster/helpful.vim"
  },
  hexmode = {
    config = { "vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe'" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/hexmode",
    url = "https://github.com/fidian/hexmode"
  },
  ["hlargs.nvim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/hlargs.nvim",
    url = "https://github.com/m-demare/hlargs.nvim"
  },
  ["hop.nvim"] = {
    after = { "nvim-treehopper" },
    config = { "require('plugs.hop')" },
    keys = { { "n", "f" }, { "x", "f" }, { "o", "f" }, { "n", "F" }, { "x", "F" }, { "o", "F" }, { "n", "t" }, { "x", "t" }, { "o", "t" }, { "n", "T" }, { "x", "T" }, { "o", "T" }, { "n", "sf" }, { "n", "sF" }, { "n", "st" }, { "n", "sT" }, { "n", "<Leader><Leader>j" }, { "n", "<Leader><Leader>k" }, { "n", "<Leader><Leader>J" }, { "n", "<Leader><Leader>K" }, { "n", "g(" }, { "n", "g)" }, { "n", "g{" }, { "n", "g}" }, { "n", ";a" }, { "n", "s/" }, { "n", "sy" }, { "n", "s?" }, { "o", "," }, { "n", "<C-S-<>" }, { "n", "<C-S-:>" }, { "n", "<Leader>sH" }, { "n", "<Leader>sL" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/hop.nvim",
    url = "https://github.com/phaazon/hop.nvim"
  },
  ["hotpot.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/hotpot.nvim",
    url = "https://github.com/rktjmp/hotpot.nvim"
  },
  ["id3.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/id3.vim",
    url = "https://github.com/AndrewRadev/id3.vim"
  },
  ["incline.nvim"] = {
    config = { "require('plugs.incline')" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/incline.nvim",
    url = "https://github.com/b0o/incline.nvim"
  },
  ["indent-blankline.nvim"] = {
    config = { "require('plugs.indent_blankline')" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["info.vim"] = {
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/info.vim",
    url = "https://github.com/HiPhish/info.vim"
  },
  ["iswap.nvim"] = {
    config = { "require('plugs.treesitter').setup_iswap()" },
    keys = { { "n", "vs" }, { "n", "sv" }, { "n", "so" }, { "n", "sc" }, { "n", "sh" }, { "n", "sl" }, { "n", "s," }, { "n", "s." } },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/iswap.nvim",
    url = "https://github.com/mizlan/iswap.nvim"
  },
  ["kanagawa.nvim"] = {
    config = { "plugs.kimbox.kanagawa" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/kanagawa.nvim",
    url = "https://github.com/rebelot/kanagawa.nvim"
  },
  kimbox = {
    after = { "lualine.nvim", "bufferline.nvim", "nvim-notify", "nvim-scrollbar", "lf.nvim", "telescope.nvim", "mkdx" },
    config = { "require('plugs.kimbox')" },
    loaded = true,
    only_config = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/kimbox",
    url = "https://github.com/lmburns/kimbox"
  },
  ["lf-vim"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim",
    url = "https://github.com/camnw/lf-vim"
  },
  ["lf.nvim"] = {
    config = { "require('plugs.config').lfnvim()" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lf.nvim",
    url = "/home/lucas/projects/nvim/lf.nvim",
    wants = { "toggleterm.nvim" }
  },
  ["lf.vim"] = {
    config = { "require('plugs.config').lf()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/lf.vim",
    url = "https://github.com/ptzz/lf.vim"
  },
  ["line-targets.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/line-targets.vim",
    url = "https://github.com/wellle/line-targets.vim"
  },
  ["linediff.vim"] = {
    commands = { "Linediff" },
    config = { "require('plugs.config').linediff()" },
    keys = { { "n", "gld" }, { "n", "<Leader>ld" }, { "x", "<Leader>ld" }, { "x", "D" }, { "n", "<Leader>lD" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/linediff.vim",
    url = "https://github.com/AndrewRadev/linediff.vim"
  },
  ["link-visitor.nvim"] = {
    config = { "require('plugs.config').link_visitor()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/link-visitor.nvim",
    url = "https://github.com/xiyaowong/link-visitor.nvim"
  },
  ["listish.nvim"] = {
    config = { "require('plugs.config').listish()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/listish.nvim",
    url = "https://github.com/arsham/listish.nvim"
  },
  ["lualine.nvim"] = {
    after = { "bufferline.nvim" },
    config = { "require('plugs.lualine')" },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["luv-vimdocs"] = {
    commands = { "help" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/luv-vimdocs",
    url = "https://github.com/nanotee/luv-vimdocs"
  },
  ["marks.nvim"] = {
    config = { "require('plugs.marks')" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/marks.nvim",
    url = "https://github.com/chentoast/marks.nvim"
  },
  mkdx = {
    after = { "vimwiki" },
    config = { 'vim.cmd(("source %s/plugins/mkdx.vim"):format(Rc.dirs.my.vimscript))' },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/mkdx",
    url = "https://github.com/SidOfc/mkdx"
  },
  neoformat = {
    config = { "require('plugs.format')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neoformat",
    url = "https://github.com/sbdchd/neoformat"
  },
  neogen = {
    commands = { "Neogen" },
    config = { "require('plugs.neogen')" },
    keys = { { "n", "<Leader>dg" }, { "n", "<Leader>dn" }, { "n", "<Leader>df" }, { "n", "<Leader>dc" }, { "n", "<Leader>dt" }, { "n", "<Leader>dF" } },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/neogen",
    url = "https://github.com/danymat/neogen"
  },
  neogit = {
    config = { "require('plugs.neogit')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neogit",
    url = "https://github.com/NeogitOrg/neogit"
  },
  ["nerdicons.nvim"] = {
    commands = { "NerdIcons" },
    config = { "require('plugs.config').nerdicons()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nerdicons.nvim",
    url = "https://github.com/glepnir/nerdicons.nvim"
  },
  ["nui.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "https://github.com/MunifTanjim/nui.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "require('plugs.autopairs')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-autopairs",
    url = "https://github.com/windwp/nvim-autopairs",
    wants = { "nvim-treesitter" }
  },
  ["nvim-bqf"] = {
    config = { "require('plugs.bqf')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-bqf",
    url = "https://github.com/kevinhwang91/nvim-bqf"
  },
  ["nvim-colorizer.lua"] = {
    config = { "require('plugs.config').colorizer()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/NvChad/nvim-colorizer.lua"
  },
  ["nvim-dap"] = {
    after = { "nvim-dap-virtual-text", "nvim-dap-ui", "nvim-dap-python", "one-small-step-for-vimkind", "telescope-dap.nvim" },
    commands = { "Debug", "DapREPL", "DapLaunch", "DapRun" },
    config = { "require('plugs.dap')" },
    keys = { { "n", "<LocalLeader>dd" }, { "n", "<LocalLeader>dc" }, { "n", "<LocalLeader>db" }, { "n", "<LocalLeader>dr" }, { "n", "<LocalLeader>dR" }, { "n", "<LocalLeader>dl" }, { "n", "<LocalLeader>dt" }, { "n", "<LocalLeader>dU" }, { "n", "<LocalLeader>dv" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap",
    url = "https://github.com/mfussenegger/nvim-dap"
  },
  ["nvim-dap-python"] = {
    load_after = {
      ["nvim-dap"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap-python",
    url = "https://github.com/mfussenegger/nvim-dap-python"
  },
  ["nvim-dap-ui"] = {
    load_after = {
      ["nvim-dap"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap-ui",
    url = "https://github.com/rcarriga/nvim-dap-ui"
  },
  ["nvim-dap-virtual-text"] = {
    load_after = {
      ["nvim-dap"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap-virtual-text",
    url = "https://github.com/theHamsta/nvim-dap-virtual-text"
  },
  ["nvim-fundo"] = {
    config = { "require('plugs.config').fundo()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-fundo",
    url = "https://github.com/kevinhwang91/nvim-fundo"
  },
  ["nvim-gps"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-gps",
    url = "https://github.com/lmburns/nvim-gps"
  },
  ["nvim-hlslens"] = {
    after = { "specs.nvim", "nvim-scrollbar" },
    config = { "require('plugs.config').hlslens()" },
    loaded = true,
    only_config = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-hlslens",
    url = "https://github.com/kevinhwang91/nvim-hlslens",
    wants = { "nvim-scrollbar" }
  },
  ["nvim-luapad"] = {
    commands = { "Luapad", "LuaRun" },
    config = { "require('plugs.config').luapad()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-luapad",
    url = "https://github.com/rafcamlet/nvim-luapad"
  },
  ["nvim-luaref"] = {
    commands = { "help" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-luaref",
    url = "https://github.com/milisims/nvim-luaref"
  },
  ["nvim-neoclip.lua"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-neoclip.lua",
    url = "https://github.com/AckslD/nvim-neoclip.lua"
  },
  ["nvim-notify"] = {
    config = { "require('plugs.notify')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-notify",
    url = "https://github.com/rcarriga/nvim-notify"
  },
  ["nvim-scrollbar"] = {
    config = { "require('plugs.scrollbar')" },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-scrollbar",
    url = "https://github.com/petertriho/nvim-scrollbar"
  },
  ["nvim-treehopper"] = {
    load_after = {
      ["hop.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-treehopper",
    url = "https://github.com/mfussenegger/nvim-treehopper",
    wants = { "nvim-treesitter" }
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-endwise"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-treesitter-endwise",
    url = "https://github.com/RRethy/nvim-treesitter-endwise"
  },
  ["nvim-treesitter-refactor"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-refactor",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-refactor"
  },
  ["nvim-treesitter-textobjects"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-textobjects",
    url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-ts-autotag"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-ts-autotag",
    url = "https://github.com/windwp/nvim-ts-autotag"
  },
  ["nvim-ts-context-commentstring"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-ts-context-commentstring",
    url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring"
  },
  ["nvim-ufo"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-ufo",
    url = "https://github.com/kevinhwang91/nvim-ufo"
  },
  ["nvim-various-textobjs"] = {
    config = { "require('plugs.textobj').various_textobjs()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-various-textobjs",
    url = "https://github.com/chrisgrieser/nvim-various-textobjs"
  },
  ["nvim-web-devicons"] = {
    config = { "require('plugs.config').devicons()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["nvim.lua"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim.lua",
    url = "https://github.com/norcalli/nvim.lua"
  },
  nvim_context_vt = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim_context_vt",
    url = "https://github.com/haringsrob/nvim_context_vt"
  },
  ["oil.nvim"] = {
    config = { "require('plugs.oil')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/oil.nvim",
    url = "https://github.com/stevearc/oil.nvim"
  },
  ["one-small-step-for-vimkind"] = {
    load_after = {
      ["nvim-dap"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/one-small-step-for-vimkind",
    url = "https://github.com/jbyuki/one-small-step-for-vimkind"
  },
  ["overseer.nvim"] = {
    commands = { "Ov", "OverseerOpen", "OverseerClose", "OverseerToggle", "OverseerSaveBundle", "OverseerLoadBundle", "OverseerDeleteBundle", "OverseerRunCmd", "OverseerRun", "OverseerBuild", "OverseerQuickAction", "OverseerTaskAction" },
    config = { "require('plugs.overseer')" },
    keys = { { "n", "<Leader>um" }, { "n", "<Leader>uc" }, { "n", "<Leader>ul" }, { "n", "<Leader>ub" }, { "n", "<Leader>uq" }, { "n", "<Leader>ua" }, { "n", "<Leader>ur" }, { "n", "<Leader>u<CR>" }, { "n", "<Leader>uR" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/overseer.nvim",
    url = "https://github.com/stevearc/overseer.nvim"
  },
  ["package-info.nvim"] = {
    config = { "require('plugs.ft.ecma').package_info()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/package-info.nvim",
    url = "https://github.com/vuki656/package-info.nvim"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["paint.nvim"] = {
    config = { "require('plugs.paint')" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/paint.nvim",
    url = "https://github.com/folke/paint.nvim"
  },
  ["paperplanes.nvim"] = {
    commands = { "PP" },
    config = { "require('plugs.config').paperplanes()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/paperplanes.nvim",
    url = "https://github.com/rktjmp/paperplanes.nvim"
  },
  playground = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/playground",
    url = "https://github.com/nvim-treesitter/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/popup.nvim",
    url = "https://github.com/nvim-lua/popup.nvim"
  },
  ["project.nvim"] = {
    config = { "require('plugs.git').project()" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/project.nvim",
    url = "https://github.com/ahmedkhalf/project.nvim"
  },
  ["promise-async"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/promise-async",
    url = "https://github.com/kevinhwang91/promise-async"
  },
  ["rainbow-delimiters.nvim"] = {
    config = { "require('plugs.treesitter').setup_rainbow()" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/rainbow-delimiters.nvim",
    url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim"
  },
  ["registers.nvim"] = {
    config = { "require('plugs.config').registers()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/registers.nvim",
    url = "https://github.com/tversteeg/registers.nvim"
  },
  ["ron.vim"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim",
    url = "https://github.com/ron-rs/ron.vim"
  },
  ["smart-splits.nvim"] = {
    config = { "require('plugs.config').smartsplits()" },
    keys = { { "n", "<C-Up>" }, { "n", "<C-Down>" }, { "n", "<C-Left>" }, { "n", "<C-Right>" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/smart-splits.nvim",
    url = "https://github.com/mrjones2014/smart-splits.nvim"
  },
  ["sort.nvim"] = {
    commands = { "Sort" },
    config = { "require('plugs.config').sort()" },
    keys = { { "n", "gz" }, { "x", "gz" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/sort.nvim",
    url = "https://github.com/sQVe/sort.nvim"
  },
  ["specs.nvim"] = {
    config = { "require('plugs.config').specs()" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/specs.nvim",
    url = "https://github.com/edluffy/specs.nvim"
  },
  ["sqlite.lua"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/sqlite.lua",
    url = "https://github.com/tami5/sqlite.lua"
  },
  ["substitute.nvim"] = {
    config = { "require('plugs.substitute')" },
    keys = { { "n", "si" }, { "n", "sa" }, { "n", "st" }, { "n", "sf" }, { "n", "ss" }, { "n", "se" }, { "n", "sr" }, { "n", "s;" }, { "n", "<Leader>sr" }, { "n", "sS" }, { "n", "sx" }, { "n", "sxx" }, { "n", "sxc" }, { "x", "s" }, { "x", "X" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/substitute.nvim",
    url = "https://github.com/gbprod/substitute.nvim"
  },
  ["suda.vim"] = {
    commands = { "SudaRead", "SudaWrite" },
    config = { "require('plugs.config').suda()" },
    keys = { { "n", "<Leader>W" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/suda.vim",
    url = "https://github.com/kevinhwang91/suda.vim"
  },
  ["syntax-tree-surfer"] = {
    commands = { "STSSwapNextVisual", "STSSwapPrevVisual", "STSSelectChildNode", "STSSelectParentNode", "STSSelectPrevSiblingNode", "STSSelectNextSiblingNode", "STSSelectCurrentNode", "STSSelectMasterNode", "STSJumpToTop" },
    config = { "require('plugs.treesitter').setup_treesurfer()" },
    keys = { { "n", "<C-M-,>" }, { "n", "<C-M-[>" }, { "n", "<C-M-]>" }, { "n", "<M-S-y>" }, { "n", "<M-S-u>" }, { "n", "(" }, { "n", ")" }, { "n", "vu" }, { "n", "vd" }, { "n", "su" }, { "n", "sd" }, { "n", "vU" }, { "n", "vD" }, { "n", "vn" }, { "n", "vm" }, { "n", "v;" }, { "x", "<A-]>" }, { "x", "<A-[>" }, { "x", "<C-A-]>" }, { "x", "<C-A-[>" }, { "x", "<C-k>" }, { "x", "<C-j>" } },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/syntax-tree-surfer",
    url = "https://github.com/ziontee113/syntax-tree-surfer"
  },
  ["targets.vim"] = {
    config = { "require('plugs.textobj').targets()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/targets.vim",
    url = "https://github.com/wellle/targets.vim"
  },
  ["telescope-bookmarks.nvim"] = {
    config = { 'require("telescope").load_extension("bookmarks")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-bookmarks.nvim",
    url = "https://github.com/dhruvmanila/telescope-bookmarks.nvim"
  },
  ["telescope-coc.nvim"] = {
    config = { 'require("telescope").load_extension("coc")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-coc.nvim",
    url = "https://github.com/fannheyward/telescope-coc.nvim"
  },
  ["telescope-dap.nvim"] = {
    config = { 'require("telescope").load_extension("dap")' },
    load_after = {
      ["nvim-dap"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-dap.nvim",
    url = "https://github.com/nvim-telescope/telescope-dap.nvim"
  },
  ["telescope-file-browser.nvim"] = {
    config = { 'require("telescope").load_extension("file_browser")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-file-browser.nvim",
    url = "https://github.com/nvim-telescope/telescope-file-browser.nvim"
  },
  ["telescope-frecency.nvim"] = {
    config = { 'require("telescope").load_extension("frecency")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-frecency.nvim",
    url = "https://github.com/nvim-telescope/telescope-frecency.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    config = { 'require("telescope").load_extension("fzf")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-ghq.nvim"] = {
    config = { 'require("telescope").load_extension("ghq")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-ghq.nvim",
    url = "https://github.com/nvim-telescope/telescope-ghq.nvim"
  },
  ["telescope-heading.nvim"] = {
    config = { 'require("telescope").load_extension("heading")' },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-heading.nvim",
    url = "https://github.com/crispgm/telescope-heading.nvim"
  },
  ["telescope-hop.nvim"] = {
    config = { 'require("telescope").load_extension("hop")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-hop.nvim",
    url = "https://github.com/nvim-telescope/telescope-hop.nvim"
  },
  ["telescope-rualdi.nvim"] = {
    config = { 'require("telescope").load_extension("rualdi")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-rualdi.nvim",
    url = "/home/lucas/projects/nvim/telescope-rualdi.nvim"
  },
  ["telescope-smart-history.nvim"] = {
    config = { 'require("telescope").load_extension("smart_history")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-smart-history.nvim",
    url = "https://github.com/nvim-telescope/telescope-smart-history.nvim"
  },
  ["telescope-ultisnips.nvim"] = {
    config = { 'require("telescope").load_extension("ultisnips")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-ultisnips.nvim",
    url = "https://github.com/fhill2/telescope-ultisnips.nvim"
  },
  ["telescope-zoxide"] = {
    config = { 'require("telescope").load_extension("zoxide")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-zoxide",
    url = "https://github.com/jvgrootveld/telescope-zoxide"
  },
  ["telescope.nvim"] = {
    after = { "nvim-notify", "urlview.nvim", "telescope-hop.nvim", "telescope-heading.nvim", "telescope-zoxide", "todo-comments.nvim", "project.nvim", "telescope-frecency.nvim", "telescope-ghq.nvim", "telescope-smart-history.nvim", "telescope-coc.nvim", "telescope-ultisnips.nvim", "telescope-rualdi.nvim", "telescope-bookmarks.nvim", "telescope-fzf-native.nvim", "nvim-neoclip.lua", "telescope-file-browser.nvim" },
    config = { "require('plugs.telescope')" },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["template-string.nvim"] = {
    config = { "require('plugs.ft.ecma').template_string()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/template-string.nvim",
    url = "https://github.com/axelvc/template-string.nvim"
  },
  ["tmux.nvim"] = {
    config = { "require('plugs.config').tmux()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/tmux.nvim",
    url = "https://github.com/aserowy/tmux.nvim"
  },
  ["todo-comments.nvim"] = {
    config = { "require('plugs.todo-comments')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/todo-comments.nvim",
    url = "https://github.com/folke/todo-comments.nvim",
    wants = { "plenary.nvim" }
  },
  ["toggleterm.nvim"] = {
    after = { "lf.nvim" },
    config = { "require('plugs.neoterm')" },
    loaded = true,
    only_config = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/toggleterm.nvim",
    url = "https://github.com/akinsho/toggleterm.nvim"
  },
  ["treesitter-unit"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/treesitter-unit",
    url = "https://github.com/David-Kunz/treesitter-unit"
  },
  treesj = {
    config = { "require('plugs.treesitter').setup_treesj()" },
    keys = { { "n", "gJ" }, { "n", "gK" }, { "n", "g\\" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/treesj",
    url = "https://github.com/Wansmer/treesj"
  },
  ultisnips = {
    after_files = { "/home/lucas/.local/share/nvim/site/pack/packer/opt/ultisnips/after/plugin/UltiSnips_after.vim" },
    config = { "require('plugs.config').ultisnips()" },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/ultisnips",
    url = "https://github.com/SirVer/ultisnips"
  },
  undotree = {
    commands = { "UndoTreeToggle" },
    config = { "require('plugs.undotree')" },
    keys = { { "n", "<Leader>ut" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/undotree",
    url = "https://github.com/mbbill/undotree"
  },
  ["urlview.nvim"] = {
    config = { "require('plugs.config').urlview()" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/urlview.nvim",
    url = "https://github.com/axieax/urlview.nvim"
  },
  ["vim-SpellCheck"] = {
    commands = { "SpellLCheck", "SpellCheck" },
    keys = { { "n", "qs" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-SpellCheck",
    url = "https://github.com/inkarkat/vim-SpellCheck"
  },
  ["vim-asterisk"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-asterisk",
    url = "https://github.com/haya14busa/vim-asterisk"
  },
  ["vim-caser"] = {
    config = { "require('plugs.config').caser()" },
    keys = { { "n", "crm" }, { "n", "crp" }, { "n", "crc" }, { "n", "crt" }, { "n", "cr<Space>" }, { "n", "cr-" }, { "n", "crk" }, { "n", "crK" }, { "n", "cr." }, { "n", "cr_" }, { "n", "crU" }, { "n", "cru" }, { "n", "crl" }, { "n", "crs" }, { "n", "crd" }, { "n", "crS" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-caser",
    url = "https://github.com/arthurxavierx/vim-caser"
  },
  ["vim-ccls"] = {
    config = { "require('plugs.config').ccls()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-ccls",
    url = "https://github.com/m-pilia/vim-ccls"
  },
  ["vim-easy-align"] = {
    commands = { "EasyAlign", "LiveEasyAlign" },
    config = { "require('plugs.easy-align')" },
    keys = { { "n", "ga" }, { "x", "ga" }, { "x", "<Leader>ga" }, { "x", "<Leader>gi" }, { "x", "<Leader>gs" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-easy-align",
    url = "https://github.com/junegunn/vim-easy-align"
  },
  ["vim-eunuch"] = {
    commands = { "Remove", "Delete", "Move", "Chmod", "Mkdir", "Cfind", "Clocate", "Lfind", "Llocate", "Wall", "SudoWrite", "SudoEdit" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-eunuch",
    url = "https://github.com/tpope/vim-eunuch"
  },
  ["vim-floaterm"] = {
    config = { "require('plugs.neoterm').floaterm()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-floaterm",
    url = "https://github.com/voldikss/vim-floaterm"
  },
  ["vim-flog"] = {
    commands = { "Flog", "Flogsplit" },
    config = { "require('plugs.flog')" },
    keys = { { "n", "<Leader>gl" }, { "n", "<Leader>gg" }, { "n", "<Leader>gi" }, { "n", "<Leader>yl" }, { "n", "<Leader>yL" }, { "n", "<Leader>yi" }, { "n", "<Leader>yI" }, { "x", "<Leader>gl" }, { "x", "<Leader>gL" } },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-flog",
    url = "https://github.com/rbong/vim-flog",
    wants = { "vim-fugitive" }
  },
  ["vim-fugitive"] = {
    commands = { "0Git", "G", "GBrowse", "Gcd", "Gclog", "GDelete", "Gdiffsplit", "Gedit", "Ggrep", "Ghdiffsplit", "Git", "Glcd", "Glgrep", "Gllog", "GMove", "Gpedit", "Gread", "GRemove", "GRename", "Gsplit", "Gtabedit", "GUnlink", "Gvdiffsplit", "Gvsplit", "Gwq", "Gwrite" },
    config = { "require('plugs.fugitive')" },
    keys = { { "n", "<LocalLeader>gg" }, { "n", "<LocalLeader>gG" }, { "n", "<LocalLeader>ge" }, { "n", "<LocalLeader>gR" }, { "n", "<LocalLeader>gB" }, { "n", "<LocalLeader>gw" }, { "n", "<LocalLeader>gW" }, { "n", "<LocalLeader>gr" }, { "n", "<LocalLeader>gf" }, { "n", "<LocalLeader>gF" }, { "n", "<LocalLeader>gs" }, { "n", "<LocalLeader>gn" }, { "n", "<LocalLeader>gc" }, { "n", "<LocalLeader>ga" }, { "n", "<LocalLeader>gT" }, { "n", "<LocalLeader>gp" }, { "n", "<LocalLeader>gh" }, { "x", "<LocalLeader>gh" }, { "n", "<LocalLeader>gH" }, { "n", "<LocalLeader>gl" }, { "n", "<LocalLeader>gL" }, { "n", "<LocalLeader>gz" }, { "n", "<LocalLeader>gZ" } },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-gh-line"] = {
    config = { "require('plugs.git').ghline()" },
    keys = { { "n", "<Leader>go" }, { "n", "<Leader>gL" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-gh-line",
    url = "https://github.com/ruanyl/vim-gh-line"
  },
  ["vim-gnupg"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-gnupg",
    url = "https://github.com/jamessan/vim-gnupg"
  },
  ["vim-go"] = {
    config = { "require('plugs.ft.go')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go",
    url = "https://github.com/fatih/vim-go"
  },
  ["vim-grepper"] = {
    commands = { "Grepper", "GrepperRg", "Grep", "LGrep", "GrepBuf", "LGrepBuf", "GrepBufs", "LGrepBufs" },
    config = { "require('plugs.config').grepper()" },
    keys = { { "n", "gs" }, { "x", "gs" }, { "n", "<Leader>rg" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-grepper",
    url = "https://github.com/mhinz/vim-grepper"
  },
  ["vim-gutentags"] = {
    after = { "vista.vim" },
    config = { "require('plugs.gutentags')" },
    loaded = true,
    only_config = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-gutentags",
    url = "https://github.com/ludovicchabant/vim-gutentags"
  },
  ["vim-ingo-library"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-ingo-library",
    url = "https://github.com/inkarkat/vim-ingo-library"
  },
  ["vim-just"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just",
    url = "https://github.com/NoahTheDuke/vim-just"
  },
  ["vim-matchup"] = {
    after_files = { "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-matchup/after/plugin/matchit.vim" },
    config = { "require('plugs.config').matchup()" },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-matchup",
    url = "https://github.com/andymass/vim-matchup"
  },
  ["vim-office"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-office",
    url = "https://github.com/Konfekt/vim-office"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-repeat",
    url = "https://github.com/tpope/vim-repeat"
  },
  ["vim-rhubarb"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-rhubarb",
    url = "https://github.com/tpope/vim-rhubarb"
  },
  ["vim-rustpeg"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg",
    url = "https://github.com/rhysd/vim-rustpeg"
  },
  ["vim-sandwich"] = {
    config = { "require('plugs.textobj').sandwich()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-sandwich",
    url = "https://github.com/machakann/vim-sandwich"
  },
  ["vim-scriptease"] = {
    commands = { "Scriptnames", "Messages", "Runtime", "Disarm", "Verbose", "Vedit", "Vopen", "Vread", "Vsplit", "Vvsplit", "Vtabedit", "Time", "PPmsg" },
    config = { "require('plugs.config').scriptease()" },
    keys = { { "n", "<Leader>nk" }, { "n", "<Leader>nr" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-scriptease",
    url = "https://github.com/tpope/vim-scriptease"
  },
  ["vim-snippets"] = {
    after = { "ultisnips" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-snippets",
    url = "https://github.com/honza/vim-snippets"
  },
  ["vim-startuptime"] = {
    commands = { "StartupTime" },
    config = { "\27LJ\2\n|\0\0\2\0\5\0\t6\0\0\0009\0\1\0)\1\15\0=\1\2\0006\0\0\0009\0\1\0005\1\4\0=\1\3\0K\0\1\0\1\2\0\0$+let g:auto_session_enabled = 0\25startuptime_exe_args\22startuptime_tries\6g\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-startuptime",
    url = "https://github.com/dstein64/vim-startuptime"
  },
  ["vim-table-mode"] = {
    config = { "require('plugs.ft.markdown').table_mode()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-table-mode",
    url = "https://github.com/dhruvasagar/vim-table-mode"
  },
  ["vim-taskwarrior"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-taskwarrior",
    url = "https://github.com/blindFS/vim-taskwarrior"
  },
  ["vim-teal"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-teal",
    url = "https://github.com/teal-language/vim-teal"
  },
  ["vim-textobj-comment"] = {
    config = { "require('plugs.textobj').comment()" },
    keys = { { "o", "iC" }, { "x", "iC" }, { "o", "aC" }, { "x", "aC" }, { "o", "aM" }, { "x", "aM" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-textobj-comment",
    url = "https://github.com/glts/vim-textobj-comment"
  },
  ["vim-textobj-lastpat"] = {
    keys = { { "o", "i/" }, { "x", "i/" }, { "o", "a/" }, { "x", "a/" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-textobj-lastpat",
    url = "https://github.com/kana/vim-textobj-lastpat"
  },
  ["vim-textobj-user"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-textobj-user",
    url = "https://github.com/kana/vim-textobj-user"
  },
  ["vim-visual-multi"] = {
    commands = { "VMSearch" },
    config = { "require('plugs.vm')" },
    keys = { { "n", "<C-n>" }, { "x", "<C-n>" }, { "n", "<C-S-Up>" }, { "n", "<C-S-Down>" }, { "n", "<M-S-i>" }, { "n", "<M-S-o>" }, { "n", "<C-M-S-Right>" }, { "n", "<C-M-S-Left>" }, { "n", "<Leader>\\" }, { "n", "<Leader>/" }, { "x", "<Leader>/" }, { "n", "<Leader>A" }, { "x", "<Leader>A" }, { "x", ";A" }, { "x", ";a" }, { "x", ";F" }, { "x", ";C" }, { "n", "<Leader>gs" }, { "n", "g/" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-visual-multi",
    url = "https://github.com/mg979/vim-visual-multi",
    wants = { "nvim-hlslens", "nvim-autopairs" }
  },
  ["vim-xxdcursor"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-xxdcursor",
    url = "https://github.com/mattn/vim-xxdcursor"
  },
  vimtex = {
    config = { "require('plugs.ft.vimtex')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex",
    url = "https://github.com/lervag/vimtex"
  },
  vimwiki = {
    load_after = {},
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vimwiki",
    url = "https://github.com/vimwiki/vimwiki"
  },
  vinfo = {
    commands = { "Vinfo", "VinfoClean", "VinfoNext", "VinfoPrevious" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vinfo",
    url = "https://github.com/alx741/vinfo"
  },
  ["virtcolumn.nvim"] = {
    config = { "require('plugs.config').virtcolumn()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/virtcolumn.nvim",
    url = "https://github.com/xiyaowong/virtcolumn.nvim"
  },
  ["vista.vim"] = {
    config = { "require('plugs.vista')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vista.vim",
    url = "https://github.com/liuchengxu/vista.vim"
  },
  ["which-key.nvim"] = {
    config = { "require('plugs.which-key')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/which-key.nvim",
    url = "https://github.com/folke/which-key.nvim"
  },
  ["wilder.nvim"] = {
    config = { "require('plugs.wilder').init()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/wilder.nvim",
    url = "https://github.com/gelguy/wilder.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: vimwiki
time([[Setup for vimwiki]], true)
require("plugs.ft.markdown").vimwiki_setup()
time([[Setup for vimwiki]], false)
-- Setup for: vim-gh-line
time([[Setup for vim-gh-line]], true)
vim.g.gh_line_blame_map_default = 0
time([[Setup for vim-gh-line]], false)
-- Setup for: vim-textobj-comment
time([[Setup for vim-textobj-comment]], true)
vim.g.loaded_textobj_comment = 1
time([[Setup for vim-textobj-comment]], false)
-- Setup for: packer.nvim
time([[Setup for packer.nvim]], true)
try_loadstring("\27LJ\2\n-\0\0\2\0\2\0\0046\0\0\0009\0\1\0B\0\1\1K\0\1\0\23vm#plugs#permanent\afnT\1\0\3\0\5\1\n6\0\0\0009\0\1\0009\0\2\0\t\0\0\0X\0\4�6\0\0\0009\0\3\0003\2\4\0B\0\2\1K\0\1\0\0\rschedule\24loaded_visual_multi\6g\bvim\2\0", "setup", "packer.nvim")
time([[Setup for packer.nvim]], false)
-- Setup for: vim-caser
time([[Setup for vim-caser]], true)
vim.g.caser_prefix = "cr"
time([[Setup for vim-caser]], false)
-- Setup for: eregex.vim
time([[Setup for eregex.vim]], true)
vim.g.eregex_default_enable = 0
time([[Setup for eregex.vim]], false)
-- Setup for: vim-visual-multi
time([[Setup for vim-visual-multi]], true)
vim.g.VM_leader = '<Space>'
time([[Setup for vim-visual-multi]], false)
-- Setup for: info.vim
time([[Setup for info.vim]], true)
vim.g.infoprg = "/usr/bin/info"
time([[Setup for info.vim]], false)
time([[packadd for info.vim]], true)
vim.cmd [[packadd info.vim]]
time([[packadd for info.vim]], false)
-- Setup for: wilder.nvim
time([[Setup for wilder.nvim]], true)
require('plugs.wilder').autocmd()
time([[Setup for wilder.nvim]], false)
-- Setup for: desktop-notify.nvim
time([[Setup for desktop-notify.nvim]], true)
pcall(vim.cmd, 'delcommand Notifications')
time([[Setup for desktop-notify.nvim]], false)
time([[packadd for desktop-notify.nvim]], true)
vim.cmd [[packadd desktop-notify.nvim]]
time([[packadd for desktop-notify.nvim]], false)
-- Config for: listish.nvim
time([[Config for listish.nvim]], true)
require('plugs.config').listish()
time([[Config for listish.nvim]], false)
-- Config for: nvim-fundo
time([[Config for nvim-fundo]], true)
require('plugs.config').fundo()
time([[Config for nvim-fundo]], false)
-- Config for: flatten.nvim
time([[Config for flatten.nvim]], true)
require('plugs.neoterm').flatten()
time([[Config for flatten.nvim]], false)
-- Config for: vim-gutentags
time([[Config for vim-gutentags]], true)
require('plugs.gutentags')
time([[Config for vim-gutentags]], false)
-- Config for: registers.nvim
time([[Config for registers.nvim]], true)
require('plugs.config').registers()
time([[Config for registers.nvim]], false)
-- Config for: oil.nvim
time([[Config for oil.nvim]], true)
require('plugs.oil')
time([[Config for oil.nvim]], false)
-- Config for: desktop-notify.nvim
time([[Config for desktop-notify.nvim]], true)
vim.cmd('command! Notifications :lua require("notify")._print_history()<CR>')
time([[Config for desktop-notify.nvim]], false)
-- Config for: link-visitor.nvim
time([[Config for link-visitor.nvim]], true)
require('plugs.config').link_visitor()
time([[Config for link-visitor.nvim]], false)
-- Config for: toggleterm.nvim
time([[Config for toggleterm.nvim]], true)
require('plugs.neoterm')
time([[Config for toggleterm.nvim]], false)
-- Config for: vim-sandwich
time([[Config for vim-sandwich]], true)
require('plugs.textobj').sandwich()
time([[Config for vim-sandwich]], false)
-- Config for: lf.vim
time([[Config for lf.vim]], true)
require('plugs.config').lf()
time([[Config for lf.vim]], false)
-- Config for: neoformat
time([[Config for neoformat]], true)
require('plugs.format')
time([[Config for neoformat]], false)
-- Config for: nvim-autopairs
time([[Config for nvim-autopairs]], true)
require('plugs.autopairs')
time([[Config for nvim-autopairs]], false)
-- Config for: kimbox
time([[Config for kimbox]], true)
require('plugs.kimbox')
time([[Config for kimbox]], false)
-- Config for: nvim-various-textobjs
time([[Config for nvim-various-textobjs]], true)
require('plugs.textobj').various_textobjs()
time([[Config for nvim-various-textobjs]], false)
-- Config for: vim-floaterm
time([[Config for vim-floaterm]], true)
require('plugs.neoterm').floaterm()
time([[Config for vim-floaterm]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
require('plugs.gitsigns')
time([[Config for gitsigns.nvim]], false)
-- Config for: which-key.nvim
time([[Config for which-key.nvim]], true)
require('plugs.which-key')
time([[Config for which-key.nvim]], false)
-- Config for: fzf-lua
time([[Config for fzf-lua]], true)
require('plugs.fzf-lua')
time([[Config for fzf-lua]], false)
-- Config for: nvim-colorizer.lua
time([[Config for nvim-colorizer.lua]], true)
require('plugs.config').colorizer()
time([[Config for nvim-colorizer.lua]], false)
-- Config for: git-conflict.nvim
time([[Config for git-conflict.nvim]], true)
require('plugs.git').git_conflict()
time([[Config for git-conflict.nvim]], false)
-- Config for: nvim-hlslens
time([[Config for nvim-hlslens]], true)
require('plugs.config').hlslens()
time([[Config for nvim-hlslens]], false)
-- Config for: nvim-web-devicons
time([[Config for nvim-web-devicons]], true)
require('plugs.config').devicons()
time([[Config for nvim-web-devicons]], false)
-- Config for: neogit
time([[Config for neogit]], true)
require('plugs.neogit')
time([[Config for neogit]], false)
-- Config for: fzf.vim
time([[Config for fzf.vim]], true)
require('plugs.fzf')
time([[Config for fzf.vim]], false)
-- Config for: tmux.nvim
time([[Config for tmux.nvim]], true)
require('plugs.config').tmux()
time([[Config for tmux.nvim]], false)
-- Config for: targets.vim
time([[Config for targets.vim]], true)
require('plugs.textobj').targets()
time([[Config for targets.vim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd coc.nvim ]]
vim.cmd [[ packadd coc-fzf ]]
vim.cmd [[ packadd coc-code-action-menu ]]
vim.cmd [[ packadd coc-kvs ]]
vim.cmd [[ packadd vim-snippets ]]
vim.cmd [[ packadd ultisnips ]]

-- Config for: ultisnips
require('plugs.config').ultisnips()

vim.cmd [[ packadd plenary.nvim ]]
vim.cmd [[ packadd sqlite.lua ]]
vim.cmd [[ packadd specs.nvim ]]

-- Config for: specs.nvim
require('plugs.config').specs()

vim.cmd [[ packadd lf.nvim ]]

-- Config for: lf.nvim
require('plugs.config').lfnvim()

vim.cmd [[ packadd mkdx ]]

-- Config for: mkdx
vim.cmd(("source %s/plugins/mkdx.vim"):format(Rc.dirs.my.vimscript))

vim.cmd [[ packadd popup.nvim ]]
vim.cmd [[ packadd telescope.nvim ]]

-- Config for: telescope.nvim
require('plugs.telescope')

vim.cmd [[ packadd nvim-notify ]]

-- Config for: nvim-notify
require('plugs.notify')

vim.cmd [[ packadd todo-comments.nvim ]]

-- Config for: todo-comments.nvim
require('plugs.todo-comments')

vim.cmd [[ packadd telescope-file-browser.nvim ]]

-- Config for: telescope-file-browser.nvim
require("telescope").load_extension("file_browser")

vim.cmd [[ packadd urlview.nvim ]]

-- Config for: urlview.nvim
require('plugs.config').urlview()

vim.cmd [[ packadd telescope-ultisnips.nvim ]]

-- Config for: telescope-ultisnips.nvim
require("telescope").load_extension("ultisnips")

vim.cmd [[ packadd telescope-coc.nvim ]]

-- Config for: telescope-coc.nvim
require("telescope").load_extension("coc")

vim.cmd [[ packadd telescope-smart-history.nvim ]]

-- Config for: telescope-smart-history.nvim
require("telescope").load_extension("smart_history")

vim.cmd [[ packadd telescope-zoxide ]]

-- Config for: telescope-zoxide
require("telescope").load_extension("zoxide")

vim.cmd [[ packadd telescope-hop.nvim ]]

-- Config for: telescope-hop.nvim
require("telescope").load_extension("hop")

vim.cmd [[ packadd telescope-ghq.nvim ]]

-- Config for: telescope-ghq.nvim
require("telescope").load_extension("ghq")

vim.cmd [[ packadd telescope-fzf-native.nvim ]]

-- Config for: telescope-fzf-native.nvim
require("telescope").load_extension("fzf")

vim.cmd [[ packadd telescope-frecency.nvim ]]

-- Config for: telescope-frecency.nvim
require("telescope").load_extension("frecency")

vim.cmd [[ packadd telescope-bookmarks.nvim ]]

-- Config for: telescope-bookmarks.nvim
require("telescope").load_extension("bookmarks")

vim.cmd [[ packadd project.nvim ]]

-- Config for: project.nvim
require('plugs.git').project()

vim.cmd [[ packadd telescope-rualdi.nvim ]]

-- Config for: telescope-rualdi.nvim
require("telescope").load_extension("rualdi")

vim.cmd [[ packadd nvim-neoclip.lua ]]
vim.cmd [[ packadd vista.vim ]]

-- Config for: vista.vim
require('plugs.vista')

vim.cmd [[ packadd nvim-treesitter ]]
vim.cmd [[ packadd Comment.nvim ]]

-- Config for: Comment.nvim
require('plugs.comment')

vim.cmd [[ packadd nvim-gps ]]
vim.cmd [[ packadd nvim_context_vt ]]
vim.cmd [[ packadd vim-matchup ]]

-- Config for: vim-matchup
require('plugs.config').matchup()

vim.cmd [[ packadd treesitter-unit ]]
vim.cmd [[ packadd hlargs.nvim ]]
vim.cmd [[ packadd nvim-treesitter-refactor ]]
vim.cmd [[ packadd nvim-treesitter-textobjects ]]
vim.cmd [[ packadd nvim-ts-context-commentstring ]]
vim.cmd [[ packadd rainbow-delimiters.nvim ]]

-- Config for: rainbow-delimiters.nvim
require('plugs.treesitter').setup_rainbow()

time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.api.nvim_create_user_command, 'Vtabedit', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Vtabedit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Vtabedit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerOpen', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerOpen', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerOpen ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerDeleteBundle', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerDeleteBundle', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerDeleteBundle ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'STSSelectMasterNode', function(cmdargs)
          require('packer.load')({'syntax-tree-surfer'}, { cmd = 'STSSelectMasterNode', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'syntax-tree-surfer'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('STSSelectMasterNode ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gread', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gread', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gread ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Time', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Time', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Time ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Wall', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Wall', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Wall ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'STSJumpToTop', function(cmdargs)
          require('packer.load')({'syntax-tree-surfer'}, { cmd = 'STSJumpToTop', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'syntax-tree-surfer'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('STSJumpToTop ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gdiffsplit', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gdiffsplit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gdiffsplit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'STSSelectChildNode', function(cmdargs)
          require('packer.load')({'syntax-tree-surfer'}, { cmd = 'STSSelectChildNode', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'syntax-tree-surfer'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('STSSelectChildNode ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Grepper', function(cmdargs)
          require('packer.load')({'vim-grepper'}, { cmd = 'Grepper', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-grepper'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Grepper ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'HelpfulVersion', function(cmdargs)
          require('packer.load')({'helpful.vim'}, { cmd = 'HelpfulVersion', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'helpful.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('HelpfulVersion ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'SpellLCheck', function(cmdargs)
          require('packer.load')({'vim-SpellCheck'}, { cmd = 'SpellLCheck', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-SpellCheck'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('SpellLCheck ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'STSSelectParentNode', function(cmdargs)
          require('packer.load')({'syntax-tree-surfer'}, { cmd = 'STSSelectParentNode', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'syntax-tree-surfer'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('STSSelectParentNode ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Debug', function(cmdargs)
          require('packer.load')({'nvim-dap'}, { cmd = 'Debug', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nvim-dap'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Debug ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Messages', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Messages', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Messages ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gedit', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gedit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gedit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'STSSwapPrevVisual', function(cmdargs)
          require('packer.load')({'syntax-tree-surfer'}, { cmd = 'STSSwapPrevVisual', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'syntax-tree-surfer'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('STSSwapPrevVisual ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Remove', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Remove', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Remove ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'GrepperRg', function(cmdargs)
          require('packer.load')({'vim-grepper'}, { cmd = 'GrepperRg', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-grepper'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('GrepperRg ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, '0Git', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = '0Git', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('0Git ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'SudoEdit', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'SudoEdit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('SudoEdit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'GrepBufs', function(cmdargs)
          require('packer.load')({'vim-grepper'}, { cmd = 'GrepBufs', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-grepper'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('GrepBufs ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Runtime', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Runtime', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Runtime ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'LiveEasyAlign', function(cmdargs)
          require('packer.load')({'vim-easy-align'}, { cmd = 'LiveEasyAlign', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-easy-align'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('LiveEasyAlign ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DapREPL', function(cmdargs)
          require('packer.load')({'nvim-dap'}, { cmd = 'DapREPL', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nvim-dap'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DapREPL ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'VinfoClean', function(cmdargs)
          require('packer.load')({'vinfo'}, { cmd = 'VinfoClean', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vinfo'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('VinfoClean ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'GrepBuf', function(cmdargs)
          require('packer.load')({'vim-grepper'}, { cmd = 'GrepBuf', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-grepper'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('GrepBuf ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerClose', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerClose', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerClose ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Neogen', function(cmdargs)
          require('packer.load')({'neogen'}, { cmd = 'Neogen', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'neogen'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Neogen ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Bufferize', function(cmdargs)
          require('packer.load')({'bufferize.vim'}, { cmd = 'Bufferize', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'bufferize.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Bufferize ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Disarm', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Disarm', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Disarm ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'STSSwapNextVisual', function(cmdargs)
          require('packer.load')({'syntax-tree-surfer'}, { cmd = 'STSSwapNextVisual', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'syntax-tree-surfer'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('STSSwapNextVisual ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Flogsplit', function(cmdargs)
          require('packer.load')({'vim-flog'}, { cmd = 'Flogsplit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-flog'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Flogsplit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerRun', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerRun', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerRun ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'help', function(cmdargs)
          require('packer.load')({'luv-vimdocs', 'nvim-luaref'}, { cmd = 'help', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'luv-vimdocs', 'nvim-luaref'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('help ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerRunCmd', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerRunCmd', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerRunCmd ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'SudaWrite', function(cmdargs)
          require('packer.load')({'suda.vim'}, { cmd = 'SudaWrite', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'suda.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('SudaWrite ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'SudaRead', function(cmdargs)
          require('packer.load')({'suda.vim'}, { cmd = 'SudaRead', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'suda.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('SudaRead ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DiffviewToggleFiles', function(cmdargs)
          require('packer.load')({'diffview.nvim'}, { cmd = 'DiffviewToggleFiles', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'diffview.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DiffviewToggleFiles ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DiffviewRefresh', function(cmdargs)
          require('packer.load')({'diffview.nvim'}, { cmd = 'DiffviewRefresh', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'diffview.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DiffviewRefresh ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Mkdir', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Mkdir', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Mkdir ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'M', function(cmdargs)
          require('packer.load')({'eregex.vim'}, { cmd = 'M', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'eregex.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('M ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DiffviewLog', function(cmdargs)
          require('packer.load')({'diffview.nvim'}, { cmd = 'DiffviewLog', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'diffview.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DiffviewLog ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DiffviewFocusFiles', function(cmdargs)
          require('packer.load')({'diffview.nvim'}, { cmd = 'DiffviewFocusFiles', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'diffview.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DiffviewFocusFiles ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Glgrep', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Glgrep', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Glgrep ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DiffviewClose', function(cmdargs)
          require('packer.load')({'diffview.nvim'}, { cmd = 'DiffviewClose', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'diffview.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DiffviewClose ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'LGrep', function(cmdargs)
          require('packer.load')({'vim-grepper'}, { cmd = 'LGrep', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-grepper'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('LGrep ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Grep', function(cmdargs)
          require('packer.load')({'vim-grepper'}, { cmd = 'Grep', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-grepper'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Grep ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'V', function(cmdargs)
          require('packer.load')({'eregex.vim'}, { cmd = 'V', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'eregex.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('V ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Linediff', function(cmdargs)
          require('packer.load')({'linediff.vim'}, { cmd = 'Linediff', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'linediff.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Linediff ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Sort', function(cmdargs)
          require('packer.load')({'sort.nvim'}, { cmd = 'Sort', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'sort.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Sort ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'PP', function(cmdargs)
          require('packer.load')({'paperplanes.nvim'}, { cmd = 'PP', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'paperplanes.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('PP ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'SudoWrite', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'SudoWrite', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('SudoWrite ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Llocate', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Llocate', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Llocate ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'VinfoNext', function(cmdargs)
          require('packer.load')({'vinfo'}, { cmd = 'VinfoNext', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vinfo'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('VinfoNext ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'GMove', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'GMove', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('GMove ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Git', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Git', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Git ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'G', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'G', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('G ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gpedit', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gpedit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gpedit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DiffviewOpen', function(cmdargs)
          require('packer.load')({'diffview.nvim'}, { cmd = 'DiffviewOpen', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'diffview.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DiffviewOpen ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'S', function(cmdargs)
          require('packer.load')({'eregex.vim'}, { cmd = 'S', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'eregex.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('S ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gvsplit', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gvsplit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gvsplit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerQuickAction', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerQuickAction', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerQuickAction ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'NerdIcons', function(cmdargs)
          require('packer.load')({'nerdicons.nvim'}, { cmd = 'NerdIcons', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nerdicons.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('NerdIcons ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Chmod', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Chmod', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Chmod ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Move', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Move', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Move ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Glcd', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Glcd', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Glcd ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'LGrepBuf', function(cmdargs)
          require('packer.load')({'vim-grepper'}, { cmd = 'LGrepBuf', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-grepper'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('LGrepBuf ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gwq', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gwq', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gwq ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Luapad', function(cmdargs)
          require('packer.load')({'nvim-luapad'}, { cmd = 'Luapad', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nvim-luapad'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Luapad ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DapLaunch', function(cmdargs)
          require('packer.load')({'nvim-dap'}, { cmd = 'DapLaunch', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nvim-dap'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DapLaunch ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Delete', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Delete', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Delete ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gwrite', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gwrite', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gwrite ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Verbose', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Verbose', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Verbose ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'VinfoPrevious', function(cmdargs)
          require('packer.load')({'vinfo'}, { cmd = 'VinfoPrevious', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vinfo'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('VinfoPrevious ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gsplit', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gsplit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gsplit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'ScratchPad', function(cmdargs)
          require('packer.load')({'ScratchPad'}, { cmd = 'ScratchPad', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'ScratchPad'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('ScratchPad ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gvdiffsplit', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gvdiffsplit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gvdiffsplit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Vedit', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Vedit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Vedit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Ggrep', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Ggrep', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Ggrep ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'STSSelectNextSiblingNode', function(cmdargs)
          require('packer.load')({'syntax-tree-surfer'}, { cmd = 'STSSelectNextSiblingNode', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'syntax-tree-surfer'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('STSSelectNextSiblingNode ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gtabedit', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gtabedit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gtabedit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'LuaRun', function(cmdargs)
          require('packer.load')({'nvim-luapad'}, { cmd = 'LuaRun', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nvim-luapad'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('LuaRun ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerLoadBundle', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerLoadBundle', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerLoadBundle ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gllog', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gllog', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gllog ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'VMSearch', function(cmdargs)
          require('packer.load')({'vim-visual-multi'}, { cmd = 'VMSearch', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-visual-multi'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('VMSearch ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'EasyAlign', function(cmdargs)
          require('packer.load')({'vim-easy-align'}, { cmd = 'EasyAlign', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-easy-align'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('EasyAlign ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'GRename', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'GRename', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('GRename ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'GUnlink', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'GUnlink', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('GUnlink ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Vread', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Vread', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Vread ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerToggle', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerToggle', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerToggle ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Clocate', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Clocate', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Clocate ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gcd', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gcd', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gcd ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DiffviewFileHistory', function(cmdargs)
          require('packer.load')({'diffview.nvim'}, { cmd = 'DiffviewFileHistory', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'diffview.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DiffviewFileHistory ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'STSSelectCurrentNode', function(cmdargs)
          require('packer.load')({'syntax-tree-surfer'}, { cmd = 'STSSelectCurrentNode', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'syntax-tree-surfer'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('STSSelectCurrentNode ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Ghdiffsplit', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Ghdiffsplit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Ghdiffsplit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'CodiumEnable', function(cmdargs)
          require('packer.load')({'codeium.vim'}, { cmd = 'CodiumEnable', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'codeium.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('CodiumEnable ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Vsplit', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Vsplit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Vsplit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'GRemove', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'GRemove', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('GRemove ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerTaskAction', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerTaskAction', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerTaskAction ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Gclog', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'Gclog', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Gclog ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'GBrowse', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'GBrowse', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('GBrowse ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'UndoTreeToggle', function(cmdargs)
          require('packer.load')({'undotree'}, { cmd = 'UndoTreeToggle', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'undotree'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('UndoTreeToggle ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Cfind', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Cfind', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Cfind ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Flog', function(cmdargs)
          require('packer.load')({'vim-flog'}, { cmd = 'Flog', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-flog'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Flog ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Scriptnames', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Scriptnames', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Scriptnames ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Vvsplit', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Vvsplit', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Vvsplit ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Ov', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'Ov', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Ov ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'DapRun', function(cmdargs)
          require('packer.load')({'nvim-dap'}, { cmd = 'DapRun', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nvim-dap'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('DapRun ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Vinfo', function(cmdargs)
          require('packer.load')({'vinfo'}, { cmd = 'Vinfo', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vinfo'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Vinfo ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'E2v', function(cmdargs)
          require('packer.load')({'eregex.vim'}, { cmd = 'E2v', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'eregex.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('E2v ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerSaveBundle', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerSaveBundle', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerSaveBundle ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'GDelete', function(cmdargs)
          require('packer.load')({'vim-fugitive'}, { cmd = 'GDelete', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-fugitive'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('GDelete ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Vopen', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'Vopen', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Vopen ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'LGrepBufs', function(cmdargs)
          require('packer.load')({'vim-grepper'}, { cmd = 'LGrepBufs', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-grepper'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('LGrepBufs ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'PPmsg', function(cmdargs)
          require('packer.load')({'vim-scriptease'}, { cmd = 'PPmsg', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-scriptease'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('PPmsg ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'StartupTime', function(cmdargs)
          require('packer.load')({'vim-startuptime'}, { cmd = 'StartupTime', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-startuptime'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('StartupTime ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Lfind', function(cmdargs)
          require('packer.load')({'vim-eunuch'}, { cmd = 'Lfind', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-eunuch'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Lfind ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'SpellCheck', function(cmdargs)
          require('packer.load')({'vim-SpellCheck'}, { cmd = 'SpellCheck', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'vim-SpellCheck'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('SpellCheck ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'STSSelectPrevSiblingNode', function(cmdargs)
          require('packer.load')({'syntax-tree-surfer'}, { cmd = 'STSSelectPrevSiblingNode', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'syntax-tree-surfer'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('STSSelectPrevSiblingNode ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'Codium', function(cmdargs)
          require('packer.load')({'codeium.vim'}, { cmd = 'Codium', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'codeium.vim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('Codium ', 'cmdline')
      end})
pcall(vim.api.nvim_create_user_command, 'OverseerBuild', function(cmdargs)
          require('packer.load')({'overseer.nvim'}, { cmd = 'OverseerBuild', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'overseer.nvim'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('OverseerBuild ', 'cmdline')
      end})
time([[Defining lazy-load commands]], false)

-- Keymap lazy-loads
vim.defer_fn(function()
time([[Defining lazy-load keymaps]], true)
pcall(vim.cmd, [[xnoremap <unique><silent> ga <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ga", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crm <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crm", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gn <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gn", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> cr. <cmd>lua require("packer.load")({'vim-caser'}, { keys = "cr.", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sS <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sS", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <M-S-o> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>M-S-o>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <C-A-]> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>C-A-]>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sf <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "sf", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>g; <cmd>lua require("packer.load")({'diffview.nvim'}, { keys = "<lt>Leader>g;", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sxx <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sxx", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <C-M--> <cmd>lua require("packer.load")({'codeium.vim'}, { keys = "<lt>C-M-->" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> vm <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "vm", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> aC <cmd>lua require("packer.load")({'vim-textobj-comment'}, { keys = "aC", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> F <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "F", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>df <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>df", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>bc <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>bc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <LocalLeader>gh <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gh", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-M-[> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>C-M-[>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>cc <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>cc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> su <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "su", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> ;C <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = ";C", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ut <cmd>lua require("packer.load")({'undotree'}, { keys = "<lt>Leader>ut", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gg <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gg", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>dg <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>dg", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>blc <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>blc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s] <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "s]", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sy <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "sy", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> cru <cmd>lua require("packer.load")({'vim-caser'}, { keys = "cru", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> vd <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "vd", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> aM <cmd>lua require("packer.load")({'vim-textobj-comment'}, { keys = "aM", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> t <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "t", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gr <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gr", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-Right> <cmd>lua require("packer.load")({'smart-splits.nvim'}, { keys = "<lt>C-Right>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crs <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s- <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "s-", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>A <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>A", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <C-n> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-n>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>bb <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>bb", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crt <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crt", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gJ <cmd>lua require("packer.load")({'treesj'}, { keys = "gJ", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <C-j> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>C-j>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gd <cmd>lua require("packer.load")({'diffview.nvim'}, { keys = "<lt>LocalLeader>gd", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s; <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "s;", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> X <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "X", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> i/ <cmd>lua require("packer.load")({'vim-textobj-lastpat'}, { keys = "i/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s/ <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "s/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>dR <cmd>lua require("packer.load")({'nvim-dap'}, { keys = "<lt>LocalLeader>dR", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> t <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "t", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> , <cmd>lua require("packer.load")({'hop.nvim'}, { keys = ",", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crl <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crl", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[vnoremap <unique><silent> g_ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "g_", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>dv <cmd>lua require("packer.load")({'nvim-dap'}, { keys = "<lt>LocalLeader>dv", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-n> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-n>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>ga <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>ga", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crc <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-M-S-Left> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-M-S-Left>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> st <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "st", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <C-k> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>C-k>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>yl <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>yl", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s, <cmd>lua require("packer.load")({'iswap.nvim'}, { keys = "s,", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> s <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "s", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sf <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sf", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ua <cmd>lua require("packer.load")({'overseer.nvim'}, { keys = "<lt>Leader>ua", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> aM <cmd>lua require("packer.load")({'vim-textobj-comment'}, { keys = "aM", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g/ <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "g/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>dt <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>dt", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>j <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>j", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <M-w> <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>M-w>" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>ld <cmd>lua require("packer.load")({'linediff.vim'}, { keys = "<lt>Leader>ld", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gl <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gl", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <M-S-y> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>M-S-y>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>u<CR> <cmd>lua require("packer.load")({'overseer.nvim'}, { keys = "<lt>Leader>u<lt>CR>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>/ <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> F <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "F", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s? <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "s?", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>ge <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>ge", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>dl <cmd>lua require("packer.load")({'nvim-dap'}, { keys = "<lt>LocalLeader>dl", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>blr <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>blr", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>dU <cmd>lua require("packer.load")({'nvim-dap'}, { keys = "<lt>LocalLeader>dU", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>bd <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>bd", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gi <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>gi", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gld <cmd>lua require("packer.load")({'linediff.vim'}, { keys = "gld", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g) <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "g)", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-Down> <cmd>lua require("packer.load")({'smart-splits.nvim'}, { keys = "<lt>C-Down>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>S <cmd>lua require("packer.load")({'eregex.vim'}, { keys = "<lt>Leader>S", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>J <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>J", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crS <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crS", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> + <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "+", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[vnoremap <unique><silent> + <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "+", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sT <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "sT", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>yL <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>yL", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sa <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sa", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gF <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gF", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> a/ <cmd>lua require("packer.load")({'vim-textobj-lastpat'}, { keys = "a/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ul <cmd>lua require("packer.load")({'overseer.nvim'}, { keys = "<lt>Leader>ul", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <C-M-'> <cmd>lua require("packer.load")({'codeium.vim'}, { keys = "<lt>C-M-'>" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gG <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gG", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ba <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>ba", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>dn <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>dn", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gz <cmd>lua require("packer.load")({'sort.nvim'}, { keys = "gz", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>yI <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>yI", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>bll <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>bll", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gs <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>gs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>bs <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>bs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gg <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>gg", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gK <cmd>lua require("packer.load")({'treesj'}, { keys = "gK", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gZ <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gZ", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>es <cmd>lua require("packer.load")({'eregex.vim'}, { keys = "<lt>Leader>es", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>k <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>k", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-S-:> <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>C-S-:>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ld <cmd>lua require("packer.load")({'linediff.vim'}, { keys = "<lt>Leader>ld", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> vs <cmd>lua require("packer.load")({'iswap.nvim'}, { keys = "vs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> si <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "si", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>A <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>A", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-S-Up> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-S-Up>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>uc <cmd>lua require("packer.load")({'overseer.nvim'}, { keys = "<lt>Leader>uc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> cr<Space> <cmd>lua require("packer.load")({'vim-caser'}, { keys = "cr<lt>Space>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <LocalLeader>gd <cmd>lua require("packer.load")({'diffview.nvim'}, { keys = "<lt>LocalLeader>gd", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>gi <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "<lt>Leader>gi", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <M-S-i> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>M-S-i>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>sc <cmd>lua require("packer.load")({'ScratchPad'}, { keys = "<lt>Leader>sc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>yi <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>yi", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gs <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> vU <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "vU", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crK <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crK", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <M-S-w> <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>M-S-w>" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>lD <cmd>lua require("packer.load")({'linediff.vim'}, { keys = "<lt>Leader>lD", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>dF <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>dF", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> T <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "T", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> gz <cmd>lua require("packer.load")({'sort.nvim'}, { keys = "gz", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s[ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "s[", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sx <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sx", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-S-<> <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>C-S-<lt>>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> vn <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "vn", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g\ <cmd>lua require("packer.load")({'treesj'}, { keys = "g\\", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>bR <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>bR", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gh <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gh", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-M-,> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>C-M-,>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>bA <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>bA", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g( <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "g(", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <M-S-u> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>M-S-u>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> f <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "f", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-S-Down> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-S-Down>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> cr_ <cmd>lua require("packer.load")({'vim-caser'}, { keys = "cr_", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[vnoremap <unique><silent> g+ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "g+", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> iC <cmd>lua require("packer.load")({'vim-textobj-comment'}, { keys = "iC", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gz <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gz", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crk <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crk", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <C-M-w> <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>C-M-w>" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> D <cmd>lua require("packer.load")({'linediff.vim'}, { keys = "D", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <M-\> <cmd>lua require("packer.load")({'codeium.vim'}, { keys = "<lt>M-\\>" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>uq <cmd>lua require("packer.load")({'overseer.nvim'}, { keys = "<lt>Leader>uq", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>uR <cmd>lua require("packer.load")({'overseer.nvim'}, { keys = "<lt>Leader>uR", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s= <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "s=", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> F <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "F", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gW <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gW", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> vD <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "vD", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <A-]> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>A-]>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gR <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gR", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>go <cmd>lua require("packer.load")({'vim-gh-line'}, { keys = "<lt>Leader>go", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gL <cmd>lua require("packer.load")({'vim-gh-line'}, { keys = "<lt>Leader>gL", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>br <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>br", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gp <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gp", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>be <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>be", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>K <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>K", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>gL <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>gL", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crU <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crU", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ct <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>ct", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>cn <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>cn", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g{ <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "g{", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sr <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sr", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> qs <cmd>lua require("packer.load")({'vim-SpellCheck'}, { keys = "qs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> f <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "f", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> T <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "T", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>sr <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "<lt>Leader>sr", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ss <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "ss", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>sL <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader>sL", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> ;F <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = ";F", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ca <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>ca", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> _ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "_", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ur <cmd>lua require("packer.load")({'overseer.nvim'}, { keys = "<lt>Leader>ur", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sl <cmd>lua require("packer.load")({'iswap.nvim'}, { keys = "sl", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[vnoremap <unique><silent> _ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "_", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> iC <cmd>lua require("packer.load")({'vim-textobj-comment'}, { keys = "iC", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> ;A <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = ";A", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ;a <cmd>lua require("packer.load")({'hop.nvim'}, { keys = ";a", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <C-A-[> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>C-A-[>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sv <cmd>lua require("packer.load")({'iswap.nvim'}, { keys = "sv", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ga <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ga", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gf <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gf", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ) <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = ")", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> a/ <cmd>lua require("packer.load")({'vim-textobj-lastpat'}, { keys = "a/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gB <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gB", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ub <cmd>lua require("packer.load")({'overseer.nvim'}, { keys = "<lt>Leader>ub", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>um <cmd>lua require("packer.load")({'overseer.nvim'}, { keys = "<lt>Leader>um", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s. <cmd>lua require("packer.load")({'iswap.nvim'}, { keys = "s.", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> vu <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "vu", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> i/ <cmd>lua require("packer.load")({'vim-textobj-lastpat'}, { keys = "i/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gw <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gw", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s' <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "s'", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ,/ <cmd>lua require("packer.load")({'eregex.vim'}, { keys = ",/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gL <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gL", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>dt <cmd>lua require("packer.load")({'nvim-dap'}, { keys = "<lt>LocalLeader>dt", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sh <cmd>lua require("packer.load")({'iswap.nvim'}, { keys = "sh", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> ;a <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = ";a", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>dr <cmd>lua require("packer.load")({'nvim-dap'}, { keys = "<lt>LocalLeader>dr", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>ga <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "<lt>Leader>ga", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>rg <cmd>lua require("packer.load")({'vim-grepper'}, { keys = "<lt>Leader>rg", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>\ <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>\\", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>dd <cmd>lua require("packer.load")({'nvim-dap'}, { keys = "<lt>LocalLeader>dd", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> cr- <cmd>lua require("packer.load")({'vim-caser'}, { keys = "cr-", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>gl <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>gl", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>nk <cmd>lua require("packer.load")({'vim-scriptease'}, { keys = "<lt>Leader>nk", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <M-[> <cmd>lua require("packer.load")({'codeium.vim'}, { keys = "<lt>M-[>" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>cT <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>cT", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gs <cmd>lua require("packer.load")({'vim-grepper'}, { keys = "gs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gc <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <A-[> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>A-[>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <M-g> <cmd>lua require("packer.load")({'codeium.vim'}, { keys = "<lt>M-g>" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crp <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crp", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <M-]> <cmd>lua require("packer.load")({'codeium.vim'}, { keys = "<lt>M-]>" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-M-S-Right> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-M-S-Right>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-Up> <cmd>lua require("packer.load")({'smart-splits.nvim'}, { keys = "<lt>C-Up>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> gs <cmd>lua require("packer.load")({'vim-grepper'}, { keys = "gs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sF <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "sF", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s` <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "s`", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>db <cmd>lua require("packer.load")({'nvim-dap'}, { keys = "<lt>LocalLeader>db", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>W <cmd>lua require("packer.load")({'suda.vim'}, { keys = "<lt>Leader>W", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> se <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "se", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sxc <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sxc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[inoremap <unique><silent> <C-M-=> <cmd>lua require("packer.load")({'codeium.vim'}, { keys = "<lt>C-M-=>" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> st <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "st", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>sH <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader>sH", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> v; <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "v;", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gl <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>gl", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> aC <cmd>lua require("packer.load")({'vim-textobj-comment'}, { keys = "aC", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>/ <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ( <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "(", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>nr <cmd>lua require("packer.load")({'vim-scriptease'}, { keys = "<lt>Leader>nr", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>dc <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>dc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>dc <cmd>lua require("packer.load")({'nvim-dap'}, { keys = "<lt>LocalLeader>dc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g} <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "g}", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-Left> <cmd>lua require("packer.load")({'smart-splits.nvim'}, { keys = "<lt>C-Left>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> crd <cmd>lua require("packer.load")({'vim-caser'}, { keys = "crd", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s~ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "s~", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ce <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>ce", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gH <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gH", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <LocalLeader>gT <cmd>lua require("packer.load")({'vim-fugitive'}, { keys = "<lt>LocalLeader>gT", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sd <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "sd", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-M-]> <cmd>lua require("packer.load")({'syntax-tree-surfer'}, { keys = "<lt>C-M-]>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>cb <cmd>lua require("packer.load")({'comment-box.nvim'}, { keys = "<lt>Leader>cb", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> f <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "f", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>gs <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "<lt>Leader>gs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s" <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "s\"", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> t <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "t", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> T <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "T", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> so <cmd>lua require("packer.load")({'iswap.nvim'}, { keys = "so", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>g. <cmd>lua require("packer.load")({'diffview.nvim'}, { keys = "<lt>Leader>g.", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gh <cmd>lua require("packer.load")({'diffview.nvim'}, { keys = "<lt>Leader>gh", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sc <cmd>lua require("packer.load")({'iswap.nvim'}, { keys = "sc", prefix = "" }, _G.packer_plugins)<cr>]])
time([[Defining lazy-load keymaps]], false)
end, 15)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType teal ++once lua require("packer.load")({'vim-teal'}, { ft = "teal" }, _G.packer_plugins)]]
vim.cmd [[au FileType xml ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "xml" }, _G.packer_plugins)]]
vim.cmd [[au FileType c ++once lua require("packer.load")({'vim-ccls'}, { ft = "c" }, _G.packer_plugins)]]
vim.cmd [[au FileType javascriptreact ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "javascriptreact" }, _G.packer_plugins)]]
vim.cmd [[au FileType typescriptreact ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "typescriptreact" }, _G.packer_plugins)]]
vim.cmd [[au FileType xhtml ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "xhtml" }, _G.packer_plugins)]]
vim.cmd [[au FileType cpp ++once lua require("packer.load")({'vim-ccls'}, { ft = "cpp" }, _G.packer_plugins)]]
vim.cmd [[au FileType phtml ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "phtml" }, _G.packer_plugins)]]
vim.cmd [[au FileType latex ++once lua require("packer.load")({'vimtex'}, { ft = "latex" }, _G.packer_plugins)]]
vim.cmd [[au FileType vue ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "vue" }, _G.packer_plugins)]]
vim.cmd [[au FileType tex ++once lua require("packer.load")({'vimtex'}, { ft = "tex" }, _G.packer_plugins)]]
vim.cmd [[au FileType svelte ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "svelte" }, _G.packer_plugins)]]
vim.cmd [[au FileType vimwiki ++once lua require("packer.load")({'vimwiki', 'telescope-heading.nvim', 'vim-table-mode'}, { ft = "vimwiki" }, _G.packer_plugins)]]
vim.cmd [[au FileType ron ++once lua require("packer.load")({'ron.vim'}, { ft = "ron" }, _G.packer_plugins)]]
vim.cmd [[au FileType lf ++once lua require("packer.load")({'lf-vim'}, { ft = "lf" }, _G.packer_plugins)]]
vim.cmd [[au FileType typescript ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "typescript" }, _G.packer_plugins)]]
vim.cmd [[au FileType help ++once lua require("packer.load")({'telescope-heading.nvim'}, { ft = "help" }, _G.packer_plugins)]]
vim.cmd [[au FileType html ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "html" }, _G.packer_plugins)]]
vim.cmd [[au FileType javascript ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "javascript" }, _G.packer_plugins)]]
vim.cmd [[au FileType qf ++once lua require("packer.load")({'nvim-bqf'}, { ft = "qf" }, _G.packer_plugins)]]
vim.cmd [[au FileType just ++once lua require("packer.load")({'vim-just'}, { ft = "just" }, _G.packer_plugins)]]
vim.cmd [[au FileType rustpeg ++once lua require("packer.load")({'vim-rustpeg'}, { ft = "rustpeg" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'vimwiki', 'telescope-heading.nvim', 'vim-table-mode'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType lua ++once lua require("packer.load")({'luv-vimdocs', 'nvim-luaref'}, { ft = "lua" }, _G.packer_plugins)]]
vim.cmd [[au FileType vimdoc ++once lua require("packer.load")({'telescope-heading.nvim'}, { ft = "vimdoc" }, _G.packer_plugins)]]
vim.cmd [[au FileType go ++once lua require("packer.load")({'vim-go'}, { ft = "go" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufWinEnter * ++once lua require("packer.load")({'marks.nvim', 'dressing.nvim'}, { event = "BufWinEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'paint.nvim'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au UIEnter * ++once lua require("packer.load")({'indent-blankline.nvim', 'incline.nvim', 'lualine.nvim', 'nvim-scrollbar', 'virtcolumn.nvim'}, { event = "UIEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead {*.asc,*.gpg} ++once lua require("packer.load")({'vim-gnupg'}, { event = "BufRead {*.asc,*.gpg}" }, _G.packer_plugins)]]
vim.cmd [[au CursorHold * ++once lua require("packer.load")({'FixCursorHold.nvim'}, { event = "CursorHold *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'better-escape.nvim'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead {package.json,*.ts,*.tsx,*.js,*.jsx} ++once lua require("packer.load")({'package-info.nvim'}, { event = "BufRead {package.json,*.ts,*.tsx,*.js,*.jsx}" }, _G.packer_plugins)]]
vim.cmd [[au BufRead {*.ts,*.tsx,*.js,*.jsx} ++once lua require("packer.load")({'template-string.nvim'}, { event = "BufRead {*.ts,*.tsx,*.js,*.jsx}" }, _G.packer_plugins)]]
vim.cmd [[au CmdlineEnter * ++once lua require("packer.load")({'wilder.nvim'}, { event = "CmdlineEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre Cargo.toml ++once lua require("packer.load")({'crates.nvim'}, { event = "BufReadPre Cargo.toml" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre */.git/index ++once lua require("packer.load")({'vim-fugitive'}, { event = "BufReadPre */.git/index" }, _G.packer_plugins)]]
vim.cmd [[au ColorSchemePre kanagawa ++once lua require("packer.load")({'kanagawa.nvim'}, { event = "ColorSchemePre kanagawa" }, _G.packer_plugins)]]
vim.cmd [[au BufRead {*.o,*.so,*.a,*.out,*.bin,*.exe} ++once lua require("packer.load")({'hexmode', 'vim-xxdcursor'}, { event = "BufRead {*.o,*.so,*.a,*.out,*.bin,*.exe}" }, _G.packer_plugins)]]
vim.cmd [[au ColorSchemePre catpuccin ++once lua require("packer.load")({'catppuccin'}, { event = "ColorSchemePre catpuccin" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
  -- Function lazy-loads
time([[Defining lazy-load function autocommands]], true)
vim.cmd[[au FuncUndefined wilder#* ++once lua require("packer.load")({'wilder.nvim'}, {}, _G.packer_plugins)]]
vim.cmd[[au FuncUndefined fugitive#* ++once lua require("packer.load")({'vim-fugitive'}, {}, _G.packer_plugins)]]
vim.cmd[[au FuncUndefined Fugitive* ++once lua require("packer.load")({'vim-fugitive'}, {}, _G.packer_plugins)]]
time([[Defining lazy-load function autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-teal/ftdetect/teal.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-teal/ftdetect/teal.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-teal/ftdetect/teal.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg/ftdetect/rustpeg.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg/ftdetect/rustpeg.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg/ftdetect/rustpeg.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just/ftdetect/just.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just/ftdetect/just.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just/ftdetect/just.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim/ftdetect/ron.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim/ftdetect/ron.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim/ftdetect/ron.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim/ftdetect/lf.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim/ftdetect/lf.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim/ftdetect/lf.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/cls.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/cls.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/cls.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tikz.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tikz.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tikz.vim]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end