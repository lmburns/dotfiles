local M = {}

local D = require("dev")
local hop = D.npcall(require, "hop")
if not hop then
    return
end

local utils = require("common.utils")
local map = utils.map

local hint_direction = require("hop.hint").HintDirection
local hint_with = require("hop").hint_with
local window = require("hop.window")
local jump_target = require("hop.jump_target")

-- =============================== Hop ================================
function M.setup()
    -- "etovxqpdygfblzhckisuran"
    -- "asdfjklhmnwertzxcvbuio"
    hop.setup({keys = "abcdefghijklmnopqrstuvwxyz;',."})
end

local function wrap_targets(targets)
    local cursor_pos = require("hop.window").get_window_context()[1].contexts[1].cursor_pos
    local indir = {}
    for i, v in ipairs(targets) do
        indir[#indir + 1] = {
            index = i,
            score = -jump_target.manh_dist({v.line, v.column}, cursor_pos)
        }
    end
    -- local indir = setmetatable({}, zero_jump_scores)
    return {jump_targets = targets, indirect_jump_targets = indir}
end

local function treesitter_filter_window(node, contexts, nodes_set)
    local context = contexts[1].contexts[1]
    local line, col, start = node:start()
    if line <= context.bot_line and line >= context.top_line then
        nodes_set[start] = {line = line, column = col + 1, window = 0}
    end
end

local treesitter_queries = function(query, inners, outers, queryfile)
    queryfile = queryfile or "textobjects"
    if inners == nil then
        inners = true
    end
    if outers == nil then
        outers = true
    end

    return function(_hint_opts)
        local context = window.get_window_context()
        local queries = require("nvim-treesitter.query")
        local tsutils = require("nvim-treesitter.utils")
        local nodes_set = {}
        -- utils.dump(queries.collect_group_results(0, "textobjects"))

        local function extract(match)
            for _, node in pairs(match) do
                if inners and node.outer then
                    treesitter_filter_window(node.outer.node, context, nodes_set)
                end
                if outers and node.inner then
                    treesitter_filter_window(node.inner.node, context, nodes_set)
                end
            end
        end

        if query == nil then
            for match in queries.iter_group_results(0, queryfile) do
                extract(match)
            end
        else
            for match in queries.iter_group_results(0, queryfile) do
                local insert = tsutils.get_at_path(match, query)
                if insert then
                    extract(match)
                end
            end
        end

        return wrap_targets(vim.tbl_values(nodes_set))
    end
end

---Use hop on textobjects
---Source: IndianBoy42/hop-extensions
function M.hint_textobjects(query, opts)
    if type(query) == "string" then
        query = {query = query}
    end
    hint_with(
        treesitter_queries(
            query and query.query,
            query and query.inners,
            query and query.outers,
            query and query.queryfile
        ),
        setmetatable(opts or {}, {__index = require("hop").opts})
    )
end

local function init()
    M.setup()

    -- map("n", "<Leader><Leader>k", ":HopLineBC<CR>")
    -- map("n", "<Leader><Leader>j", ":HopLineAC<CR>")
    map("n", "<Leader><Leader>k", ":HopLineStartBC<CR>")
    map("n", "<Leader><Leader>j", ":HopLineStartAC<CR>")

    map("n", "<Leader><Leader>l", ":HopAnywhereCurrentLineAC<CR>", {desc = "Hop current line AC"})
    map("n", "<Leader><Leader>h", ":HopAnywhereCurrentLineBC<CR>", {desc = "Hop current line BC"})
    map("n", "<Leader><Leader>K", ":HopWordBC<CR>", {desc = "Hop any word BC"})
    map("n", "<Leader><Leader>J", ":HopWordAC<CR>", {desc = "Hop any word AC"})
    map("n", "<Leader><Leader>/", ":HopPattern<CR>", {desc = "Hop pattern"})
    map("n", "<C-S-:>", ":lua require('plugs.hop').hint_textobjects()<CR>", {desc = "Hop textobjects"})
    -- map("n", "<C-S-:>", ":HopWord<CR>", {desc = "Hop any word"})
    map("n", "<C-S-<>", ":HopLine<CR>", {desc = "Hop any line"})

    map("n", "g(", "require'hop'.hint_patterns({}, '(')", {desc = "Previous brace", luacmd = true})
    map("n", "g)", "require'hop'.hint_patterns({}, ')')", {desc = "Next brace", luacmd = true})

    -- ========================== f-Mapping ==========================

    -- Normal
    map(
        "n",
        "f",
        function()
            hop.hint_char1({direction = hint_direction.AFTER_CURSOR, current_line_only = true})
        end
    )

    -- Normal
    map(
        "n",
        "F",
        function()
            hop.hint_char1({direction = hint_direction.BEFORE_CURSOR, current_line_only = true})
        end
    )

    -- Motions
    map(
        "o",
        "f",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.AFTER_CURSOR,
                    current_line_only = true,
                    inclusive_jump = true
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "F",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.BEFORE_CURSOR,
                    current_line_only = true
                    -- inclusive_jump = true
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "f",
        function()
            hop.hint_char1({direction = hint_direction.AFTER_CURSOR, current_line_only = true})
        end
    )

    -- Visual mode
    map(
        "x",
        "F",
        function()
            hop.hint_char1({direction = hint_direction.BEFORE_CURSOR, current_line_only = true})
        end
    )

    -- ========================== t-Mapping ==========================

    -- Normal
    map(
        "n",
        "t",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.AFTER_CURSOR,
                    current_line_only = true,
                    hint_offset = -1
                }
            )
        end
    )

    -- Normal
    map(
        "n",
        "T",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.BEFORE_CURSOR,
                    current_line_only = true,
                    hint_offset = 1,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "t",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.AFTER_CURSOR,
                    current_line_only = true,
                    hint_offset = -1,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Motions
    map(
        "o",
        "T",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.BEFORE_CURSOR,
                    current_line_only = true,
                    hint_offset = 1,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "t",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.AFTER_CURSOR,
                    current_line_only = true,
                    hint_offset = -1,
                    inclusive_jump = false
                }
            )
        end
    )

    -- Visual mode
    map(
        "x",
        "T",
        function()
            hop.hint_char1(
                {
                    direction = hint_direction.BEFORE_CURSOR,
                    current_line_only = true,
                    hint_offset = 1,
                    inclusive_jump = false
                }
            )
        end
    )
end

init()

return M
