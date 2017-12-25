--Variaveis globais
local lpeg = require("lpeg")

-- Globals
parserLine = 1
insideMacro = false
hasError = false
currentElement = nil

symbolTable = {
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

function beginParse(input, outputFile, play)
   if not input:find(".sncl") then
      utils.printErro("Invalid file extension")
      return
   end

   local inputContent = utils.readFile(input)
   if not inputContent then
      utils.printErro("Error reading input file")
      return
   end

   lpeg.match(gramaticaSncl, inputContent)

   -- Checar se o parser chegou no final do arquivo
   local lineNum = 0
   for _ in io.lines(input) do
      lineNum = lineNum+1
   end
   if parserLine < lineNum then
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
   if outputFile then
      utils.writeFile(outputFile, output)
   else
      outputFile = input:sub(1, input:len()-4)
      outputFile = outputFile.."ncl"
      utils.writeFile(outputFile, output)
   end
   if play then
      os.execute("ginga "..outputFile)
   end
end
