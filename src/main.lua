local utils = require('sncl.utils')
local gbl = require('sncl.globals')
local ins = require('sncl.inspect')
local pp = require('sncl.pre_process')
local gen = require('sncl.gen')
local gen_lua = require('sncl.gen_lua')
local grammar = require('sncl.grammar')
--local lyaml = require('lyaml')
require('sncl.pegdebug')
require('sncl.macro')

local sncl = {}

function sncl.genNCL(sncl)
   local symbol_tbl = grammar.lpegMatch(grammar, sncl)
   if not symbol_tbl then
      utils.printErro('Error parsing document', gbl.parser_line)
      return sncl, gbl.erros, nil
   end

   -- Resolve macros and templates
   pp.pre_process(symbol_tbl)

   -- For ltab on Ginga
   --genLua(symbol_tbl)

   -- Generate the NCL from the Lua table
   local NCL = gen:genNCL(symbol_tbl)
   if gbl.has_error then
      utils.printErro('Error in sncl file')
      return gbl.erros, nil
   end

   return NCL, symbol_tbl
end

--- The main function of the compiler
-- @param args the arguments of the command line
function beginParse(args)
   gbl.input_file = args.input

   local sncl_input = utils:readFile(args.input)
   if not sncl_input then
      utils.printErro('Error reading input file')
      return gbl.erros
   end
   local NCL, symbol_tbl = sncl.genNCL(sncl_input)
   if gbl.has_error then
      print(gbl.erros)
   end
   if not NCL then return end

   if args.show_symbol then
      print("Symbol Table:", ins.inspect(symbol_tbl))
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

   -- Parse the sncl table, generate an equivalent Lua table

   local output_file = nil
   if args.output then
      utils:writeFile(args.output, NCL)
      output_file = args.output
   else
      output_file = args.input:sub(1, args.input:len()-4)
      output_file = output_file..'ncl'
      utils:writeFile(output_file, NCL)
   end
   if args.play then
      os.execute('ginga '..output_file)
   end
end
return sncl
