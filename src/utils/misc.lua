local utils= {}
local colors = require("ansicolors")

function utils.readFile(fileLocation)
   local file = io.open(fileLocation, 'r')
   if file then
      local fileContent = file:read('*a')
      if fileContent then
         return fileContent
      end
   end
   utils.printErro("File could not be opened")
   return nil
end

function utils.writeFile(file, content)
   file = io.open(file, "w")
   if file then
      io.output(file)
      io.write(content)
      io.close(file)
   else
      utils.printErro("Could not create output file")
      return nil
   end
end

function utils.printErro(string, line)
   line = line or ""
   local file = fileEntrada or ""
   io.write(colors("%{bright}"..file..":"..line..": %{red}erro:%{reset} "..string.."\n"))
   hasError = true
end

function utils.splitSpace(string)
   if string then
      local words = {}
      for w in string:gmatch("%S+") do
         table.insert(words, w)
      end
      return words
   end
   return nil
end

function utils.splitSymbol(str, symbol)
   local sign = str:find(symbol)
   if sign then
      return str:sub(1, sign-1), str:sub(sign+1)
   else
      return str
   end
end

function utils.isMacroSon(element) 
   if element then
      while element  do
         if element._type == "macro" then
            return element
         end
         element = element.father
      end
   end
   return nil
end

function utils.newElement (str, element)
   local id = parseId(str)

   element:setId(id)
   element.hasPort = port

   if currentElement then
      --[[
      if element.tipo == "context" then
         if currentElement.tipo ~= "context" and
            currentElement.tipo ~= "macro" and
            currentElement.tipo ~= "switch" then
            utils.printErro("Context can not be declared inside of"..currentElement.tipo..".", linhaParser)
            return
         end
      end
      ]]
      element.father = currentElement
      currentElement:addSon(element)
      currentElement = element
   else
      currentElement = element
   end
end

function utils.checkDependenciesElements()
   for _, val in pairs(symbolTable.macros) do
      if not val.hasEnd then
         utils.printErro("Macro "..val.id.." sem end.")
         return
      end
   end

   for pos, val in pairs(symbolTable.body) do
      if not val.father then
         val:check()
      end
   end

   for pos, val in pairs(symbolTable.connectors) do
      val:check()
   end
end

function utils.genNCL()
   local indent = "\n   "
   local NCL = [[<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">]]

   local body = indent.."<body>"
   for _, val in pairs(symbolTable.body) do
      if not val.father then
         body = body..val:toNCL(indent.."   ")
      end
   end
   body = body..indent.."</body>\n</ncl>"

   local head = indent.."<head>"

   local ruleBase = nil
   for _, val in pairs(symbolTable.rules) do
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
   for _, val in pairs(symbolTable.regions) do
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
   for _, val in pairs(symbolTable.descriptors) do
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
   for _, val in pairs(symbolTable.connectors) do
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


