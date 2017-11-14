local lpeg = require("lpeg")
local utils = require("utils")
local t = lpeg.locale()
local V, P = lpeg.V, lpeg.P

local SPC = V"Espacos"

gramaticaSncl = {
   "INICIAL";

   ------ Bases ------
   Espacos = t.space
   /function(str)
      if str == "\n" then
         linhaParser = linhaParser+1
      end
   end,
   Symbols = (P"@"+P"_"+P"/"+P"."+P"%"+P","+P"-"),
   AlphaNumericSymbols = (t.alnum+V"Symbols"+P"."),
   AlphaNumericSpace = (t.alnum+SPC)^1,
   AlphaNumericSymbolsSpace = (t.alnum+V"Symbols"+P" ")^1,
   ParamCharacters = (t.alnum+P"\""+P"%"+P"/"+P"."+P"-"),
   Id = (t.alnum+P"_"+P"-"),
   String = (P"\""*V"AlphaNumericSymbolsSpace"^-1*P"\""),

   End = (P"end" * SPC^0)
   /function()
      if currentElement == nil then
         utils.printErro("No element to end", linhaParser)
         return
      end
      if currentElement.tipo == "macro" then
         insideMacro = false
      end
      currentElement.temEnd = true
      if currentElement.pai == nil then
         currentElement = nil
      else
         currentElement = currentElement.pai
      end
   end,

   ------ REGION ------
   RegionId = (P"region" *P" "^1 *V"Id"^1 *SPC^0)
   /function(str)
      local newRegion = Elemento.novo("region", linhaParser)
      utils.newElement(str, newRegion)
   end,
   Region = (V"RegionId" *(V"Comentario"+V"Region"+V"Property"+V"MacroRefer")^0* V"End"^-1),

   ------ SWITCH ------
   --[[
   SwitchPort = ("switchPort" * SwitchPortId)
   /function(str)
   end,
<<<<<<< HEAD
   SwitchPort = (P"switchPort" *P" "^1* V"AlphaNumericSymbols"^1 *SPC^0)
=======

   SwitchId = ()
>>>>>>> 665a9606dc115cae245ea5ffab7fba3fedefba37
   /function(str)
   end,

   Switch = (),
   ]]

   ------ CONTEXT ------
   ContextId = (P"context"*P" "^1*V"Id"^1*SPC^0)
   /function(str)
      local newContext = Elemento.novo("context", linhaParser)
      utils.newElement(str, newContext)
   end,
   ContextProperty = (t.alnum^1*P" "^0*P":"*P" "^0*V"String"*SPC^0)
   /function(str)
      str = str:gsub("%s+", "")
      if currentElement then
         local nome, valor = parseProperty(str)
         currentElement:addPropriedade(nome, valor)
      else
         utils.printErro("Property has no element", linhaParser)
      end
   end,
   Context = (V"ContextId"
   *(V"Comentario"+V"MacroRefer"+V"ContextProperty"+ V"Media"+V"Context"+V"Link"+V"Refer")^0*
   V"End"^-1),

   ------ MEDIA ------

   Port = (P"port" *P" "^1),
   MediaId = (V"Port"^-1* P"media" *P" "^1* V"Id"^1 *SPC^0)
   /function(str)
      local newMedia = Elemento.novo("media", linhaParser)
      utils.newElement(str, newMedia)
   end,
   Media = (V"MediaId" *(V"Comentario"+V"MacroRefer"+V"Area"+V"Refer"+V"Property")^0* V"End"^-1),

   ------ AREA ------
   AreaId = (P"area" *P" "^1* V"Id"^1 *SPC^0)
   /function(str)
      local newArea = Elemento.novo("area", linhaParser)
      utils.newElement(str, newArea)
   end,
   Area = (V"AreaId" *(V"Comentario"+V"Property")^0* V"End"^-1),

   ------ MACRO ------
   MacroParams2 = (V"ParamCharacters"^1*P" "^0* (P","*P" "^0*V"ParamCharacters"^1*P" "^0)^0), --Parametros recebidos
   MacroRefer = (P"*" * V"AlphaNumericSymbols"^1 *P" "^0*P"("*P" "^0*V"MacroParams2"^-1*P" "^0*P")" *SPC^0)
   /function(str)
      parseMacroChamada(str)
   end,
   MacroParams = (t.alnum^1*P" "^0* (P","*P" "^0*V"ParamCharacters"^1*P" "^0)^0), -- Parametros passados
   MacroId = (P"macro" *P" "^1* V"Id"^1 *P" "^0*P"("*P" "^0*V"MacroParams"^-1*P" "^0*P")" *SPC^0)
   /function(str)
      local id, params, quant = parseIdMacro(str)
      if id == nil then
         utils.printErro("Invalid Id", linhaParser)
         return
      end
      if tabelaSimbolos[id] == nil then
         local newMacro = Macro.new(id)
         newMacro:setParams(params)
         newMacro.quantParams = quant
         tabelaSimbolos[id] = newMacro
         tabelaSimbolos.macros[id] = tabelaSimbolos[id]
         if currentElement ~= nil then
            utils.printErro("Macro can not be declared inside of another element", linhaParser)
            return
         else
            currentElement = newMacro
         end
      else
         utils.printErro("Id "..id.." already declared", linhaParser)
         return
      end
      insideMacro = true
   end,
   Macro = (V"MacroId" *(V"Comentario"+V"MacroRefer"+V"Property"+V"Media"+V"Area"+V"Context"+V"Link"+V"Region")^0* V"End"^-1),

   ------ LINK ------
   Link = (V"Condition" *SPC^0* (V"Comentario"+V"Property"+V"Action")^0 *V"End"^-1),

   ------ CONDITION ------
   Condition = (V"ConditionParse")
   /function(str)
      parseLinkCondition(str)
   end,
   ConditionParse = (V"AlphaNumericSymbols"^1 *P" "^1* V"AlphaNumericSymbols"^1* P" "^0 *V"CondTerm"*P" "^0),
   CondTerm = ((P"and" *P" "^1* V"ConditionParse") + (P"do")),

   ------ ACTION ------
   ActionMedia = (t.alnum^1 *P" "^1* V"AlphaNumericSymbols"^1 *SPC^1)
   /function(str)
      parseLinkAction(str)
   end,
   ActionParam = (t.alnum^1 *P" "^0* P":" *P" "^0* V"String"* SPC^0)
   /function(str)
      parseLinkActionParam(str)
   end,
   Action = ( V"ActionMedia"*(V"Comentario"+V"Property")^0 *V"End"^-1),
   ------ MISC ------
   Property= (V"AlphaNumericSymbols"^1 *P" "^0* P":" *P" "^0* (V"String"+t.alnum^1) *SPC^0)
   /function(str)
      str = str:gsub("%s+", "")
      if currentElement ~= nil then
         --print(currentElement.tipo)
         currentElement:parseProperty(str)
      else
         utils.printErro("Property"..str.." declared in invalid context", linhaParser)
      end
   end,
   Refer = (P"refer" *P" "^0* P":" *P" "^0* t.alnum^1 *SPC^0)
   /function(str)
      str = str:gsub("%s+", "")
      parseRefer(str)
   end,
   Comentario = (P"--"*P" "^0* (t.alnum+t.punct+t.xdigit+P"¨"+P"´"+P" ")^0 *SPC^0),

   -- START --
   INICIAL = SPC^0 * (V"Comentario"+V"Macro"+V"MacroRefer"+V"Region"+V"Media"+V"Context"+V"Link")^0,
}
