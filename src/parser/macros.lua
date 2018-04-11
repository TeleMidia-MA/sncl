local ins = require"inspect"
local utils = require"utils"
local pT = require("parse-tree")

-- stack -> call stack
function resolveCall(call, stack)
   print("\nResolving call on line", call.line)
   print("Arguments:", ins.inspect(call.arguments))
   print(ins.inspect(stack))
   local macro = gblMacroTbl[call.macro]
   local abv = stack[#stack]

   -- Se a macro chamada n existe
   if not macro then 
      print("ERRO: MACRO CHAMADA N EXISTE")
      return nil
   end

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

   -- Se tiver aspas, é pq o argumento ta sendo passado
   -- Se n, é pq o argumento é um parametro da macro em q a call ta dentro
   for p, val in pairs(call.arguments) do
      if val:match("\"*\"") then
         call.arguments[p] = val:gsub("\"", "")
         -- TODO: Remover aspas
      else
         if abv then
            -- Checar se a macro realmente tem o argumento como parametro
            if utils.containValue(gblMacroTbl[abv.macro].parameters, val) then
               print(abv.arguments[utils.getIndex(gblMacroTbl[abv.macro].parameters, val)])
               call.arguments[p] = abv.arguments[utils.getIndex(gblMacroTbl[abv.macro].parameters, val)]
               -- Se tiver, substituir o argumento da call pelo o que foi passado pra macro
            else
               io.write("ERRO: Argumento ", val, " invalido, n é parametro: ", call.line, "\n")
            end
         else
            io.write("ERRO: Argumento invalido, n ha macro: ", call.line,"\n")
         end
      end
   end

   table.insert(stack, call)
   for _, son in pairs(macro.sons) do
      if son._type == "context" or son._type == "media" then
         resolvePresentationMacro(son, call, stack)
      end
   end
   table.remove(stack)
end

function resolvePresentationMacro(ele, call, stack)
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

   for _, son in pairs(ele.sons) do
      if son._type == "macro-call" then
         resolveCall(son, stack)
      end
   end
   --return newEle
end

function resolveElementProperties(ele, newEle, call)
   for name, value in pairs(ele.properties) do
      -- Se o valor da propriedade for um parametro
      if utils.containValue(ele.father.parameters, value) then
         utils.addProperty(newEle, name, call.arguments[utils.getIndex(ele.father.parameters, value)])
      else
         utils.addProperty(newEle, name, value)
      end
   end
end
