local ins = require('inspect')

function genPort(port)
   local newPort = port.component.."@"

   if port.interface then
      newPort = newPort..port.interface
   else
      newPort = newPort.."lambda"
   end

   return newPort
end

function genMedia(media)
   local newMedia = {media._type, media.id, {}, {}}

   for name, value in pairs(media.properties) do
      newMedia[3][name] = value
   end
   for _, area in pairs(media.children) do
      local newArea = {area.id}
      table.insert(newMedia[4], newArea)
   end
   newMedia[3].src = media.src

   return newMedia
end

function genContext(context)
   --print(ins.inspect(context))
   -- Ports, Children and Links
   local newContext = {context._type, context.id, {}, {}, {}}
   for _, son in pairs(context.children) do

      if son._type == 'port' then
         table.insert(newContext[3], genPort(son))

      elseif son._type == 'media' then
         table.insert(newContext[4], genMedia(son))

      elseif son._type == 'context' then
         table.insert(newContext[4], genContext(son))

      elseif son._type == 'link' then
         table.insert(newContext[5], genLink(son))
      end

   end
   return newContext
end

function genLink(link)
   local newLink = {{}, {}}

   for _, condition in pairs(link.conditions) do
      local newCond = {condition.role, condition.component}
      table.insert(newLink[1], newCond)
   end

   for _, action in pairs(link.actions) do
      local newAction = {action.role, action.component, {}, {}}
      for name, value in pairs(action.properties) do
         newAction[4][name] = value
      end
      table.insert(newLink[2], newAction)
   end
   return newLink
end

function genLua(snclTable)
   ncl = {
      'context',
      'ncl',
      {}, -- Ports
      {}, -- Media, Context, ule
      {{}, {}}, -- Link
   }

   for _, element in pairs(snclTable.presentation) do
      if not element.father then
         if element._type == 'port' then
            table.insert(ncl[3], genPort(element))

         elseif element._type == 'media' then
            table.insert(ncl[4], genMedia(element))

         elseif element._type == 'context' then
            table.insert(ncl[4], genContext(element))

         elseif element._type == 'link' then
            table.insert(ncl[5], genLink(element))
         end
      end
   end
   print(ins.inspect(ncl))
end

