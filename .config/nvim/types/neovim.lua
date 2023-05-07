---@meta
---Neovim library extra stuff

--  ╭──────────────────────────────────────────────────────────╮
--  │                         vim.cmd                          │
--  ╰──────────────────────────────────────────────────────────╯

---@class Vim.Cmd.Opts
---@field cmd string command name
---@field range? string[] optional range (`<line1>` `<line2>`) (omitted if cannot take range)
---@field count? number command `<count>` (omitted if cannot take count)
---@field reg? string command `<register>` (omitted if cannot take register)
---@field bang? boolean whether command contains a `<bang>` (!) modifier
---@field args? string[] command arguments
---@field addr? CommandAddr value of `:command-addr`. uses short name or "line" for -addr=lines
---@field nargs? CommandNargs value of `:command-nargs`
---@field nextcmd? string next command if there's multiple separated by `<Bar>` ("" if none)
---@field magic? Vim.Cmd.Opts.Magic which chars have special meaning in command args
---@field mods? Vim.Cmd.Mods command modifiers

---@class Vim.Cmd.Opts.Magic
---@field file boolean command expands filenames ("%", "#", etc. are expanded)
---@field bar boolean "|" = is treated as command sep, '"' = start of comment

---@class Vim.Cmd.Mods
---@field silent boolean `:silent`
---@field emsg_silent boolean `:silent!`
---@field unsilent boolean `:unsilent`
---@field sandbox boolean `:sandbox`
---@field noautocmd boolean `:noautocmd`
---@field browse boolean `:browse`
---@field confirm boolean `:confirm`
---@field hide boolean `:hide`
---@field horizontal boolean `:horizontal`
---@field vertical boolean `:vertical`
---@field keepalt boolean `:keepalt`
---@field keepjumps boolean `:keepjumps`
---@field keepmarks boolean `:keepmarks`
---@field keeppatterns boolean `:keeppatterns`
---@field lockmarks boolean `:lockmarks`
---@field noswapfile boolean `:noswapfile`
---@field tab integer `:tab` (-1 when omitted)
---@field verbose integer `:verbose` (-1 when omitted)
---@field filter Vim.Cmd.Mods.Filter `:filter`
---@field split Vim.Cmd.Mods.SplitModifier|"''" split modifier ("" if none)

---@class Vim.Cmd.Mods.Filter
---@field pattern string filter pattern ("" if none)
---@field force boolean whether filter is inverted or not

---@alias Vim.Cmd.Mods.SplitModifier
---|   "'aboveleft'"  `:aboveleft`
---|   "'belowright'" `:belowright`
---|   "'topleft'"    `:topleft`
---|   "'botright'"   `:botright`

---Execute Vim script commands.
---```lua
---  vim.cmd('echo "foo"')
---  vim.cmd { cmd = 'echo', args = { '"foo"' } }
---  vim.cmd.echo({ args = { '"foo"' } })
---  vim.cmd.echo('"foo"')
---  vim.cmd('write! myfile.txt')
---  vim.cmd { cmd = 'write', args = { "myfile.txt" }, bang = true }
---  vim.cmd.write { args = { "myfile.txt" }, bang = true }
---  vim.cmd.write { "myfile.txt", bang = true }
---  vim.cmd('colorscheme blue')
---  vim.cmd.colorscheme('blue')
---```
---@param command string|Vim.Cmd.Opts command(s) to execute
function vim.cmd(command)
end
