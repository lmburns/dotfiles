local wk = require("which-key")

wk.register({
    -- Misc. mappings [[[
    ["g?"] = "Flog: yank buffer",           -- <Plug>(FlogHelp)
    ["y<C-g>"] = "Flog: yank buffer",       -- <Plug>(FlogYank)
    ["git"] = "Flog: type :Floggit in cli", -- <Plug>(FlogGit)
    ["ZZ"] = "Flog: quit",                  -- <Plug>(FlogQuit)
    ["gq"] = "Flog: quit",                  -- <Plug>(FlogQuit)
    ["dq"] = "Flog: close side window",     -- <Plug>(FlogCloseTmpWin)
    --
    ["qd"] = "Flog: close side window ",    -- <Plug>(FlogCloseTmpWin)
    ["qq"] = "Flog: quit ",                 -- <Plug>(FlogQuit)
    ["Q"] = "Flog: quit ",                  -- <Plug>(FlogQuit)
    -- ]]]

    -- Diff mappings [[[
    ["D!"] = "Flog: open diff, compare last sel; use -path/-limit", -- <Plug>(FlogVDiffSplitLastCommitPathsRight)
    ["DD"] = "Flog: open diff tmp win, use -path/-limit",           -- <Plug>(FlogVDiffSplitPathsRight)
    ["DV"] = "Flog: open diff tmp win, use -path/-limit",           -- <Plug>(FlogVDiffSplitPathsRight)
    ["d!"] = "Flog: open diff, compare last selected",              -- <Plug>(FlogVDiffSplitLastCommitRight)
    ["d?"] = "Flog: diff help",                                     -- <Plug>(FlogDiffHelp)
    ["dd"] = "Flog: open diff tmp win, with HEAD",                  -- <Plug>(FlogVDiffSplitRight)
    ["dv"] = "Flog: open diff tmp win, with HEAD",                  -- <Plug>(FlogVDiffSplitRight)
    --
    ["dp"] = "Flog: open diff tmp win, use -path/-limit",           -- <Plug>(FlogVDiffSplitPathsRight)
    ["sc"] = "Flog: open diff, compare last selected",              -- <Plug>(FlogVDiffSplitLastCommitRight)
    ["sp"] = "Flog: open diff tmp win, use -path/-limit",           -- <Plug>(FlogVDiffSplitPathsRight)
    ["ss"] = "Flog: open diff tmp win, with HEAD",                  -- <Plug>(FlogVDiffSplitRight)
    -- ]]]

    -- Navigation mappings [[[
    -- gcg
    ["a"] = "Flog: toggle :Flog-all",                              -- <Plug>(FlogToggleAll)
    ["gb"] = "Flog: toggle :Flog-bisect",                          -- <Plug>(FlogToggleBisect)
    ["gm"] = "Flog: toggle :Flog-merges",                          -- <Plug>(FlogToggleMerges)
    ["gr"] = "Flog: toggle :Flog-reflog",                          -- <Plug>(FlogToggleReflog)
    ["gx"] = "Flog: toggle :Flog-graph",                           -- <Plug>(FlogToggleGraph)
    ["gp"] = "Flog: toggle :Flog-patch",                           -- <Plug>(FlogTogglePatch)
    ["g/"] = "Flog: open cli with ':Flogsetargs -search='",        -- <Plug>(FlogSearch)
    ["g\\"] = "Flog: open cli with ':Flogsetargs -patch-search='", -- <Plug>(FlogPatchSearch)
    ["goo"] = "Flog: cycle through diff order opts",               -- <Plug>(FlogCycleOrder)
    ["god"] = "Flog: set :Flog-order to 'date'",                   -- <Plug>(FlogOrderDate)
    ["goa"] = "Flog: set :Flog-order to 'author'",                 -- <Plug>(FlogOrderAuthor)
    ["got"] = "Flog: set :Flog-order to 'topo'",                   -- <Plug>(FlogOrderTopo)
    ["gor"] = "Flog: toggle :Flog-reverse",                        -- <Plug>(FlogToggleReverse)
    ["gcc"] = "Flog: unset :Flog-rev",                             -- <Plug>(FlogClearRev)
    ["gcg"] = "Flog: skip to commit [cnt], or 0th",                -- <Plug>(FlogSetSkip)
    ["gct"] = "Flog: set _-rev to cursor commit; clear _-skip",    -- <Plug>(FlogSetRev)
    ["gs"] = "Flog: show curr staged changes",                     -- <Plug>(FlogVSplitStaged)
    ["gu"] = "Flog: show curr untracked/unstaged changes",         -- <Plug>(FlogVSplitUntracked)
    ["gU"] = "Flog: show curr unstaged changes",                   -- <Plug>(FlogVSplitUnstaged)
    ["^"] = "Flog: start of curr commit branch",                   -- <Plug>(FlogJumpToCommitStart)
    -- FIX: Buffer keeps resizing bigger and bigger
    ["]]"] = "Flog: next commit in history",                       -- <Plug>(FlogSkipAhead)
    ["[["] = "Flog: prev commit in history ",                      -- <Plug>(FlogSkipBack)
    --
    ["<C-i>"] = "Flog: next [cnt] flog-jump-hist",                 -- <Plug>(FlogJumpToNewer)
    ["<C-o>"] = "Flog: prev [cnt] flog-jump-hist ",                -- <Plug>(FlogJumpToOlder)
    ["[f"] = "Flog: Nth child of commit ",                         -- <Plug>(FlogJumpToChild)
    ["]f"] = "Flog: Nth parent of commit",                         -- <Plug>(FlogJumpToParent)
    ["}"] = "Flog: next [cnt] commit",                             -- <Plug>(FlogNextCommit)
    ["{"] = "Flog: prev [cnt] commit ",                            -- <Plug>(FlogPrevCommit)
    ["]d"] = "Flog: next commit & open temp win",                  -- <Plug>(FlogVNextCommitRight)
    ["[d"] = "Flog: prev commit & open temp win ",                 -- <Plug>(FlogVPrevCommitRight)


    [")"] = "Flog: next commit & open temp win",
    ["("] = "Flog: next commit & open temp win",
    ["<A-n>"] = "Flog: next commit & open temp win",
    ["<A-p>"] = "Flog: prev commit & open temp win",
    ["]R"] = "Flog: ", -- <Plug>(FlogVNextRefRight)
    ["[R"] = "Flog: ", -- <Plug>(FlogVPrevRefRight)
    ["]r"] = "Flog: next commit with ref name",
    ["[r"] = "Flog: prev commit with ref name ",
    -- ]]]


    -- Commit/branch mappings [[[
    ["c?"] = "Flog: commit help",                                -- <Plug>(FlogCommitHelp)
    ["cs"] = "Flog: create '--squash' cursor commit ",           -- <Plug>(FlogSquash)
    ["cA"] = "Flog: equiv 'cs', but edit commit msg",            -- <Plug>(FlogSquashEdit)
    ["cF"] = "Flog: equiv 'cf', but 'rebase --autosquash'",      -- <Plug>(FlogFixupRebase)
    ["cS"] = "Flog: equiv 'cs', but 'rebase --autosquash'",      -- <Plug>(FlogSquashRebase)
    ["cf"] = "Flog: create '--fixup' commit for cursor commit",  -- <Plug>(FlogFixup)
    ["cob"] = "Flog: checkout 1st cursor branch",                -- <Plug>(FlogCheckoutBranch)
    ["col"] = "Flog: checkout 1st local cursor branch, or 1st",  -- <Plug>(FlogCheckoutLocalBranch)
    ["coo"] = "Flog: checkout cursor commit",                    -- <Plug>(FlogCheckout)
    ["crc"] = "Flog: revert cursor commit",                      -- <Plug>(FlogRevert)
    ["crn"] = "Flog: equiv 'crc', but use '--no-edit'",          -- <Plug>(FlogRevertNoEdit)
    ["c<Space>"] = "Flog: start cli with ':Floggit commit '",    -- <Plug>(FlogGitCommit)
    ["cb<Space>"] = "Flog: start cli with ':Floggit branch '",   -- <Plug>(FlogGitBranch)
    ["cm<Space>"] = "Flog: start cli with ':Floggit merge '",    -- <Plug>(FlogGitMerge)
    ["co<Space>"] = "Flog: start cli with ':Floggit checkout '", -- <Plug>(FlogGitCheckout)
    ["cr<Space>"] = "Flog: start cli with ':Floggit revert '",   -- <Plug>(FlogGitRevert)

    ["u"] = "Flog: update window",                               -- <Plug>(FlogUpdate)
    ["U"] = "Flog: update window ",                              -- <Plug>(FlogUpdate)
    ["<"] = "Flog: collapse body of commit",                     -- <Plug>(FlogCollapseCommit)
    [">"] = "Flog: expand body of commit",                       -- <Plug>(FlogExpandCommit)
    ["="] = "Flog: toggle collapsing body of commit",            -- <Plug>(FlogToggleCollapseCommit)
    ["o"] = "Flog: open commit in split ",                       -- <Plug>(FlogVSplitCommitRight)
    ["<CR>"] = "Flog: open commit in split",                     -- <Cmd>bel Flogsplitcommit<CR>
    ["<Tab>"] = "Flog: open selected in split",                  -- <Plug>(FlogVSplitCommitPathsRight)
    -- ]]]

    -- Rebase mappings [[[
    ["r?"] = "Flog: rebase help",                               -- <Plug>(FlogRebaseHelp)
    ["ri"] = "Flog: start irebase; use root of cursor commit",  -- <Plug>(FlogRebaseInteractive)
    ["rf"] = "Flog: do autosquash rebase w/o edit TODO list",   -- <Plug>(FlogRebaseInteractiveAutosquash)
    ["ru"] = "Flog: do irebase against '@{upstream}'",          -- <Plug>(FlogRebaseInteractiveUpstream)
    ["rp"] = "Flog: do irebase against '@{push}'",              -- <Plug>(FlogRebaseInteractivePush)
    ["rr"] = "Flog: run 'git rebase --continue'",               -- <Plug>(FlogRebaseContinue)
    ["rs"] = "Flog: run 'git rebase --skip'",                   -- <Plug>(FlogRebaseSkip)
    ["ra"] = "Flog: run 'git rebase --abort'",                  -- <Plug>(FlogRebaseAbort)
    ["re"] = "Flog: run 'git rebase --edit-todo'",              -- <Plug>(FlogRebaseEditTodo)
    ["rw"] = "Flog: start irebase with commit set to 'reword'", -- <Plug>(FlogRebaseInteractiveReword)
    ["rm"] = "Flog: start irebase with commit set to 'edit'",   -- <Plug>(FlogRebaseInteractiveEdit)
    ["rd"] = "Flog: start irebase with commit set to 'drop'",   -- <Plug>(FlogRebaseInteractiveDrop)
    ["r<Space>"] = "Flog: start cli ':Floggit rebase '",        -- <Plug>(FlogGitRebase)
    -- ]]]

    -- Mark mappings [[[
    ["m"] = "Flog: set commit mark",  -- <Plug>(FlogSetCommitMark)
    -- ["'"] = "Flog: jump commit mark", -- <Plug>(FlogJumpToCommitMark)
    ["'@"] = "Flog: jump curr head",
    ["'~"] = "Flog: jump parent of curr head",
    ["'^"] = "Flog: jump parent of curr head",
    ["'!"] = "Flog: jump last commit with %h",
    ["''"] = "Flog: jump last commit before jumping",
    -- ]]]


    -- My Mappings [[[
    -- ["rl"] = "Flog: ",
    -- ["rh"] = "Flog: ",
    ["rl"] = "Flog: reset",
    ["rh"] = "Flog: reset hard",

    -- ["<Leader>gt"] = "Flog: difftool cursor commit",
    ["<Leader>gt"] = "Flog: difftool cursor commit ",
    ["<Leader>gs"] = "Flog: set args cursor commit",
    ["<Leader>gp"] = "Flog: set args parent",
    -- Update the arguments passed to "git log
    ["<Leader>gr"] = "Flog: cli with Flogsetargs",
    ["<Leader>gj"] = "Flog: FlogJump",
    -- ]]]

    -- Vim navigation mappings [[[
    -- ["<C-f>"] = "Flog: scroll down",
    -- ["<C-b>"] = "Flog: scroll up",
    -- ["gg"] = "Flog: go to top",
    -- ["G"] = "Flog: go to bottom",
    -- ["<C-d>"] = "Flog: scroll down",
    -- ["<C-u>"] = "Flog: scroll up",
    -- ]]]
}, {mode = "n", buffer = 0})

wk.register({
    -- Misc. mappings [[[
    ["y<C-g>"] = "Flog: yank buffer",        -- <Plug>(FlogYank)
    ["git"] = "Flog: type :Floggit in cli ", -- <Plug>(FlogGit)
    -- ]]]

    -- Diff mappings [[[
    ["DD"] = "Flog: open diff tmp win, use -path/-limit ", -- <Plug>(FlogVDiffSplitPathsRight)
    ["DV"] = "Flog: open diff tmp win, use -path/-limit ", -- <Plug>(FlogVDiffSplitPathsRight)
    ["dd"] = "Flog: open diff tmp win, with HEAD",         -- <Plug>(FlogVDiffSplitRight)
    ["dv"] = "Flog: open diff tmp win, with HEAD",         -- <Plug>(FlogVDiffSplitRight)
    --
    ["dp"] = "Flog: open diff tmp win, use -path/-limit ", -- <Plug>(FlogVDiffSplitPathsRight)
    ["sp"] = "Flog: open diff tmp win, use -path/-limit ", -- <Plug>(FlogVDiffSplitPathsRight)
    ["ss"] = "Flog: open diff tmp win, with HEAD",         -- <Plug>(FlogVDiffSplitRight)
    -- ]]]

    -- Navigation mappings [[[
    ["^"] = "Flog: start of curr commit branch ", -- <Plug>(FlogJumpToCommitStart)
    -- ]]]

    -- Commit/branch mappings [[[
    ["c<Space>"] = "Flog: start cli with ':Floggit commit '",    -- <Plug>(FlogGitCommit)
    ["cb<Space>"] = "Flog: start cli with ':Floggit branch '",   -- <Plug>(FlogGitBranch)
    ["cm<Space>"] = "Flog: start cli with ':Floggit merge '",    -- <Plug>(FlogGitMerge)
    ["co<Space>"] = "Flog: start cli with ':Floggit checkout '", -- <Plug>(FlogGitCheckout)
    ["cr<Space>"] = "Flog: start cli with ':Floggit revert '",   -- <Plug>(FlogGitRevert)
    ["crc"] = "Flog: revert cursor commit",                      -- <Plug>(FlogRevert)
    ["crn"] = "Flog: equiv 'crc', but use '--no-edit'",          -- <Plug>(FlogRevertNoEdit)
    --
    ["<"] = "Flog: collapse body of commit",                     -- <Plug>(FlogCollapseCommit)
    [">"] = "Flog: expand body of commit",                       -- <Plug>(FlogExpandCommit)
    ["="] = "Flog: toggle collapsing body of commit",            -- <Plug>(FlogToggleCollapseCommit)
    -- ]]]

    -- Rebase mappings [[[
    ["r<Space>"] = "Flog: ", -- <Plug>(FlogGitRebase)
    -- ]]]

    -- Mark mappings [[[
    ["m"] = "Flog: set commit mark",  -- <Plug>(FlogSetCommitMark)
    ["'"] = "Flog: jump commit mark", -- <Plug>(FlogJumpToCommitMark)
    -- ]]]

    ["<Leader>gt"] = "Flog: ", -- :Floggit difftool -y<Space>
}, {mode = "v", buffer = 0})

wk.register({
}, {mode = "o", buffer = 0})
