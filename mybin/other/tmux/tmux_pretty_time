#!/usr/bin/env bash

uptime | awk -F'[ ,:\t\n]+' '{
      msg = " "
      if ($7 == "day" || $7 == "days") {
        msg = msg $6 $7 " "
        n = $8
        o = $9
      } else {
        n = $6
        o = $7
      }

      if (int(o) == 0) {
        msg = msg int(n)" "o
      } else {
        msg = msg int(n) "h "
        msg = msg int(o) "m"
      }

      print msg
    }'
