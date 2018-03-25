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

-- function beginParse(input, outputFile, play)
--    if not input:find(".sncl") then
--       utils.printErro("Invalid file extension")
--       return
--    end
--
--    gblInputFile = input
--    local inputContent = utils.readFile(input)
--    if not inputContent then
--       utils.printErro("Error reading input file")
--       return
--    end
--
--    lpeg.match(gramaticaSncl, inputContent)
--
--    -- Check if parser reached the end of the file
--    local lineNum = 0
--    for _ in io.lines(input) do
--       lineNum = lineNum+1
--    end
--    if gblParserLine < lineNum then
--       utils.printErro("Parsing error", gblParserLine)
--       return
--    end
--
--    utils.checkDependenciesElements()
--    if gblHasError then
--       utils.printErro("Error creating output file")
--       return
--    end
--    local output = utils.genNCL()
--
--    if gblHasError then
--       utils.printErro("Error creating output file")
--       return
--    end
--    if outputFile then
--       utils.writeFile(outputFile, output)
--    else
--       outputFile = input:sub(1, input:len()-4)
--       outputFile = outputFile.."ncl"
--       utils.writeFile(outputFile, output)
--    end
--    if play then
--       os.execute("ginga "..outputFile)
--    end
-- end
