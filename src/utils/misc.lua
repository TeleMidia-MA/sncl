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
   utils.printErro("Arquivo não pode ser aberto.", "")
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

function utilsTable.printNCL()
   local indent = "\n   "
   local NCL = [[<?xml version="1.0" encoding="ISO-8859-1"?>
   <ncl id="main" xmlns="http://www.ncl.org.br/NCL3.0/EDTVProfile">]]

   for _, val in pairs(tabelaSimbolos.macros) do
      if val:getEnd() == false then
         utils.printErro("Macro "..val:getId().." sem end.")
         return
      end
   end

   local body = indent.."<body>"
   for _, val in pairs(tabelaSimbolos.body) do
      if val.pai == nil then
         body = body..val:toNCL(indent.."   ")
      end
   end
   body = body..indent.."</body>\n</ncl>"

   local head = indent.."<head>"

   local regionBase = indent.."   <regionBase>"
   local i = 0
   for _, val in pairs(tabelaSimbolos.regions) do
      i = i+1
      if val.pai == nil then
         regionBase = regionBase..val:toNCL(indent.."      ")
      end
   end
   regionBase = regionBase..indent.."   </regionBase>"
   if i ~= 0 then
      head = head..regionBase
   end

   local descriptorBase = indent.."   <descriptorBase>"
   i = 0
   for _, val in pairs(tabelaSimbolos.descriptors) do
      i = i+1
      descriptorBase = descriptorBase..val:toNCL(indent.."      ")
   end
   descriptorBase = descriptorBase..indent.."   </descriptorBase>"
   if i ~= 0 then
      head = head..descriptorBase
   end

   local connectorBase = indent.."   <connectorBase>"
   i = 0
   for _, val in pairs(tabelaSimbolos.connectors) do
      i = i+1
      connectorBase = connectorBase..val:toNCL(indent.."      ")
   end
   connectorBase = connectorBase..indent.."   </connectorBase>"
   if i ~= 0 then
      head = head..connectorBase
   end

   head = head..indent.."</head>"

   NCL = NCL..head..body
   return NCL
end

return utilsTable


