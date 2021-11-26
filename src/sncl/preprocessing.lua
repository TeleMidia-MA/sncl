local macro = require('sncl.macro')
local utils = require('sncl.utils')

local preprocessing = {

   --- Process macro calls and templates
   -- @param sT symbol table
   pre_process = function(symbolsTable)
      for _, val in pairs(symbolsTable.macroCall) do
         if not utils:isMacroSon(val) then
            local stack = {}
            macro:call(val, stack, sT)
         end
      end
      -- resolveTemplates()
   end,
}

return preprocessing
