local macro = require('macro')
local utils = require('utils')

local pre_process = {

   --- Process macro calls and templates
   -- @param sT symbol table
   pre_process = function(sT)
      for _, val in pairs(sT.macroCall) do
         if not utils:isMacroSon(val) then
            local stack = {}
            macro:resolveCall(val, stack, sT)
         end
      end
      -- resolveTemplates()
   end,
}

return pre_process
