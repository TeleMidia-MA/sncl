local ins = require"inspect"
local utils = require"utils"

function genBind(ele, indent)
   local NCL = ""
   if not gblPresTbl[ele.component] then
      utils.printErro("No element "..ele.component.." declared")
      return ""
   end
   NCL = NCL..indent.."<bind role=\""..ele.role.."\" component=\""..ele.component.."\""
   if ele.interface then
      NCL = NCL.." interface=\""..ele.interface.."\""
   end
   NCL = NCL.." >"
   if ele.properties then
      for name, value in pairs(ele.properties) do
         NCL = NCL..indent.."   <bindParam name=\""..name.."\" value=\""..value.."\"/>"
      end
   end
   NCL = NCL..indent.."</bind>"
   return NCL
end

function genLink(ele, indent)
   local NCL = indent.."<link xconnector=\""..ele.xconnector.."\" >"

   for _, act in pairs(ele.actions) do
      NCL = NCL..genBind(act,indent.."   ")
   end
   for _, cond in pairs(ele.conditions) do
      NCL = NCL..genBind(cond, indent.."   ")
   end
   if ele.properties then
      for name, value in pairs(ele.properties) do
         NCL = NCL..indent.."   <linkParam name=\""..name.."\" value=\""..value.."\" />"
      end
   end

   local NCL = NCL..indent.."</link>"
   return NCL
end

function genPresentation(ele, indent)
   -- Check if the refered region is decladed
   if ele._type == "macro-call" then
      return ""
   end
   if ele._region then
      if not gblHeadTbl[ele._region] then
         utils.printErro("Region "..ele._region.." not declared")
         return ""
      end
   end
   local NCL = indent.."<"..ele._type.." id=\""..ele.id.."\" "
   if ele.component then
      NCL = NCL.."component=\""..ele.component.."\" "
   end
   if ele.interface then
      NCL = NCL.."interface=\""..ele.interface.."\" "
   end
   if ele.src then
      NCL = NCL.."src=\""..ele.src.."\" "
   end
   if ele.descriptor then
      NCL = NCL.."descriptor=\""..ele.descriptor.."\" "
   end
   if ele.type then
      NCL = NCL.."type=\""..ele.type.."\" "
   end
   NCL = NCL..">"
   if ele.properties then
      for name, value in pairs(ele.properties) do
         NCL = NCL..indent.."   <property name=\""..name.."\" value=\""..value.."\" />"
      end
   end
   -- TODO: Check if the son type is valid
   if ele.sons then
      for _, son in pairs(ele.sons) do
         if son._type == "link" then
            NCL = NCL..genLink(son, indent.."   ")
         else
            NCL = NCL..genPresentation(son, indent.."   ")
         end
      end
   end
   NCL = NCL..indent.."</"..ele._type..">"
   return NCL
end

function genBodyNCL(indent)
   local NCL = ""
   for _, ele in pairs(gblPresTbl) do
      if ele._type and not ele.father then
         NCL = NCL..genPresentation(ele, indent)
      end
   end

   for _, ele in pairs(gblLinkTbl) do
      if not ele.father then
         NCL = NCL..genLink(ele, indent)
      end
   end

   return NCL
end

function genConditions(conds, indent, props)
   local NCL = ""
   for pos, val in pairs(conds) do
      NCL = NCL..indent.."<simpleCondition role=\""..pos.."\""
      if val > 1 then
         NCL = NCL.." max=\"unbounded\" qualifier=\"and\""
      end
      if utils.containValue(props, "__keyValue") and pos=="onSelection" then
         NCL = NCL.." key=\"$__keyValue\""
      end
      NCL = NCL..">"
      NCL = NCL..indent.."</simpleCondition>"
   end
   return NCL
end

function genActions(acts, indent, props)
   local NCL = ""
   for pos, val in pairs(acts) do
      NCL = NCL..indent.."<simpleAction role=\""..pos.."\""
      if val > 1 then
         NCL = NCL.." max=\"unbounded\" qualifier=\"par\""
      end
      if pos == "set" then
         NCL = NCL.." value=\"$setValue\""
      end
      NCL = NCL..">"
      NCL = NCL..indent.."</simpleAction>"
   end
   return NCL
end

function genXConnector(xconn, indent)
   local NCL = ""
   NCL = NCL..indent.."<causalConnector id=\""..xconn.id.."\" >"
   local nConds = 0
   for _, _ in pairs(xconn.condition) do
      nConds = nConds+1
   end
   if nConds > 1 then
      NCL = NCL..indent.."   <compoundCondition operator=\"and\" >"
      NCL = NCL..genConditions(xconn.condition, indent.."      ", xconn.properties)
      NCL = NCL..indent.."   </compoundCondition>"
   else
      NCL = NCL..genConditions(xconn.condition, indent.."   ", xconn.properties)
   end
   local nActs = 0
   for _, _ in pairs(xconn.action) do
      nActs = nActs+1
   end
   if nActs > 1 then
      NCL = NCL..indent.."   <compoundAction operator=\"par\" >"
      NCL = NCL..genActions(xconn.action, indent.."      ")
      NCL = NCL..indent.."   </compoundAction>"
   else
      NCL = NCL..genActions(xconn.action, indent.."   ")
   end
   for _, value in pairs(xconn.properties) do
      NCL = NCL..indent.."   <connectorParam name=\""..value.."\" />"
   end
   NCL = NCL..indent.."</causalConnector>"
   return NCL
end

function genRegion(ele, indent)
   local NCL = indent.."<region id=\""..ele.id.."\""
   if ele.properties then
      for name, value in pairs(ele.properties) do
         NCL = NCL.." "..name.."=\""..value.."\""
      end
   end
   NCL = NCL.."/>"
   return NCL
end

function genDesc(ele, indent)
   local NCL = indent.."<descriptor id=\""..ele.id.."\" region=\""..ele.region.."\" />"
   return NCL
end

function genHeadNCL(indent)
   local NCL = ""
   local connBase = "\n      <connectorBase>"
   local regionBase = "      <regionBase>"
   local descBase = "      <descriptorBase>"
   for _, val in pairs(gblHeadTbl) do
      if val._type == "xconnector"then
         connBase = connBase..genXConnector(val,indent.."   ")
      elseif val._type == "region" then
         regionBase = regionBase..genRegion(val, indent.."   ")
      elseif val._type == "descriptor" then
         descBase = descBase..genDesc(val, indent.."   ")
      end
   end
   NCL = NCL..connBase..indent.."</connectorBase>\n"
   NCL = NCL..regionBase..indent.."</regionBase>\n"
   NCL = NCL..descBase..indent.."</descriptorBase>"
   return NCL
end

function genNCL()
   local indent = "\n   "
   local NCL = [[<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">]]
   NCL = NCL..indent.."<head>"
   NCL = NCL..genHeadNCL(indent.."   ")
   NCL = NCL..indent.."</head>"
   NCL = NCL..indent.."<body>"
   NCL = NCL..genBodyNCL(indent.."   ")
   NCL = NCL..indent.."</body>\n</ncl>"
   return NCL
end
