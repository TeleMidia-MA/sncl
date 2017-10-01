Link = {}
Link_mt = {}

Link_mt.__index = Link

function Link.new(linha)
   local linkObject = {
      xconnector = nil,
      temEnd = false,
      pai = nil,
      linha = linha,
      conditions = {},
      actions = {},
      tipo = "link",
   }
   setmetatable(linkObject, Link_mt)
   return linkObject
end

function Link:getActions() return self.actions end
function Link:getConditions() return self.conditions end

function Link:addCondition(condition)
   table.insert(self.conditions, condition)
end
function Link:addAction(action)
   table.insert(self.actions, action)
end

function Link:createConnector()
   local id = ""
   local nConditions = 0
   local nActions = 0
   local conditionsTable = {}
   local actionsTable = {}

   for __, val in pairs(self.conditions) do
      local condition = val.condition
      if conditionsTable[condition] == nil then
         if val:getParam() then
            conditionsTable[condition] = {
               param = true,
               times = 1,
            }
         else
            conditionsTable[condition] = {
               param = false,
               times = 1,
            }
         end
      else
         conditionsTable[condition].times = conditionsTable[condition].times+1
      end
      condition = condition:sub(1,1):upper()..condition:sub(2)
      if id:find(condition) then
         local __,endCondition = id:find(condition)
         id = id:sub(1, endCondition).."N"..id:sub(endCondition+1)
      else
         nConditions = nConditions+1
         id = id..condition
      end
      if val:getParam() then
         if not id:find("_condVar") then
            id = id.."_condVar"
         end
      end
   end

   for pos, val in pairs(self.actions) do
      local action = val.action
      if actionsTable[action] == nil then --Se Link ainda não tiver essa Action
         actionsTable[action] = { --Adicionar Action
            times = 1,
            propriedades = {},
         }
         for i,__ in pairs(val.propriedades) do --Adicionar Propriedades da Action
            table.insert(actionsTable[action].propriedades, i)
         end
      else
         actionsTable[action].times = actionsTable[action].times+1
      end

      action = action:sub(1,1):upper()..action:sub(2)
      if id:find(action) then
         local __,endAction = id:find(action)
         id = id:sub(1, endAction).."N"..id:sub(endAction+1)
      else
         nActions = nActions+1
         id = id..action
      end
   end

   if tabelaSimbolos.connectors[id] == nil then
      local newConnector = Connector.new(id)
      newConnector:addConditions(conditionsTable)
      newConnector:addActions(actionsTable)
      newConnector:setNumCondsAndActions(nConditions, nActions)
      tabelaSimbolos.connectors[id] = newConnector
   end
   self.xconnector = id
end

function Link:toNCL(indent)
   if self.hasEnd == false then
      utils.printErro("Elemento Link não tem end.", self.linha)
      return ""
   end
   self:createConnector()

   local link = indent.."<link xconnector=\""..self.xconnector.."\">"

   ------ Conditions
   local hasCondition = false
   for pos, val in pairs (self.conditions) do
      link = link..val:toNCL(indent.."   ")
      hasCondition = true
   end

   ------ Actions
   local hasAction = false
   for pos, val in pairs(self.actions) do
      link = link..val:toNCL(indent.."   ")
      hasAction = true
   end
   if not hasCondition or not hasAction then
      utils.printErro("Elemento Link deve ter ao menos 1 ação e 1 condição.", self.linha)
      return ""
   end

   link = link..indent.."</link>" 

   return link
end
