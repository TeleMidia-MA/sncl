local lpeg = require("lpeg")
local utils = require("utils")
local t = lpeg.locale()
local V, P, R, C = lpeg.V, lpeg.P, lpeg.R, lpeg.C
local Cb = lpeg.Cb

local SPC = V"Espacos"

gramaticaSncl = {
   "INICIAL";

   ------ MISC ------
   Espacos = t.space
   /function(str)
      if str == "\n" then
         gblParserLine = gblParserLine+1
      end
   end,
   Symbols = (P"@"+P"_"+P"/"+P"."+P"%"+P"-"),
   Id = (t.alnum+P"_"+P"-")^1,
   String = (P"\""*(t.alnum+P" "+P"/"+P"."+P"-"+P"%")^0*P"\""),

   PropertyName = (t.alnum+P"_"+P"-")^1,
   PropertyValue = (V"String" + (t.alnum+P":"+P"_"+P"-"+P"."+P"/"+P"%")^1 ),

   Property = (V"PropertyName" *P" "^0* P":" *P" "^0* V"PropertyValue" *SPC^0)
   /function(str)
      str = str:gsub("%s+", "")
      if gblCurrentElement ~= nil then
         gblCurrentElement:parseProperty(str)
      else
         utils.printErro("Property"..str.." declared in invalid context", gblParserLine)
      end
   end,

   Refer = (P"refer" *P" "^0* P":" *P" "^0* t.alnum^1 *SPC^0)
   /function(str)
      str = str:gsub("%s+", "")
      parseRefer(str)
   end,
   Comentario = (P"--"*P" "^0* (t.alnum+t.punct+t.xdigit+P"¨"+P"´"+P" ")^0 *SPC^0),

   End = (P"end" * SPC^0)
   /function()
      if not gblCurrentElement then
         utils.printErro("No element to end", gblParserLine)
         return
      end
      if gblCurrentElement._type == "macro" then
         gblInsideMacro = false
      end
      gblCurrentElement.hasEnd = true
      if not gblCurrentElement.father then
         gblCurrentElement = nil
      else
         gblCurrentElement = gblCurrentElement.father
      end
   end,

   ------ PORT ------
   Port = (P"port" *P" "^1* V"Id" *P" "^1* (V"Symbols"+t.alnum)^1 *SPC^0)
   /function(str)
      parsePort(str)
   end,

   ------ REGION ------
   RegionId = (P"region" *P" "^1 *V"Id" *SPC^0)
   /function(str)
      local newRegion = Elemento.new("region", gblParserLine)
      utils.newElement(str, newRegion)
   end,
   Region = (V"RegionId"
   * (V"Comentario"+V"MacroCall"+V"Region"+V"Property")^0
   * V"End"^-1),

   ------ SWITCH ------

   ------ CONTEXT ------
   ContextId = (P"context"*P" "^1*V"Id"*SPC^0)
   /function(str)
      local newContext = Elemento.new("context", gblParserLine)
      utils.newElement(str, newContext)
   end,
   Context = (V"ContextId"
   *(V"Comentario"+V"MacroCall"+V"Port"+V"Property"+ V"Media"+V"Context"+V"Link"+V"Refer")^0
   * V"End"^-1),

   ------ MEDIA ------
   MediaId = (P"media" *P" "^1* V"Id" *SPC^0)
   /function(str)
      local newMedia = Elemento.new("media", gblParserLine)
      utils.newElement(str, newMedia)
   end,
   Media = V"MediaId"
   * (V"Comentario"+V"MacroCall"+V"Area"+V"Refer"+V"Property")^0
   * V"End"^-1,

   ------ AREA ------
   AreaId = P"area" *P" "^1* V"Id" *SPC^0
   /function(str)
      local newArea = Elemento.new("area", gblParserLine)
      utils.newElement(str, newArea)
   end,
   Area = (V"AreaId"
   * (V"Comentario"+V"Property")^0
   * V"End"^-1),

   ------ LINK ------
   Link = (V"Condition"
   * SPC^0* (V"Comentario"+V"Property"+V"Action")^0
   * V"End"^0)
   /function(str)
      print(str)
      local newLink = Link.new(gblParserLine)
      print"Link Criado"
   end,

   Condition = (V"ConditionParse")
   /function(str)
      print(str)
      local newCondition = Condition.new(gblParserLine)
      newCondition:parseStr(str)
      --parseLinkCondition(str)
   end,
   ConditionParse = ((t.alnum+V"Symbols")^1 *P" "^1* (V"Id"*(P"."*V"Id")^-1) *P" "^0* V"CondTerm" *P" "^0),
   CondTerm = ((P"and" *P" "^1* V"ConditionParse") + (P"do")),

   Action = ( V"ActionMedia"
   * (V"Comentario"+V"Property")^0
   * V"End"^-1)
   /function(str)
      print(str)
      local newAction = Action.new(gblParserLine)
   end,
   ActionMedia = (t.alnum^1 *P" "^1* (t.alnum+V"Symbols")^1 *SPC^1)
   /function(str)
      --parseLinkAction(str)
   end,
   -- ActionParam = (t.alnum^1 *P" "^0* P":" *P" "^0* V"String"* SPC^0)
   -- /function(str)
   --    --parseLinkActionParam(str)
   -- end,

   ------ MACRO ------
   MacroCallParams = V"PropertyValue" *P" "^0* (P","*P" "^0*V"PropertyValue"*P" "^0)^0,
   MacroCall = V"Id" *P" "^0*P"("*P" "^0*V"MacroCallParams"^-1*P" "^0*P")" *SPC^0
   /function(str)
      parseMacroCall(str)
   end,

   MacroParams = V"PropertyName"*P" "^0* (P","*P" "^0*V"PropertyName"*P" "^0)^0,

   MacroId = P"macro" *P" "^1* V"Id" *P" "^0*P"("*P" "^0*V"MacroParams"^-1*P" "^0*P")" *SPC^0
   /function(str)
      local id, params, quant = parseIdMacro(str)
      if not id then
         utils.printErro("Invalid Id", gblParserLine)
         return
      end
      if not gblSymbolTable[id] then
         local newMacro = Macro.new(id)
         newMacro:setParams(params)
         newMacro.quantParams = quant
         gblSymbolTable[id] = newMacro
         gblSymbolTable.macros[id] = gblSymbolTable[id]
         if gblCurrentElement then
            utils.printErro("Macro can not be declared inside of "..gblCurrentElement._type, gblParserLine)
            return
         else
            gblCurrentElement = newMacro
         end
      else
         utils.printErro("Id "..id.." already declared", gblParserLine)
         return
      end
      gblInsideMacro = true
   end,
   Macro = (V"MacroId"
   * (V"Comentario"+V"MacroCall"+V"Property"+V"Media"+V"Area"+V"Context"+V"Link"+V"Region")^0
   * V"End"^-1),


   --
   -- START --
   INICIAL = SPC^0 * (V"Comentario"+V"Macro"+V"MacroCall"+V"Port"+V"Region"+V"Media"+V"Context"+V"Link")^0,
}

keywordTable = {
   action = (P"start"+P"stop"+P"abort"+P"pause"+P"resume"+P"set"),

   condition = (P"onBegin"+P"onEnd"+P"onAbort"+P"onPause"+P"onResume"+P"onSelection"+
   P"onBeginSelection"+P"onEndSelection"+P"onAbortSelection"+P"onPauseSelection"+
   P"onResumeSelection"+P"onBeginAttribution"+P"onEndAttribution"+P"onPauseAttribution"+
   P"onResumeAttribution"+P"onAbortAttribution"),

   properties = (P"background"+P"balanceLevel"+P"bassLevel"+P"bottom"+P"bounds"+
   P"explicitDur"+P"fit"+P"focusIndex"+P"fontColor"+P"fontFamily"+P"fontSize"+
   P"fontStyle"+P"fontVariant"+P"fontWeight"+P"height"+P"left"+P"location"+
   P"plan"+P"playerLife"+P"reusePlayer"+P"rgbChromakey"+P"right"+P"scroll"+
   P"size"+P"soundLevel"+P"style"+P"top"+P"transparency"+P"trebleLevel"+
   P"visible"+P"width"+P"zIndex"),

   areaProperties = (P"coords"+P"begin"+P"end"+P"beginText"+P"endText"+P"beginPosition"+P"endPosition"+P"first"+P"last"+P"label"+P"clip"),
}

-- TODO: Add check for Id

dataType = {
   time = ( ((R"01"*R"09")+(P"2"*R"03"))*P":"*(R"05"*R"09")*P":"*(R"05"*R"09")*(P"."*R"09"^1)^-1*(P"."*R"09"^1)^-1 ),
   percent = ((P"100"*(P"."*P"0"^1)^-1*P"%") + (R"09"*R"09"^-1*(P"."*R"09"^1)^-1*P"%")), seconds = (R"09"*R"09"*P"s"), 
   pixel = ((R"09"^1*P"px"^-1) ),
   integer = (t.digit^1),
   button = (P"0"+P"1"+P"2"+P"3"+P"4"+P"5"+P"6"+P"7"+P"8"+P"9"+
   P"A"+P"B"+P"C"+P"D"+P"E"+P"F"+P"G"+P"H"+P"I"+
   P"J"+P"K"+P"L"+P"M"+P"N"+P"O"+P"P"+P"Q"+P"R"+
   P"S"+P"T"+P"U"+P"V"+P"W"+P"X"+P"Y"+P"Z"+P"#"+
   P"MENU"+P"INFO"+P"GUIDE"+
   P"CURSOR_DOWN"+P"CURSOR_LEFT"+P"CURSOR_RIGHT"+P"CURSOR_UP"+
   P"CHANNEL_DOWN"+P"CHANNEL_UP"+P"CHANNEL_LEFT"+P"CHANNEL_RIGHT"+
   P"VOLUME_DOWN"+P"VOLUME_UP"+P"VOLUME_LEFT"+P"VOLUME_RIGHT"+
   P"RED"+P"GREEN"+P"YELLOW"+P"BLUE"+
   P"BACK"+P"EXIT"+P"POWER"+P"REWIND"+P"STOP"+P"EJECT"+P"PLAY"+P"RECORD"+P"PAUSE"+P"ENTER"),
   color = (P"\""*(P"white"+P"black"+P"silver"+P"gray"+P"red"+P"maroon"+P"fuchsia"+
      P"purple"+P"lime"+P"green"+P"yellow"+P"olive"+P"blue"+P"navy"+P"aqua"+
      P"transparent")*P"\""),
   -- TODO: Fix Id
   id = (t.alnum+P"_"+P"-")^1,
   string = (P"\"" *(t.alnum+P"@"+P"_"+P"/"+P"."+P"%"+P","+P"-"+P" ")^1* P"\""),
   mime = (P"\""*t.alpha^1*P"/"*t.alpha^1*P"\""),
   rgb = (""),-- #XXXXXX
   actionProperties = (P"delay"+P"value"+P"repeat"+P"repeatDelay"+P"duration"+P"by"),
   conditionProperties = (P"delay"+P"transition"+P"key"),
   boolean = (P"true"+P"false"),
}

-- TODO: Add transition properties

propertiesValues = {
   --[[
   ["style"]       = nil,
   ["playerLife"]  = nil,
   ["deviceClass"] = nil,
   ["fit"] = nil,
   ["scroll"] = nil,
   ["focusSrc"] = nil,
   ["focusSelSrc"] = nil,
   ["plan"] = nil,
   ]]
   ["src"]                     = {1, dataType.string},
   ["type"]                    = {1, dataType.mime},
   ["rg"]                      = {1, dataType.id},
   ["player"]                  = {1, dataType.string},
   ["reusePlayer"]             = {1, dataType.boolean},
   ["explicitDur"]             = {1, dataType.time+dataType.seconds},
   ["focusIndex"]              = {1, dataType.integer},
   ["moveLeft"]                = {1, dataType.integer},
   ["moveRight"]               = {1, dataType.integer},
   ["moveUp"]                  = {1, dataType.integer},
   ["moveDown"]                = {1, dataType.integer},
   ["top"]                     = {1, dataType.percent + dataType.pixel},
   ["bottom"]                  = {1, dataType.percent + dataType.pixel},
   ["left"]                    = {1, dataType.percent + dataType.pixel},
   ["right"]                   = {1, dataType.percent + dataType.pixel},
   ["width"]                   = {1, dataType.percent + dataType.pixel},
   ["height"]                  = {1, dataType.percent + dataType.pixel},
   ["location"]                = {2, dataType.percent + dataType.pixel},
   ["size"]                    = {2, dataType.percent + dataType.pixel},
   ["bounds"]                  = {4, dataType.percent + dataType.pixel},
   ["background"]              = {1, dataType.color},
   ["rgbChromaKey"]            = {1, dataType.color + dataType.rgb},
   ["visible"]                 = {1, dataType.boolean},
   ["transparency"]            = {1, dataType.percent},
   ["zIndex"]                  = {1, dataType.integer},
   ["focusBorderColor"]        = {1, dataType.color},
   ["selBorderColor"]          = {1, dataType.color},
   ["focusBorderWidth"]        = {1, dataType.integer},
   ["focusBorderTransparency"] = {1, dataType.percent},
   ["freeze"]                  = {1, dataType.boolean},
   ["fontColor"]               = {1, dataType.color},
   ["fontSize"]                = {1, dataType.integer},
   ["text"]                    = {1, dataType.string},
   -- TODO: Separate area properties
   ["coords"]                  = {4, dataType.percent+dataType.pixel},
   ["begin"]                   = {1, dataType.time+dataType.seconds},
   ["end"]                     = {1, dataType.time+dataType.seconds},
   ["beginText"]               = {1, dataType.string},
   ["endText"]                 = {1, dataType.string},
   ["beginPosition"]           = {1, dataType.integer},
   ["endPosition"]             = {1, dataType.integer},
   --["first"] =
   --["last"] =
   ["label"]                   = {1, dataType.string},
   ["clip"]                    = {1, dataType.string},
}
