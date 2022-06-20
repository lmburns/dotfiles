-- Alternative to the above
autopairs.add_rule(
    Rule("<", ">"):with_move(
        function(opts)
            if opts.char == ">" then
                return true
            end
            return false
        end
    )
)

autopairs.add_rule(
    Rule("", ">"):use_key(">"):with_pair(cond.none()):with_move(
        function(opts)
            return opts.char == ">"
        end
    )
)

autopairs.add_rule(
    Rule("<", "<del>"):with_pair(
        function(opts)
            local prev_char = nil
            if opts.col > 1 then
                local pos = opts.col - 1
                prev_char = opts.line:sub(pos, pos)
            end
            return prev_char ~= nil and prev_char == "<" and opts.next_char == ">"
        end
    )
)

-- Example: tab = b1234s => B1234S124S
autopairs.add_rules(
    {
        Rule("b%d%d%d%d%w$", "", "vim"):use_regex(true, "<tab>"):replace_endpair(
            function(opts)
                return opts.prev_char:sub(#opts.prev_char - 4, #opts.prev_char) .. "<esc>viwU"
            end
        )
    }
)
