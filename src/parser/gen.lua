local ins = require"inspect"
local utils = require"utils"

function genLink(ele, indent)
   local NCL = indent.."<link xconnector=\""..ele.xconnector.."\" >"

   for _, act in pairs(ele.actions) do
      if not gblPresTbl[act.component] then
         utils.printErro("No element "..act.component.." declared")
         return ""
      end
      NCL = NCL..indent.."   <bind role=\""..act.role.."\" component=\""..act.component.."\""
      if act.interface then
         NCL = NCL.." interface=\""..act.interface.."\""
      end
      NCL = NCL.." >"
      if act.properties then
         for name, value in pairs(act.properties) do
            NCL = NCL..indent.."      <bindParam name=\""..name.."\" value=\""..value.."\" />"
         end
      end
      NCL = NCL..indent.."   </bind>"
   end

   for _, cond in pairs(ele.conditions) do
      if not gblPresTbl[cond.component] then
         utils.printErro("No element "..cond.component.." declared")
         return ""
      end
      NCL = NCL..indent.."   <bind role=\""..cond.role.."\" component=\""..cond.component.."\""
      if cond.interface then
         NCL = NCL.." interface=\""..cond.interface.."\""
      end
      NCL = NCL.." >"
      NCL = NCL..indent.."   </bind>"
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
   local NCL = indent.."<"..ele._type.." id=\""..ele.id.."\" >"
   if ele.properties then
      for name, value in pairs(ele.properties) do
         NCL = NCL..indent.."   <property name=\""..name.."\" value=\""..value.."\" />"
      end
   end
   if ele.sons then
      for _, son in pairs(ele.sons) do
         if son._type == "link" then
            NCL = NCL..genLink(son, indent.."   ")
         else
            NCL = NCL..genPresentation(son, indent.."   ")
         end
      end
   end
   NCL = NCL..indent.."</"..ele._type.." >"
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

function genConditions(conds, indent)
   local NCL = ""
   for pos, val in pairs(conds) do
      NCL = NCL..indent.."<simpleCondition role=\""..pos.."\""
      if val > 1 then
         NCL = NCL.." max=\"unbounded\" qualifier=\"and\""
      end
      NCL = NCL..">"
      NCL = NCL..indent.."</simpleCondition>"
   end
   return NCL
end

function genActions(acts, indent)
   local NCL = ""
   for pos, val in pairs(acts) do
      NCL = NCL..indent.."<simpleAction role=\""..pos.."\""
      if val > 1 then
         NCL = NCL.." max=\"unbounded\" qualifier=\"par\""
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
   for _, _ in pairs(xconn.conditions) do
      nConds = nConds+1
   end
   if nConds > 1 then
      NCL = NCL..indent.."   <compoundCondition operator=\"and\" >"
      NCL = NCL..genConditions(xconn.conditions, indent.."      ")
      NCL = NCL..indent.."   </compoundCondition>"
   else
      NCL = NCL..genConditions(xconn.conditions, indent.."   ")
   end
   local nActs = 0
   for _, _ in pairs(xconn.actions) do
      nActs = nActs+1
   end
   if nActs > 1 then
      NCL = NCL..indent.."   <compoundAction operator=\"par\" >"
      NCL = NCL..genActions(xconn.actions, indent.."      ")
      NCL = NCL..indent.."   </compoundAction>"
   else
      NCL = NCL..genActions(xconn.actions, indent.."   ")
   end
   NCL = NCL..indent.."</causalConnector>"
   return NCL
end

function genHeadNCL(indent)
   local NCL = ""
   local connBase = ""
   for _, val in pairs(gblHeadTbl) do
      if val._type == "xconnector"then
         connBase = connBase..genXConnector(val,indent.."   ")
      end
   end
   NCL = NCL..indent.."<connectorBase>"
   NCL = NCL..connBase
   NCL = NCL..indent.."</connectorBase>"
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
