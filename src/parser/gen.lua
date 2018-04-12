local ins = require"inspect"
local utils = require"utils"
local gbl = utils.globals

local gen = {
   genBind = function(ele, indent)
      local NCL = ""

      if not gbl.presentationTbl[ele.component] then
         utils.printErro(string.format('No element %s declared', ele.component))
         return ""
      end
      NCL = NCL..string.format('%s<bind role="%s" component="%s"', indent, ele.role, ele.component)
      if ele.interface then
         NCL = NCL..string.format(' interface="%s"', ele.interface)
      end
      NCL = NCL..'>'
      if ele.properties then
         for name, value in pairs(ele.properties) do
            NCL = NCL..string.format('%s<bindParam name="%s" value="%s" >', indent, name, value)
         end
      end
      NCL = NCL..string.format('%s</bind>', indent)

      return NCL
   end,

   genLink = function(ele, indent)
      NCL = string.format('%s<link xconnector="%s" >', indent, ele.xconnector)

      for _, act in pairs(ele.actions) do
         NCL = NCL..genBind(act,indent..'   ')
      end
      for _, cond in pairs(ele.conditions) do
         NCL = NCL..genBind(cond, indent..'   ')
      end
      if ele.properties then
         for name, value in pairs(ele.properties) do
            NCL = NCL..indent..'   <linkParam name="..name.." value="..value.." />'
         end
      end
      NCL = NCL..string.format('%s</link>', indent)

      return NCL
   end,

   genPresentation = function(ele, indent)
      -- Check if the refered region is decladed
      if ele._type == 'macro-call' or ele._type == 'for' then
         return ''
      end
      if ele._region then
         if not gbl.headTbl[ele._region] then
            utils.printErro(string.format('Region %s not declares', ele.region))
            return ''
         end
      end
      local NCL = string.format('%s<%s id="%s"', indent, ele._type, ele.id)

      if ele.component then
         NCL = NCL..string.format(' component="%s"', ele.component)
      end
      if ele.interface then
         NCL = NCL..string.format(' interface="%s"', ele.interface)
      end
      if ele.src then
         NCL = NCL..string.format(' src="%s"', ele.src)
      end
      if ele.descriptor then
         NCL = NCL..string.format(' descriptor="%s"', ele.descriptor)
      end
      if ele.type then
         NCL = NCL..string.format(' type="%s"', ele.type)
      end
      NCL = NCL..'>'
      if ele.properties then
         for name, value in pairs(ele.properties) do
            NCL = NCL..string.format('%s<property name="%s" value="%s" />', indent, name, value)
         end
      end
      -- TODO: Check if the son type is valid
      if ele.sons then
         for _, son in pairs(ele.sons) do
            if son._type == 'link' then
               NCL = NCL..genLink(son, indent..'   ')
            else
               NCL = NCL..genPresentation(son, indent..'   ')
            end
         end
      end
      NCL = NCL..string.format('%s</%s>', indent, ele._type)

      return NCL
   end,

   genConditions = function(conds, indent, props)
      local NCL = ''
      for pos, val in pairs(conds) do
         NCL = NCL..string.format('<simpleCondition role="%s"', pos)
         if val > 1 then
            NCL = NCL..(' max="unbounded" qualifier="and"')
         end
         if utils.containValue(props, '__keyValue') and pos=='onSelection' then
            NCL = NCL..' key="$__keyValue"'
         end
         NCL = NCL..string.format('>%s</simpleCondition>', indent)
      end
      return NCL
   end,

   genActions = function(acts, indent, props)
      local NCL = ''
      for pos, val in pairs(acts) do
         NCL = NCL..string.format('<simpleAction role="pos"', pos)
         if val > 1 then
            NCL = NCL..' max="unbounded" qualifier="par"'
         end
         if pos == 'set' then
            NCL = NCL..' value="$setValue"'
         end
         NCL = NCL..string.format('>%s</simpleAction>', indent)
      end
      return NCL
   end,

   genXConnector = function(xconn, indent)
      local NCL = string.format('%s<causalConnector id="%s" >', indent, xconn.id)

      local nConds = 0
      for _, _ in pairs(xconn.condition) do
         nConds = nConds+1
      end
      if nConds > 1 then
         NCL = NCL..string.format('%s   <compoundCondition operator="and" >', indent)
         NCL = NCL..genConditions(xconn.condition, indent..'      ', xconn.properties)
         NCL = NCL..string.format('%s   </compoundCondition>', indent)
      else
         NCL = NCL..genConditions(xconn.condition, indent..'   ', xconn.properties)
      end

      local nActs = 0
      for _, _ in pairs(xconn.action) do
         nActs = nActs+1
      end
      if nActs > 1 then
         NCL = NCL..string.format('%s   <compoundAction operator="par" >', indent)
         NCL = NCL..genActions(xconn.action, indent.."      ")
         NCL = NCL..string.format('%s   </compoundAction>', indent)
      else
         NCL = NCL..genActions(xconn.action, indent.."   ")
      end
      for _, value in pairs(xconn.properties) do
         NCL = NCL..string.format('%s   <connectorParam name="%s" />', indent, value)
      end
      NCL = NCL..string.format('%s</causalConnector>', indent)

      return NCL
   end,

   genRegion = function(ele, indent)
      local NCL = string.format('%s <region id="%s"', indent, ele.id)
      if ele.properties then
         for name, value in pairs(ele.properties) do
            NCL = string.format(' %s="%s"', name, value)
         end
      end
      NCL = NCL..'/>'
      return NCL
   end,

   genDesc = function(ele, indent)
      local NCL = string.format('%s<descriptor id="%s" region="%s" />', indent, ele.id, ele.region)
      return NCL
   end,

   genHeadNCL = function(indent)
      local connBase = '\n      <connectorBase>'
      local regionBase = '      <regionBase>'
      local descBase = '      <descriptorBase>'

      for _, val in pairs(gbl.headTbl) do
         if val._type == "xconnector"then
            connBase = connBase..genXConnector(val,indent.."   ")
         elseif val._type == "region" then
            regionBase = regionBase..genRegion(val, indent.."   ")
         elseif val._type == "descriptor" then
            descBase = descBase..genDesc(val, indent.."   ")
         end
      end
      return string.format('%s%s</connectorBase>\n%s%s</regionBase>\n%s%s</descriptorBase>', connBase, indent, regionBase, indent, descBase, indent)
   end,

   genBodyNCL = function(indent)
      local NCL = ''

      for _, ele in pairs(gbl.presentationTbl) do
         if ele._type and not ele.father then
            NCL = NCL..genPresentation(ele, indent)
         end
      end

      for _, ele in pairs(gbl.linkTbl) do
         if not ele.father then
            NCL = NCL..genLink(ele, indent)
         end
      end

      return NCL
   end,

   genNCL = function()
      local indent = '\n   '
      local NCL = [[<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">]]
      NCL = NCL..indent..'<head>'
      NCL = NCL..genHeadNCL(indent..'   ')
      NCL = NCL..indent..'</head>'
      NCL = NCL..indent..'<body>'
      NCL = NCL..genBodyNCL(indent..'   ')
      NCL = NCL..indent..'</body>\n</ncl>'
      return NCL
   end,
}
return gen
