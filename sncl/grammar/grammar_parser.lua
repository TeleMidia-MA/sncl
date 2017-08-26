lpeg.locale(lpeg)
local S, R, V, P = lpeg.S, lpeg.R, lpeg.V, lpeg.P
local Cg, Ct, C = lpeg.Cg, lpeg.Ct, lpeg.C

local SPC = V"Espacos"

currentElement = nil

snclGrammar = {
   "INICIAL";

   ------ Bases ------
   OnlyEspace = P" ",
   Espacos = lpeg.space
   /function(str)
      if str == "\n" then
         linhaParser = linhaParser+1
      end
   end,
   Inteiro = R("09"),
   Alpha =  (R"az"+R"AZ"),
   Symbols = (P"@"+P"_"+P"/"+P"."+P"%"+P","+P"-"),
   AlphaNumeric = (V"Alpha"+V"Inteiro"),
   AlphaNumericSymbols = (V"Alpha"+V"Inteiro"+V"Symbols"),
   AlphaNumericSpace = (V"Alpha"+V"Inteiro"+SPC)^1,
   AlphaNumericSymbolsSpace = (V"Alpha"+V"Inteiro"+V"Symbols"+SPC)^1,
   Id = (V"Alpha"+V"Inteiro"+P"_"),
   String = (P"\""*V"AlphaNumericSymbolsSpace"^-1*P"\""),

   End = (P"end" *(SPC)^0)
   /function()
      if currentElement ~= nil then
         currentElement:setEnd(true)
         if currentElement:getFather() == nil then
            currentElement = nil
         else
            currentElement = currentElement:getFather()
         end
      else
         utils.printErro("No element to end.", linhaParser-1)
      end
   end,

   ------ REGION ------
   RegionId = (P"region" *V"OnlyEspace"^1 *V"Id"^1 *SPC^0)
   /function(str)
      local id = parseId(str)
      if tabelaSimbolos[id] == nil then
         local newRegion = Region.new(id)
         tabelaSimbolos[id] = newRegion
         tabelaSimbolos.regions[id] = tabelaSimbolos[id]
         if currentElement ~= nil then
            newRegion:setFather(currentElement)
            currentElement:addSon(newRegion)
            currentElement = newRegion
         else
            currentElement = newRegion
         end
      else
         utils.printErro("Id "..id.." already declared.")
      end
   end,
   Region = (V"RegionId" * (V"Region"+V"Property")^0 * V"End"^-1),
   ------ REGION ------

   ------ AREA ------
   AreaId = (P"area" *V"OnlyEspace"^1* V"Id"^1 *SPC^0)
   /function(str)
      local id = parseId(str)
      if tabelaSimbolos[id] == nil then
         local newArea = Area.new(id)
         tabelaSimbolos[id] = newArea
         tabelaSimbolos.body[id] = tabelaSimbolos[id]
         if currentElement ~= nil then
            newArea:setFather(currentElement)
            currentElement:addSon(newArea)
            currentElement = newArea
         else
            currentElement = newArea
         end
      else
         utils.printErro("Id "..id.." already declared.")
      end
   end,
   Area = (V"AreaId" * V"Property"^0 *V"End"^-1),
   ------ AREA ------

   ------ MEDIA ------
   MediaId = (P"media" *V"OnlyEspace"^1* V"Id"^1 *SPC^0)
   /function(str)
      local id = parseId(str)
      if tabelaSimbolos[id] == nil then
         local newMedia = Media.new(id)
         tabelaSimbolos[id] = newMedia
         tabelaSimbolos.body[id] = tabelaSimbolos[id]
         if currentElement ~= nil then
            newMedia:setFather(currentElement)
            currentElement:addSon(newMedia)
            currentElement = newMedia
         else
            currentElement = newMedia
         end
      else
         utils.printErro("Id "..id.." already declared.")
      end
   end,
   MediaRegion = (P"rg" *V"OnlyEspace"^0* P":" *V"OnlyEspace"^0* V"AlphaNumeric"^1 *SPC^0)
   /function(str)
      str = str:gsub("%s+", "")
      local name, value = parseProperty(str)
      if currentElement ~= nil then
         currentElement:addProperty(name, value)
      else
         utils.printErro("No element")
      end
   end,

   Media = (V"MediaId" * (V"Area"+V"Refer"+V"MediaRegion"+V"Property")^0 * V"End"^-1),
   ------ MEDIA ------

   ------ CONTEXT ------
   ContextId = (P"context"*V"OnlyEspace"^1*V"Id"^1*SPC^0)
   /function(str)
      local id = parseId(str)
      if tabelaSimbolos[id] == nil then
         local newContext = Context.new(id)
         tabelaSimbolos[id] = newContext
         tabelaSimbolos.body[id] = tabelaSimbolos[id]
         if currentElement ~= nil then --Se tiver dentro de um elemento
            if currentElement.getType() == "context" then
               newContext:setFather(currentElement)
               currentElement:addSon(newContext)
               currentElement = newContext
            else
               utils.printErro("Contexto "..id.." somente pode ser declarado dentro de outro contexto.", linhaParser)
            end
         else --Se tiver fora de um elemento
            currentElement = newContext
         end
      else
         utils.printErro("Id "..id.." já declarado.")
      end
   end,
   ContextProperty = (V"AlphaNumeric"^1*V"OnlyEspace"^0*P":"*V"OnlyEspace"^0*V"String"*SPC^0)
   /function(str)
      str = str:gsub("%s+", "")
      if currentElement then
         local name, value = parseProperty(str)
         currentElement:addProperty(name, value)
      else
         utils.printErro("No element.")
      end
   end,
   Context = (V"ContextId" *(V"Port"+V"ContextProperty"+ V"Media"+V"Context"+V"Link"+V"Refer")^0*V"End"^-1),
   ------ CONTEXT ------

   ------ LINK ------
   Condition = (V"AlphaNumericSymbols"^1 *V"OnlyEspace"^1* V"AlphaNumericSymbols"^1* V"OnlyEspace"^0 *(P"and"+P"do")*V"OnlyEspace"^0)
   /function(str)
      parseLinkCondition(str)
   end,
   Link = (V"Condition"^1 *SPC^0* (V"Action")^0 *V"End"^-1),
   ------ LINK ------
   ------ ACTION ------
   ActionMedia = (V"AlphaNumeric"^1 *V"OnlyEspace"^1* V"AlphaNumericSymbols"^1 *SPC^1)
   /function(str)
      parseLinkAction(str)
   end,
   ActionParam = (V"AlphaNumeric"^1 *V"OnlyEspace"^0* P":" *V"OnlyEspace"^0* V"String"* SPC^0)
   /function(str)
      parseLinkActionParam(str)
   end,
   Action = ( V"ActionMedia"*V"ActionParam"^0 *V"End"^-1),
   ------ ACTION ------

   ------ MISC ------
   Property = (V"AlphaNumericSymbols"^1 *V"OnlyEspace"^0* P":" *V"OnlyEspace"^0*V"String"*SPC^0)
   /function(str)
      str = str:gsub("%s+", "")
      local name, value = parseProperty(str)
      if currentElement ~= nil then
         currentElement:addProperty(name, value)
      else
         utils.printErro("Propriedade somente pode ser declarada dentro de um elemento.")
      end
   end,
   Port = (P"port" *V"OnlyEspace"^1* V"AlphaNumeric"^1*V"OnlyEspace"^1* V"AlphaNumeric"^1*SPC^0)
   /function(str)
      parsePort(str)
   end,
   Refer = (P"refer" *V"OnlyEspace"^0* P":" *V"OnlyEspace"^0* V"AlphaNumeric"^1 *SPC^0)
   /function(str)
      str = str:gsub("%s+", "")
      parseRefer(str)
   end,

   -- START --
   INICIAL = SPC^0 * (V"Port"+V"Region"+V"Media"+V"Context"+V"Link")^0,
}
