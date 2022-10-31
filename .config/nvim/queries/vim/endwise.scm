((if_statement condition: (_) @cursor) @endable @indent (#endwise! "endif"))
((for_loop iter: (_) @cursor) @indent (#endwise! "endfor"))
((while_loop condition: (_) @cursor) @indent (#endwise! "endwhile"))
((function_definition "function" @indent (function_declaration parameters: (_) @cursor) . ["abort" "closure" "dict" "range"]* @cursor) @endable (#endwise! "end" @indent "endfunction"))
((try_statement "try" @cursor) @endable @indent (#endwise! "endtry"))

((ERROR ("if" @indent . (_) @cursor)) (#endwise! "endif"))
((ERROR ("for" @indent . (_) . "in" . (_) @cursor)) (#endwise! "endfor"))
((ERROR ("while" @indent . (_) @cursor)) (#endwise! "endwhile"))
((ERROR ("function" @indent (bang)? . (function_declaration parameters: (_) @cursor) ["abort" "closure" "dict" "range"]* @cursor)) (#endwise! "end" @indent))
((ERROR ("try" @indent @cursor)) (#endwise! "endtry"))
