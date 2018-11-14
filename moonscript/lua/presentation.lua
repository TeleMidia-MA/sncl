local Presentation
do
  local _class_0
  local _base_0 = {
    addProperty = function(self, name, value)
      return true
    end,
    getProperty = function(self, name)
      return true
    end,
    addAttribute = function(self, name, value)
      assert(self.__class.attributes[name], "Invalid attribute " .. tostring(name) .. " on " .. tostring(self.__class.__name) .. " " .. tostring(self.id))
      if self.attributes == nil then
        self.attributes = { }
      end
      self.attributes[name] = value
    end,
    getAttribute = function(self, name)
      if self.attributes[name] then
        return self.attributes[name]
      end
      return false
    end,
    addChildren = function(self, child)
      assert(self.__class.children[child.__class.__name], tostring(child.__class.__name) .. " cannot be children of " .. tostring(self.__class.__name))
      if not self.children then
        self.children = { }
      end
      if child.__class.__name == "Link" then
        return table.insert(self.children, child)
      else
        self.children[child.id] = child
      end
    end,
    toNcl = function(self, indent)
      if indent == nil then
        indent = ""
      end
      local attributes_ncl
      if self.attributes then
        attributes_ncl = ""
        for k, v in pairs(self.attributes) do
          attributes_ncl = attributes_ncl .. " \"" .. tostring(k) .. "=" .. tostring(v) .. "\""
        end
      end
      local child_ncl
      if self.children then
        child_ncl = ""
        for k, v in pairs(self.children) do
          child_ncl = child_ncl .. v:toNcl(indent .. "   ")
        end
      end
      return "\n" .. tostring(indent) .. "<" .. tostring(self.__class.__name:lower()) .. " id=\"" .. tostring(self.id) .. "\"" .. tostring((function()
        if attributes_ncl then
          return attributes_ncl
        else
          return ""
        end
      end)()) .. ">" .. tostring((function()
        if child_ncl then
          return child_ncl
        else
          return ""
        end
      end)()) .. "\n" .. tostring(indent) .. "</" .. tostring(self.__class.__name:lower()) .. ">"
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, id)
      if __DEBUG__ then
        print("Creating ", self.__class.__name)
      end
      assert(id ~= nil)
      self.id = id
    end,
    __base = _base_0,
    __name = "Presentation"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Presentation = _class_0
end
local Context
do
  local _class_0
  local _parent_0 = Presentation
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, id, attributes)
      _class_0.__parent.__init(self, id)
      if attributes then
        for k, v in pairs(attributes) do
          _class_0.__parent.addProperty(self, k, v)
        end
      end
    end,
    __base = _base_0,
    __name = "Context",
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
  self.__class.attributes = {
    ["refer"] = true
  }
  self.__class.children = {
    ["Context"] = true,
    ["Media"] = true,
    ["Link"] = true
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Context = _class_0
end
local Media
do
  local _class_0
  local _parent_0 = Presentation
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, id, attributes)
      _class_0.__parent.__init(self, id)
      if attributes then
        for k, v in pairs(attributes) do
          _class_0.__parent.addAttribute(self, k, v)
        end
      end
    end,
    __base = _base_0,
    __name = "Media",
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
  self.__class.attributes = {
    ["src"] = true,
    ["type"] = true,
    ["refer"] = true,
    ["instance"] = true,
    ["descriptor"] = true
  }
  self.__class.children = {
    ["Area"] = true
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Media = _class_0
end
local Area
do
  local _class_0
  local _parent_0 = Presentation
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, id, attributes)
      _class_0.__parent.__init(self, id)
      if attributes then
        for k, v in pairs(attributes) do
          _class_0.__parent.addAttribute(self, k, v)
        end
      end
    end,
    __base = _base_0,
    __name = "Area",
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
  self.__class.attributes = {
    ["coords"] = true,
    ["begins"] = true,
    ["end"] = true,
    ["beginText"] = true,
    ["endText"] = true,
    ["beginPosition"] = true,
    ["endPosition"] = true,
    ["first"] = true,
    ["last"] = true,
    ["label"] = true,
    ["clip"] = true
  }
  self.__class.children = nil
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Area = _class_0
end
return {
  Context = Context,
  Media = Media,
  Area = Area
}
