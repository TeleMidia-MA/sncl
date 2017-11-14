local utilsTable = {}
local colors = require("ansicolors")

function utilsTable.lerArquivo(fileLocation)
   local file = io.open(fileLocation, 'r')
   if file then
      local fileContent = file:read('*a')
      if fileContent then
         return fileContent
      end
   end
   utils.printErro("Arquivo não pode ser aberto.")
   return nil
end

function utilsTable.escreverArquivo(arquivo, conteudo)
   arquivo = io.open(arquivo, "w")
   if arquivo then
      io.output(arquivo)
      io.write(conteudo)
      io.close(arquivo)
   else
      utils.printErro("Erro ao criar arquivo de saída.")
      return nil
   end
end

function utilsTable.printErro(string, linha)
   linha = linha or ""
   local arquivo = arquivoEntrada or ""
   io.write(colors("%{bright}"..arquivo..":"..linha..": %{red}erro:%{reset} "..string.."\n"))
   hasError = true
end

function utilsTable.separarEspaco(string)
   if string then
      local words = {}
      for w in string:gmatch("%S+") do
         table.insert(words, w)
      end
      return words
   end
   return nil
end

function utilsTable.separateSymbol(str)
   local sign = str:find(":")
   if sign then
      return str:sub(1, sign-1), str:sub(sign+1)
   else
      return str
   end
end

function utilsTable.separarPonto(str)
   local dot = str:find("%.")
   if dot then
      return str:sub(1,dot-1), str:sub(dot+1)
   else
      return str
   end
end

function utilsTable.isMacroSon(element) 
   if element then
      while element  do
         if element.tipo == "macro" then
            return element
         end
         element = element.pai
      end
   end
   return false
end

function utilsTable.newElement (str, element)
   local port, id = parseId(str)
   element:setId(id)
   if element.tipo == "media" then
      element.temPort = true
   end

   if currentElement then
      if element.tipo == "context" then
         if currentElement.tipo ~= "context" and
            currentElement.tipo ~= "macro" and
            currentElement.tipo ~= "switch" then
            utils.printErro("Context can not be declared inside of"..currentElement.tipo..".", linhaParser)
            return
         end
      end
      element.pai = currentElement
      currentElement:addFilho(element)
      currentElement = element
   else
      currentElement = element
   end
end

function utilsTable.checkDependenciesElements()
   for _, val in pairs(tabelaSimbolos.macros) do
      if not val:getEnd() then
         utils.printErro("Macro "..val:getId().." sem end.")
         return
      end
   end

   for pos, val in pairs(tabelaSimbolos.body) do
      if not val.pai then
         val:check()
      end
   end
end

function utilsTable.genNCL()
   local indent = "\n   "
   local NCL = [[<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">]]

   local body = indent.."<body>"
   for _, val in pairs(tabelaSimbolos.body) do
      if not val.pai then
         body = body..val:toNCL(indent.."   ")
      end
   end
   body = body..indent.."</body>\n</ncl>"

   local head = indent.."<head>"

   local ruleBase = nil
   for _, val in pairs(tabelaSimbolos.rules) do
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
   for _, val in pairs(tabelaSimbolos.regions) do
      if not regionBase then
         regionBase = indent.."   <regionBase>"
      end
      if val.pai == nil then
         regionBase = regionBase..val:toNCL(indent.."      ")
      end
   end
   if regionBase then
      regionBase = regionBase..indent.."   </regionBase>"
      head = head..regionBase
   end

   local descriptorBase = nil
   for _, val in pairs(tabelaSimbolos.descriptors) do
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
   for _, val in pairs(tabelaSimbolos.connectors) do
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

return utilsTable


