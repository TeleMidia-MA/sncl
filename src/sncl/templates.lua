local resolveTemplates = {
   resolveTemplate = function(eles, loop, pos)
      local s = loop.start
      for i = s, #eles do
         for _, son in pairs(loop.sons) do
            if son._type == "macro-call" then
               local macro = gblMacroTbl[son.macro] --TODO: checar se macro existe
               if not macro then
                  io.write("ERRO: macro ", son.macro, " n declarada.", son.line, '\n')
                  table.remove(gblTemplateTbl, pos)
                  return
               end
               local parameters = macro.parameters
               local call = {
                  _type = "macro-call",
                  macro = macro.id,
                  arguments = {},
                  father = loop.father,
                  line = son.line
               }
               for pos, val in pairs(eles[i]) do 
                  if type(val) == "table" then -- Se for uma table, é um elemento
                  else
                     if utils.containValue(parameters, pos) then
                        call.arguments[utils.getIndex(parameters, pos)] = eles[i][pos]
                     end
                  end
               end
               resolveCall(call)
            end
         end
      end
   end
}

return resolveTemplates

-- if padding then
--    local nF = 0
--    while #gblTemplateTbl > 0 do
--       for pos, loop in ipairs(gblTemplateTbl) do
--          print("loop:", pos, "l:",loop.line)
--          print("parents:", utils.getNumberOfParents(loop, 0), "nf:", nF)
--          print("isMacroSon:", utils.isMacroSon(loop))
--          if utils.getNumberOfParents(loop, 0) == nF and not utils.isMacroSon(loop) then
--             -- TODO: 
--             local elements = utils.getElementsWithClass(gblPaddingTbl[1], loop.class)
--             io.write('\tElements: ')
--             for _, ele in ipairs(elements) do
--                io.write(ele.id)
--             end
--             io.write('\n')
--             resolveTemplate(elements, loop, pos)
--             table.remove(gblTemplateTbl, pos)
--          end
--       end
--       nF = nF+1
--    end
-- e
