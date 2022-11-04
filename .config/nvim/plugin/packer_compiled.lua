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
local package_path_str = "/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/lucas/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
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
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/FixCursorHold.nvim",
    url = "https://github.com/antoinemadec/FixCursorHold.nvim"
  },
  ["JuliaFormatter.vim"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/JuliaFormatter.vim",
    url = "https://github.com/kdheepak/JuliaFormatter.vim"
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
  ["Spacegray.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/Spacegray.vim",
    url = "https://github.com/ackyshake/Spacegray.vim"
  },
  UnconditionalPaste = {
    keys = { { "n", "gcp" }, { "n", "gcP" }, { "n", "glp" }, { "n", "glP" }, { "n", "gbp" }, { "n", "gbP" }, { "n", "ghp" }, { "n", "ghP" }, { "n", "g[p" }, { "n", "g]P" }, { "n", "g[p" }, { "n", "g[P" }, { "n", "gsp" }, { "n", "gsP" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/UnconditionalPaste",
    url = "https://github.com/vim-scripts/UnconditionalPaste"
  },
  ["aerial.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/aerial.nvim",
    url = "https://github.com/stevearc/aerial.nvim"
  },
  ["architext.nvim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/architext.nvim",
    url = "https://github.com/vigoux/architext.nvim"
  },
  ["arctic.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/arctic.nvim",
    url = "https://github.com/rockyzhang24/arctic.nvim"
  },
  ["arshlib.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/arshlib.nvim",
    url = "https://github.com/arsham/arshlib.nvim"
  },
  ["asyncrun.vim"] = {
    commands = { "AsyncRun" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/asyncrun.vim",
    url = "https://github.com/skywind3000/asyncrun.vim"
  },
  ["better-escape.nvim"] = {
    config = { "require('plugs.config').better_esc()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/better-escape.nvim",
    url = "https://github.com/max397574/better-escape.nvim"
  },
  ["blue-moon"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/blue-moon",
    url = "https://github.com/kyazdani42/blue-moon"
  },
  bogster = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/bogster",
    url = "https://github.com/vv9k/bogster"
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
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  catppuccin = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/catppuccin",
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
    after = { "coc-kvs", "coc-fzf", "coc-code-action-menu" },
    config = { "require('plugs.coc').tag_cmd()" },
    loaded = true,
    only_config = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/coc.nvim",
    url = "https://github.com/neoclide/coc.nvim"
  },
  ["comment-box.nvim"] = {
    config = { "require('plugs.config').comment_box()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/comment-box.nvim",
    url = "https://github.com/LudoPinelli/comment-box.nvim"
  },
  ["crates.nvim"] = {
    after_files = { "/home/lucas/.local/share/nvim/site/pack/packer/opt/crates.nvim/after/plugin/cmp_crates.lua" },
    config = { "require('plugs.config').crates()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/crates.nvim",
    url = "https://github.com/Saecki/crates.nvim"
  },
  ["daycula-vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/daycula-vim",
    url = "https://github.com/ghifarit53/daycula-vim"
  },
  ["desktop-notify.nvim"] = {
    config = { "vim.cmd'command! Notifications :lua require(\"notify\")._print_history()<CR>'" },
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/desktop-notify.nvim",
    url = "https://github.com/simrat39/desktop-notify.nvim"
  },
  ["dial.nvim"] = {
    config = { "require('plugs.dial')" },
    keys = { { "n", "+" }, { "n", "_" }, { "v", "+" }, { "v", "_" }, { "v", "g+" }, { "v", "g_" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/dial.nvim",
    url = "https://github.com/monaqa/dial.nvim"
  },
  ["diffview.nvim"] = {
    commands = { "DiffviewClose", "DiffviewFileHistory", "DiffviewFocusFiles", "DiffviewLog", "DiffviewOpen", "DiffviewRefresh", "DiffviewToggleFiles" },
    config = { "require('plugs.diffview')" },
    keys = { { "n", "<Leader>g;" }, { "n", "<Leader>g." }, { "n", "<Leader>gh" } },
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
  edge = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/edge",
    url = "https://github.com/sainnhe/edge"
  },
  ["editorconfig-vim"] = {
    config = { "require('plugs.editorconf')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/editorconfig-vim",
    url = "https://github.com/editorconfig/editorconfig-vim"
  },
  ["eregex.vim"] = {
    commands = { "E2v", "S", "M" },
    config = { "require('plugs.config').eregex()" },
    keys = { { "n", "<Leader>es" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/eregex.vim",
    url = "https://github.com/othree/eregex.vim"
  },
  everforest = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/everforest",
    url = "https://github.com/sainnhe/everforest"
  },
  fzf = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf",
    url = "https://github.com/junegunn/fzf"
  },
  ["fzf-floaterm"] = {
    config = { "require('plugs.config').floaterm()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/fzf-floaterm",
    url = "https://github.com/voldikss/fzf-floaterm"
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
    config = { "require('plugs.config').git_conflict()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/git-conflict.nvim",
    url = "https://github.com/akinsho/git-conflict.nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "require('plugs.gitsigns')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["gruvbox-flat.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/gruvbox-flat.nvim",
    url = "https://github.com/eddyekofo94/gruvbox-flat.nvim"
  },
  ["gruvbox-material"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/gruvbox-material",
    url = "https://github.com/sainnhe/gruvbox-material"
  },
  hexmode = {
    config = { "vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe'" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/hexmode",
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
    config = { "require('plugs.hop')" },
    keys = { { "n", "f" }, { "x", "f" }, { "o", "f" }, { "n", "F" }, { "x", "F" }, { "o", "F" }, { "n", "t" }, { "x", "t" }, { "o", "t" }, { "n", "T" }, { "x", "T" }, { "o", "T" }, { "n", "<Leader><Leader>h" }, { "n", "<Leader><Leader>j" }, { "n", "<Leader><Leader>k" }, { "n", "<Leader><Leader>l" }, { "n", "<Leader><Leader>J" }, { "n", "<Leader><Leader>K" }, { "n", "<Leader><Leader>/" }, { "n", "<Leader><Leader>o" }, { "n", "<C-S-:>" }, { "n", "<C-S-<>" } },
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
  ["iceberg.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/iceberg.vim",
    url = "https://github.com/cocopon/iceberg.vim"
  },
  ["id3.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/id3.vim",
    url = "https://github.com/AndrewRadev/id3.vim"
  },
  ["impatient.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/impatient.nvim",
    url = "https://github.com/lewis6991/impatient.nvim"
  },
  ["incline.nvim"] = {
    config = { "require('plugs.incline')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/incline.nvim",
    url = "https://github.com/b0o/incline.nvim"
  },
  ["indent-blankline.nvim"] = {
    config = { "require('plugs.indent_blankline')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/indent-blankline.nvim",
    url = "https://github.com/lukas-reineke/indent-blankline.nvim"
  },
  ["info.vim"] = {
    commands = { "Info" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/info.vim",
    url = "https://github.com/HiPhish/info.vim"
  },
  ["iswap.nvim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/iswap.nvim",
    url = "https://github.com/mizlan/iswap.nvim"
  },
  ["kanagawa.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/kanagawa.nvim",
    url = "https://github.com/rebelot/kanagawa.nvim"
  },
  kimbox = {
    after = { "bufferline.nvim", "indent-blankline.nvim", "telescope.nvim", "lualine.nvim", "nvim-scrollbar", "lf.nvim", "nvim-notify", "vimwiki" },
    config = { "require('plugs.kimbox')" },
    loaded = true,
    only_config = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/kimbox",
    url = "https://github.com/lmburns/kimbox"
  },
  ["lazygit.nvim"] = {
    config = { "require('plugs.config').lazygit()" },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lazygit.nvim",
    url = "https://github.com/kdheepak/lazygit.nvim"
  },
  ["legendary.nvim"] = {
    config = { "require('plugs.legendary')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/legendary.nvim",
    url = "https://github.com/mrjones2014/legendary.nvim"
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
  ["linediff.vim"] = {
    commands = { "Linediff" },
    config = { "require('plugs.config').linediff()" },
    keys = { { "n", "<Leader>ld" }, { "x", "<Leader>ld" } },
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
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["lush.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/lush.nvim",
    url = "https://github.com/rktjmp/lush.nvim"
  },
  ["luv-vimdocs"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/luv-vimdocs",
    url = "https://github.com/nanotee/luv-vimdocs"
  },
  ["marks.nvim"] = {
    config = { "require('plugs.marks')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/marks.nvim",
    url = "https://github.com/chentoast/marks.nvim"
  },
  ["material.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/material.nvim",
    url = "https://github.com/marko-cerovac/material.nvim"
  },
  melange = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/melange",
    url = "https://github.com/savq/melange"
  },
  miramare = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/miramare",
    url = "https://github.com/franbach/miramare"
  },
  mkdx = {
    config = { 'vim.cmd("source ~/.config/nvim/vimscript/plugins/mkdx.vim")' },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/mkdx",
    url = "https://github.com/SidOfc/mkdx"
  },
  ["move.nvim"] = {
    config = { "require('plugs.config').move()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/move.nvim",
    url = "https://github.com/fedepujol/move.nvim"
  },
  ["neodark.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neodark.vim",
    url = "https://github.com/KeitaNakamura/neodark.vim"
  },
  neoformat = {
    config = { "require('plugs.format')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neoformat",
    url = "https://github.com/sbdchd/neoformat"
  },
  neogen = {
    commands = { "Neogen" },
    config = { "require('plugs.config').neogen()" },
    keys = { { "n", "<Leader>dg" }, { "n", "<Leader>df" }, { "n", "<Leader>dc" } },
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
    url = "https://github.com/TimUntersberger/neogit"
  },
  neotest = {
    config = { "require('plugs.neotest')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/neotest",
    url = "https://github.com/rcarriga/neotest"
  },
  ["neotest-go"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neotest-go",
    url = "https://github.com/nvim-neotest/neotest-go"
  },
  ["neotest-plenary"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neotest-plenary",
    url = "https://github.com/nvim-neotest/neotest-plenary"
  },
  ["neotest-python"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neotest-python",
    url = "https://github.com/nvim-neotest/neotest-python"
  },
  ["neotest-vim-test"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neotest-vim-test",
    url = "https://github.com/nvim-neotest/neotest-vim-test"
  },
  neovim = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/neovim",
    url = "https://github.com/meliora-theme/neovim"
  },
  ["night-owl.vim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/night-owl.vim",
    url = "https://github.com/haishanh/night-owl.vim"
  },
  ["nightfox.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nightfox.nvim",
    url = "https://github.com/EdenEast/nightfox.nvim"
  },
  ["nlua.nvim"] = {
    config = { "require('plugs.config').nlua()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nlua.nvim",
    url = "https://github.com/tjdevries/nlua.nvim"
  },
  ["nui.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nui.nvim",
    url = "https://github.com/MunifTanjim/nui.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "require('plugs.autopairs')" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-autopairs",
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
    url = "https://github.com/xiyaowong/nvim-colorizer.lua"
  },
  ["nvim-dap"] = {
    after = { "telescope-dap.nvim", "nvim-dap-ui", "nvim-dap-python" },
    config = { "require('plugs.dap')" },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap",
    url = "https://github.com/mfussenegger/nvim-dap",
    wants = { "one-small-step-for-vimkind" }
  },
  ["nvim-dap-python"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap-python",
    url = "https://github.com/mfussenegger/nvim-dap-python",
    wants = { "nvim-dap" }
  },
  ["nvim-dap-ui"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-dap-ui",
    url = "https://github.com/rcarriga/nvim-dap-ui"
  },
  ["nvim-dap-virtual-text"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-dap-virtual-text",
    url = "https://github.com/theHamsta/nvim-dap-virtual-text"
  },
  ["nvim-gps"] = {
    config = { 'require("nvim-gps").setup()' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-gps",
    url = "https://github.com/SmiteshP/nvim-gps"
  },
  ["nvim-hlslens"] = {
    after = { "nvim-scrollbar" },
    config = { "require('plugs.config').hlslens()" },
    keys = { { "n", "n" }, { "x", "n" }, { "o", "n" }, { "n", "N" }, { "x", "N" }, { "o", "N" }, { "n", "/" }, { "n", "?" }, { "n", "*" }, { "x", "*" }, { "n", "#" }, { "x", "#" }, { "n", "g*" }, { "x", "g*" }, { "n", "g#" }, { "x", "g#" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-hlslens",
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
    load_after = {
      ["nvim-hlslens"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-scrollbar",
    url = "https://github.com/petertriho/nvim-scrollbar"
  },
  ["nvim-treehopper"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-treehopper",
    url = "https://github.com/mfussenegger/nvim-treehopper"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-endwise"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-endwise",
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
    load_after = {},
    loaded = true,
    needs_bufread = false,
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
  ["nvim-ts-rainbow"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/nvim-ts-rainbow",
    url = "https://github.com/p00f/nvim-ts-rainbow"
  },
  ["nvim-ufo"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/nvim-ufo",
    url = "https://github.com/kevinhwang91/nvim-ufo"
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
  ["oceanic-material"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/oceanic-material",
    url = "https://github.com/glepnir/oceanic-material"
  },
  ["one-small-step-for-vimkind"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/one-small-step-for-vimkind",
    url = "https://github.com/jbyuki/one-small-step-for-vimkind"
  },
  ["onenord.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/onenord.nvim",
    url = "https://github.com/rmehri01/onenord.nvim"
  },
  ["open-browser.vim"] = {
    config = { "require('plugs.config').open_browser()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/open-browser.vim",
    url = "https://github.com/tyru/open-browser.vim"
  },
  ["package-info.nvim"] = {
    config = { "require('plugs.config').package_info()" },
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
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/playground",
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
    config = { "require('plugs.config').project()" },
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
  ["query-secretary"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/query-secretary",
    url = "https://github.com/ziontee113/query-secretary"
  },
  ["registers.nvim"] = {
    config = { "require('plugs.config').registers()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/registers.nvim",
    url = "https://github.com/tversteeg/registers.nvim"
  },
  rnvimr = {
    config = { "require('plugs.rnvimr')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/rnvimr",
    url = "https://github.com/kevinhwang91/rnvimr"
  },
  ["ron.vim"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim",
    url = "https://github.com/ron-rs/ron.vim"
  },
  ["rose-pine"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/rose-pine",
    url = "https://github.com/rose-pine/neovim"
  },
  ["rust.vim"] = {
    config = { "require('plugs.rust')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim",
    url = "https://github.com/rust-lang/rust.vim"
  },
  ["smart-splits.nvim"] = {
    config = { "require('plugs.config').smartsplits()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/smart-splits.nvim",
    url = "https://github.com/mrjones2014/smart-splits.nvim"
  },
  sonokai = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/sonokai",
    url = "https://github.com/sainnhe/sonokai"
  },
  ["sort.nvim"] = {
    commands = { "Sort" },
    config = { "require('plugs.config').sort()" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/sort.nvim",
    url = "https://github.com/sQVe/sort.nvim"
  },
  spaceduck = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/spaceduck",
    url = "https://github.com/pineapplegiant/spaceduck"
  },
  ["specs.nvim"] = {
    config = { "require('plugs.config').specs()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/specs.nvim",
    url = "https://github.com/edluffy/specs.nvim"
  },
  ["spread.nvim"] = {
    config = { "require('plugs.config').spread()" },
    keys = { { "n", "gJ" }, { "n", "gS" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/spread.nvim",
    url = "https://github.com/aarondiel/spread.nvim"
  },
  ["sqlite.lua"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/sqlite.lua",
    url = "https://github.com/tami5/sqlite.lua"
  },
  ["substitute.nvim"] = {
    config = { "require('plugs.substitute')" },
    keys = { { "n", "s" }, { "n", "ss" }, { "n", "se" }, { "n", "sr" }, { "n", "<Leader>sr" }, { "n", "sS" }, { "n", "sx" }, { "n", "sxx" }, { "n", "sxc" }, { "x", "s" }, { "x", "X" } },
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
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/syntax-tree-surfer",
    url = "https://github.com/ziontee113/syntax-tree-surfer"
  },
  ["targets.vim"] = {
    config = { "require('plugs.config').targets()" },
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
    load_after = {},
    loaded = true,
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
  ["telescope-github.nvim"] = {
    config = { 'require("telescope").load_extension("gh")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-github.nvim",
    url = "https://github.com/nvim-telescope/telescope-github.nvim"
  },
  ["telescope-heading.nvim"] = {
    config = { 'require("telescope").load_extension("heading")' },
    load_after = {},
    loaded = true,
    needs_bufread = false,
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
  ["telescope-packer.nvim"] = {
    config = { "\27LJ\2\n«\1\0\1\4\0\t\0\0266\1\0\0'\3\1\0B\1\2\0029\1\2\1'\3\3\0B\1\2\1\14\0\0\0X\1\1Ä4\0\0\0+\1\1\0=\1\4\0006\1\0\0'\3\5\0B\1\2\0029\1\6\1'\3\a\0B\1\2\0016\1\0\0'\3\5\0B\1\2\0029\1\b\0019\1\a\0019\1\a\1\18\3\0\0B\1\2\1K\0\1\0\15extensions\vpacker\19load_extension\14telescope\14previewer\16packer.nvim\vloader\fplugins\frequireA\1\0\3\0\4\0\0066\0\0\0'\2\1\0B\0\2\0023\1\3\0=\1\2\0K\0\1\0\0\vpacker\22telescope.builtin\frequire\0" },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope-packer.nvim",
    url = "https://github.com/nvim-telescope/telescope-packer.nvim",
    wants = { "telescope.nvim", "packer.nvim" }
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
    after = { "telescope-heading.nvim", "telescope-ultisnips.nvim", "telescope-zoxide", "nvim-neoclip.lua", "telescope-bookmarks.nvim", "telescope-file-browser.nvim", "telescope-ghq.nvim", "telescope-github.nvim", "telescope-hop.nvim", "telescope-smart-history.nvim", "telescope-frecency.nvim", "telescope-packer.nvim", "telescope-rualdi.nvim", "urlview.nvim", "nvim-dap", "todo-comments.nvim", "lazygit.nvim", "project.nvim", "telescope-fzf-native.nvim", "telescope-coc.nvim" },
    config = { "require('plugs.telescope')" },
    load_after = {},
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["template-string.nvim"] = {
    config = { "require('plugs.config').template_string()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/template-string.nvim",
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
  ["tokyodark.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/tokyodark.nvim",
    url = "https://github.com/tiagovla/tokyodark.nvim"
  },
  ["tokyonight.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/tokyonight.nvim",
    url = "https://github.com/folke/tokyonight.nvim"
  },
  ["treesitter-unit"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/treesitter-unit",
    url = "https://github.com/David-Kunz/treesitter-unit"
  },
  ["trouble.nvim"] = {
    config = { "require('plugs.trouble')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/trouble.nvim",
    url = "https://github.com/lmburns/trouble.nvim"
  },
  ["twilight.nvim"] = {
    commands = { "Twilight" },
    config = { "require('plugs.twilight')" },
    keys = { { "n", "<Leader>li" }, { "n", "<Leader>zm" } },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/twilight.nvim",
    url = "https://github.com/folke/twilight.nvim"
  },
  ultisnips = {
    config = { "require('plugs.config').ultisnips()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/ultisnips",
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
  ["vCoolor.vim"] = {
    config = { "require('plugs.config').vcoolor()" },
    keys = { { "n", "<Leader>pc" }, { "n", "<Leader>yb" }, { "n", "<Leader>yr" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vCoolor.vim",
    url = "https://github.com/KabbAmine/vCoolor.vim"
  },
  ["vim-SpellCheck"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-SpellCheck",
    url = "https://github.com/inkarkat/vim-SpellCheck"
  },
  ["vim-asterisk"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-asterisk",
    url = "https://github.com/haya14busa/vim-asterisk"
  },
  ["vim-cargo-make"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-cargo-make",
    url = "https://github.com/nastevens/vim-cargo-make"
  },
  ["vim-caser"] = {
    config = { "require('plugs.config').caser()" },
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-caser",
    url = "https://github.com/arthurxavierx/vim-caser"
  },
  ["vim-crystal"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-crystal",
    url = "https://github.com/jlcrochet/vim-crystal"
  },
  ["vim-deep-space"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-deep-space",
    url = "https://github.com/tyrannicaltoucan/vim-deep-space"
  },
  ["vim-devicons"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-devicons",
    url = "https://github.com/ryanoasis/vim-devicons"
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
  ["vim-floaterm"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-floaterm",
    url = "https://github.com/voldikss/vim-floaterm"
  },
  ["vim-flog"] = {
    commands = { "Flog", "Flogsplit" },
    config = { "require('plugs.flog')" },
    keys = { { "n", "<Leader>gl" }, { "n", "<Leader>gi" } },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-flog",
    url = "https://github.com/rbong/vim-flog",
    wants = { "vim-fugitive" }
  },
  ["vim-fugitive"] = {
    config = { "require('plugs.fugitive')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-gh-line"] = {
    config = { "require('plugs.config').ghline()" },
    keys = { { "n", "<Leader>go" }, { "n", "<Leader>gL" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-gh-line",
    url = "https://github.com/ruanyl/vim-gh-line"
  },
  ["vim-gnupg"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-gnupg",
    url = "https://github.com/jamessan/vim-gnupg"
  },
  ["vim-go"] = {
    config = { "require('plugs.go')" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go",
    url = "https://github.com/fatih/vim-go"
  },
  ["vim-grepper"] = {
    commands = { "Grepper", "GrepperRg" },
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
  ["vim-indent-object"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-indent-object",
    url = "https://github.com/michaeljsmith/vim-indent-object"
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
  ["vim-markdown"] = {
    config = { "require('plugs.config').markdown()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown",
    url = "https://github.com/plasticboy/vim-markdown"
  },
  ["vim-matchup"] = {
    config = { "require('plugs.config').matchup()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-matchup",
    url = "https://github.com/andymass/vim-matchup"
  },
  ["vim-nightfly-guicolors"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-nightfly-guicolors",
    url = "https://github.com/bluz71/vim-nightfly-guicolors"
  },
  ["vim-perl"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl",
    url = "https://github.com/vim-perl/vim-perl"
  },
  ["vim-polyglot"] = {
    loaded = true,
    needs_bufread = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-polyglot",
    url = "https://github.com/sheerun/vim-polyglot"
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
    config = { "require('plugs.config').sandwhich()" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-sandwich",
    url = "https://github.com/machakann/vim-sandwich"
  },
  ["vim-slime"] = {
    config = { "require('plugs.config').slime()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-slime",
    url = "https://github.com/jpalardy/vim-slime"
  },
  ["vim-snippets"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-snippets",
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
    config = { "require('plugs.config').table_mode()" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-table-mode",
    url = "https://github.com/dhruvasagar/vim-table-mode"
  },
  ["vim-teal"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-teal",
    url = "https://github.com/teal-language/vim-teal"
  },
  ["vim-visual-multi"] = {
    commands = { "VMSearch" },
    config = { "require('plugs.config').visualmulti()" },
    keys = { { "n", "<C-n>" }, { "x", "<C-n>" }, { "n", "<Leader>\\" }, { "n", "<Leader>/" }, { "n", "<Leader>A" }, { "n", "<Leader>gs" }, { "x", "<Leader>A" }, { "n", "<M-S-i>" }, { "n", "<M-S-o>" }, { "n", "<C-Up>" }, { "n", "<C-Down>" }, { "n", "g/" } },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/vim-visual-multi",
    url = "https://github.com/mg979/vim-visual-multi",
    wants = { "nvim-hlslens", "nvim-autopairs" }
  },
  ["vim-xxdcursor"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vim-xxdcursor",
    url = "https://github.com/mattn/vim-xxdcursor"
  },
  vimtex = {
    config = { "require('plugs.vimtex')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/vimtex",
    url = "https://github.com/lervag/vimtex"
  },
  vimwiki = {
    config = { "require('plugs.config').vimwiki()" },
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
    config = { "require('plugs.wilder')" },
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/wilder.nvim",
    url = "https://github.com/gelguy/wilder.nvim"
  },
  ["zen-mode.nvim"] = {
    loaded = true,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/start/zen-mode.nvim",
    url = "https://github.com/folke/zen-mode.nvim"
  },
  ["zig.vim"] = {
    config = { "vim.g.zig_fmt_autosave = 0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/home/lucas/.local/share/nvim/site/pack/packer/opt/zig.vim",
    url = "https://github.com/ziglang/zig.vim"
  }
}

time([[Defining packer_plugins]], false)
local module_lazy_loads = {
  ["^neotest"] = "neotest"
}
local lazy_load_called = {['packer.load'] = true}
local function lazy_load_module(module_name)
  local to_load = {}
  if lazy_load_called[module_name] then return nil end
  lazy_load_called[module_name] = true
  for module_pat, plugin_name in pairs(module_lazy_loads) do
    if not _G.packer_plugins[plugin_name].loaded and string.match(module_name, module_pat) then
      to_load[#to_load + 1] = plugin_name
    end
  end

  if #to_load > 0 then
    require('packer.load')(to_load, {module = module_name}, _G.packer_plugins)
    local loaded_mod = package.loaded[module_name]
    if loaded_mod then
      return function(modname) return loaded_mod end
    end
  end
end

if not vim.g.packer_custom_loader_enabled then
  table.insert(package.loaders, 1, lazy_load_module)
  vim.g.packer_custom_loader_enabled = true
end

-- Setup for: vim-caser
time([[Setup for vim-caser]], true)
vim.g.caser_prefix = "cr"
time([[Setup for vim-caser]], false)
time([[packadd for vim-caser]], true)
vim.cmd [[packadd vim-caser]]
time([[packadd for vim-caser]], false)
-- Setup for: vimwiki
time([[Setup for vimwiki]], true)
require("plugs.config").vimwiki_setup()
time([[Setup for vimwiki]], false)
-- Setup for: vim-gh-line
time([[Setup for vim-gh-line]], true)
vim.g.gh_line_blame_map_default = 0
time([[Setup for vim-gh-line]], false)
-- Setup for: vim-polyglot
time([[Setup for vim-polyglot]], true)
try_loadstring("\27LJ\2\nø\1\0\0\2\0\4\0\0056\0\0\0009\0\1\0005\1\3\0=\1\2\0K\0\1\0\1\26\0\0\rftdetect\rmarkdown\frustpeg\alf\bron\ncmake\bcss\bcpp\6d\tdart\15dockerfile\ago\ngomod\thtml\tjava\njulia\tmake\vpython\nquery\truby\trust\tscss\bvim\tteal\bzig\22polyglot_disabled\6g\bvim\0", "setup", "vim-polyglot")
time([[Setup for vim-polyglot]], false)
time([[packadd for vim-polyglot]], true)
vim.cmd [[packadd vim-polyglot]]
time([[packadd for vim-polyglot]], false)
-- Setup for: vim-visual-multi
time([[Setup for vim-visual-multi]], true)
vim.g.VM_leader = '<Space>'
time([[Setup for vim-visual-multi]], false)
-- Setup for: packer.nvim
time([[Setup for packer.nvim]], true)
try_loadstring("\27LJ\2\n,\0\0\2\1\1\0\4-\0\0\0009\0\0\0B\0\1\1K\0\1\0\0\0\23vm#plugs#permanentV\1\0\3\1\5\1\n6\0\0\0009\0\1\0009\0\2\0\t\0\0\0X\0\4Ä6\0\0\0009\0\3\0003\2\4\0B\0\2\1K\0\1\0\0\0\0\rschedule\24loaded_visual_multi\6g\bvim\2\0", "setup", "packer.nvim")
time([[Setup for packer.nvim]], false)
-- Setup for: eregex.vim
time([[Setup for eregex.vim]], true)
vim.g.eregex_default_enable = 0
time([[Setup for eregex.vim]], false)
-- Setup for: desktop-notify.nvim
time([[Setup for desktop-notify.nvim]], true)
pcall(vim.cmd, 'delcommand Notifications')
time([[Setup for desktop-notify.nvim]], false)
time([[packadd for desktop-notify.nvim]], true)
vim.cmd [[packadd desktop-notify.nvim]]
time([[packadd for desktop-notify.nvim]], false)
-- Setup for: vCoolor.vim
time([[Setup for vCoolor.vim]], true)
vim.g.vcoolor_disable_mappings = 1 vim.g.vcoolor_lowercase = 1
time([[Setup for vCoolor.vim]], false)
-- Config for: nvim-colorizer.lua
time([[Config for nvim-colorizer.lua]], true)
require('plugs.config').colorizer()
time([[Config for nvim-colorizer.lua]], false)
-- Config for: vimtex
time([[Config for vimtex]], true)
require('plugs.vimtex')
time([[Config for vimtex]], false)
-- Config for: marks.nvim
time([[Config for marks.nvim]], true)
require('plugs.marks')
time([[Config for marks.nvim]], false)
-- Config for: targets.vim
time([[Config for targets.vim]], true)
require('plugs.config').targets()
time([[Config for targets.vim]], false)
-- Config for: tmux.nvim
time([[Config for tmux.nvim]], true)
require('plugs.config').tmux()
time([[Config for tmux.nvim]], false)
-- Config for: legendary.nvim
time([[Config for legendary.nvim]], true)
require('plugs.legendary')
time([[Config for legendary.nvim]], false)
-- Config for: nvim-web-devicons
time([[Config for nvim-web-devicons]], true)
require('plugs.config').devicons()
time([[Config for nvim-web-devicons]], false)
-- Config for: editorconfig-vim
time([[Config for editorconfig-vim]], true)
require('plugs.editorconf')
time([[Config for editorconfig-vim]], false)
-- Config for: listish.nvim
time([[Config for listish.nvim]], true)
require('plugs.config').listish()
time([[Config for listish.nvim]], false)
-- Config for: fzf-lua
time([[Config for fzf-lua]], true)
require('plugs.fzf-lua')
time([[Config for fzf-lua]], false)
-- Config for: hexmode
time([[Config for hexmode]], true)
vim.g.hexmode_patterns = '*.o,*.so,*.a,*.out,*.bin,*.exe'
time([[Config for hexmode]], false)
-- Config for: kimbox
time([[Config for kimbox]], true)
require('plugs.kimbox')
time([[Config for kimbox]], false)
-- Config for: link-visitor.nvim
time([[Config for link-visitor.nvim]], true)
require('plugs.config').link_visitor()
time([[Config for link-visitor.nvim]], false)
-- Config for: specs.nvim
time([[Config for specs.nvim]], true)
require('plugs.config').specs()
time([[Config for specs.nvim]], false)
-- Config for: ultisnips
time([[Config for ultisnips]], true)
require('plugs.config').ultisnips()
time([[Config for ultisnips]], false)
-- Config for: desktop-notify.nvim
time([[Config for desktop-notify.nvim]], true)
vim.cmd'command! Notifications :lua require("notify")._print_history()<CR>'
time([[Config for desktop-notify.nvim]], false)
-- Config for: lf.vim
time([[Config for lf.vim]], true)
require('plugs.config').lf()
time([[Config for lf.vim]], false)
-- Config for: vim-sandwich
time([[Config for vim-sandwich]], true)
require('plugs.config').sandwhich()
time([[Config for vim-sandwich]], false)
-- Config for: comment-box.nvim
time([[Config for comment-box.nvim]], true)
require('plugs.config').comment_box()
time([[Config for comment-box.nvim]], false)
-- Config for: smart-splits.nvim
time([[Config for smart-splits.nvim]], true)
require('plugs.config').smartsplits()
time([[Config for smart-splits.nvim]], false)
-- Config for: neogit
time([[Config for neogit]], true)
require('plugs.neogit')
time([[Config for neogit]], false)
-- Config for: wilder.nvim
time([[Config for wilder.nvim]], true)
require('plugs.wilder')
time([[Config for wilder.nvim]], false)
-- Config for: move.nvim
time([[Config for move.nvim]], true)
require('plugs.config').move()
time([[Config for move.nvim]], false)
-- Config for: neoformat
time([[Config for neoformat]], true)
require('plugs.format')
time([[Config for neoformat]], false)
-- Config for: template-string.nvim
time([[Config for template-string.nvim]], true)
require('plugs.config').template_string()
time([[Config for template-string.nvim]], false)
-- Config for: which-key.nvim
time([[Config for which-key.nvim]], true)
require('plugs.which-key')
time([[Config for which-key.nvim]], false)
-- Config for: toggleterm.nvim
time([[Config for toggleterm.nvim]], true)
require('plugs.neoterm')
time([[Config for toggleterm.nvim]], false)
-- Config for: trouble.nvim
time([[Config for trouble.nvim]], true)
require('plugs.trouble')
time([[Config for trouble.nvim]], false)
-- Config for: vim-caser
time([[Config for vim-caser]], true)
require('plugs.config').caser()
time([[Config for vim-caser]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
require('plugs.gitsigns')
time([[Config for gitsigns.nvim]], false)
-- Config for: vim-fugitive
time([[Config for vim-fugitive]], true)
require('plugs.fugitive')
time([[Config for vim-fugitive]], false)
-- Config for: fzf-floaterm
time([[Config for fzf-floaterm]], true)
require('plugs.config').floaterm()
time([[Config for fzf-floaterm]], false)
-- Config for: rnvimr
time([[Config for rnvimr]], true)
require('plugs.rnvimr')
time([[Config for rnvimr]], false)
-- Config for: git-conflict.nvim
time([[Config for git-conflict.nvim]], true)
require('plugs.config').git_conflict()
time([[Config for git-conflict.nvim]], false)
-- Config for: registers.nvim
time([[Config for registers.nvim]], true)
require('plugs.config').registers()
time([[Config for registers.nvim]], false)
-- Config for: open-browser.vim
time([[Config for open-browser.vim]], true)
require('plugs.config').open_browser()
time([[Config for open-browser.vim]], false)
-- Config for: vim-gutentags
time([[Config for vim-gutentags]], true)
require('plugs.gutentags')
time([[Config for vim-gutentags]], false)
-- Config for: better-escape.nvim
time([[Config for better-escape.nvim]], true)
require('plugs.config').better_esc()
time([[Config for better-escape.nvim]], false)
-- Config for: vim-matchup
time([[Config for vim-matchup]], true)
require('plugs.config').matchup()
time([[Config for vim-matchup]], false)
-- Config for: fzf.vim
time([[Config for fzf.vim]], true)
require('plugs.fzf')
time([[Config for fzf.vim]], false)
-- Config for: coc.nvim
time([[Config for coc.nvim]], true)
require('plugs.coc').tag_cmd()
time([[Config for coc.nvim]], false)
-- Config for: incline.nvim
time([[Config for incline.nvim]], true)
require('plugs.incline')
time([[Config for incline.nvim]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd vista.vim ]]

-- Config for: vista.vim
require('plugs.vista')

vim.cmd [[ packadd sqlite.lua ]]
vim.cmd [[ packadd plenary.nvim ]]
vim.cmd [[ packadd lualine.nvim ]]

-- Config for: lualine.nvim
require('plugs.lualine')

vim.cmd [[ packadd bufferline.nvim ]]

-- Config for: bufferline.nvim
require('plugs.bufferline')

vim.cmd [[ packadd indent-blankline.nvim ]]

-- Config for: indent-blankline.nvim
require('plugs.indent_blankline')

vim.cmd [[ packadd nvim-notify ]]

-- Config for: nvim-notify
require('plugs.notify')

vim.cmd [[ packadd lf.nvim ]]

-- Config for: lf.nvim
require('plugs.config').lfnvim()

vim.cmd [[ packadd coc-code-action-menu ]]
vim.cmd [[ packadd coc-kvs ]]
vim.cmd [[ packadd coc-fzf ]]
vim.cmd [[ packadd popup.nvim ]]
vim.cmd [[ packadd telescope.nvim ]]

-- Config for: telescope.nvim
require('plugs.telescope')

vim.cmd [[ packadd todo-comments.nvim ]]

-- Config for: todo-comments.nvim
require('plugs.todo-comments')

vim.cmd [[ packadd telescope-rualdi.nvim ]]

-- Config for: telescope-rualdi.nvim
require("telescope").load_extension("rualdi")

vim.cmd [[ packadd telescope-smart-history.nvim ]]

-- Config for: telescope-smart-history.nvim
require("telescope").load_extension("smart_history")

vim.cmd [[ packadd telescope-coc.nvim ]]

-- Config for: telescope-coc.nvim
require("telescope").load_extension("coc")

vim.cmd [[ packadd telescope-hop.nvim ]]

-- Config for: telescope-hop.nvim
require("telescope").load_extension("hop")

vim.cmd [[ packadd telescope-github.nvim ]]

-- Config for: telescope-github.nvim
require("telescope").load_extension("gh")

vim.cmd [[ packadd telescope-ghq.nvim ]]

-- Config for: telescope-ghq.nvim
require("telescope").load_extension("ghq")

vim.cmd [[ packadd telescope-fzf-native.nvim ]]

-- Config for: telescope-fzf-native.nvim
require("telescope").load_extension("fzf")

vim.cmd [[ packadd telescope-frecency.nvim ]]

-- Config for: telescope-frecency.nvim
require("telescope").load_extension("frecency")

vim.cmd [[ packadd telescope-file-browser.nvim ]]

-- Config for: telescope-file-browser.nvim
require("telescope").load_extension("file_browser")

vim.cmd [[ packadd telescope-bookmarks.nvim ]]

-- Config for: telescope-bookmarks.nvim
require("telescope").load_extension("bookmarks")

vim.cmd [[ packadd nvim-neoclip.lua ]]
vim.cmd [[ packadd lazygit.nvim ]]

-- Config for: lazygit.nvim
require('plugs.config').lazygit()

vim.cmd [[ packadd telescope-zoxide ]]

-- Config for: telescope-zoxide
require("telescope").load_extension("zoxide")

vim.cmd [[ packadd telescope-ultisnips.nvim ]]

-- Config for: telescope-ultisnips.nvim
require("telescope").load_extension("ultisnips")

vim.cmd [[ packadd telescope-heading.nvim ]]

-- Config for: telescope-heading.nvim
require("telescope").load_extension("heading")

vim.cmd [[ packadd project.nvim ]]

-- Config for: project.nvim
require('plugs.config').project()

vim.cmd [[ packadd nvim-dap ]]

-- Config for: nvim-dap
require('plugs.dap')

vim.cmd [[ packadd nvim-dap-python ]]
vim.cmd [[ packadd nvim-dap-ui ]]
vim.cmd [[ packadd telescope-dap.nvim ]]

-- Config for: telescope-dap.nvim
require("telescope").load_extension("dap")

vim.cmd [[ packadd urlview.nvim ]]

-- Config for: urlview.nvim
require('plugs.config').urlview()

vim.cmd [[ packadd zen-mode.nvim ]]
vim.cmd [[ packadd nvim-treesitter ]]
vim.cmd [[ packadd nvim_context_vt ]]
vim.cmd [[ packadd iswap.nvim ]]
vim.cmd [[ packadd hlargs.nvim ]]
vim.cmd [[ packadd query-secretary ]]
vim.cmd [[ packadd nvim-treehopper ]]
vim.cmd [[ packadd nvim-treesitter-textobjects ]]
vim.cmd [[ packadd nvim-ts-context-commentstring ]]
vim.cmd [[ packadd playground ]]
vim.cmd [[ packadd nvim-ts-rainbow ]]
vim.cmd [[ packadd nvim-ts-autotag ]]
vim.cmd [[ packadd nvim-treesitter-endwise ]]
vim.cmd [[ packadd Comment.nvim ]]

-- Config for: Comment.nvim
require('plugs.comment')

vim.cmd [[ packadd treesitter-unit ]]
vim.cmd [[ packadd architext.nvim ]]
vim.cmd [[ packadd syntax-tree-surfer ]]
vim.cmd [[ packadd nvim-gps ]]

-- Config for: nvim-gps
require("nvim-gps").setup()

vim.cmd [[ packadd nvim-treesitter-refactor ]]
vim.cmd [[ packadd vim-indent-object ]]
time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SudaRead lua require("packer.load")({'suda.vim'}, { cmd = "SudaRead", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SudaWrite lua require("packer.load")({'suda.vim'}, { cmd = "SudaWrite", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GrepperRg lua require("packer.load")({'vim-grepper'}, { cmd = "GrepperRg", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file VMSearch lua require("packer.load")({'vim-visual-multi'}, { cmd = "VMSearch", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Luapad lua require("packer.load")({'nvim-luapad'}, { cmd = "Luapad", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file PP lua require("packer.load")({'paperplanes.nvim'}, { cmd = "PP", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewClose lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewClose", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewFileHistory lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewFileHistory", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewFocusFiles lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewFocusFiles", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file S lua require("packer.load")({'eregex.vim'}, { cmd = "S", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewOpen lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Twilight lua require("packer.load")({'twilight.nvim'}, { cmd = "Twilight", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewToggleFiles lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewToggleFiles", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Info lua require("packer.load")({'info.vim'}, { cmd = "Info", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file EasyAlign lua require("packer.load")({'vim-easy-align'}, { cmd = "EasyAlign", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file VinfoClean lua require("packer.load")({'vinfo'}, { cmd = "VinfoClean", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file VinfoNext lua require("packer.load")({'vinfo'}, { cmd = "VinfoNext", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file VinfoPrevious lua require("packer.load")({'vinfo'}, { cmd = "VinfoPrevious", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Linediff lua require("packer.load")({'linediff.vim'}, { cmd = "Linediff", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file M lua require("packer.load")({'eregex.vim'}, { cmd = "M", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Flogsplit lua require("packer.load")({'vim-flog'}, { cmd = "Flogsplit", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Bufferize lua require("packer.load")({'bufferize.vim'}, { cmd = "Bufferize", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewRefresh lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewRefresh", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewLog lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewLog", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file LiveEasyAlign lua require("packer.load")({'vim-easy-align'}, { cmd = "LiveEasyAlign", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Grepper lua require("packer.load")({'vim-grepper'}, { cmd = "Grepper", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file ScratchPad lua require("packer.load")({'ScratchPad'}, { cmd = "ScratchPad", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndoTreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndoTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Sort lua require("packer.load")({'sort.nvim'}, { cmd = "Sort", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'vim-startuptime'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Vinfo lua require("packer.load")({'vinfo'}, { cmd = "Vinfo", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Neogen lua require("packer.load")({'neogen'}, { cmd = "Neogen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file E2v lua require("packer.load")({'eregex.vim'}, { cmd = "E2v", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Flog lua require("packer.load")({'vim-flog'}, { cmd = "Flog", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file LuaRun lua require("packer.load")({'nvim-luapad'}, { cmd = "LuaRun", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file AsyncRun lua require("packer.load")({'asyncrun.vim'}, { cmd = "AsyncRun", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

-- Keymap lazy-loads
vim.defer_fn(function()
time([[Defining lazy-load keymaps]], true)
pcall(vim.cmd, [[nnoremap <unique><silent> g# <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "g#", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>/ <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>yb <cmd>lua require("packer.load")({'vCoolor.vim'}, { keys = "<lt>Leader>yb", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>df <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>df", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> n <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "n", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> F <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "F", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gcp <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "gcp", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g* <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "g*", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>J <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>J", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ghP <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "ghP", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>ld <cmd>lua require("packer.load")({'linediff.vim'}, { keys = "<lt>Leader>ld", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> g# <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "g#", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> t <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "t", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gsP <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "gsP", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> X <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "X", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>gi <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "<lt>Leader>gi", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> s <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "s", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> * <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "*", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>go <cmd>lua require("packer.load")({'vim-gh-line'}, { keys = "<lt>Leader>go", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gbP <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "gbP", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sxc <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sxc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sxx <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sxx", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sx <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sx", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sS <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sS", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>sr <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "<lt>Leader>sr", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>li <cmd>lua require("packer.load")({'twilight.nvim'}, { keys = "<lt>Leader>li", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> gs <cmd>lua require("packer.load")({'vim-grepper'}, { keys = "gs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g[P <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "g[P", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> sr <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "sr", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> se <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "se", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ld <cmd>lua require("packer.load")({'linediff.vim'}, { keys = "<lt>Leader>ld", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ss <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "ss", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> s <cmd>lua require("packer.load")({'substitute.nvim'}, { keys = "s", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> N <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "N", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <C-n> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-n>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> glP <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "glP", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[vnoremap <unique><silent> g_ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "g_", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[vnoremap <unique><silent> g+ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "g+", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[vnoremap <unique><silent> _ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "_", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[vnoremap <unique><silent> + <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "+", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> _ <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "_", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> + <cmd>lua require("packer.load")({'dial.nvim'}, { keys = "+", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>o <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>o", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gh <cmd>lua require("packer.load")({'diffview.nvim'}, { keys = "<lt>Leader>gh", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>g. <cmd>lua require("packer.load")({'diffview.nvim'}, { keys = "<lt>Leader>g.", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>g; <cmd>lua require("packer.load")({'diffview.nvim'}, { keys = "<lt>Leader>g;", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>sc <cmd>lua require("packer.load")({'ScratchPad'}, { keys = "<lt>Leader>sc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>ut <cmd>lua require("packer.load")({'undotree'}, { keys = "<lt>Leader>ut", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>dc <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>dc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gS <cmd>lua require("packer.load")({'spread.nvim'}, { keys = "gS", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> T <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "T", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gcP <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "gcP", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>es <cmd>lua require("packer.load")({'eregex.vim'}, { keys = "<lt>Leader>es", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>yr <cmd>lua require("packer.load")({'vCoolor.vim'}, { keys = "<lt>Leader>yr", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gi <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>gi", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> / <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>ga <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "<lt>Leader>ga", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> g* <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "g*", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>K <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>K", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g[p <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "g[p", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> ga <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ga", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ga <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "ga", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> f <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "f", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>pc <cmd>lua require("packer.load")({'vCoolor.vim'}, { keys = "<lt>Leader>pc", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gl <cmd>lua require("packer.load")({'vim-flog'}, { keys = "<lt>Leader>gl", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> N <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "N", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> F <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "F", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-S-<> <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>C-S-<lt>>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> # <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "#", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> * <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "*", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ? <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "?", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>gs <cmd>lua require("packer.load")({'vim-easy-align'}, { keys = "<lt>Leader>gs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>h <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>h", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> # <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "#", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gL <cmd>lua require("packer.load")({'vim-gh-line'}, { keys = "<lt>Leader>gL", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> ghp <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "ghp", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> t <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "t", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <M-S-o> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>M-S-o>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> t <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "t", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gs <cmd>lua require("packer.load")({'vim-grepper'}, { keys = "gs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> T <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "T", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>zm <cmd>lua require("packer.load")({'twilight.nvim'}, { keys = "<lt>Leader>zm", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>rg <cmd>lua require("packer.load")({'vim-grepper'}, { keys = "<lt>Leader>rg", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gsp <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "gsp", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> f <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "f", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-Down> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-Down>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> f <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "f", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>W <cmd>lua require("packer.load")({'suda.vim'}, { keys = "<lt>Leader>W", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g/ <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "g/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> N <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "N", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>j <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>j", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gbp <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "gbp", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-n> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-n>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>/ <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>/", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> T <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "T", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>A <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>A", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>\ <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>\\", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <M-S-i> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>M-S-i>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> F <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "F", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g[p <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "g[p", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-Up> <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>C-Up>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>k <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>k", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader><Leader>l <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>Leader><lt>Leader>l", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>dg <cmd>lua require("packer.load")({'neogen'}, { keys = "<lt>Leader>dg", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <C-S-:> <cmd>lua require("packer.load")({'hop.nvim'}, { keys = "<lt>C-S-:>", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[onoremap <unique><silent> n <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "n", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> <Leader>A <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>A", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> glp <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "glp", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> <Leader>gs <cmd>lua require("packer.load")({'vim-visual-multi'}, { keys = "<lt>Leader>gs", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> g]P <cmd>lua require("packer.load")({'UnconditionalPaste'}, { keys = "g]P", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[nnoremap <unique><silent> gJ <cmd>lua require("packer.load")({'spread.nvim'}, { keys = "gJ", prefix = "" }, _G.packer_plugins)<cr>]])
pcall(vim.cmd, [[xnoremap <unique><silent> n <cmd>lua require("packer.load")({'nvim-hlslens'}, { keys = "n", prefix = "" }, _G.packer_plugins)<cr>]])
time([[Defining lazy-load keymaps]], false)
end, 15)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType lf ++once lua require("packer.load")({'lf-vim'}, { ft = "lf" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'vim-table-mode', 'vim-markdown', 'vimwiki', 'mkdx'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType perl ++once lua require("packer.load")({'vim-perl'}, { ft = "perl" }, _G.packer_plugins)]]
vim.cmd [[au FileType vimwiki ++once lua require("packer.load")({'vim-table-mode', 'vim-markdown', 'vimwiki', 'mkdx'}, { ft = "vimwiki" }, _G.packer_plugins)]]
vim.cmd [[au FileType crystal ++once lua require("packer.load")({'vim-crystal'}, { ft = "crystal" }, _G.packer_plugins)]]
vim.cmd [[au FileType lua ++once lua require("packer.load")({'luv-vimdocs', 'nvim-luaref', 'nvim-luapad', 'nlua.nvim'}, { ft = "lua" }, _G.packer_plugins)]]
vim.cmd [[au FileType julia ++once lua require("packer.load")({'JuliaFormatter.vim'}, { ft = "julia" }, _G.packer_plugins)]]
vim.cmd [[au FileType python ++once lua require("packer.load")({'vim-slime'}, { ft = "python" }, _G.packer_plugins)]]
vim.cmd [[au FileType qf ++once lua require("packer.load")({'nvim-bqf'}, { ft = "qf" }, _G.packer_plugins)]]
vim.cmd [[au FileType rust ++once lua require("packer.load")({'rust.vim'}, { ft = "rust" }, _G.packer_plugins)]]
vim.cmd [[au FileType go ++once lua require("packer.load")({'vim-go'}, { ft = "go" }, _G.packer_plugins)]]
vim.cmd [[au FileType teal ++once lua require("packer.load")({'vim-teal'}, { ft = "teal" }, _G.packer_plugins)]]
vim.cmd [[au FileType zig ++once lua require("packer.load")({'zig.vim'}, { ft = "zig" }, _G.packer_plugins)]]
vim.cmd [[au FileType ron ++once lua require("packer.load")({'ron.vim'}, { ft = "ron" }, _G.packer_plugins)]]
vim.cmd [[au FileType just ++once lua require("packer.load")({'vim-just'}, { ft = "just" }, _G.packer_plugins)]]
vim.cmd [[au FileType rustpeg ++once lua require("packer.load")({'vim-rustpeg'}, { ft = "rustpeg" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufRead package.json ++once lua require("packer.load")({'package-info.nvim'}, { event = "BufRead package.json" }, _G.packer_plugins)]]
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'telescope-packer.nvim'}, { event = "VimEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead Cargo.toml ++once lua require("packer.load")({'crates.nvim'}, { event = "BufRead Cargo.toml" }, _G.packer_plugins)]]
vim.cmd [[au BufWinEnter * ++once lua require("packer.load")({'dressing.nvim'}, { event = "BufWinEnter *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-autopairs'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufEnter * ++once lua require("packer.load")({'nvim-scrollbar'}, { event = "BufEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/zig.vim/ftdetect/zig.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/zig.vim/ftdetect/zig.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/zig.vim/ftdetect/zig.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim/ftdetect/lf.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim/ftdetect/lf.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/lf-vim/ftdetect/lf.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg/ftdetect/rustpeg.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg/ftdetect/rustpeg.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-rustpeg/ftdetect/rustpeg.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim/ftdetect/rust.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim/ftdetect/rust.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/rust.vim/ftdetect/rust.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-markdown/ftdetect/markdown.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just/ftdetect/just.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just/ftdetect/just.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-just/ftdetect/just.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/crystal.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/crystal.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/crystal.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/ecrystal.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/ecrystal.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/ecrystal.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim/ftdetect/ron.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim/ftdetect/ron.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/ron.vim/ftdetect/ron.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/mason-in-html.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/mason-in-html.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/mason-in-html.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/perl11.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/perl11.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-perl/ftdetect/perl11.vim]], false)
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-teal/ftdetect/teal.vim]], true)
vim.cmd [[source /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-teal/ftdetect/teal.vim]]
time([[Sourcing ftdetect script at: /home/lucas/.local/share/nvim/site/pack/packer/opt/vim-teal/ftdetect/teal.vim]], false)
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