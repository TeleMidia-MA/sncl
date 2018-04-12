local utils = require"utils"
local gbl = utils.globals
local inspect = require"inspect"
local lyaml = require"lyaml"
local ins = require"inspect"
local pp = require"pre_process"
local gen = require"gen"

require"grammar"
require"pegdebug"
require"gen"
require"process"
require"macro"

function beginParse(input, output, padding, play)

   gbl.inputFile = input
   local snclInput = utils.readFile(input)
   if not snclInput then
      utils.printErro("Error reading input file")
      return
   end

   if padding then
      -- TODO: Checar extensao do yaml
      -- TODO: Checar erros no yaml?
      local paddingContent = utils.readFile(padding)
      gbl.paddingTbl = lyaml.load(paddingContent, { all = true })
   end

   local parsed = utils.lpegMatch(grammar, snclInput)

   if not parsed then
      utils.printErro("Error parsing document")
      return -1
   end
   pp.pre_process()

   if _DEBUG_SYMBOL_TABLE then
      -- print("Symbol Table:", inspect.inspect(gbl.presTbl))
      -- print("Head Table:", inspect.inspect(gblHeadTbl))
      -- print("Link Table:", inspect.inspect(gblLinkTbl))
      -- print("Macro Table:", inspect.inspect(gblMacroTbl))
      -- print("Macro Call Table:", inspect.inspect(gblMacroCallTbl))
   end

   local NCL = gen.genNCL()
   if gbl.hasError then
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


