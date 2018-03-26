local lpeg = require"lpeg"
local utils = require"utils"
local inspect = require"inspect"
require"grammar"
require"pegdebug"
require"gen"
require"process"


-- TODO: Macro cant have recursion
-- TODO: Check if the sons are valid elements

gblParserLine = 1

gblPresTbl = {}
gblLinkTbl = {}
gblMacroTbl = {}
gblMacroCallTbl = {}
gblHeadTbl = {}

_DEBUG_PEG = false
_DEBUG_PARSE_TABLE = false
_DEBUG_SYMBOL_TABLE = false

function beginParse(input, output, play)
   gblInputFile = input
   local snclInput = utils.readFile(input)
   if not snclInput then
      utils.printErro("Error reading input file")
      return
   end

   if _DEBUG_PEG then
      lpeg.match(require("pegdebug").trace(grammar), snclInput)
   else
      lpeg.match(grammar, snclInput)
   end

   resolveMacroCalls(gblMacroCallTbl)
   resolveXConnectors(gblLinkTbl)
   local NCL = genNCL()

   if _DEBUG_SYMBOL_TABLE then
      print("Head Table:", inspect.inspect(gblHeadTbl))
      print("Symbol Table:", inspect.inspect(gblPresTbl))
      print("Link Table:", inspect.inspect(gblLinkTbl))
      print("Macro Table:", inspect.inspect(gblMacroTbl))
      print("Macro Call Table:", inspect.inspect(gblMacroCallTbl))
   end

   -- TODO: Dont output if the parser didnt reach end of the file
   if gblHasError then
      utils.printErro("Error creating output file")
      return
   end
   if outputFile then
      utils.writeFile(outputFile, NCL)
   else
      outputFile = input:sub(1, input:len()-4)
      outputFile = outputFile.."ncl"
      utils.writeFile(outputFile, NCL)
   end
   if play then
      os.execute("ginga "..outputFile)
   end

end

