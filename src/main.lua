local lpeg = require"lpeg"

require"grammar"
require"pegdebug"
require"gen"

local inspect = require"inspect"

-- TODO: Macro cant have recursion

gblPresTbl = {}
gblLinkTbl = {}
gblMacroTbl = {}
gblMacroCallTbl = {}

_DEBUG_PEG = false
_DEBUG_PARSE_TABLE = false
_DEBUG_SYMBOL_TABLE = false

function beginParse()
   local file = io.open(arg[1])
   local sncl = file:read("*all")
   file:close(file)
   if _DEBUG_PEG then
      lpeg.match(require("pegdebug").trace(grammar), sncl)
   else
      lpeg.match(grammar, sncl)
   end

   resolveMacroCalls(gblMacroCallTbl)

   if _DEBUG_SYMBOL_TABLE then
      print("Symbol Table:", inspect.inspect(gblPresTbl))
      print("macro table:", inspect.inspect(gblMacroTbl))
      print("macro call table:", inspect.inspect(gblMacroCallTbl))
   end
   local NCL = genNCL(gblPresTbl,"")
   print(NCL)
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
