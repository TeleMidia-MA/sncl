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

-- TODO: Essas tabelas n devem ser globais
gblParserLine = 1
gblPresTbl = {}
gblLinkTbl = {}
gblMacroTbl = {}
gblMacroCallTbl = {}
gblHeadTbl = {}
gblTemplateTbl = {}

_DEBUG_PEG = false
_DEBUG_PARSE_TABLE = false
_DEBUG_SYMBOL_TABLE = true

function beginParse(input, output, padding, play)
   local parsed = nil
   local paddingTbl = nil

   gblInputFile = input
   local snclInput = utils.readFile(input)
   if not snclInput then
      utils.printErro("Error reading input file")
      return
   end

   if padding then
      -- TODO: Checar extensao do yaml
      -- TODO: Checar erros no yaml?
      local paddingContent = utils.readFile(padding)
      paddingTbl = lyaml.load(paddingContent, { all = true })
   end

   if _DEBUG_PEG then
      parsed = lpeg.match(require("pegdebug").trace(grammar), snclInput)
   else
      parsed = lpeg.match(grammar, snclInput)
   end
   if not parsed then
      utils.printErro("Error parsing document")
      return -1
   end

   resolveMacroCalls(gblMacroCallTbl)
   resolveXConnectors(gblLinkTbl)
   if padding then
      resolveTemplates(paddingTbl[1], gblTemplateTbl)
   end

   local NCL = genNCL()

   if _DEBUG_SYMBOL_TABLE then
      -- print("Head Table:", inspect.inspect(gblHeadTbl))
      -- print("Symbol Table:", inspect.inspect(gblPresTbl))
      -- print("Link Table:", inspect.inspect(gblLinkTbl))
      -- print("Macro Table:", inspect.inspect(gblMacroTbl))
      -- print("Macro Call Table:", inspect.inspect(gblMacroCallTbl))
      --print("Template Table:", inspect.inspect(gblTemplateTbl))
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

-- TODO: Onde botar? N devem ser globais
Buttons = R"09"+R"AZ"+P"*"+P"#"+P"MENU"+P"INFO"+P"GUIDE"+P"CURSOR_DOWN"
   +P"CURSOR_LEFT"+P"CURSOR_RIGHT"+P"CURSOR_UP"+P"CHANNEL_DOWN"+P"CHANNEL_UP"
   +P"VOLUME_DOWN"+P"VOLUME_UP"+P"ENTER"+P"RED"+P"GREEN"+P"YELLOW"+P"BLUE"
   +P"BLACK"+P"EXIT"+P"POWER"+P"REWIND"+P"STOP"+P"EJECT"+P"PLAY"+P"RECORD"+P"PAUSE"
Types = P"context"+P"media"+P"area"+P"region"+P"macro"

