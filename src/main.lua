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
