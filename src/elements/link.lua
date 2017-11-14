local utils = require("utils")
local link = {}
local Link = {}

function link.new(linha)
   local self = {
      xconnector = nil,
      temEnd = false,
      pai = nil,
      linha = linha,
      conditions = {},
      actions = {},
      propriedades = {},
      tipo = "link",
   }
   setmetatable(self, {__index = Link})
   return self
end

function Link:getActions() return self.actions end
function Link:getConditions() return self.conditions end

function Link:addCondition(condition)
   table.insert(self.conditions, condition)
end
function Link:addAction(action)
   table.insert(self.actions, action)
end
function Link:addPropriedade(nome, valor)
   self.propriedades[nome] = valor
end

function Link:createConnector()
   local id = ""
   local nConditions = 0
   local nActions = 0
   local conditionsTable = {}
   local actionsTable = {}
   -- TODO: create connectorParam for bindParam of conditions

   for _, val in pairs(self.conditions) do
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
         local _,endCondition = id:find(condition)
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

   for _, val in pairs(self.actions) do
      local action = val.action
      if actionsTable[action] == nil then -- Se Link ainda não tiver essa Action
         actionsTable[action] = { -- Adicionar Action
            times = 1,
            propriedades = {},
         }
         for i,_ in pairs(val.propriedades) do -- Adicionar Propriedades da Action
            table.insert(actionsTable[action].propriedades, i)
         end
      else
         actionsTable[action].times = actionsTable[action].times+1
      end

      action = action:sub(1,1):upper()..action:sub(2)
      if id:find(action) then
         local _,endAction = id:find(action)
         id = id:sub(1, endAction).."N"..id:sub(endAction+1)
      else
         nActions = nActions+1
         id = id..action
      end
   end

   if not tabelaSimbolos.connectors[id] then
      local newConnector = Connector.new(id)
      newConnector:addConditions(conditionsTable)
      newConnector:addActions(actionsTable)
      newConnector:setNumCondsAndActions(nConditions, nActions)
      tabelaSimbolos.connectors[id] = newConnector
   end
   self.xconnector = id
end

-- Code Generation
function Link:check()
   if self.hasEnd == false then
      utils.printErro("Element Link does not have end", self.linha)
      return
   end
   for _, val in pairs(self.conditions) do
      val:check()
   end
   for _, val in pairs(self.actions) do
      val:check()
   end
end

function Link:toNCL(indent)
   self:createConnector()
   local NCL = indent.."<link xconnector=\""..self.xconnector.."\">"

   -- Link Params
   for pos, val in pairs(self.propriedades) do
      NCL = NCL..indent.."   <linkParam name=\""..pos.."\" value="..val.."/>"
   end

   -- Conditions
   local hasCondition = false
   for _, val in pairs (self.conditions) do
      NCL = NCL..val:toNCL(indent.."   ")
      hasCondition = true
   end

   -- Actions
   local hasAction = false
   for _, val in pairs(self.actions) do
      NCL = NCL..val:toNCL(indent.."   ")
      hasAction = true
   end
   if not hasCondition or not hasAction then
      utils.printErro("Link element must have at least 1 action and 1 condition", self.linha)
      return ""
   end

   NCL = NCL..indent.."</link>"

   return NCL
end

function Link:parseProperty(str)
   local name, value = utils.separateSymbol(str)
   if name and value then
      self.propriedades[name] = value
   end
end

return link
