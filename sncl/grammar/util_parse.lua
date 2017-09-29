function parseId (str)
   local words = {}
   for word in str:gmatch("%S+") do -- Separar as palavras por espaco
      table.insert(words, word)
   end

   if #words == 2 then
      return words[2]
   else
      utils.printErro("Elemento nao pode ter mais de 2 Ids.", linhaParser)
      return
   end
end

function parseProperty (str)
   local sign = str:find(":")
   if sign then
      local name = str:sub(1, sign-1)
      local value = str:sub(sign+1)
      return name, value
   else
      return str
   end
end

function parseRefer (str)
   if currentElement == nil then
      utils.printErro("Refer somente dentro de Context, Switch ou Media.", linhaParser)
      return
   end

   local eleType = currentElement.getType()
   if eleType ~= "context" and eleType ~= "media" and eleType ~= "switch" then
      utils.printErro("Refer não pode ser declarado fora de algum elemento.", linhaParser)
      return
   end

   local sign = str:find(":")
   if sign then
      local value = str:sub(sign+1)
      local ponto = value:find("%.")
      local interface, media = nil, nil
      if ponto then
         interface = value:sub(ponto+1)
         media =  value:sub(1, ponto-1)
      else
         media = value
      end
      currentElement:setRefer(media, interface)
   end
end


function separateByDot (str)
   local dot = str:find("%.")
   local beforeDot, afterDot = nil, nil
   if dot then
      beforeDot = str:sub(1,dot-1)
      afterDot = str:sub(dot+1)
      return beforeDot, afterDot
   else
      return str
   end
end

function parseLinkCondition (str)
   --Separar as palavras por espaco
   local words = {}
   for word in str:gmatch("%S+") do
      table.insert(words, word)
   end

   if #words == 3 then
      local condition = words[1]
      local media= words[2]

      local condition, conditionParam = separateByDot(condition)
      local media, interface = separateByDot(media)

      if currentElement ~= nil then
         if currentElement:getType() == "link" then --Se for link, adicionar condicao
            local newCondition = Condition.new(condition, conditionParam, media, interface, linhaParser)
            newCondition:setFather(currentElement)
            currentElement:addCondition(newCondition)

         elseif currentElement.getType() == "context" then
            local newLink = Link.new(linhaParser)
            newLink:setFather(currentElement)
            currentElement:addSon(newLink)
            currentElement = newLink
            table.insert(tabelaSimbolos.body, newLink)
            local newCondition = Condition.new(condition, conditionParam, media, interface, linhaParser)
            newCondition:setFather(currentElement)
            currentElement:addCondition(newCondition)

         elseif currentElement.getType() == "macro" then
            local newLink = Link.new()
            currentElement:addSon(newLink)
            newLink:setFather(currentElement)
            local newCondition = Condition.new(condition, conditionParam, media, interface)
            newCondition:setFather(newLink)
            newLink:addCondition(newCondition)
            currentElement = newLink

         else
            utils.printErro("Condição declarada em lugar errado.", linhaParser)
            return
         end
      else
         local newLink = Link.new(linhaParser)
         newLink:setFather(currentElement)
         currentElement = newLink
         table.insert(tabelaSimbolos.body, newLink)

         local newCondition = Condition.new(condition, conditionParam, media, interface, linhaParser)
         newCondition:setFather(currentElement)
         currentElement:addCondition(newCondition)
      end
   end
end

function parseLinkAction (str)
   local words = {}
   for word in str:gmatch("%S+") do
      table.insert(words, word)
   end
   local action = words[1]
   local media = words[2]
   local interface = nil

   local barra = media:find("%.")

   if barra then
      interface = media:sub(barra+1)
      media = media:sub(1, barra-1)
   end

   if currentElement == nil or currentElement:getType() ~= "link" then
      utils.printErro("Action somente pode ser declarada dentro de um link.", linhaParser)
      return
   end

   local newAction = Action.new(action, media, interface, linhaParser)
   newAction:setFather(currentElement)
   currentElement:addAction(newAction)
   currentElement = newAction
end

function parseLinkActionParam (str)
   str = str:gsub("%s+", "")
   local sign = str:find(":")
   local paramName = str:sub(1, sign-1)
   local paramValue = str:sub(sign+1)

   if currentElement == nil or currentElement:getType() ~= "action" then
      utils.printErro("Parametro somente dentro de uma action.", linhaParser)
      return
   end

   currentElement:addParam(paramName, paramValue)
end

function parsePort (str)
   local words = {}
   for word in str:gmatch("%S+") do
      table.insert(words, word)
   end

   local id = words[2]
   local media = words[3]
   local interface = nil

   local barra = media:find("%.")

   local newPort = nil

   if currentElement then
      if currentElement.getType() == "context" or currentElement:getType() == "macro" then
         newPort = Port.new(id, media, interface, currentElement, linhaParser)
         currentElement:addSon(newPort)
      else
         utils.printErro("Elemento não pode ter porta.", linhaParser)
         return
      end
   else
      newPort = Port.new(id, media, nil)
   end

   if newPort ~= nil then
      tabelaSimbolos[id] = newPort
      tabelaSimbolos.body[id] = tabelaSimbolos[id]
   end
end

function parseIdMacro (str)
   local paramString = string.match(str,"%(.*%)")
   local id = parseId(str:gsub("%(.*%)", ""))
   --paramString = paramString:gsub("%s+", "")

   local paramsTable = {}
   local count = 1
   for w in string.gmatch(paramString, "%w+") do
      paramsTable[w] = count
      count = count+1
   end
   return id, paramsTable, count-1
end

function isMacroSon(element)
   if element then
      while element  do
         if element:getType() == "macro" then
            return element:getId()
         end
         element = element.father
      end
   end
   return false
end

function parseMacroRefer (str)
   str = str:gsub("*", "", 1)
   str = str:gsub("%s+", "")

   local paramString = string.match(str,"%(.*%)")
   local idMacro = str:gsub("%(.*%)", "")

   if isMacroSon(currentElement) then
      if idMacro == isMacroSon(currentElement) then
         utils.printErro("Macro não são recursivas", linhaParser-1)
         return
      end
   end

   if tabelaSimbolos.macros[idMacro] == nil then --Se a macro não foi declarada
      utils.printErro("Macro "..idMacro.." não declarada.", linhaParser-1)
      return
   end

   local macro = tabelaSimbolos.macros[idMacro]
   paramString = paramString:gsub("%s+", "")
   local paramsTable = {} -- Separar Parametros
   for w in string.gmatch(paramString, "[^%,%(%)]*") do
      if w ~= "" then
         table.insert(paramsTable, w)
      end
   end

   if (#paramsTable ~= macro.quantParams) then
      utils.printErro("Macro recebe "..macro.quantParams.." parametros, "..#paramsTable.." estão sendo passados.", linhaParser)
      return
   end

   for _, macroSon in pairs(macro.sons) do --Copiando filhos
      parseMacroSon(macro, macroSon, paramsTable)
   end

   local count = 1 -- Copiando propriedades
   for pos, val in pairs(macro.properties) do
      if macro.params[val] then
         if paramsTable[macro.params[val]] then
            currentElement.properties[pos] = paramsTable[macro.params[val]]
         else
            --currentElement.properties[pos] = "\"default\""
         end
      else
         currentElement.properties[pos] = val
      end
   end
end

function parseMacroSon(macro, son, paramsTable)
   local newElement
   local sonType = son.getType()
   local father = currentElement
   if sonType == 'link' then
      newElement = Link.new()
      for __, condition in pairs(son.conditions) do
         local component = paramsTable[macro.params[condition.component]]:gsub("\"","")
         local newCondition = Condition.new(condition.condition, new, component)
         newElement:addCondition(newCondition)
      end
      for __, action in pairs(son.actions) do
         local component = paramsTable[macro.params[action.component]]:gsub("\"","")
         local newAction = Action.new(action.action, component)
         for pos, val in pairs(action.properties) do --Adicionar as propriedades da action
            local value = paramsTable[macro.params[val]]
            newAction:addProperty(pos, "\""..value.."\"")
         end
         newAction:setEnd(true)
         newElement:addAction(newAction)
      end
      newElement:setEnd(true)
      table.insert(tabelaSimbolos.body, newElement)

   elseif sonType == 'port' then
      local id = paramsTable[macro.params[son.id]]:gsub("\"", "")
      local component = paramsTable[macro.params[son.media]]:gsub("\"", "")
      newElement = Port.new(id, component)

   else
      if sonType == 'media' then
         newElement = Media.new()
      elseif sonType == 'context' then
         newElement = Context.new()
      elseif sonType == 'area' then
         newElement = Area.new()
      end
      currentElement = newElement

      if macro.params[son:getId()] then --Se o Id é um argumento
         local id = paramsTable[macro.params[son:getId()]]
         newElement:setId(id:gsub("\"", ""))
      else
         newElement:setId(son:getId())
      end

      for name, val in pairs(son.properties) do --Copiar Propriedades
         local value = paramsTable[macro.params[val]]
         if value then
            newElement:addProperty(name, value)
         else
            newElement:addProperty(name, val)
         end
      end

      for __, aux in pairs(son.sons) do --Copiar Filhos
         parseMacroSon(macro, aux, paramsTable)
      end

      newElement:setEnd(true)
   end

   if newElement ~= nil then
      if father ~= nil then
         father:addSon(newElement)
         newElement:setFather(father)
      else
         if newElement.id then
            if tabelaSimbolos[newElement:getId()] == nil then
               tabelaSimbolos[newElement:getId()] = newElement
               tabelaSimbolos.body[newElement:getId()] = tabelaSimbolos[newElement:getId()]
            end
         end
      end
   end

   currentElement = father
end

function newElement (str, element)
   local id = parseId(str)
   if tabelaSimbolos[id]  then
      utils.printErro("Id "..id.." já declarado.", linhaParser)
      return
   end

   element:setId(id)
   if currentElement ~= nil then
      element:setFather(currentElement)
      currentElement:addSon(element)
      currentElement = element
   else
      currentElement = element
   end
end
