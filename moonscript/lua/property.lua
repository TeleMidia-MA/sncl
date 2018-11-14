local Property
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "Property"
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
  self.predefined = {
    "style",
    "player",
    "reusePlayer",
    "playerLife",
    "deviceClass",
    "explicitDur",
    "focusIndex",
    "moveLeft",
    "moveRight",
    "moveUp",
    "moveDown"
  }
  self.visual = {
    "top",
    "bottom",
    "left",
    "right",
    "width",
    "height",
    "location",
    "size",
    "bounds",
    "background",
    "rgbChromakey",
    "visible",
    "transparency",
    "fit",
    "scroll",
    "zIndex",
    "plan",
    "focusBorderColor",
    "selBorderColor",
    "focusBorderWidth",
    "focusBorderTransparency",
    "focusSrc",
    "focusSelSrc",
    "freeze"
  }
  self.continuous = {
    "contentId",
    "standby"
  }
  self.audio = {
    "soundLevel",
    "balanceLevel",
    "trebleLevel",
    "bassLevel",
    "freeze",
    "transIn",
    "transOut"
  }
  self.text = {
    "fontColot",
    "fontFamily",
    "textAlign",
    "fontStyle",
    "fontSize",
    "fontVariant",
    "fontWeight",
    "freeze",
    "transIn",
    "transOut"
  }
  self.settings = {
    "language",
    "caption",
    "subtitle",
    "returnBitRate",
    "screenSize",
    "screenGraphicSize",
    "audioType",
    "devNumber",
    "classType",
    "parentDeviceRegion",
    "info",
    "classNumber",
    "cpu",
    "memory",
    "operatingSystem",
    "luaVersion",
    "ncl.version",
    "GingaNCL.version"
  }
  self.user = {
    "age",
    "location",
    "genre"
  }
  self.default = {
    "focusBorderColor",
    "selBorderColor",
    "focusBorderWidth",
    "focusBorderTransparency"
  }
  self.service = {
    "currentFocus",
    "currentKeyMaster"
  }
  self.si = {
    "numberOfServices",
    "numberOfPartialServices",
    "channelNumber"
  }
  self.channel = {
    "keyCapture",
    "virtualKeyboard",
    "keyboardBounds"
  }
  self.shared = { }
  self.color = {
    "White",
    "Silver",
    "Gray",
    "Black",
    "Red",
    "Maroon",
    "Yellow",
    "Olive",
    "Lime",
    "Green",
    "Aqua",
    "Teal",
    "Blue",
    "Navy",
    "Fuchsia",
    "Purple"
  }
  Property = _class_0
  return _class_0
end
