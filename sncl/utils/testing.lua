local testTable = {}

local indent = "\n   "

function processBases(base)
   local i = 0
   local str = ""
   for pos in testTable.pairsById(base) do
      i = i+1
      str = str..pos
   end
   if i>0 then
      return str
   else
      return false
   end
end

function testTable.sortTable()
   local NCL = 
   [[<?xml version="1.0" encoding="ISO-8859-1"?>
<ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">]]

   local body = indent.."<body>"
   for pos in testTable.pairsById(tabelaSimbolos.body) do
      body = body..pos
   end
   for pos, val in pairs(tabelaSimbolos.body) do
      if val.tipo == "link" then
         body = body..val:toNCL(indent.."   ")
      end
   end
   body = body..indent.."</body>"

   local head = indent.."<head>"
   --regions
   local regionBase = processBases(tabelaSimbolos.regions)
   if regionBase then
      head = head..indent.."   <regionBase>"..regionBase..indent.."   </regionBase>"
   end
   --descriptors
   local descriptorBase = processBases(tabelaSimbolos.descriptors)
   if descriptorBase then
      head = head..indent.."   <descriptorBase>"..descriptorBase..indent.."   </descriptorBase>"
   end
   --connectors
   local connectorBase = processBases(tabelaSimbolos.connectors)
   if connectorBase then
      head = head..indent.."   <connectorBase>"..connectorBase..indent.."   </connectorBase>"
   end
   head = head..indent.."</head>"

   return NCL..head..body.."\n</ncl>"
end

function testTable.pairsByProperty(t)
   local a = {}
   for pos, val in pairs(t) do 
      table.insert(a, pos) 
   end
   table.sort(a)
   local i = 0
   local iter = function()
      i = i+1
      if a[i] == nil then 
         return nil
      else
         return a[i], t[a[i]]
      end
   end
   return iter
end

function testTable.pairsById(t)
   local a = {}
   for pos, val in pairs(t) do 
      if val.tipo == "link" then
         table.insert(a, a.xconnector)
      else
         table.insert(a, val.id) 
      end
   end
   table.sort(a)
   local i = 0
   local iter = function()
      i = i+1
      if a[i] == nil or t[a[i]] == nil then 
         return nil
      end
      if t[a[i]].pai ~= nil then --Se tiver pai
         return ""
      else
         return t[a[i]]:toNCL(indent.."   ")
      end
   end
   return iter
end

return testTable
