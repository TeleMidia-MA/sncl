local ins = require"inspect"
local utils = require"utils"

local gen = {
}

--- Generates the NCL code of all the <simpleCondition> elements of a <causalConnector>
-- @param conds The conditions of the link
-- @param indent The indentation level
-- @param props The properties of the condition
-- @return
function gen.genConditions(conds, indent, props)
   local NCL = ''
   for pos, val in pairs(conds) do
      NCL = NCL..string.format('%s   <simpleCondition role="%s"', indent, pos)
      if val > 1 then
         NCL = NCL..(' max="unbounded" qualifier="and"')
      end
      if utils.containValue(props, '__keyValue') and pos == 'onSelection' then
         NCL = NCL..' key="$__keyValue"'
      end
      NCL = NCL..string.format('>%s</simpleCondition>', indent)
   end
   return NCL
end

--- Generates the NCL code of all the <simpleAction> elements of a <causalConnector>
-- @param acts
-- @param indent
-- @param props Properties of the action
-- @return
function gen.genActions(acts, indent)
   local NCL = ''
   for pos, val in pairs(acts) do
      NCL = NCL..string.format('%s   <simpleAction role="%s"', indent, pos)
      if val > 1 then
         NCL = NCL..' max="unbounded" qualifier="par"'
      end
      if pos == 'set' then
         NCL = NCL..' value="$setValue"'
      end
      NCL = NCL..string.format('>%s</simpleAction>', indent)
   end
   return NCL
end

--- Generates the NCL code of one <causalConnector> element
-- @param xconn
-- @param indent
-- @return
function gen:genXConnector(xconn, indent)
   local NCL = string.format('%s<causalConnector id="%s" >', indent, xconn.id)

   local nConds = 0
   for _, _ in pairs(xconn.condition) do
      nConds = nConds + 1
   end
   if nConds > 1 then
      NCL = NCL..string.format('%s   <compoundCondition operator="and" >', indent)
      NCL = NCL..self.genConditions(xconn.condition, indent, xconn.properties)
      NCL = NCL..string.format('%s   </compoundCondition>', indent)
   else
      NCL = NCL..self.genConditions(xconn.condition, indent, xconn.properties)
   end

   local nActs = 0
   for _, _ in pairs(xconn.action) do
      nActs = nActs + 1
   end
   if nActs > 1 then
      NCL = NCL..string.format('%s   <compoundAction operator="par" >', indent)
      NCL = NCL..self.genActions(xconn.action, indent)
      NCL = NCL..string.format('%s   </compoundAction>', indent)
   else
      NCL = NCL..self.genActions(xconn.action, indent)
   end
   for _, value in pairs(xconn.properties) do
      NCL = NCL..string.format('%s   <connectorParam name="%s" />', indent, value)
   end
   NCL = NCL..string.format('%s</causalConnector>', indent)

   return NCL
end

--- Generates the NCL code of one <region> element
-- @param ele
-- @param indent
-- @return
function gen.genRegion(ele, indent)
   local NCL = string.format('%s <region id="%s"', indent, ele.id)
   if ele.properties then
      for name, value in pairs(ele.properties) do
         NCL = NCL..string.format(' %s="%s"', name, value)
      end
   end
   NCL = NCL..'/>'
   return NCL
end

--- Generates the NCL code of one <descriptor> element
-- @param ele
-- @param indent
-- @return
function gen.genDesc(ele, indent)
   local NCL = string.format('%s<descriptor id="%s" region="%s" />', indent, ele.id, ele.region)
   return NCL
end

--- Generates the NCL code of the <head> element
-- @param indent
-- @param sT
-- @return
function gen:genHeadNCL(indent, sT)
   local connBase = '\n      <connectorBase>'
   local regionBase = '      <regionBase>'
   local descBase = '      <descriptorBase>'

   for _, val in pairs(sT.head) do
      if val._type == "xconnector"then
         connBase = connBase..self:genXConnector(val, indent.."   ")
      elseif val._type == "region" then
         regionBase = regionBase..self.genRegion(val, indent.."   ")
      elseif val._type == "descriptor" then
         descBase = descBase..self.genDesc(val, indent.."   ")
      end
   end
   return string.format('%s%s</connectorBase>\n%s%s</regionBase>\n%s%s</descriptorBase>'
      , connBase, indent, regionBase, indent, descBase, indent)
end

--- Generates the NCL code of the <bind> of a <link>
-- @param ele
-- @param indent
-- @param sT
-- @return
function gen.genBind(ele, indent, sT)
   local NCL = ""

   --[[ If the link(ele.father) has a father, then the component must
   be a son of the father of the link. Else, then the component must
   not have a father either]]
   if ele.father.father then
      if not ele.father.father.sons[ele.component] then
         utils.printErro(string.format('Component %s not in scope', ele.component), ele.line)
         return NCL
      end
   else
      if sT.presentation[ele.component].father then
         utils.printErro(string.format('Component %s not in scope', ele.component), ele.line)
         return NCL
      end
   end

   if not sT.presentation[ele.component] then
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
end

--- Generates the NCL code of one <link> element
-- @param ele
-- @param indent
-- @param sT
-- @return
function gen:genLink(ele, indent, sT)
   local NCL = string.format('%s<link xconnector="%s" >', indent, ele.xconnector)

   for _, act in pairs(ele.actions) do
      NCL = NCL..self.genBind(act,indent..'   ', sT)
   end
   for _, cond in pairs(ele.conditions) do
      NCL = NCL..self.genBind(cond, indent..'   ', sT)
   end
   if ele.properties then
      for name, value in pairs(ele.properties) do
         NCL = NCL..string.format('%s   <linkParam name="%s" value="%s" />', indent, name, value)
      end
   end
   NCL = NCL..string.format('%s</link>', indent)

   return NCL
end

--- Generates the NCL code of one presentation element
-- Elements: <media> <context> <area>
-- @param ele
-- @param indent
-- @param sT
-- @return
function gen:genPresentation(ele, indent, sT)
   -- Check if the refered region is decladed
   if ele._type == 'macro-call' or ele._type == 'for' then
      return ''
   end
   if ele.region then
      if not sT.head[ele.region] then
         utils.printErro(string.format('Region %s not declared', ele.region))
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
      NCL = NCL..string.format(' src=%s', ele.src)
   end
   if ele.descriptor then
      NCL = NCL..string.format(' descriptor=%s', ele.descriptor)
   end
   if ele.type then
      NCL = NCL..string.format(' type=%s', ele.type)
   end
   NCL = NCL..'>'
   if ele.properties then
      for name, value in pairs(ele.properties) do
         NCL = NCL..string.format('%s   <property name="%s" value=%s />', indent, name, value)
      end
   end
   -- TODO: Check if the son type is valid
   if ele.sons then
      for _, son in pairs(ele.sons) do
         if son._type == 'link' then
            NCL = NCL..self:genLink(son, indent..'   ', sT)
         else
            NCL = NCL..self:genPresentation(son, indent..'   ', sT)
         end
      end
   end
   NCL = NCL..string.format('%s</%s>', indent, ele._type)

   return NCL
end

--- Generates the NCL code of the <body> element
-- @param indent
-- @param sT
-- @return
function gen:genBodyNCL(indent, sT)
   local NCL = ''

   for _, ele in pairs(sT.presentation) do
      if ele._type and not ele.father then
         if ele._type == 'link' then
            NCL = NCL..self:genLink(ele, indent, sT)
         else
            NCL = NCL..self:genPresentation(ele, indent, sT)
         end
      end
   end

   for _, ele in pairs(sT.link) do
      if not ele.father then
         NCL = NCL..self:genLink(ele, indent, sT)
      end
   end

   return NCL
end

--- Generates the NCL code of the whole document
-- @param sT
-- @return
function gen:genNCL(sT)
   local indent = '\n   '
   local NCL = [[<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">]]
   NCL = NCL..indent..'<head>'
   NCL = NCL..self:genHeadNCL(indent..'   ', sT)
   NCL = NCL..indent..'</head>'
   NCL = NCL..indent..'<body>'
   NCL = NCL..self:genBodyNCL(indent..'   ', sT)
   NCL = NCL..indent..'</body>\n</ncl>'
   return NCL
end

return gen
