Port = {}
Port_mt = {}

Port.__index = Port

function Port.new (id, media, interface, father, linha)
	local portObject = {
		id = id,
		father = father,
		media = media,
		interface = interface,
		linha = linha,
	}
	setmetatable(portObject, Port)
	return portObject
end

function Port:getFather()
	return self.father
end

function Port:toNCL(indent)
	if tabelaSimbolos[self.media] == nil then
		utils.printErro("No element "..self.media)
	end

	local port = indent.."<port id=\""..self.id.."\" component=\""..self.media.."\" />"

	return port
end
