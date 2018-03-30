local lpeg = require"lpeg"
local utils = require"utils"
local inspect = require"inspect"
local lyaml = require"lyaml"
local ins = require"inspect"
require"grammar"
require"pegdebug"
require"gen"
require"process"

local R, P = lpeg.R, lpeg.P

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

function beginParse(input, output, template, play)
   local parsed = nil
   gblInputFile = input
   local snclInput = utils.readFile(input)
   if not snclInput then
      utils.printErro("Error reading input file")
      return
   end

   if _DEBUG_PEG then
      lpeg.match(require("pegdebug").trace(grammar), snclInput)
   else
      parsed = lpeg.match(grammar, snclInput)
   end
   if not parsed then
      utils.printErro("Error parsing document")
      return -1
   end

   if template then
      -- TODO: Check yaml extension
      -- TODO: Check errors in yaml file
      local templateContent = utils.readFile(template)
      gblTemplateTbl = lyaml.load(templateContent, { all = true })
      print(ins.inspect(gblTemplateTbl))
      resolveTemplate()
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


   if gblHasError or not parsed then
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

Buttons = R"09"+R"AZ"+P"*"+P"#"+P"MENU"+P"INFO"+P"GUIDE"+P"CURSOR_DOWN"
   +P"CURSOR_LEFT"+P"CURSOR_RIGHT"+P"CURSOR_UP"+P"CHANNEL_DOWN"+P"CHANNEL_UP"
   +P"VOLUME_DOWN"+P"VOLUME_UP"+P"ENTER"+P"RED"+P"GREEN"+P"YELLOW"+P"BLUE"
   +P"BLACK"+P"EXIT"+P"POWER"+P"REWIND"+P"STOP"+P"EJECT"+P"PLAY"+P"RECORD"+P"PAUSE"

