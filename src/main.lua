--Variaveis globais
local lpeg = require("lpeg")

-- Globals
linhaParser = 1
arquivoEntrada = nil
insideMacro = false
hasError = false
currentElement = nil

tabelaSimbolos = {
   macros = {},
   rules = {},
   regions = {},
   descriptors = {},
   connectors = {},
   body = {},
}

local utils = require("utils")

require("parser.grammar")
require("parser.parse")
require("elements.require")

function beginParse(entrada, saida, play)
   arquivoEntrada = entrada
   if not entrada:find(".sncl") then
      utils.printErro("Invalid file extension")
      return
   end

   local conteudoEntrada = utils.lerArquivo(entrada)
   if not conteudoEntrada then
      utils.printErro("Error reading input file")
      return
   end

   lpeg.match(gramaticaSncl, conteudoEntrada)

   -- Checar se o parser chegou no final do arquivo
   local nLinhas = 0
   for _ in io.lines(entrada) do
      nLinhas = nLinhas+1
   end
   if linhaParser < nLinhas then
      utils.printErro("Parsing error", linhaParser)
      return
   end

   utils.checkDependenciesElements()
   if hasError then
      utils.printErro("Error creating output file")
      return
   end
   local output = utils.genNCL()

   if hasError then
      utils.printErro("Error creating output file")
      return
   end
   if saida then
      utils.escreverArquivo(saida, output)
   else
      saida = entrada:sub(1, entrada:len()-4)
      saida = saida.."ncl"
      utils.escreverArquivo(saida, output)
   end
   if play then
      os.execute("ginga "..saida)
   end
end

--[[
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
]]
