local utils = require("utils")
local lpeg = require("lpeg")
lpeg.locale(lpeg)
local V, P, R, C, Cg = lpeg.V, lpeg.P, lpeg.R, lpeg.C, lpeg.Cg

function parseId(str)
   local words = utils.splitSpace(str)

   if #words == 1 then
      return words[1]
   elseif #words == 2 then
      return words[2]
   else
      utils.printErro("Invalid id "..str, gblParserLine)
      return nil
   end
end

function parseRefer(str)
   -- Format of refer: "refer: component.interface"
   local sign = str:find(":")
   if sign then
      local value = str:sub(sign+1)
      local dot = value:find("%.")
      local interface, media
      if dot then
         interface = value:sub(dot+1)
         media =  value:sub(1, dot-1)
      else
         media = value
      end
      gblCurrentElement:setRefer(media, interface)
   end
end

function parseLinkCondition(str)
   --Separar as palavras por espaco
   local words = {}
   for word in str:gmatch("%S+") do
      table.insert(words, word)
   end

   if #words < 3 then
      utils.printErro("Error in link declaration", gblParserLine)
      return
   end
   local condCount, mediaCount = 1, 2
   local condition = words[condCount]
   local media = words[mediaCount]
   while condition and media do
      condition = utils.splitSymbol(condition, "%.")

      local interface
      media, interface = utils.splitSymbol(media, "%.")

      if gblCurrentElement ~= nil then
         if gblCurrentElement._type == "link" then --Se for link, adicionar condicao
            local newCondition = Condition.new(condition, media, interface, gblParserLine)
            newCondition.father = gblCurrentElement
            gblCurrentElement:addCondition(newCondition)

         elseif gblCurrentElement._type == "context" then
            local newLink = Link.new(gblParserLine)
            newLink.father = gblCurrentElement
            gblCurrentElement:addSon(newLink)
            gblCurrentElement = newLink
            local newCondition = Condition.new(condition, media, interface, gblParserLine)
            newCondition.father = gblCurrentElement
            gblCurrentElement:addCondition(newCondition)

         elseif gblCurrentElement._type == "macro" then
            local newLink = Link.new()
            gblCurrentElement:addSon(newLink)
            newLink.father = gblCurrentElement
            local newCondition = Condition.new(condition, media, interface)
            newCondition.father = newLink
            newLink:addCondition(newCondition)
            gblCurrentElement = newLink

         else
            utils.printErro("Condition can be declared only inside a link", gblParserLine)
            return
         end
      else
         local newLink = Link.new(gblParserLine)
         newLink.father = gblCurrentElement
         gblCurrentElement = newLink
         table.insert(gblSymbolTable.body, newLink)

         local newCondition = Condition.new(condition, media, interface, gblParserLine)
         newCondition.father = gblCurrentElement
         gblCurrentElement:addCondition(newCondition)

      end
      condCount = condCount+3
      mediaCount = mediaCount+3
      condition = words[condCount]
      media = words[mediaCount]
   end
end

function parseLinkAction(str)
   local words = {}
   for word in str:gmatch("%S+") do
      table.insert(words, word)
   end
   local action = words[1]
   local component = words[2]
   local interface = nil
   local variable = nil
   if action == "set" then
      local ponto = component:find("%.")
      if ponto then
         interface = component:sub(ponto+1)
         component = component:sub(1, ponto-1)
      end
      if interface then
         ponto = interface:find("%.")
         if ponto then
            variable = interface:sub(ponto+1)
            interface = interface:sub(1, ponto-1)
         end
      end
   else
      local ponto = component:find("%.")
      if ponto then
         interface = component:sub(ponto+1)
         component = component:sub(1, ponto-1)
      end
   end

   local newAction = Action.new(action, component, interface, gblParserLine, variable)
   newAction.father = gblCurrentElement
   gblCurrentElement:addAction(newAction)
   gblCurrentElement = newAction
end

function parseLinkActionParam(str)
   str = str:gsub("%s+", "")
   local sign = str:find(":")
   local paramName = str:sub(1, sign-1)
   local paramValue = str:sub(sign+1)

   gblCurrentElement:addParam(paramName, paramValue)
end

function parsePort(str)
   local words = {}

   for word in str:gmatch("%S+") do
      table.insert(words, word)
   end

   local id = words[2]
   local media, interface = utils.splitSymbol(words[3], "%.")

   local newPort = Port.new(media, interface, gblCurrentElement, gblParserLine-1)
   newPort:setId(id)

   if gblCurrentElement then
      gblCurrentElement:addSon(newPort)
   end
end

function parseIdMacro(str)
   local paramString = string.match(str,"%(.*%)")
   local id = parseId(str:gsub("%(.*%)", ""))

   local paramsTable = {}
   local count = 1
   for w in string.gmatch(paramString, "%w+") do
      paramsTable[w] = count
      count = count+1
   end
   return id, paramsTable, count-1
end


local field = '(' * lpeg.Cs( (lpeg.P(1)-')') ) * ')' + lpeg.C( (1-lpeg.S',\n')^0 )
local record = lpeg.Ct(field * (',' * field)^0) * (lpeg.P'\n' + -1)
function csv (s)
   return lpeg.match(record, s)
end

function parseMacroCall (str)
   str = str:gsub("*", "", 1)
   str = str:gsub("%s+", "")

   local paramString = string.match(str,"%(.*%)")
   paramString = paramString:sub(2)
   paramString = paramString:sub(1, #paramString-1)
   local idMacro = str:gsub("%(.*%)", "")

   -- Cant nest macros
   if utils.isMacroSon(gblCurrentElement) then
      utils.printErro("Macro "..idMacro.." not declared", gblParserLine-1)
      return
   end
   -- Cant call a macro that is not declared yet
   if not gblSymbolTable.macros[idMacro] then
      utils.printErro("Macro "..idMacro.." not declared", gblParserLine-1)
      return
   end

   local paramsTable = csv(paramString)
   local macroElement = gblSymbolTable.macros[idMacro]
   for pos, val in pairs(paramsTable) do
      paramsTable[pos] = val:gsub("\"", "")
   end

   if (#paramsTable ~= macroElement.quantParams) then
      utils.printErro("Macro "..idMacro.." receives "..macroElement.quantParams.." parameters, "..#paramsTable.." are being passed", gblParserLine)
      return
   end

   -- Parse of the sons of the macro
   for _, macroSon in pairs(macroElement.sons) do
      parseMacroSon(macroElement, macroSon, paramsTable)
   end

   -- Parse of properties that are inside the macro but outside of its sons
   for pos, val in pairs(macroElement.properties) do
      if macroElement.params[val] then
         if paramsTable[macroElement.params[val]] then
            gblCurrentElement:addProperty(pos, paramsTable[macroElement.params[val]])
            -- TODO: Se o valor for "nil"
         end
      else
         gblCurrentElement:addProperty(pos, val)
      end
   end
end

function parseMacroSonLink(macro, son, paramsTable)
   newElement = Link.new()

   for _, condition in pairs(son.conditions) do --Copiar condicoes
      -- Check if condition and component are parameters
      local cond = condition.condition
      if macro.params[condition.condition] then
         cond = paramsTable[macro.params[condition.condition]]:gsub("\"","")
      end
      local component = condition.component
      if macro.params[component] then
         component = paramsTable[macro.params[condition.component]]:gsub("\"","")
      end
      local newCondition = Condition.new(cond, component)
      newElement:addCondition(newCondition)
      newCondition.father = newElement
   end

   for _, action in pairs(son.actions) do -- Copiar acoes
      local act = action.action
      if macro.params[action.action] then
         act = paramsTable[macro.params[action.action]]:gsub("\"","")
      end
      local component = action.component
      local interface = action.interface
      if macro.params[component] then
         component = paramsTable[macro.params[action.component]]:gsub("\"","")
      end
      if macro.params[interface] then
         interface = paramsTable[macro.params[action.interface]]:gsub("\"", "")
      end
      local newAction = Action.new(act, component, interface)
      for pos, val in pairs(action.properties) do
         local value = paramsTable[macro.params[val]]
         newAction:addProperty(pos, "\""..value.."\"")
      end
      newAction.hasEnd = true
      newElement:addAction(newAction)
      newAction.father = newElement
   end

   newElement.hasEnd = true
   table.insert(gblSymbolTable.body, newElement)
end

function parseMacroSon(macro, son, paramsTable)
   local newElement
   local father = gblCurrentElement
   if son._type == 'link' then
      parseMacroSonLink(macro, son, paramsTable)
   else
      if son._type == 'media' then
         newElement = Elemento.new("media", gblParserLine)
      elseif son._type == 'context' then
         newElement = Elemento.new("context", gblParserLine)
      elseif son._type == 'area' then
         newElement = Elemento.new("area", gblParserLine)
      elseif son._type == "region" then
         newElement = Elemento.new("region", gblParserLine)
      end
      gblCurrentElement = newElement

      if macro.params[son.id] then --Se o Id é um argumento
         local id = paramsTable[macro.params[son.id]]
         newElement:setId(id:gsub("\"", ""))
      else
         newElement:setId(son.id)
      end

      for name, val in pairs(son.properties) do --Copiar properties
         local value = paramsTable[macro.params[val]]
         if value then --Se a propriedade é parametro
            newElement:addProperty(name, value)
         else --Se a propriedade não é parametro
            newElement:addProperty(name, val)
         end
      end
      -- TODO: type de macro ta com aspas extra
      if paramsTable[macro.params[son.mType]] then
         newElement.mType = paramsTable[macro.params[son.mType]]
      else
         newElement.mType = son.mType
      end
      if paramsTable[macro.params[son.src]] then
         newElement.src = paramsTable[macro.params[son.src]]
      else
         newElement.src = son.src
      end
      if paramsTable[macro.params[son.region]] then
         newElement.region = paramsTable[macro.params[son.region]]
      else
         newElement.region = son.region
      end
      if paramsTable[macro.params[son.hasPort]] then
         newElement.hasPort = paramsTable[macro.params[son.hasPort]]
      else
         newElement.hasPort = son.hasPort
      end
      for _, aux in pairs(son.sons) do --Copiar Sons
         parseMacroSon(macro, aux, paramsTable)
      end
      newElement.hasEnd = true
   end

   if newElement ~= nil then
      if father ~= nil then
         father:addSon(newElement)
         newElement.father = father
      else
         if newElement.id then
            if gblSymbolTable[newElement.id] == nil then
               gblSymbolTable[newElement.id] = newElement
               table.insert(gblSymbolTable.body, gblSymbolTable[newElement.id])
            end
         end
      end
   end

   gblCurrentElement = father
end

function lpegMatch(regex, string)
   if lpeg.match(regex, string) then
      --   if lpeg.match(regex, string) == #string+1 then
      return true
      --   end
   else
      return false
   end
   return false
end
