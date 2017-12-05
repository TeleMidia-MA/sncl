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
   local connId = ""
   local conditionsTable = {}
   local actionsTable = {}
   -- TODO: create connectorParam for bindParam of conditions
   local condId = ""

   local actionId = ""
   for _, action in pairs(self.actions) do
      local act = action.action

      act = act:upper()
      if not actionId:find(act) then
         actionId = actionId..act
         actionsTable[action.action] = {
            times = 1
         }
      else
         actionsTable[action.action].times = actionsTable[action.action].times+1
      end
      for prop, _ in pairs(action.propriedades) do
         prop = prop:sub(1,1):upper()..prop:sub(2)
         if not actionId:find(prop) then
            actionsTable[action.action]
            actionId = actionId..prop
         end
      end

   end
   print("ActionId:", actionId)

   connId = condId..actionId
   if not tabelaSimbolos.connectors[connId] then
      local newConnector = Connector.new(connId)
      newConnector:addConditions(conditionsTable)
      newConnector:addActions(actionsTable)
      tabelaSimbolos.connectors[connId] = newConnector
   end
   self.xconnector = connId
end

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
      NCL = NCL..indent.."   <linkParam name=\""..pos.."\" value=\""..val.."\"/>"
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

function Link:parsePropriedade(str)
   local name, value = utils.separateSymbol(str)
   if name and value then
      self.propriedades[name] = value
   end
end

return link
