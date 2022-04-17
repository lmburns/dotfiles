-- =============================== Path ===============================
-- ====================================================================

---Check if a given path is absolute.
---@param path string
---@return boolean
function M.path_is_abs(path)
    if is_windows then
        return path:match([[^%a:\]]) ~= nil
    else
        return path:sub(1, 1) == "/"
    end
end

---Joins an ordered list of path segments into a path string.
---@param paths string[]
---@return string
function M.path_join(paths)
    local result = paths[1]
    for i = 2, #paths do
        if tostring(paths[i]):sub(1, 1) == path_sep then
            result = result .. paths[i]
        else
            result = result .. path_sep .. paths[i]
        end
    end
    return result
end

---Explodes the path into an ordered list of path segments.
---@param path string
---@return string[]
function M.path_explode(path)
    local parts = {}
    for part in path:gmatch(string.format("([^%s]+)%s?", path_sep, path_sep)) do
        table.insert(parts, part)
    end
    return parts
end

---Get the basename of the given path.
---@param path string
---@return string
function M.path_basename(path)
    path = M.path_remove_trailing(path)
    local i = path:match("^.*()" .. path_sep)
    if not i then
        return path
    end
    return path:sub(i + 1, #path)
end

function M.path_extension(path)
    path = M.path_basename(path)
    return path:match(".+%.(.*)")
end

---Get the path to the parent directory of the given path. Returns `nil` if the
---path has no parent.
---@param path string
---@param remove_trailing boolean
---@return string|nil
function M.path_parent(path, remove_trailing)
    path = " " .. M.path_remove_trailing(path)
    local i = path:match("^.+()" .. path_sep)
    if not i then
        return nil
    end
    path = path:sub(2, i)
    if remove_trailing then
        path = M.path_remove_trailing(path)
    end
    return path
end

---Get a path relative to another path.
---@param path string
---@param relative_to string
---@return string
function M.path_relative(path, relative_to)
    local p, _ = path:gsub("^" .. M.pattern_esc(M.path_add_trailing(relative_to)), "")
    return p
end

function M.path_add_trailing(path)
    if path:sub(-1) == path_sep then
        return path
    end

    return path .. path_sep
end

function M.path_remove_trailing(path)
    local p, _ = path:gsub(path_sep .. "$", "")
    return p
end

function M.path_shorten(path, max_length)
    if string.len(path) > max_length - 1 then
        path = path:sub(string.len(path) - max_length + 1, string.len(path))
        local i = path:match("()" .. path_sep)
        if not i then
            return "…" .. path
        end
        return "…" .. path:sub(i, -1)
    else
        return path
    end
end
