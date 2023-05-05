local D = require("dev")
local coc = require("plugs.coc")
local mpi = require("common.api")

local function bmap(...)
    mpi.bmap(0, ...)
end

vim.bo.include = [[\v<((do|load)file|require)[^''"]*[''"]\zs[^''"]+]]
-- o.matchpairs:append({"if:end", "function:end"})

local function kw_prog(word)
    local original_iskeyword = vim.bo.iskeyword

    vim.bo.iskeyword = vim.bo.iskeyword .. ",."
    word = word or vim.fn.expand("<cword>")

    vim.bo.iskeyword = original_iskeyword

    if word:find("vim.api") then
        local _, finish = word:find("vim.api.")
        local api_function = word:sub(finish + 1)

        vim.cmd(("help %s"):format(api_function))
        return
    elseif word:find("vim.fn") then
        local _, finish = word:find("vim.fn.")
        local api_function = word:sub(finish + 1) .. "()"

        vim.cmd(("help %s"):format(api_function))
        return
    else
        local ok = pcall(vim.cmd, ("help %s"):format(word))

        if not ok then
            local split_word = vim.split(word, ".", {plain = true})
            ok = pcall(vim.cmd, ("help %s"):format(split_word[#split_word]))
        end
    end
end

bmap("n", "<Leader>tt", "<Plug>PlenaryTestFile", {desc = "Plenary test"})
bmap("n", "M", D.ithunk(kw_prog), {desc = "Find keyword"})

bmap(
    "n",
    "<Leader>jR",
    D.ithunk(coc.run_command, "sumneko-lua.restart", {}),
    {desc = "Reload Lua workspace"}
)
