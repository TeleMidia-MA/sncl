#!/usr/bin/env lua
require"new-grammar"
require"pegdebug"
require"gen"
local lpeg = require"lpeg"
local pT = require"print-table"
local inspect = require"inspect"

-- TODO: Macro cant have recursion

gblPresTbl = {}
gblLinkTbl = {}
gblMacroTbl = {}
gblMacroCallTbl = {}

_DEBUG_PEG = false
_DEBUG_PARSE_TABLE = false
_DEBUG_SYMBOL_TABLE = false

function main()
   local file = io.open(arg[1])
   local sncl = file:read("*all")
   file:close(file)
   if _DEBUG_PEG then
      lpeg.match(require("pegdebug").trace(grammar), sncl)
   else
      lpeg.match(grammar, sncl)
   end

   resolveMacroCalls(gblMacroCallTbl)

   if _DEBUG_SYMBOL_TABLE then
      print("Symbol Table:", inspect.inspect(gblPresTbl))
      print("macro table:", inspect.inspect(gblMacroTbl))
      print("macro call table:", inspect.inspect(gblMacroCallTbl))
   end
   local NCL = genNCL(gblPresTbl,"")
   print(NCL)
end

function isMacroSon(ele)
   if ele.father then
      if ele.father._type == "macro" then
         return true
      else
         return isMacroSon(ele.father)
      end
   else
      return false
   end
end

main()
