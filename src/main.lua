local lpeg = require("lpeg")
local utils = require("utils")
require("parser.grammar")
require("parser.parse")
require("elements.require")

-- Global Variables
gblParserLine = 1
gblInsideMacro = false
gblHasError = false
gblCurrentElement = nil
gblInputFile= nil
gblSymbolTable = {
   macros = {},
   rules = {},
   regions = {},
   descriptors = {},
   connectors = {},
   body = {},
}

function beginParse(input, outputFile, play)
   if not input:find(".sncl") then
      utils.printErro("Invalid file extension")
      return
   end

   gblInputFile = input
   local inputContent = utils.readFile(input)
   if not inputContent then
      utils.printErro("Error reading input file")
      return
   end

   lpeg.match(gramaticaSncl, inputContent)

   -- Check if parser reached the end of the file
   local lineNum = 0
   for _ in io.lines(input) do
      lineNum = lineNum+1
   end
   if gblParserLine < lineNum then
      utils.printErro("Parsing error", gblParserLine)
      return
   end

   utils.checkDependenciesElements()
   if gblHasError then
      utils.printErro("Error creating output file")
      return
   end
   local output = utils.genNCL()

   if gblHasError then
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
