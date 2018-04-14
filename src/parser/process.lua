local utils = require"utils"
local ins = require"inspect"
local lpeg = require"lpeg"
local pT = require"parse-tree"
require"macro"
--
-- function resolveMacroPresentationSon(element, macro, call)
--    local newEle = {_type = element._type, region = element.region, descriptor=element.descriptor, properties = {}, sons={}, father = call.father}
--    print(ins.inspect(element))
--
--    -- Se o Id é um parametro
--    if utils.containValue(macro.parameters, element.id) then
--       newEle.id = call.arguments[utils.getIndex(macro.parameters, element.id)]
--    else
--       newEle.id = element.id
--    end
--
--    if gblPresTbl[newEle.id] then
--       utils.printErro("Id "..newEle.id.." already declared")
--       return nil
--    end
--    gblPresTbl[newEle.id] = newEle
--    -- if element.properties then
--    --    for name, value in pairs(element.properties) do
--    --       -- If a property is a parameter, create the property
--    --       -- with the new value
--    --       if utils.containValue(macro.parameters, value) then
--    --          pT.addProperty(newEle, name, call.arguments[utils.getIndex(macro.parameters, value)])
--    --       else
--    --          pT.addProperty(newEle, name, value)
--    --       end
--    --    end
--    -- end
--
--    for pos, val in pairs(element.sons) do
--       if val._type == "for" then
--          resolveTemplate(gblPaddingTbl[1], val, newEle)
--       end
--    end
--
--    -- O novo elemento vai ser filho do elemento que tem a macro
--    if newEle.father then
--       newEle.father.sons[newEle.id] = newEle
--    end
--    return newEle
-- end
--
-- function resolveMacroLinkSon(son, macro, call)
--    local newEle = {_type="link", actions={}, conditions={}}
--
--    for _, act in pairs(son.actions) do
--       local newAct = {_type="action"}
--       newAct.role = act.role


--       if act.properties then
--          newAct.properties = {}
--          for name, value in pairs(act.properties) do
--             -- TODO: Check if the name is a parameter?
--             if utils.containValue(macro.parameters, value) then
--                newAct.properties[name] = call.arguments[utils.getIndex(macro.parameters, value)]
--             else
--                newAct.properties[name] = value
--             end
--          end
--       end
--       table.insert(newEle.actions, newAct)
--    end
--
--    for _, cond in pairs(son.conditions) do
--       local newCond = {_type="condition"}
--       newCond.role = cond.role

--       -- TODO: BUTTONS
--       if cond.interface then
--          if utils.containValue(macro.parameters, cond.interface) then
--             newCond.interface = call.arguments[utils.getIndex(macro.parameters, cond.interface)]
--          else
--             newCond.interface = cond.interface
--          end
--          if lpeg.match(Buttons, newCond.interface) then
--             newCond.properties = {__keyValue=newCond.interface}
--             newCond.interface = nil
--          end
--       end
--       table.insert(newEle.conditions, newCond)
--    end
--
--    if son.properties then
--       newEle.properties = {}
--       for name, value in pairs(son.properties) do
--          -- TODO: Check if the name is a parameter?
--          if utils.containValue(macro.parameters, value) then
--             newEle.properties[name] = call.arguments[utils.getIndex(macro.parameters, value)]
--          else
--             newEle.properties[name] = value
--          end
--       end
--    end
--    table.insert(gblLinkTbl, newEle)
-- end
--
-- -- function resolveMacro(macro, call)
-- --    print("Resolving macro of ", macro.id)
-- --    for _, son in pairs(macro.sons) do
-- --       if son._type == "link" then
-- --          resolveMacroLinkSon(son, macro, call)
-- --       else
-- --          resolveMacroPresentationSon(son, macro, call)
-- --       end
-- --    end
-- end

-- function resolveMacroCalls(tbl)
--    for _, call in pairs(tbl) do
--       if call.father then
--       else
--          local macro = gblMacroTbl[call.macro]
--          if not macro then
--             utils.printErro("Macro "..call.macro.." not declared")
--             return nil
--          end
--          -- TODO: Nao tem que checar se o pai é um for, e sim se o argumento é um indice
--          if #macro.parameters ~= #call.arguments and call.father._type ~= "for" then
--             utils.printErro("Wrong number of arguments on call "..macro.id)
--             return nil
--          end
--          resolveMacro(macro, call)
--       end
--    end
-- end



-- function resolveTemplate(padding, loop, pos)
--    local start = loop.start
--    local elements = getElementsWithClass(padding, loop.class)
--    for i = start, #elements do
--       local element = elements[i]
--       for _, son in pairs(loop.sons) do
--          if son._type == "macro-call" then
--             local macro = gblMacroTbl[son.macro]
--             local parameters = macro.parameters
--             local call = {_type="macro-call", macro=macro.id, arguments = {}, father = loop.father}
--             -- Pegar as propriedades do objeto yaml, e transforma-los em argumentos da chamada
--             for pos, val in pairs(element) do 
--                if type(val) == "table" then -- Se for uma table, é um elemento
--                else
--                   if utils.containValue(parameters, pos) then
--                      call.arguments[utils.getIndex(parameters, pos)] = element[pos]
--                   end
--                end
--             end
--             resolveCall(call)
--          end
--       end
--    end
--    table.remove(gblTemplateTbl, pos)
-- end

function makeElementsLoop(lp, els)
   local s = lp.start
end




