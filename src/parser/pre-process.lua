local utils = require"utils"
local gbl = utils.globals

local pre_process = {
   pre_process = function()
      for _, val in pairs(gbl.macroCallTbl) do
         if not val.father then
            local stack = {}
            resolveCall(val, stack)
         end
      end
      -- resolveTemplates
      resolveXConnectors()
   end,

   resolveXConnectorBinds = function(xconn, bind)
      if xconn[bind._type][bind.role] then
         xconn[bind._type][bind.role] = xconn[bind._type][bind.role]+1
      else
         xconn[bind._type][bind.role] = 1
      end
      if xconn.id:find(bind.role:gsub("^%l",string.upper)) then
         xconn.id = xconn.id.."N"
      else
         xconn.id = xconn.id..bind.role:gsub("^%l",string.upper)
      end
      if bind.properties then
         for name, _ in pairs(bind.properties) do
            table.insert(xconn.properties, name)
         end
      end
   end,

   resolveXConnectors = function(tbl)
      for _, link in pairs(tbl) do
         local newConn = {_type="xconnector", id="__", condition = {}, action = {}, properties={}}

         for _, cond in pairs(link.conditions) do
            resolveXConnectorBinds(newConn, cond)
         end
         for _, act in pairs(link.actions) do
            resolveXConnectorBinds(newConn, act)
         end
         if link.properties then
            for name, _ in pairs(link.properties) do
               table.insert(newConn.properties, name)
            end
         end
         -- TODO: Has to do all above to check if another equal
         -- connect is already created, wasting time. How to fix?
         link.xconnector = newConn.id
         if not gblHeadTbl[newConn.id] then
            gblHeadTbl[newConn.id] = newConn
         end
      end
   end
}

return pre_process
