local ins = require('inspect')

function genLua(snclTable)
   ncl = {
      'context',
      'ncl',
      {}, -- Ports
      {}, -- Media, context, rule
      {{}, {}}, -- Link
   }

   for _, element in pairs(snclTable.presentation) do
      if element._type == 'port' then
         local newPort = element.component.."@"
         if element.interface then
            newPort = newPort..element.interface
         else
            newPort = newPort.."lambda"
         end
         table.insert(ncl[3], newPort)

      elseif element._type == 'media' then
         local newEle = {element._type, element.id, {}, {}}
         for name, value in pairs(element.properties) do
            newEle[3][name] = value
         end
         for _, area in pairs(element.sons) do
            local newArea = {area.id}
            table.insert(newEle[4], newArea)
         end
         newEle[3].src = element.src
         table.insert(ncl[4], newEle)

      elseif element._type == 'link' then
         local newLink = {}

         for _, condition in pairs(element.conditions) do
            local newCond = {condition.role, condition.component}
            table.insert(newLink, newCond)
         end

         for _, action in pairs(element.actions) do
            local newAction = {action.role, action.component, {}, {}}
            for name, value in pairs(action.properties) do
               newAction[4][name] = value
            end
            table.insert(newLink, newAction)
         end

         table.insert(ncl[5], newLink)
      end
   end
   print(ins.inspect(ncl))
end
