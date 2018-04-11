local ins = require"inspect"
local utils = require"utils"
local pT = require("parse-tree")

function resolveCall(call)
   local macro = gblMacroTbl[call.macro]

   if not macro then 
      print("MACRO CHAMADA N EXISTE")
      return nil 
   end -- Se a macro chamada n existe
   -- Se tem o mesmo numero de parametros e argumentos
   -- Mas se for um for, n vai ter
   if #macro.parameters ~= #call.arguments then
      if call.father then
         if call.father._type ~= "for" then 
            print("ERRO: N ERRADO DE ARGS1", call.line)
            return nil
         end
      else
         print("ERRO: N ERRADO DE ARGS2", call.line)
         return nil
      end
   end

   for _, son in pairs(macro.sons) do
      if son._type == "link" then
      elseif son._type == "for" then
      else
         if call.father and call.father._type == "for" then
         else
            resolvePresentationMacro(son, call)
         end
      end
   end
end

function resolvePresentationMacro(ele, call)
   local newEle = {
      id = ele.id, 
      _type = ele._type,
      properties = {}, sons = ele.sons,
   }
   local parameters = ele.father.parameters

   -- Se o Id é uma propriedade
   if utils.containValue(parameters, ele.id) then
      local newId = call.arguments[utils.getIndex(parameters, ele.id)]
      if gblPresTbl[newId] then
         print("ERRO: ID ", newId, " EXISTE")
         return nil
      end
      newEle.id = newId
   end

   if ele.properties then
      resolveElementProperties(ele, newEle, call)
   end

   newEle.sons = ele.sons

   gblPresTbl[newEle.id] = newEle

   if call.father then
      if call.father._type == "for" then
         newEle.father = call.father.father
      else
         newEle.father = call.father
      end
      if newEle.father then
         newEle.father.sons[newEle.id] = newEle
      end
   end

   --return newEle
end

function resolveElementProperties(ele, newEle, call)
   for name, value in pairs(ele.properties) do
      -- Se o valor da propriedade for um parametro
      if utils.containValue(ele.father.parameters, value) then
         pT.addProperty(newEle, name, call.arguments[utils.getIndex(ele.father.parameters, value)])
      else
         pT.addProperty(newEle, name, value)
      end
   end
end
