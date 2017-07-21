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
	print("Can't open file.")
end

function utilsTable.parse(gramatica, input)
	lpeg.match(gramatica, input)
end

function utilsTable.printErro(string, linha)
	if linha then
		print("ERRO: "..string.." Linha: "..linha)
	else
		print("ERRO: "..string)
	end
	hasError = true
end

function utilsTable.printAviso(string, linha)
	if string ~= nil then
		print("AVISO: linha "..linha..": "..string)
	end
end

function utilsTable.printNCL()
	local indent = "\n   "
	local NCL = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"
	NCL = NCL.."\n<ncl id=\"main\" xmlns=\"http://www.ncl.org.br/NCL3.0/EDTVProfile\">"
	
	local body = indent.."<body>"
	for pos, val in pairs(tabelaSimbolos.body) do
		if val:getFather() == nil then
			body = body..val:toNCL(indent.."   ")
		end
	end
	body = body..indent.."</body>\n</ncl>"

	local head = indent.."<head>"

	local regionBase = indent.."   <regionBase>"
	local i = 0
	for pos, val in pairs(tabelaSimbolos.regions) do
		i = i+1
		if val:getFather() == nil then
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


