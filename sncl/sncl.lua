lpeg = require("lpeg")
argparse = require("argparse")
ansicolors = require("ansicolors")

--[[
package.path = package.path..";./model/init.lua;./grammar/init.lua"
require("model")
require("grammar")
]]--
utils = require("sncl.utils.utils")
require("sncl.grammar.grammar_parser")
require("sncl.grammar.util_parse")

require("sncl.model.descriptor")
require("sncl.model.connector")
require("sncl.model.context")
require("sncl.model.region")
require("sncl.model.media")
require("sncl.model.link")
require("sncl.model.area")
require("sncl.model.action")

--Variaveis globais
linha = 1

tabelaSimbolos = {}
tabelaSimbolos.regions = {}
tabelaSimbolos.descriptors = {}
tabelaSimbolos.connectors = {}
tabelaSimbolos.body = {}

function beginParse(entrada, saida) 
	if utils.isValidSncl(entrada) == true then
		local conteudoArquivoEntrada = utils.conteudoArquivo(entrada)
		utils.parse(snclGrammar, conteudoArquivoEntrada)
		local output = utils.printNCL()
		if hasError == false then
			print(hasError)
			arquivoSaida = nil
			arquivoSaida = entrada:sub(1, entrada:len()-4)
			arquivoSaida = arquivoSaida.."ncl"
			arquivoSaida = io.open(arquivoSaida, "w")
			if arquivoSaida ~= nil then
				io.output(arquivoSaida)
				io.write(output)
				io.close(arquivoSaida)
			else
				utils.printErro("ERRO NO ARQUIVO DE SAIDA")
			end
		else
			utils.printErro("ARQUIVO TEM ERRO")
		end
	else
		utils.printErro("Arquivo nao é um sncl valido")
	end
end

mediaProperties = {
	'style', 'player', 'reusePlayer', 'playerLife', 'deviceClass', 'explicitDur',
	'focusIndex', 'moveLeft', 'moveRight', 'moveUp', 'moveDown', 'top', 'bottom',
	'left', 'right', 'width', 'height', 'location', 'size', 'bounds', 'background',
	'rgbChromakey', 'visible', 'transparency', 'fit', 'scroll', 'zIndex', 'plan',
	'focusBorderColor', 'selBorderColor', 'focusBorderWidth', 'focusBorderTransparency',
	'focusSrc', 'focusSelSrc', 'freeze', 'contentId', 'standby', 'soundLevel',
	'balanceLevel', 'trebleLevel', 'bassLevel', 'transIn', 'transOut', 'fontColor',
	'fontFamily', 'textAlign', 'fontStyle', 'fontSize', 'fontVariant', 'fontWeight',
	'system.language', 'system.caption', 'system.subtitle', 'system.returnBitRate',
	'system.screenSize', 'system.screenGraphicSize', 'system.audioType', 'system.devNumber',
	'system.classType', 'system.parentDeviceRegion', 'system.info', 'system.classNumber',
	'system.CPU', 'system.memory', 'system.operationgSystem', 'system.luaVesion',
	'system.ncl.version', 'system.gingaNCL.version', 'system.xyz', 'service.currentFocus',
	'service.currentKeyMaster', 'service.xyz', 'service.interactivity', 'region'
}

mediaTypes = {
	'text/html', 'text/css', 'text/xml', 'text/plain', 'image/bmp', 'image/png', 'image/gif',
	'image/jpeg', 'audio/basic', 'audio/x-wav', 'audio/mpeg', 'audio/mpeg4', 'video/mpeg',
	'video/mp4', 'video/x-mng', 'video-quicktime', 'video/x-msvideo', 'application/x-ginga-NCL',
	'application/x-ncl-NCL', 'application/x-ginga-NCLUA', 'application/x-ncl-NCLUA', 'application/x-ginga-NCLet',
	'application/x-ginga-settings', 'application/x-ncl-settings', 'application/x-ginga-time', 'application/x-ncl-time'
}

mediaRestrictedProperties = {
	"src", "descriptor", "type", "rg",
}

areaProperties = {
	"begin","end","first","last","text","positon",
	"coords","label","clip"
}

