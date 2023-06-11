---@class Usr.Lib.Pcre
local M = {}

-- Vim:
-- +--------+--------------------------+---------------+
-- | syntax | description              | documentation |
-- +--------+--------------------------+---------------|
-- | \|     | logical OR (alternation) | :help /\|     |
-- | \(bc\) | treat `bc` as a group    | :help /atom   |
-- | \=     | zero or one occurrences  | :help \=      |
-- | \?     | zero or one occurrences  | :help \?      |
-- | \{-\}  | zero or more occurrences |               |
-- | \%[]   | make the match optional  | :help \%[]    |
-- | \v     | "very magic": omit \'s   | :help \v      |
-- +--------+--------------------------+---------------+

-- Positive lookahead (?=) (\@=)  - next thing has to be
--   foo\(bar\)\@=  =>  "foo" if followed by "bar"
--   /foo(?=bar)/   =>  "foo" if followed by "bar" (Perl)

-- Negative lookahead (?!) (\@!)  - next thing can't be
--   foo\(bar\)\@!  =>  "foo" if not followed by "bar"
--   /foo(?!bar)/   =>  "foo" if not followed by "bar"

-- Positive lookbehind (?<=) (\@<=)
--   \(foo\)\@<=bar  =>  "bar" when preceded by "foo"
--   /(?<=foo)bar/   =>  "bar" when preceded by "foo"  foobar

--     Start match         (\K) (\zs)
--       \([a-z]\+\)\zs,\1  =>  ",abc" in "abc,abc"
--       ([a-z]+)\K,\1      =>  ",abc" in "abc,abc"

-- Negative lookbehind (?<!) (\@<!)
--   \(foo\)\@<!bar  =>  "bar" when NOT preceded by "foo"
--   /(?<!foo)bar/   =>  "bar" when NOT preceded by "foo"

local api = vim.api

-- http://rrthomas.github.io/lrexlib/manual.html

---@type PCRE
local rex = require("rex_pcre2")

function M.search_all(pattern, bufnr)
    bufnr = bufnr and bufnr or api.nvim_get_current_buf()
    local pos = {}
    -- local start = vim.loop.hrtime()
    local re = rex.new(pattern)
    local len = api.nvim_buf_line_count(bufnr)
    local j = 1
    while j <= len do
        local i = 1
        local line = api.nvim_buf_get_lines(bufnr, j - 1, j, false)[1]
        while i <= #line do
            local s, e = re:find(line, i)
            if s then
                table.insert(pos, {s, e})
                i = e + 1
            else
                break
            end
        end
        j = j + 1
    end

    -- info('find')
    -- local text = table.concat(lines, '\n')
    -- rex.gsub(text, pattern, '', function(s, e, _)
    --     table.insert(pos, {s, e})
    --     return false, false
    -- end)
    -- info('gsub')
    -- info(vim.loop.hrtime() - start)
    return pos
end

-- local flgs = rex.flags()
-- flgs.CASELESS

---Create a new compiled regex
---@param pattern string
---@return PCREObj
function M.new(pattern)
    return rex.new(pattern)
end

return M
