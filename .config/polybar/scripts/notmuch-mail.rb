#!/usr/bin/env ruby

# encoding: UTF-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

inbox = `/usr/bin/notmuch --config=/home/lucas/.config/notmuch/notmuch-config search tag:unread`

mails = inbox.split("\n")
puts " #{mails.length}"
