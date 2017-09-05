Switch = {}
Switch_mt = {}

Switch_mt.__index = Switch

function Switch.new(id, linha)
   local switchObject = {
      id = id,
      father = nil,
      refer = nil,
   }
   setmetatable(switchObject, Switch_mt)
   return switchObject
end

function Switch:toNCL()
   local switch = ""
   return switch
end
