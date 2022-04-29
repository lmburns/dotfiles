local M = {}

local map = require("common.utils").map

--[[
| Key       | Option             | Values                                                     |
| --------- | ------------------ | --------------------------------------------------         |
| `CTRL-F`  | `filter`           | Input string (`[gv]/.*/?`)                                 |
| `CTRL-I`  | `indentation`      | shallow, deep, none, keep                                  |
| `CTRL-L`  | `left_margin`      | Input number or string                                     |
| `CTRL-R`  | `right_margin`     | Input number or string                                     |
| `CTRL-D`  | `delimiter_align`  | left, center, right                                        |
| `CTRL-U`  | `ignore_unmatched` | 0, 1                                                       |
| `CTRL-G`  | `ignore_groups`    | `[]`, `['String']`, `['Comment']`, `['String', 'Comment']` |
| `CTRL-A`  | `align`            | Input string (`/[lrc]+\*{0,2}/`)                           |
| `<Left>`  | `stick_to_left`    | `{ 'stick_to_left': 1, 'left_margin': 0 }`                 |
| `<Right>` | `stick_to_left`    | `{ 'stick_to_left': 0, 'left_margin': 1 }`                 |
| `<Down>`  | `*_margin`         | `{ 'left_margin': 0, 'right_margin': 0 }`                  |
]]
function M.setup()
    g.easy_align_bypass_fold = 1

    local equal_sign =
        _t(
        {
            "===",
            "<=>",
            [[\(&&\|||\|<<\|>>\)=]],
            [[=\~[#?]\?]],
            "=>",
            [[[:+/*!%^=><&|.-]\?=[#?]\?]],
            "\\~="
        }
    )
    local gt_sign = _t({">>", "=>", ">"})
    local lt_sign = _t({"<<", "=<", "<"})

    g.easy_align_delimiters = {
        ["f"] = {pattern = [[ \(\S\+(\)\@=]], left_margin = 0, right_margin = 0},
        [">"] = {pattern = table.concat(gt_sign, "\\|")},
        ["<"] = {pattern = table.concat(lt_sign, "\\|")},
        ["\\"] = {pattern = [[\]]},
        ["/"] = {
            pattern = [[//\+\|/\*\|\*/]],
            delimiter_align = "l",
            ignore_groups = {"!Comment"}
        },
        ["]"] = {
            -- pattern = "[[\\]]",
            pattern = [[\]\zs]],
            left_margin = 0,
            right_margin = 0,
            stick_to_left = 0
        },
        [")"] = {
            -- pattern = "[()]",
            pattern = [[)\zs]],
            left_margin = 0,
            right_margin = 0,
            stick_to_left = 0
        },
        d = {
            -- pattern = [[ \(\S\+\s*[;=]\)\@=]],
            pattern = [==[ \ze\S\+\s*[;=]]==],
            left_margin = 0,
            right_margin = 0
        },
        s = {
            pattern = table.concat(equal_sign:merge(lt_sign:merge(gt_sign)), "\\|"),
            left_margin = 1,
            right_margin = 1,
            stick_to_left = 0
        },
        ['"'] = {
            pattern = '\\"',
            ignore_groups = {"!Comment"},
            ignore_unmatched = 0
        }
    }
end

local function init()
    M.setup()

    map("x", "ga", "<Plug>(EasyAlign)", {noremap = false})
    map("x", "<Leader>ga", "<Plug>(LiveEasyAlign)", {noremap = false})
    map(
        "x",
        "<Leader>gi",
        [[:EasyAlign//ig['Comment']<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>]],
        {noremap = false}
    )
    map(
        "x",
        "<Leader>gs",
        [[:EasyAlign//ig['String']<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>]],
        {noremap = false}
    )
end

init()

return M
