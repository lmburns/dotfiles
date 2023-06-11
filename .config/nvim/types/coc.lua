---@meta
---@description coc.nvim

---@class Coc
local Coc = {}
---@class Coc.Config
local config = {}
---@class Coc.Fn
local fn = {}
---@class Coc.Snippet
local snippet = {}
---@class Coc.Float
local float = {}
---@class Coc.Notify
local notify = {}
---@class Coc.Pum
local pum = {}

---Get configuration of current document
---@param key? string
---@return Dict<string>|Dict<Dict<string>>
function config.get(key)
end

---Set an item in Coc's config
---@param section string
---@param value Dict<string>|Dict<Dict<string>>
---@return Vim.bool
function config.set(section, value)
end

---Check if Coc is ready
---@return boolean
function fn.ready()
end

---Start or refresh completion at current cursor position
function fn.refresh()
end

---Notify coc.nvim that <CR> has been pressed.
---Used for the format on type and improvement of brackets.
function fn.on_enter()
end

---Select first completion item if no completion item is selected, then
---confirm the completion like `coc#pum#confirm()`
---@return "'<Ignore>'"
function fn.select_confirm()
end

---Check if a snippet is expandable at the current position.
---Requires `coc-snippets` extension installed.
---@return boolean
function fn.expandable()
end

---Check if a snippet is jumpable at the current position.
---@return boolean
function fn.jumpable()
end

---Check if a snippet is expandable or jumpable at the current position.
---@return boolean
function fn.expandableOrJumpable()
end

---Return a status string that can be used in the status line, the status
---includes diagnostic information from `vim.b.coc_diagnostic_info` and
---extension contributed statuses from `vim.g.coc_status`. For statusline
---integration, see |coc-status|.
---@param esc? boolean|Vim.bool
---@return string
function fn.status(esc)
end

---Add custom Vim command to commands list opened by `:CocList commands`.
---@param id string unique command ID
---@param cmd string command name
---@param title? string text viewed in `:CocList`
---@return string
function fn.add_command(id, cmd, title)
end

---@param provider Coc.Providers
---@return boolean
function fn.has_provider(provider)
end

---Jump to next placeholder, does nothing when `coc#jumpable` is 0.
function snippet.next()
end

---Jump to previous placeholder, does nothing when `coc#jumpable` is 0.
function snippet.prev()
end

---Check if float window/popup exists, check coc.nvim's float
---window/popup by default.
---@param ... integer
---@return Vim.bool
function float.has_float(...)
end

---Get visible float windows
---@param all? boolean|Vim.bool
---@return integer[]
function float.get_float_win_list(all)
end

---Close all float windows/popups created by coc.nvim,
---set `all` to `1` for all float window/popups.
---@param ... 1|true|winid window ids
---@return "''"
function float.close_all(...)
end

---Close float window/popup with `winid`
---@param winid winid
function float.close(winid)
end

---Return `1` when there is scrollable float window/popup created by coc.nvim.
---@return Vim.bool
function float.has_scroll()
end

---Scroll all scrollable float windows, backward when `forward` is not `1`.
---Popup menu is excluded.
---@param forward Vim.bool should scroll forward?
---@param amount? integer about to scroll by; could be number or full page when omitted
---@return Vim.bool
function float.scroll(forward, amount)
end

---Check if PUM is visible like `pumvisible()` does.
---@return Vim.bool visible `1` when pum is visible
function pum.visible()
end

---Select next item of PUM, insert word when `insert` is truth value.
---Note: should only be used in `<expr>` mappings.
---@param insert Vim.bool|boolean
function pum.next(insert)
end

---Select prev item of PUM, insert word when `insert` is truth value.
---Note: should only be used in `<expr>` mappings.
---@param insert Vim.bool|boolean
function pum.prev(insert)
end

---Close the PUM, works like `<C-x><C-z>` of vim.
---Note: should only be used in `<expr>` mappings.
function pum.stop()
end

---Cancel PUM and revert trigger input, like `<C-e>` of vim.
---When no completion item selected, close the popup menu only.
---Note: should only be used in `<expr>` mappings.
function pum.cancel()
end

---Insert word of selected item and finish completion.
---Unlike `coc#pum#confirm()`, no text edit is applied & snippet not expanded.
---Note: should only be used in `<expr>` mappings.
function pum.insert()
end

---Confirm completion of selected item & close PUM, like `<C-y>` of vim.
---Note: should only be used in `<expr>` mappings.
function pum.confirm()
end

---Return information of the PUM.
---Note: should only be used when `coc#pum#visible()` is `1`.
---@return Coc.Pum.Info
function pum.info()
end

---Selects an item in the completion popupmenu.
---@param idx integer (zero-based) of the item to select
---@param insert? boolean should selection be inserted in the buffer?
---@param confirm? boolean confirm and dismiss the pum, implies `insert`.
---@return "''"
function pum.select(idx, insert, confirm)
end

---Insert one more character from current complete item (first complete
---item when no complete item selected), works like `<CTRL-L>` of `popupmenu-keys`.
---Nothing happens when failed.
---Note: word of complete item should starts with current input.
---Note: should only be used in `<expr>` mappings.
function pum.one_more()
end

---Scroll the popupmenu forward or backward by page.
---Timer is used to make it works as {rhs} of key-mappings.
---@param forward Vim.bool|boolean
---@return "'<Ignore>'"
function pum.scroll(forward)
end

---Close all notification windows
function notify.close_all()
end

---Invoke action for all notification wins, or givin window with `winid`.
---@param winid? winid
function notify.do_action(winid)
end

---Copy all content from notifications to system clipboard
function notify.copy()
end

---Show source name (extension name) in notification windows.
function notify.show_sources()
end

---Stop auto hide timer of notification windows.
function notify.keep()
end

---@alias Coc.CodeAction.Mode
---| "'currline'"
---| "'cursor'"
---| "'V'"
---| "'C-V'"

---@alias Coc.CodeAction_t
---| "''"
---| "'refactor'" base kind for refactoring actions
---| "'quickfix'" base kind for quickfix actions
---| "'refactor.extract'" base kind for refactoring extraction actions
---| "'refactor.inline'" base kind for refactoring inline actions
---| "'refactor.rewrite'" base kind for refactoring rewrite actions
---| "'source'" base kind for source actions
---| "'source.organizeImports'" base kind for an organize imports source action
---| "'source.fixAll'" base kind for auto-fix source actions

---@class Coc.Locations
---@field filename string full file path
---@field lnum integer line number (1 based)
---@field col integer column number(1 based)
---@field text string  line content of location

---@class Coc.Pum.Info
---@field index integer current select item index, 0 based
---@field scrollbar integer non-zero if a scrollbar is displayed.
---@field row row screen row count, 0 based
---@field col column screen column count, 0 based
---@field width integer width of pum, including padding and border
---@field height integer height of pum, including padding and border
---@field size integer count of displayed complete items
---@field inserted integer `v:true` when there is item inserted
---@field reversed integer `v:true` when pum shown above cursor

---@class Outline
---@field filter_kind SymbolKind[]
---@field fzf boolean
---@field bufnr number?

---@alias SymbolKind
---|  '"Array"'
---|  '"Boolean"'
---|  '"Class"'
---|  '"Constant"'
---|  '"Constructor"'
---|  '"Enum"'
---|  '"EnumMember"'
---|  '"Event"'
---|  '"Field"'
---|  '"File"'
---|  '"Function"'
---|  '"Interface"'
---|  '"Key"'
---|  '"Method"'
---|  '"Module"'
---|  '"Namespace"'
---|  '"Null"'
---|  '"Number"'
---|  '"Object"'
---|  '"Operator"'
---|  '"Package"'
---|  '"Property"'
---|  '"String"'
---|  '"Struct"'
---|  '"TypeParameter"'
---|  '"Variable"'

---@alias Coc.Providers
---| '"rename"'
---| '"onTypeEdit"'
---| '"documentLink"'
---| '"documentColor"'
---| '"foldingRange"'
---| '"format"'
---| '"codeAction"'
---| '"workspaceSymbols"'
---| '"formatRange"'
---| '"hover"'
---| '"signature"'
---| '"documentSymbol"'
---| '"documentHighlight"'
---| '"definition"'
---| '"declaration"'
---| '"typeDefinition"'
---| '"reference"'
---| '"implementation"'
---| '"codeLens"'
---| '"selectionRange"'

---@alias Coc.Actions
---| '"checkJsonExtension"'
---| '"rootPatterns"'
---| '"ensureDocument"'
---| '"addWorkspaceFolder"'
---| '"getConfig"'
---| '"doAutocmd"'
---| '"openLog"'
---| '"attach"'
---| '"detach"'
---| '"doKeymap"'
---| '"registerExtensions"'
---| '"snippetCheck"'
---| '"snippetInsert"'
---| '"snippetNext"'
---| '"snippetPrev"'
---| '"snippetCancel"'
---| '"openLocalConfig"'
---| '"bufferCheck"'
---| '"showInfo"'
---| '"hasProvider"'
---| '"cursorsSelect"'
---| '"fillDiagnostics"'
---| '"commandList"'
---| '"selectSymbolRange"'
---| '"openList"'
---| '"listNames"'
---| '"listDescriptions"'
---| '"listLoadItems"'
---| '"listResume"'
---| '"listCancel"'
---| '"listPrev"'
---| '"listNext"'
---| '"listFirst"'
---| '"listLast"'
---| '"sendRequest"'
---| '"sendNotification"'
---| '"registerNotification"'
---| '"updateConfig"'
---| '"links"'
---| '"openLink"'
---| '"pickColor"'
---| '"colorPresentation"'
---| '"highlight"'
---| '"fold"'
---| '"startCompletion"'
---| '"sourceStat"'
---| '"refreshSource"'
---| '"toggleSource"'
---| '"diagnosticRefresh"'
---| '"diagnosticInfo"'
---| '"diagnosticToggle"'
---| '"diagnosticToggleBuffer"'
---| '"diagnosticNext"'
---| '"diagnosticPrevious"'
---| '"diagnosticPreview"'
---| '"diagnosticList"'
---| '"findLocations"'
---| '"getTagList"'
---| '"definitions"'
---| '"declarations"'
---| '"implementations"'
---| '"typeDefinitions"'
---| '"references"'
---| '"jumpUsed"'
---| '"jumpDefinition"'
---| '"jumpReferences"'
---| '"jumpTypeDefinition"'
---| '"jumpDeclaration"'
---| '"jumpImplementation"'
---| '"doHover"'
---| '"definitionHover"'
---| '"getHover"'
---| '"showSignatureHelp"'
---| '"documentSymbols"'
---| '"symbolRanges"'
---| '"selectionRanges"'
---| '"rangeSelect"'
---| '"rename"'
---| '"getWorkspaceSymbols"'
---| '"resolveWorkspaceSymbol"'
---| '"formatSelected"'
---| '"format"'
---| '"commands"'
---| '"services"'
---| '"toggleService"'
---| '"codeAction"'
---| '"organizeImport"'
---| '"fixAll"'
---| '"doCodeAction"'
---| '"codeActions"'
---| '"quickfixes"'
---| '"codeLensAction"'
---| '"doQuickfix"'
---| '"search"'
---| '"saveRefactor"'
---| '"refactor"'
---| '"runCommand"'
---| '"repeatCommand"'
---| '"installExtensions"'
---| '"updateExtensions"'
---| '"extensionStats"'
---| '"loadedExtensions"'
---| '"watchExtension"'
---| '"activeExtension"'
---| '"deactivateExtension"'
---| '"reloadExtension"'
---| '"toggleExtension"'
---| '"uninstallExtension"'
---| '"getCurrentFunctionSymbol"'
---| '"showOutline"'
---| '"hideOutline"'
---| '"getWordEdit"'
---| '"addCommand"'
---| '"addRanges"'
---| '"currentWorkspacePath"'
---| '"selectCurrentPlaceholder"'
---| '"codeActionRange"'
---| '"incomingCalls"'
---| '"outgoingCalls"'
---| '"showIncomingCalls"'
---| '"showOutgoingCalls"'
---| '"showSuperTypes"'
---| '"showSubTypes"'
---| '"inspectSemanticToken"'
---| '"semanticHighlight"'
---| '"showSemanticHighlightInfo"'
