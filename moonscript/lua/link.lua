local Bind
do
  local _class_0
  local _base_0 = {
    checkComponent = function(self, symbolTable, component)
      return true
    end,
    checkInterface = function(self, symbolTable, component)
      return true
    end,
    toNcl = function(self, indent)
      return "\n" .. tostring(indent) .. "<bind role=\"" .. tostring(self.role) .. "\" component=\"" .. tostring(self.component) .. "\">"
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, role, component, attributes)
      assert(role ~= nil, tostring(self.__class.__name) .. " cannot have empty role")
      assert(component ~= nil, tostring(self.__class.__name) .. " cannot have empty component")
      assert(self.__class.roles[role], "Role " .. tostring(role) .. " invalid on component " .. tostring(self.__class.__name))
      self.role = role
      self.component = component
    end,
    __base = _base_0,
    __name = "Bind"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Bind = _class_0
end
local Condition
do
  local _class_0
  local _parent_0 = Bind
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, role, component, attributes)
      return _class_0.__parent.__init(self, role, component)
    end,
    __base = _base_0,
    __name = "Condition",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.__class.roles = {
    onBegin = true,
    onEnd = true,
    onAbort = true,
    onPause = true,
    onResume = true,
    onSelection = true,
    onAbortSelection = true,
    onEndSelection = true,
    onBeginSelection = true,
    onPauseSelection = true,
    onResumeSelection = true,
    onBeginAttribution = true,
    onEndAttributions = true,
    onPauseAttribution = true,
    onResumeAttribution = true,
    onAbortAttribution = true
  }
  self.__class.attributes = {
    delay = true,
    eventType = true,
    key = true,
    transition = true,
    min = true,
    max = true,
    qualifier = true
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Condition = _class_0
end
local Action
do
  local _class_0
  local _parent_0 = Bind
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, role, component, attributes)
      return _class_0.__parent.__init(self, role, component)
    end,
    __base = _base_0,
    __name = "Action",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.__class.roles = {
    start = true,
    stop = true,
    pause = true,
    abort = true,
    resume = true,
    set = true
  }
  self.__class.attributes = {
    delay = true,
    eventType = true,
    actionType = true,
    value = true,
    min = true,
    max = true,
    qualifier = true,
    ["repeat"] = true,
    repeatDelay = true,
    duration = true,
    by = true
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Action = _class_0
end
local Link
do
  local _class_0
  local _base_0 = {
    addCondition = function(self, condition)
      if self.conditions == nil then
        self.conditions = { }
      end
      return table.insert(self.conditions, condition)
    end,
    addAction = function(self, action)
      if self.actions == nil then
        self.actions = { }
      end
      return table.insert(self.actions, action)
    end,
    createxConnector = function(self)
      self.xconnector = ""
    end,
    toNcl = function(self, indent)
      if indent == nil then
        indent = ""
      end
      local children_ncl
      if self.actions then
        children_ncl = children_ncl or ""
        for _, action in pairs(self.actions) do
          children_ncl = children_ncl .. action:toNcl(indent .. "   ")
        end
      end
      if self.conditions then
        children_ncl = children_ncl or ""
        for _, condition in pairs(self.conditions) do
          children_ncl = children_ncl .. condition:toNcl(indent .. "   ")
        end
      end
      return "\n" .. tostring(indent) .. "<link>" .. tostring(children_ncl) .. "\n" .. tostring(indent) .. "</link>"
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, condition, action)
      if condition then
        self.conditions = {
          condition
        }
      end
      if action then
        self.actions = {
          action
        }
      end
      self.parameters = { }
      self.xconnector = ""
    end,
    __base = _base_0,
    __name = "Link"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.__class.children = {
    ["Condition"] = true,
    ["Action"] = true
  }
  Link = _class_0
end
return {
  Link = Link,
  Condition = Condition,
  Action = Action
}
