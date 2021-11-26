local utils = require('sncl.utils')
local gbl = require('sncl.globals')

local grammar = require('sncl.grammar')
--local pp = require('sncl.pre_process')
local ltab = require('sncl.ltab')
local nclGeneration = require('sncl.generation')

local ins = require('sncl.inspect')

--local lyaml = require('lyaml')
require('sncl.pegdebug')
require('sncl.macro')

local sncl = {}

function sncl:init()
  return self
end

--function sncl:generateLTab(input)
--   local symbolsTable
--   -- Checar se ta sendo passado uma string ou uma tabela
--   if type(input) == "string" then
--      symbolsTable = grammar.lpegMatch(input)
--      if not symbolsTable then
--         utils.printErro('Error parsing document: ', gbl.parser_line)
--         return sncl, gbl.errors, nil
--      end
--   elseif type(input) == "table" then
--      symbolsTable = input
--   end
--   return makeLtab(symbolsTable)
--end

function sncl:generateNCL(symbolsTable)
   -- resolve macros and templates
   -- pp.pre_process(symbol_tbl)

   -- generate the ncl from the Lua table
   local ncl = nclGeneration:generateNCL(symbolsTable)
   if gbl.hasError then
      utils.printError('Error in sncl file')
      return gbl.errors, nil
   end
   return ncl
end

--- The main function of the compiler
-- @param args the arguments of the command line
function sncl:beginParse(args)
   gbl.input_file = args.input
   local sncl_input = utils:readFile(args.input)
   if not sncl_input then
      utils.printErro('Error reading input file')
      return gbl.erros
   end
   -- gerar a tabela Lua que representa o sncl
   local symbolsTable = grammar.lpegMatch(sncl_input)
   if not symbolsTable then
      utils.printError('Error parsing document: ', gbl.parser_line)
      return sncl, gbl.errors, nil
   end

   -- gerar o ltab
--   if args.to_ltab then
--      ltab = sncl.generage(symbol_tbl)
--      return ltab
--   end

   local ncl = self:generateNCL(symbolsTable)
   if not ncl then
      return gbl.errors
   end

   -- se o usuario passou a opcao "-s", imprimir a tabela de simbolos
   if args.show_symbol_table then
      print("Symbol Table:", ins.inspect(symbolsTable))
   end

   --[[
   Templates: not yet implemented
   if padding then
      -- TODO: Check yaml file extension
      -- TODO: Check errors in yaml
      local paddingContent = utils.readFile(padding)
      sT.padding = lyaml.load(paddingContent, { all = true })
   end
   ]]

   local output_file = nil
   if args.output then
      utils:writeFile(args.output, ncl)
      output_file = args.output
   else
      output_file = args.input:sub(1, args.input:len()-4)
      output_file = output_file..'ncl'
      utils:writeFile(output_file, ncl)
   end
   if args.play then
      os.execute('ginga '..output_file)
   end
end

return sncl
