local utils = require'utils'
local gbl = require('globals')
local inspect = require('inspect')
local lyaml = require('lyaml')
local ins = require('inspect')
local pp = require('pre_process')
local gen = require('gen')

require'pegdebug'
require'gen'
require'pre_process'
require'macro'
require'grammar'

function beginParse(args)
   gbl.inputFile = input

   local snclInput = utils:readFile(args.input)
   if not snclInput then
      utils:printErro('Error reading input file')
      return
   end

   -- Templates: not yet implemented
   -- if padding then
   --    -- TODO: Check yaml file extension
   --    -- TODO: Check errors in yaml
   --    local paddingContent = utils.readFile(padding)
   --    sT.padding = lyaml.load(paddingContent, { all = true })
   -- end

   local symbolTable = utils.lpegMatch(grammar, snclInput) --[[  ]]
   if not symbolTable then
      utils:printErro('Error parsing document', gbl.parserLine)
      return -1
   end

   pp.pre_process(symbolTable) --[[ Process the macro calls and the templates ]]

   if args.show_symbol then
      print("Symbol Table:", inspect.inspect(symbolTable))
   end
   --
   local NCL = gen:genNCL(symbolTable) --[[ Receives a lua table, and generate the NCL ]]

   if gbl.hasError then
      utils:printErro('Error in sncl file')
      return
   end

   local outputFile = nil
   if args.output then
      utils:writeFile(args.output, NCL)
      outputFile = args.output
   else
      outputFile = args.input:sub(1, args.input:len()-4)
      outputFile = outputFile..'ncl'
      utils:writeFile(outputFile, NCL)
   end
   if play then
      os.execute('ginga '..outputFile)
   end

end

-- TODO: Onde botar? N devem ser globais


