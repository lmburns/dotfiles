" Copyright 2017 The Chromium Authors. All rights reserved.
" Use of this source code is governed by a BSD-style license that can be
" found in the LICENSE file.

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setl includeexpr=gn#TranslateToBuildFile(v:fname)
setl commentstring=#\ %s

let b:undo_ftplugin = "setl cms< inex<"
