local utils= {}
local colors = require("ansicolors")

function utils.readFile(file)
   file = io.open(file, 'r')
   if not file then
      utils.printErro("Can't open file")
      return nil
   end
   local fileContent = file:read('*a')
   if not fileContent then
      utils.printErro("Can't read file")
      return nil
   end
   return fileContent
end

function utils.writeFile(file, content)
   file = io.open(file, "w")
   if not file then
      utils.printErro("Could not create output file")
      return nil
   end
   io.output(file)
   io.write(content)
   io.close(file)
end

function utils.printErro(errString, line)
   line = line or ""
   local file = gblInputFile or ""
   io.write(colors("%{bright}"..file..":"..line..": %{red}erro:%{reset} "..errString.."\n"))
   gblHasError = true
end

function utils.splitSpace(str)
   local words = {}
   for w in str:gmatch("%S+") do
      table.insert(words, w)
   end
   return words
end

function utils.splitSymbol(str, symbol)
   local sign = str:find(symbol)
   if sign then
      return str:sub(1, sign-1), str:sub(sign+1)
   end
   return str
end

function utils.isMacroSon(element) 
   if element then
      while element do
         if element._type == "macro" then
            return true
         end
         element = element.father
      end
   end
   return false
end

function utils.getMacroFather(element)
   if element then
      while element do
         if element._type == "macro" then
            return element
         end
         element = element.father
      end
   end
   return false
end

function utils.newElement (idStr, element)
   element:setId(parseId(idStr))

   if gblCurrentElement then
      element.father = gblCurrentElement
      gblCurrentElement:addSon(element)
      gblCurrentElement = element
   else
      gblCurrentElement = element
   end
end

function utils.checkDependenciesElements()
   for _, val in pairs(gblSymbolTable.macros) do
      if not val.hasEnd then
         utils.printErro("Macro "..val.id.." sem end.")
         return
      end
   end

   for pos, val in pairs(gblSymbolTable.body) do
      if not val.father then
         val:check()
      end
   end

   for pos, val in pairs(gblSymbolTable.connectors) do
      val:check()
   end
end

function utils.genNCL()
   local indent = "\n   "
   local NCL = [[<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">]]

   local body = indent.."<body>"
   for _, val in pairs(gblSymbolTable.body) do
      if not val.father then
         body = body..val:toNCL(indent.."   ")
      end
   end
   body = body..indent.."</body>\n</ncl>"

   local head = indent.."<head>"

   local ruleBase = nil
   for _, val in pairs(gblSymbolTable.rules) do
      if not ruleBase then
         ruleBase = indent.."   <ruleBase>"
      end
      ruleBase = ruleBase..val:toNCL(indent.."      ")
   end
   if ruleBase then
      ruleBase = ruleBase..indent.."   </ruleBase>"
      head = head..ruleBase
   end

   local regionBase = nil
   for _, val in pairs(gblSymbolTable.regions) do
      if not regionBase then
         regionBase = indent.."   <regionBase>"
      end
      if val.father == nil then
         regionBase = regionBase..val:toNCL(indent.."      ")
      end
   end
   if regionBase then
      regionBase = regionBase..indent.."   </regionBase>"
      head = head..regionBase
   end

   local descriptorBase = nil
   for _, val in pairs(gblSymbolTable.descriptors) do
      if not descriptorBase then
         descriptorBase = indent.."   <descriptorBase>"
      end
      descriptorBase = descriptorBase..val:toNCL(indent.."      ")
   end
   if descriptorBase then
      descriptorBase = descriptorBase..indent.."   </descriptorBase>"
      head = head..descriptorBase
   end

   local connectorBase = nil
   for _, val in pairs(gblSymbolTable.connectors) do
      if not connectorBase then
         connectorBase = indent.."   <connectorBase>"
      end
      connectorBase = connectorBase..val:toNCL(indent.."      ")
   end
   if connectorBase then
      connectorBase = connectorBase..indent.."   </connectorBase>"
      head = head..connectorBase
   end

   head = head..indent.."</head>"

   NCL = NCL..head..body
   return NCL
end

return utils


