function parseId (str)
   local words = {}
   for word in str:gmatch("%S+") do -- Separar as palavras por espaco
      table.insert(words, word)
   end

   if #words == 2 then
      return words[2]
   else
      utils.printErro("Elemento nao pode ter mais de 2 Ids.", linhaParser)
      return nil
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
   return id, paramsTable
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
   if currentElement then
      if (currentElement.getType() == "context" or currentElement.getType() == "media" or
         currentElement.getType() == "switch") then
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
      else
         utils.printErro("Refer somente dentro de Context, Switch ou Media.", linhaParser)
      end
   else
      utils.printErro("Refer não pode ser declarado fora de algum elemento.", linhaParser)
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
            --To-Do
            local newLink = Link.new()
            currentElement:addSon(newLink)
            local newCondition = Condition.new(condition, conditionParam, media, interface)
            newCondition:setFather(newLink)
            newLink:addCondition(newCondition)
            currentElement = newLink

         else
            utils.printErro("Condição declarada em lugar errado.", linhaParser)
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

   if currentElement ~= nil then
      if currentElement:getType() == "link" then
         local newAction = Action.new(action, media, interface, linhaParser)
         newAction:setFather(currentElement)
         currentElement:addAction(newAction)
         currentElement = newAction
      else
         utils.printErro("Action somente pode ser declarada dentro de um link.", linhaParser)
      end
   else
      utils.printErro("Action somente pode ser declarada dentro de um link.", linhaParser)
   end
end

function parseLinkActionParam (str)
   str = str:gsub("%s+", "")
   local sign = str:find(":")
   local paramName = str:sub(1, sign-1)
   local paramValue = str:sub(sign+1)

   if currentElement ~= nil then
      if currentElement:getType() == "action" then
         currentElement:addParam(paramName, paramValue)
      else
         utils.printErro("Parametro somente dentro de uma action.")
      end
   else
      utils.printErro("Parametro somente dentro de uma action.")
   end
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
      if currentElement.getType() == "context" then
         newPort = Port.new(id, media, interface, currentElement, linhaParser)
         currentElement:addSon(newPort)
      else
         utils.printErro("Elemento não pode ter porta.")
      end
   else
      newPort = Port.new(id, media, nil)
   end

   if newPort ~= nil then
      tabelaSimbolos[id] = newPort
      tabelaSimbolos.body[id] = tabelaSimbolos[id]
   end
end

function parseMacroRefer (str)
   str = str:gsub("*", "", 1)
   str = str:gsub("%s+", "")

   local paramString = string.match(str,"%(.*%)")
   local idMacro = str:gsub("%(.*%)", "")

   if tabelaSimbolos.macros[idMacro] then --Se a macro foi declarada
      local macro = tabelaSimbolos.macros[idMacro]

      paramString = paramString:gsub("%s+", "")
      local paramsTable = {} -- Separar Parametros
      for w in string.gmatch(paramString, "[^%,%(%)]*") do
         if w ~= "" then
            table.insert(paramsTable, w)
         end
      end

      for _, son in pairs(macro.sons) do --Copiando filhos
         local newSon = utils.newElementTable[son:getType()]
         if newSon.getType() ~= "link" then
            for pos, val in pairs(val.properties) do
               if macro.params[val] then
                  newSon:addProperty(pos, paramsTable[macro.params[val]])
               else
                  newSon:addProperty(pos, val)
               end
            end
            if macro.params[val:getId()] then --Se o Id é parametro
               newSon:setId(paramsTable[macro.params[val:getId()]]:gsub("\"","") )
               newSon:setEnd(true)
            end
            currentElement:addSon(newSon)
            newSon:setFather(currentElement)
         else
            --print(son:toNCL(""))

            for _, b in pairs(son.conditions) do
               print(b.condition)
            end

            for _, d in pairs(son.actions) do
               print(d.action)
            end

         end
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

   else
      utils.printErro("Macro "..idMacro.." não declarada.")
   end
end

function newElement (str, element)
   local id = parseId(str)
   if tabelaSimbolos[id] == nil then
      element:setId(id)
      if currentElement ~= nil then
         element:setFather(currentElement)
         currentElement:addSon(element)
         currentElement = element
      else
         currentElement = element
      end
   else
      utils.printErro("Id "..id.." já declarado.")
   end
end
