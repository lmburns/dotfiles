local function escape_literal(literal)
  local special_chars = {
    ["\\"] = true,
    ["^"] = true,
    ["$"] = true,
    ["."] = true,
    ["*"] = true,
    ["("] = true,
    [")"] = true,
  }
  local r, _ = literal:gsub(".", function(char)
    if special_chars[char] then
      return ("\\" .. char)
    else
      return char
    end
  end)
  return r
end

local function make_special(value)
  return {type = "special", value = value}
end
local function make_literal(value, is_literal)
  return {type = "literal", value = value, ["is-literal"] = is_literal}
end
local function startswith(str, prefix)
  return (string.sub(str, 1, #prefix) == prefix)
end
local function get_node_type(v)
  if v.type then
    return v.type
  elseif (type(v) == "table") then
    return "tree"
  else
    return error(("not a node: %s"):format(v))
  end
end
local function is_group(v)
  if (get_node_type(v) ~= "tree") then
    return false
  else
    local first_node = v[1]
    return ((first_node.type == "special") and (first_node.value == "{"))
  end
end
local function split_group(group)
  local output = {}
  for _, node in ipairs(group) do
    if (node.type == "special") then
      if ((node.value == "{") or (node.value == ",")) then
        table.insert(output, {})
      elseif (node.value ~= "}") then
        table.insert(output[#output], node)
      else
      end
    else
      table.insert(output[#output], node)
    end
  end
  return output
end
local function compile_to_regex(tree)
  local function compile_special(value)
    local _7_ = value
    if (_7_ == "*") then
      return "[^/]*"
    elseif (_7_ == "?") then
      return "."
    elseif (_7_ == "{") then
      return "("
    elseif (_7_ == "}") then
      return ")"
    elseif (_7_ == ",") then
      return "|"
    else
      local function _8_()
        return startswith(value, "**")
      end
      if ((_7_ == value) and _8_()) then
        return ".*"
      elseif (_7_ == value) then
        return value
      else
        return nil
      end
    end
  end
  local function compile_literal(value, is_literal)
    if is_literal then
      return value
    else
      return escape_literal(value)
    end
  end
  local regex = ""
  for _, node in ipairs(tree) do
    local node_str
    do
      local _11_ = get_node_type(node)
      if (_11_ == "tree") then
        node_str = compile_to_regex(node)
      elseif (_11_ == "special") then
        node_str = compile_special(node.value)
      elseif (_11_ == "literal") then
        node_str = compile_literal(node.value, node["is-literal"])
      else
        node_str = nil
      end
    end
    regex = (regex .. node_str)
  end
  return regex
end
local lpeg = require("lpeg")
local Ct = lpeg.Ct
local C = lpeg.C
local P = lpeg.P
local S = lpeg.S
local R = lpeg.R
local V = lpeg.V
local glob_parser

do
  local GroupLiteralChar = (R("AZ") + R("az") + R("09") + S("!-+@_~;:./$^"))
  local LiteralChar = (GroupLiteralChar + S(",}"))
  local OneStar = (P("*") / make_special)
  local QuestionMark = (P("?") / make_special)
  local TwoStars = ((P("**") * (P("/*") ^ 0)) / make_special)
  local OpenGroup = (P("{") / make_special)
  local CloseGroup = (P("}") / make_special)
  local Comma = (P(",") / make_special)
  local OpenRange = (P("[") / make_special)
  local CloseRange = (P("]") / make_special)
  local RangeNegation = (P("!") / make_special)
  local RangeLiteral
  local function _14_(_241)
    return make_literal(_241, true)
  end
  RangeLiteral = (((P(1) - P("]")) ^ 1) / _14_)
  local InsideRange = ((RangeNegation ^ -1) * RangeLiteral)
  local Range = (OpenRange * InsideRange * CloseRange)
  local GroupLiteral = ((GroupLiteralChar ^ 1) / make_literal)
  local Literal = ((LiteralChar ^ 1) / make_literal)
  local Glob = V("Glob")
  local Term = V("Term")
  local InsideGroup = V("InsideGroup")
  local GroupGlob = V("GroupGlob")
  local GroupTerm = V("GroupTerm")
  local Group = V("Group")
  glob_parser = P({
    Glob,
    Glob = Ct((Term ^ 1)),
    Term = (TwoStars + OneStar + QuestionMark + Group + Literal + Range),
    Group = Ct((OpenGroup * InsideGroup * CloseGroup)),
    InsideGroup = (GroupGlob * ((Comma * GroupGlob) ^ 0)),
    GroupGlob = (GroupTerm ^ 1),
    GroupTerm = (TwoStars + OneStar + QuestionMark + Group + GroupLiteral + Range),
  })
end
local glob_parser0 = (glob_parser * -1)
local function parse(glob)
  return lpeg.match(glob_parser0, glob)
end
local function compile(glob)
  local tree = parse(glob)
  if tree then
    local rex = require("rex_pcre2")
    local re = compile_to_regex(tree)
    local re0 = ("^" .. re .. "$")
    local ok, pat_or_err = pcall(rex.new, re0)
    if ok then
      return true, pat_or_err
    else
      return false,
          string.format(
            "internal error compiling glob string '%s' to a regular expression:\n  generated regex: %s\n  pcre error: %s",
            glob, re0, pat_or_err)
    end
  else
    return false, string.format("invalid glob string '%s'", glob)
  end
end
local function do_match(patt, str)
  local m = patt:exec(str)
  if m then
    return true
  else
    return false
  end
end
local function break_tree(tree)
  local acc = {""}
  for _, node in ipairs(tree) do
    if is_group(node) then
      local trees = split_group(node)
      local broken_trees
      do
        local tbl_17_auto = {}
        local i_18_auto = #tbl_17_auto
        for _0, t in ipairs(trees) do
          local val_19_auto = break_tree(t)
          if (nil ~= val_19_auto) then
            i_18_auto = (i_18_auto + 1)
            do end
            (tbl_17_auto)[i_18_auto] = val_19_auto
          else
          end
        end
        broken_trees = tbl_17_auto
      end
      local result = {}
      for _0, nodes_str in ipairs(broken_trees) do
        for _1, node_str in ipairs(nodes_str) do
          for _2, e in ipairs(acc) do
            table.insert(result, (e .. node_str))
          end
        end
        result = result
      end
      acc = result
    else
      local tbl_17_auto = {}
      local i_18_auto = #tbl_17_auto
      for _0, e in ipairs(acc) do
        local val_19_auto = (e .. node.value)
        if (nil ~= val_19_auto) then
          i_18_auto = (i_18_auto + 1)
          do end
          (tbl_17_auto)[i_18_auto] = val_19_auto
        else
        end
      end
      acc = tbl_17_auto
    end
  end
  return acc
end
local function strip_special(glob)
  return string.gsub(glob, "/?[^/]+[*?[{].*", "")
end
local function _break(glob)
  local tree = parse(glob)
  if not tree then
    return vim.api.nvim_echo({{string.format("invalid glob %s", vim.inspect(glob)), "WarningMsg"}},
      true, {})
  else
    return break_tree(tree)
  end
end
return {
  compile = compile,
  match = do_match,
  ["break"] = _break,
  parse = parse,
  ["strip-special"] = strip_special,
}
