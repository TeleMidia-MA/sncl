local lpeg = require"lpeg"
local utils = require"utils"
local inspect = require"inspect"
local lyaml = require"lyaml"
local ins = require"inspect"
require"grammar"
require"pegdebug"
require"gen"
require"process"
require"macro"

local R, P = lpeg.R, lpeg.P

-- TODO: Macro cant have recursion
-- TODO: Check if the sons are valid elements

-- TODO: Essas tabelas devem ser globais?
-- Acho que sim, por que se n o stack das funções recursivas
-- ficam mt grande
gblParserLine = 1
gblPresTbl = {}
gblLinkTbl = {}
gblMacroTbl = {}
gblMacroCallTbl = {}
gblHeadTbl = {}
gblTemplateTbl = {}
gblPaddingTbl = {}

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
      gblPaddingTbl = lyaml.load(paddingContent, { all = true })
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

   for _, val in pairs(gblMacroCallTbl) do
      if not val.father then
         resolveCall(val)
      end
   end
   resolveXConnectors(gblLinkTbl)

   if padding then
      local nF = 0
      while #gblTemplateTbl > 0 do
         for pos, loop in ipairs(gblTemplateTbl) do
            print("loop:", pos, "l:",loop.line)
            print("parents:", utils.getNumberOfParents(loop, 0), "nf:", nF)
            print("isMacroSon:", utils.isMacroSon(loop))
            if utils.getNumberOfParents(loop, 0) == nF and not utils.isMacroSon(loop) then
               -- TODO: 
               local elements = utils.getElementsWithClass(gblPaddingTbl[1], loop.class)
               io.write('\tElements: ')
               for _, ele in ipairs(elements) do
                  io.write(ele.id)
               end
               io.write('\n')
               resolveTemplate(elements, loop, pos)
               table.remove(gblTemplateTbl, pos)
            end
         end
         nF = nF+1
      end
   end

   if _DEBUG_SYMBOL_TABLE then
      -- print("Symbol Table:", inspect.inspect(gblPresTbl))
      -- print("Head Table:", inspect.inspect(gblHeadTbl))
      -- print("Link Table:", inspect.inspect(gblLinkTbl))
      -- print("Macro Table:", inspect.inspect(gblMacroTbl))
      -- print("Macro Call Table:", inspect.inspect(gblMacroCallTbl))
   end

   local NCL = genNCL()
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

