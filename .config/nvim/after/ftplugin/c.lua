local o = vim.opt_local

o.textwidth = 80
o.define = [[^\s*#\s*define]]
o.include = [[^\s*#\s*include]]
o.comments = [[sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,:///,://!,://]]
o.commentstring = [[// %s]]

o.path:append({"/usr/include/**", "/usr/local/include/**"})
-- o.path:append("/usr/include")
o.path:append(".")
