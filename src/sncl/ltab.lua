-- local ins = require('sncl.inspect')

-- @param port uma porta sNCL
function makePort(port)
   local newPort = port.component.."@"

   if port.interface then
      newPort = newPort..port.interface
   else
      newPort = newPort.."lambda"
   end

   return newPort
end

-- @param media uma media sNCL
function makeMedia(media)
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

function makeContext(context)
   -- Ports, Children and Links
   local newContext = {context._type, context.id, {}, {}, {}}
   for _, son in pairs(context.children) do

      if son._type == 'port' then
         table.insert(newContext[3], makePort(son))

      elseif son._type == 'media' then
         table.insert(newContext[4], makeMedia(son))

      elseif son._type == 'context' then
         table.insert(newContext[4], makeContext(son))

      elseif son._type == 'link' then
         table.insert(newContext[5], makeLink(son))
      end

   end
   return newContext
end

function makeLink(link)
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

function makeLtab(sncl_table)
   ncl = {
      'context',
      'ncl',
      {}, -- Ports
      {}, -- Media, Context, rule
      {{}, {}}, -- Link
   }

   for _, element in pairs(sncl_table.presentation) do
      if not element.father then
         if element._type == 'port' then
            table.insert(ncl[3], makePort(element))

         elseif element._type == 'media' then
            table.insert(ncl[4], makeMedia(element))

         elseif element._type == 'context' then
            table.insert(ncl[4], makeContext(element))

         elseif element._type == 'link' then
            table.insert(ncl[5], makeLink(element))
         end
      end
   end
   return ncl
end

