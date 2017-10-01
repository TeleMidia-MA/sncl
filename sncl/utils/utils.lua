local utilsTable = {}

hasError = false

function utilsTable.isValidSncl(fileName)
   local found = fileName:find(".sncl")
   if found then
      return true
   else
      return false
   end
end

function utilsTable.conteudoArquivo(fileLocation)
   local file = io.open(fileLocation, 'r')

   if file then
      local fileContent = file:read('*a')
      if fileContent then
         return fileContent
      end
   end
   utils.printErro("Arquivo não pode ser aberto.", "")
end

function utilsTable.parse(gramatica, input)
   lpeg.match(gramatica, input)
end

function utilsTable.printErro(string, linha)
   linha = linha or ""
   io.write(colors("%{bright}"..arquivo..":"..linha..": %{red}erro:%{reset} "..string))
   hasError = true
end

function utilsTable.printNCL()
   local indent = "\n   "
   local NCL = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
   NCL = NCL.."\n<ncl id=\"main\" xmlns=\"http://www.ncl.org.br/NCL3.0/EDTVProfile\">"

   for pos, val in pairs(tabelaSimbolos.macros) do
      if val:getEnd() == false then
         utils.printErro("Macro "..val:getId().." sem end.")
         return
      end
   end

   local body = indent.."<body>"
   for pos, val in pairs(tabelaSimbolos.body) do
      if val.pai == nil then
         body = body..val:toNCL(indent.."   ")
      end
   end
   body = body..indent.."</body>\n</ncl>"

   local head = indent.."<head>"

   local regionBase = indent.."   <regionBase>"
   local i = 0
   for pos, val in pairs(tabelaSimbolos.regions) do
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
   local i = 0
   for pos, val in pairs(tabelaSimbolos.descriptors) do
      i = i+1
      descriptorBase = descriptorBase..val:toNCL(indent.."      ")
   end
   descriptorBase = descriptorBase..indent.."   </descriptorBase>"
   if i ~= 0 then
      head = head..descriptorBase
   end

   local connectorBase = indent.."   <connectorBase>"
   local i = 0
   for pos, val in pairs(tabelaSimbolos.connectors) do
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

function utilsTable.containsKey(table, key)
   for pos, __ in pairs(table) do
      if pos == key then
         return true
      end
   end
   return false
end

function utilsTable.containsValue(table, value)
   for __,val in pairs(table) do
      if val == value then
         return true
      end
   end
   return false
end

return utilsTable


