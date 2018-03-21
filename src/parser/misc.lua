#!/usr/bin/env lua
require"new-grammar"

local lpeg = require"lpeg"

function main()
   local file = io.open(arg[1])
   local sncl = file:read("*all")
   file:close(file)
   lpeg.match(grammar, sncl)
end

main()

