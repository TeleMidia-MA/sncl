local utils = require('utils')
local gbl = require('globals')

local pre_process = {

   pre_process = function()
      for _, val in pairs(gbl.macroCallTbl) do
         if not val.father then
            local stack = {}
            resolveCall(val, stack)
         end
      end
      -- resolveTemplates
   end,
}

return pre_process
