local switch
local Switch = {}

function switch.new(id, linha)
   local self = {
      id = id,
      father = nil,
      refer = nil,
   }
   setmetatable(self, {__index = Switch})
   return self
end

function Switch:toNCL()
   local switch = ""
   return switch
end

return switch
