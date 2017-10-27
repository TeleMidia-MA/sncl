local utils = require("utils")

function parseId(str)
   local words = utils.separarEspaco(str)

   if #words == 1 then
      return words[1]
   elseif #words == 2 then
      return words[2]
   else
      utils.printErro("Declaração \'"..str.."\' de elemento invalida.", linhaParser)
      return nil
   end
end

function parseRefer(str)
   if currentElement == nil then
      utils.printErro("Refer declarado em context inválido.", linhaParser)
      return
   end

   local eleType = currentElement.tipo
   if eleType ~= "context" and eleType ~= "media" and eleType ~= "switch" then
      utils.printErro("Refer declarado em contexto inválido.", linhaParser)
      return
   end

   local sign = str:find(":")
   if sign then
      local value = str:sub(sign+1)
      local ponto = value:find("%.")
      local interface, media
      if ponto then
         interface = value:sub(ponto+1)
         media =  value:sub(1, ponto-1)
      else
         media = value
      end
      currentElement:setRefer(media, interface)
   end
end

function parseLinkCondition(str)
   --Separar as palavras por espaco
   local words = {}
   for word in str:gmatch("%S+") do
      table.insert(words, word)
   end

   if #words < 3 then
      utils.printErro("Error in link declaration", linhaParser)
      return
   end
   local condCount, mediaCount = 1, 2
   local condition = words[condCount]
   local media = words[mediaCount]
   while condition and media do
      local conditionParam
      condition, conditionParam = utils.separarPonto(condition)

      local interface
      media, interface = utils.separarPonto(media)

      if currentElement ~= nil then
         if currentElement.tipo == "link" then --Se for link, adicionar condicao
            local newCondition = Condition.new(condition, conditionParam, media, interface, linhaParser)
            newCondition.pai = currentElement
            currentElement:addCondition(newCondition)

         elseif currentElement.tipo == "context" then
            local newLink = Link.new(linhaParser)
            newLink.pai = currentElement
            currentElement:addFilho(newLink)
            currentElement = newLink
            local newCondition = Condition.new(condition, conditionParam, media, interface, linhaParser)
            newCondition.pai = currentElement
            currentElement:addCondition(newCondition)

         elseif currentElement.tipo == "macro" then
            local newLink = Link.new()
            currentElement:addFilho(newLink)
            newLink.pai = currentElement
            local newCondition = Condition.new(condition, conditionParam, media, interface)
            newCondition.pai = newLink
            newLink:addCondition(newCondition)
            currentElement = newLink

         else
            utils.printErro("Condition somente pode ser declarada dentro de Link.", linhaParser)
            return
         end
      else
         local newLink = Link.new(linhaParser)
         newLink.pai = currentElement
         currentElement = newLink
         table.insert(tabelaSimbolos.body, newLink)

         local newCondition = Condition.new(condition, conditionParam, media, interface, linhaParser)
         newCondition.pai = currentElement
         currentElement:addCondition(newCondition)

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
   local media = words[2]
   local interface = nil

   local barra = media:find("%.")

   if barra then
      interface = media:sub(barra+1)
      media = media:sub(1, barra-1)
   end

   if currentElement == nil or currentElement.tipo ~= "link" then
      utils.printErro("Action somente pode ser declarada dentro de um Link.", linhaParser)
      return
   end

   local newAction = Action.new(action, media, interface, linhaParser)
   newAction.pai = currentElement
   currentElement:addAction(newAction)
   currentElement = newAction
end

function parseLinkActionParam(str)
   str = str:gsub("%s+", "")
   local sign = str:find(":")
   local paramName = str:sub(1, sign-1)
   local paramValue = str:sub(sign+1)

   if currentElement == nil or currentElement.tipo ~= "action" then
      utils.printErro("Parametro declarado em context inválido.", linhaParser)
      return
   end

   currentElement:addParam(paramName, paramValue)
end

function parsePort(str)
   local words = {}

   for word in str:gmatch("%S+") do
      table.insert(words, word)
   end

   local id = words[2]
   local media, interface = utils.separarPonto(words[3])

   local newPort = Port.novo(media, interface, currentElement, linhaParser-1)
   newPort:setId(id)

   if currentElement then
      currentElement:addFilho(newPort)
   end
end

function parseIdMacro(str)
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
function parseMacroChamada (str)
   str = str:gsub("*", "", 1)
   str = str:gsub("%s+", "")

   local paramString = string.match(str,"%(.*%)")
   local idMacro = str:gsub("%(.*%)", "")

   if utils.isMacroSon(currentElement) then
      if idMacro == utils.isMacroSon(currentElement) then
         utils.printErro("Macro "..idMacro.." não declarada neste contexto.", linhaParser-1)
         return
      end
   end

   if tabelaSimbolos.macros[idMacro] == nil then --Se a macro não foi declarada
      utils.printErro("Macro "..idMacro.." não declarada.", linhaParser-1)
      return
   end

   local paramsTable = {}
   for w in string.gmatch(paramString, '".-"') do
      table.insert(paramsTable, w)
   end
   local macro = tabelaSimbolos.macros[idMacro]

   if (#paramsTable ~= macro.quantParams) then
      utils.printErro("Macro "..idMacro.." recebe "..macro.quantParams.." parametros, "..#paramsTable.." estão sendo passados.", linhaParser)
      return
   end

   for _, macroSon in pairs(macro.filhos) do --Copiando filhos
      parseMacroSon(macro, macroSon, paramsTable)
   end

   for pos, val in pairs(macro.propriedades) do
      if macro.params[val] then
         if paramsTable[macro.params[val]] then
            currentElement:addPropriedade(pos, paramsTable[macro.params[val]])
            -- TODO: Se o valor for "default"
         end
      else
         currentElement:addPropriedade(pos, val)
      end
   end
end

function parseMacroSon(macro, son, paramsTable)
   local newElement
   local father = currentElement
   if son.tipo == 'link' then
      newElement = Link.new()

      for _, condition in pairs(son.conditions) do --Copiar condicoes
         -- Check if condition and component are parameters
         local cond = condition.condition
         if macro.params[condition.condition] then
            cond = paramsTable[macro.params[condition.condition]]:gsub("\"","")
         end
         local component = condition.component
         if macro.params[condition.component] then
            component = paramsTable[macro.params[condition.component]]:gsub("\"","")
         end
         local newCondition = Condition.new(cond, new, component)
         newElement:addCondition(newCondition)
         newCondition.pai = newElement
      end

      for _, action in pairs(son.actions) do -- Copiar acoes
         local act = action.action
         if macro.params[action.action] then
            act = paramsTable[macro.params[action.action]]:gsub("\"","")
         end
         local component = action.component
         if macro.params[action.component] then
            component = paramsTable[macro.params[action.component]]:gsub("\"","")
         end
         local newAction = Action.new(act, component)
         for pos, val in pairs(action.propriedades) do
            local value = paramsTable[macro.params[val]]
            newAction:addProperty(pos, "\""..value.."\"")
         end
         newAction.temEnd = true
         newElement:addAction(newAction)
         newAction.pai = newElement
      end

      newElement.temEnd = true
      table.insert(tabelaSimbolos.body, newElement)

   elseif son.tipo == 'port' then
      newElement = Port.new()
      if macro.params[son.id] == nil then
         newElement:setId(son.id)
      else
         newElement:setId(paramsTable[macro.params[son.id]]:gsub("\"", ""))
      end

      newElement:setComponent(paramsTable[macro.params[son.media]]:gsub("\"", ""))

   else
      if son.tipo == 'media' then
         newElement = Elemento.novo("media", linhaParser)
      elseif son.tipo == 'context' then
         newElement = Elemento.novo("context", linhaParser)
      elseif son.tipo == 'area' then
         newElement = Elemento.novo("area", linhaParser)
      elseif son.tipo == "region" then
         newElement = Elemento.novo("region", linhaParser)
      end
      currentElement = newElement

      if macro.params[son.id] then --Se o Id é um argumento
         local id = paramsTable[macro.params[son.id]]
         newElement:setId(id:gsub("\"", ""))
      else
         newElement:setId(son.id)
      end

      for name, val in pairs(son.propriedades) do --Copiar Propriedades
         local value = paramsTable[macro.params[val]]
         if value then --Se a propriedade é parametro
            newElement:addPropriedade(name, value)
         else --Se a propriedade não é parametro
            newElement:addPropriedade(name, val)
         end
      end
      if paramsTable[macro.params[son._type]] then
         newElement._type = paramsTable[macro.params[son._type]]
      else
         newElement._type = son._type
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

      for _, aux in pairs(son.filhos) do --Copiar Filhos
         parseMacroSon(macro, aux, paramsTable)
      end

      newElement.temEnd = true
   end

   if newElement ~= nil then
      if father ~= nil then
         father:addFilho(newElement)
         newElement.pai = father
      else
         if newElement.id then
            if tabelaSimbolos[newElement.id] == nil then
               tabelaSimbolos[newElement.id] = newElement
               tabelaSimbolos.body[newElement.id] = tabelaSimbolos[newElement.id]
            end
         end
      end
   end

   currentElement = father
end

