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
local helpers = require("neogen.utilities.helpers")
local i = require("neogen.types.template").item
i.Struct = "struct"
i.Enum = "enum"
i.Preproc = "preproc"
i.PreprocFunc = "preproc_func"
i.PreprocParam = "preproc_param"

function M.setup(aa)
    local langs_t = {}

    langs_t.lua = {
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
    }

    langs_t.python = {
        template = {annotation_convention = "numpydoc"},
    }

    langs_t.rust = {
        template = {annotation_convention = "rustdoc"},
    }

    local c = require("neogen.configurations.c")
    langs_t.c = {
        template = {
            annotation_convention = "doxygen_alt",
            doxygen_alt = {
                --  * @struct <name> [<header-file>] [<header-name>]
                --  * @union  <name> [<header-file>] [<header-name>]
                --  * @enum   <name>
                --  * @var    (variable declaration)
                --  * @def    MAX(x,y)

                -- {nil, "/// @file", {no_results = true, type = {"file"}}},
                -- {nil, "/// @brief $1", {no_results = true, type = {"func", "file", "class"}}},
                -- {nil, "", {no_results = true, type = {"file"}}},
                --
                {nil, "/**", {no_results = true, type = {"func", "file", "class"}}},
                {nil, " * @file", {no_results = true, type = {"file"}}},
                {nil, " * @author", {no_results = true, type = {"file"}}},
                -- {nil, " * @headerfile", {no_results = true, type = {"file"}}},
                {nil, " * @brief $1", {no_results = true, type = {"func", "file", "class"}}},
                {nil, " */", {no_results = true, type = {"func", "file", "class"}}},
                {nil, "", {no_results = true, type = {"file"}}},
                --
                {i.ClassName, "/// @class %s", {type = {"class"}}},
                -- {i.Struct, "/// @brief %s", {type = {"type"}}},
                -- {i.Enum, "/// @brief %s", {type = {"type"}}},
                -- {i.Preproc, "/// @brief %s", {type = {"type"}}},
                {i.Struct, "/// @struct %s", {type = {"type"}}},
                {i.Enum, "/// @enum %s", {type = {"type"}}},
                {i.Type, "/// @typedef %s", {type = {"type"}}},
                {i.Preproc, "/// @def %s", {type = {"type"}}},
                {i.PreprocFunc, "/// @def %s($1)", {type = {"func"}}},
                -- {{i.PreprocFunc, i.Parameter}, "/// @def %s(%s)", {required = i.Parameter, type = {"func"}}},
                {nil, "/// @brief $1", {type = {"func", "class", "type"}}},
                {i.Tparam, "/// @tparam %s $1"},
                {i.Parameter, "/// @param %s $1"},
                {i.Return, "/// @return $1"},
            },
        },
        parent = {
            file = c.parent.file,
            func = {
                "function_declaration",
                "function_definition",
                "declaration",
                "field_declaration",
                "template_declaration",
                "preproc_function_def",
            },
            type = {
                "type_definition",
                "struct_specifier",
                "enum_specifier",
                "declaration",
                "preproc_def",
            },
        },
        data = {
            type = {
                ["preproc_def"] = {
                    ["0"] = {
                        extract = function(node)
                            local tree = {{
                                retrieve = "first",
                                node_type = "identifier",
                                extract = true,
                                as = i.Preproc,
                            }}
                            local nodes = nodes_utils:matching_nodes_from(node, tree)
                            local res = extractors:extract_from_matched(nodes)
                            return res
                        end,
                    },
                },
                ["type_definition"] = {
                    ["1"] = {
                        extract = function(node)
                            local tree = {{
                                retrieve = "first",
                                node_type = "type_identifier",
                                extract = true,
                                as = i.Type,
                            }}
                            local nodes = nodes_utils:matching_nodes_from(node, tree)
                            local res = extractors:extract_from_matched(nodes)
                            return res
                        end,
                    },
                },
                ["struct_specifier"] = {
                    ["0"] = {
                        extract = function(node)
                            local parent = node:parent()
                            local as = i.Struct
                            if parent:type() == "type_definition" then
                                as = i.Type
                            end

                            local tree = {{
                                retrieve = "first",
                                node_type = "type_identifier",
                                extract = true,
                                as = as,
                            }}

                            local nodes = nodes_utils:matching_nodes_from(node, tree)
                            local res = extractors:extract_from_matched(nodes)
                            return res
                        end,
                    },
                },
                ["enum_specifier"] = {
                    ["0"] = {
                        extract = function(node)
                            local parent = node:parent()
                            local as = i.Enum
                            if parent:type() == "type_definition" then
                                as = i.Type
                            end

                            local tree = {{
                                retrieve = "first",
                                node_type = "type_identifier",
                                extract = true,
                                as = as,
                            }}

                            local nodes = nodes_utils:matching_nodes_from(node, tree)
                            local res = extractors:extract_from_matched(nodes)
                            return res
                        end,
                    },
                },
                ["declaration"] = {
                    ["0"] = {
                        extract = function(node)
                            local tree = {{
                                retrieve = "first",
                                node_type = "primitive_type",
                                extract = true,
                                as = i.Struct,
                            }}
                            local nodes = nodes_utils:matching_nodes_from(node, tree)
                            local res = extractors:extract_from_matched(nodes)
                            return res
                        end,
                    },
                },
            },
            func = {
                -- preproc_function_def [24, 0] - [27, 0]
                --   name: identifier [24, 8] - [24, 12]
                --   parameters: preproc_params [24, 12] - [24, 21]
                --     identifier [24, 13] - [24, 17]
                --     identifier [24, 19] - [24, 20]
                --   value: preproc_arg [24, 22] - [26, 22]

                --                 local regular_params = neogen.utilities.extractors:extract_children_text("identifier")(node)
                --                 local varargs = neogen.utilities.extractors:extract_children_text("spread")(node)
                ["preproc_function_def"] = {
                    ["0"] = {
                        extract = function(node)
                            local tree = {{
                                retrieve = "first",
                                node_type = "identifier",
                                extract = true,
                                as = i.PreprocFunc,
                            }, {
                                retrieve = "first",
                                node_type = "preproc_params",
                                subtree = {{
                                    retrieve = "all",
                                    node_type = "identifier",
                                    extract = true,
                                    as = i.Parameter,
                                }},
                            }}
                            local nodes = nodes_utils:matching_nodes_from(node, tree)
                            local res = extractors:extract_from_matched(nodes)
                            return res

                            -- local j = {
                            --     [i.PreprocFunc] = res.preproc_func,
                            --     [i.Parameter] = res.parameters,
                            --     [i.PreprocParam] =  res.parameters
                            --     -- [i.Return] = {true},
                            -- }
                            -- N(j)
                            -- return j
                        end,
                    },
                },
            },
            -- file = c.data.file,
        },
        -- locator = c.locator,
    }

    langs_t.vim = {
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
                            local tree = {{
                                retrieve = "first",
                                node_type = "parameters",
                                subtree = {{
                                    retrieve = "all",
                                    node_type = "identifier",
                                    extract = true,
                                    as = i.Parameter,
                                }, {
                                    retrieve = "all",
                                    node_type = "spread",
                                    extract = true,
                                    as = i.Vararg,
                                }},
                            }}

                            local nodes = nodes_utils:matching_nodes_from(node, tree)
                            local res = extractors:extract_from_matched(nodes)

                            return res
                        end,

                    },
                    ["3"] = {
                        match = "body",
                        extract = function(node)
                            local tree = {{
                                retrieve = "first",
                                node_type = "return_statement",
                                extract = true,
                                as = i.Return,
                            }}

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
                            local tree = {{
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
                            }}

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
    }

    neogen.setup({
        enabled = true,
        input_after_comment = true,
        -- Placeholders used during annotation expansion
        placeholders_text = {
            ["description"] = "[TODO:description]",
            ["tparam"] = "[TODO:tparam]",
            ["parameter"] = "[TODO:parameter]",
            ["return"] = "[TODO:return]",
            ["class"] = "[TODO:class]",
            ["throw"] = "[TODO:throw]",
            ["varargs"] = "[TODO:varargs]",
            ["type"] = "[TODO:type]",
            ["attribute"] = "[TODO:attribute]",
            ["args"] = "[TODO:args]",
            ["kwargs"] = "[TODO:kwargs]",
        },
        -- Placeholders highlights to use. If you don't want custom highlight, pass "None"
        placeholders_hl = "@symbol",

        languages = langs_t,
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
