--Variaveis globais
linhaParser = 1
arquivoEntrada = nil
testing = true

tabelaSimbolos = {
   regions = {},
   descriptors = {},
   connectors = {},
   body = {},
   macros = {},
}

lpeg = require("lpeg")
argparse = require("argparse")
colors = require("ansicolors")

require("sncl.model.require")

utils = require("sncl.utils")
test = require("sncl.testing")

require("sncl.grammar.parser")
require("sncl.grammar.utils")

function beginParse(entrada, saida) 
   arquivoEntrada = entrada
   local arquivoSaida
   if not utils.isValidSncl(entrada) then
      utils.printErro("Extensão do arquivo inválida.") 
      return
   end

      local conteudoArquivoEntrada = utils.conteudoArquivo(entrada)
      local nLinhas = 0
      for _ in io.lines(entrada) do
         nLinhas = nLinhas+1
      end
      utils.parse(snclGrammar, conteudoArquivoEntrada)
      if linhaParser < nLinhas then
         utils.printErro("Erro de análise.", linhaParser)
         return
      end

   arquivoSaida = entrada:sub(1, entrada:len()-4)
   local output = ""
   if testing == false then
      output = utils.printNCL()
      arquivoSaida = arquivoSaida.."ncl"
      arquivoSaida = io.open(arquivoSaida, "w")
      if hasError then
         utils.printErro("Erro ao criar arquivo de saída.")
         return
      end

      if arquivoSaida ~= nil then
         io.output(arquivoSaida)
         io.write(output)
         io.close(arquivoSaida)
      end
   else
      output = test.sortTable()
      if hasError then
         utils.printErro("Erro ao criar arquivo de saída.")
         return
      end
      print(output)
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
