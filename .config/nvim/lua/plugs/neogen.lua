---@module 'plugs.neogen'
---@author 'lmburns'
---@description 'Code documentation generator'
---@plugin 'danymat/neogen'
local M = {}

local F = Rc.F
local neogen = F.npcall(require, "neogen")
if not neogen then
    return
end

local map = Rc.api.map
-- local command = Rc.api.command

local extractors = require("neogen.utilities.extractors")
local nodes_utils = require("neogen.utilities.nodes")
local i = require("neogen.types.template").item

function M.setup()
    neogen.setup({
        enabled = true,
        input_after_comment = true,
        languages = {
            lua = {
                template = {
                    annotation_convention = "emmylua",
                    emmylua = {
                        {nil, "- $1", {type = {"class", "func"}}},
                        {nil, "- $1", {no_results = true, type = {"class", "func"}}},
                        {nil, "-@module '$1'", {no_results = true, type = {"file"}}},
                        {nil, "-@author '$1'", {no_results = true, type = {"file"}}},
                        {nil, "-@license '$1'", {no_results = true, type = {"file"}}},
                        {nil, "-@description '$1'", {no_results = true, type = {"file"}}},
                        {nil, "", {no_results = true, type = {"file"}}},
                        {i.Parameter, "-@param %s $1|any"},
                        {i.Vararg, "-@param ... $1|any"},
                        {i.Return, "-@return $1|any"},
                        {i.ClassName, "-@class $1|any"},
                        {i.Type, "-@type $1"},
                    },
                },
            },
            python = {
                template = {annotation_convention = "numpydoc"},
            },
            c = {
                template = {annotation_convention = "doxygen"},
            },
            vim = {
                parent = {
                    func = {"function_definition"},
                    class = {"let_statement"},
                    -- type = {"let_statement"},
                    -- file = {"module"},
                },
                data = {
                    func = {
                        ["function_definition"] = {
                            ["2"] = {
                                match = "function_declaration",
                                extract = function(node)
                                    local tree = {
                                        {
                                            retrieve = "first",
                                            node_type = "parameters",
                                            subtree = {
                                                {
                                                    retrieve = "all",
                                                    node_type = "identifier",
                                                    extract = true,
                                                    as = i.Parameter,
                                                },
                                                {
                                                    retrieve = "all",
                                                    node_type = "spread",
                                                    extract = true,
                                                    as = i.Vararg,
                                                },
                                            },
                                        },
                                    }

                                    local nodes = nodes_utils:matching_nodes_from(node, tree)
                                    local res = extractors:extract_from_matched(nodes)

                                    return res
                                end,

                            },
                            ["3"] = {
                                match = "body",
                                extract = function(node)
                                    local tree = {
                                        {
                                            retrieve = "first",
                                            node_type = "return_statement",
                                            extract = true,
                                            as = i.Return,
                                        },
                                    }

                                    local nodes = nodes_utils:matching_nodes_from(node, tree)
                                    local res = extractors:extract_from_matched(nodes)
                                    return res
                                end,

                            },
                        },
                    },
                    class = {
                        ["let_statement"] = {
                            ["0"] = {
                                extract = function(node)
                                    local tree = {
                                        {
                                            retrieve = "first",
                                            node_type = "scoped_identifier",
                                            subtree = {
                                                {
                                                    retrieve = "all",
                                                    node_type = "scope",
                                                    extract = true,
                                                    as = i.ClassAttribute,
                                                },
                                                {
                                                    retrieve = "all",
                                                    node_type = "identifier",
                                                    extract = true,
                                                    as = i.ClassName,
                                                },
                                            },
                                        },
                                    }

                                    local nodes = nodes_utils:matching_nodes_from(node, tree)
                                    local res = extractors:extract_from_matched(nodes)

                                    return res
                                end,
                            },
                        },
                    },
                },
                template = {
                    annotation_convention = "vimdoc",
                    vimdoc = {
                        {nil, " $1", {type = {"func"}}},
                        {nil, " $1", {no_results = true}},
                        -- {i.Parameter, " @param %s {$1|any}"},
                        {i.Parameter, " @param %s $1|any"},
                        {i.Vararg, " @param ... $1|any"},
                        {i.Return, " @return $1|any"},
                        {i.ClassName, " @class %s", {type = {"class"}}},
                        {i.ClassAttribute, " Scope: %s"},
                        {i.Type, " @type $1"},
                    },
                },
            },
        },
    })
end

local function init()
    M.setup()

    map("i", "<C-S-j>", [[<Cmd>lua require('neogen').jump_next()<CR>]])
    map("i", "<C-S-k>", [[<Cmd>lua require('neogen').jump_prev()<CR>]])
    map("n", "<Leader>dg", [[:Neogen<Space>]], {desc = "Neogen <text>"})
    map("n", "<Leader>dn", [[<Cmd>Neogen<CR>]], {desc = "Neogen default"})
    map("n", "<Leader>df", F.ithunk(neogen.generate, {type = "func"}), {desc = "Neogen: func"})
    map("n", "<Leader>dc", F.ithunk(neogen.generate, {type = "class"}), {desc = "Neogen: class"})
    map("n", "<Leader>dt", F.ithunk(neogen.generate, {type = "type"}), {desc = "Neogen: type"})
    map("n", "<Leader>dF", F.ithunk(neogen.generate, {type = "file"}), {desc = "Neogen: file"})
end

init()

return M
