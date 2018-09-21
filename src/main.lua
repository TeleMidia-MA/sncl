local utils = require('sncl.utils')
local gbl = require('sncl.globals')
local grammar = require('sncl.grammar') -- definicao da gramatica
local pp = require('sncl.pre_process') -- processamento de macros, templates
local ltab = require('sncl.ltab') -- geracao da tabela ltab
local gen = require('sncl.gen') -- geracao do codigo ncl
local ins = require('sncl.inspect') -- print melhor de tabelas

--local lyaml = require('lyaml')
require('sncl.pegdebug')
require('sncl.macro')

local sncl = {}

function sncl.genLtab(sNCL)
   local symbol_table
   -- Checar se ta sendo passado uma string ou uma tabela
   if type(sNCL) == "string" then
      symbol_table = grammar.lpegMatch(grammar, sNCL)
      if not symbol_table then
         utils.printErro('Error parsing document', gbl.parser_line)
         return sncl, gbl.erros, nil
      end
   elseif type(sNCL) == "table" then
      symbol_table = sNCL
   end

   local ltab_table = makeLtab(symbol_table)
   return ltab_table
end

function sncl.genNCL(symbol_table)
   -- resolve macros and templates
   --pp.pre_process(symbol_tbl)

   -- generate the ncl from the Lua table
   local ncl = gen:genNCL(symbol_table)
   if gbl.has_error then
      utils.printErro('Error in sncl file')
      return gbl.erros, nil
   end

   return ncl
end

--- The main function of the compiler
-- @param args the arguments of the command line
function beginParse(args)
   gbl.input_file = args.input

   -- le o arquivo sncl de entrada
   local sncl_input = utils:readFile(args.input)
   -- se houve erro, retorna os erros
   if not sncl_input then
      utils.printErro('Error reading input file')
      return gbl.erros
   end
   -- gerar a tabela Lua que representa o sncl
   local symbol_tbl = grammar.lpegMatch(grammar, sncl_input)
   if not symbol_tbl then
      utils.printErro('Error parsing document', gbl.parser_line)
      return sncl, gbl.erros, nil
   end

   -- gerar o ltab
   if args.to_ltab then
      ltab = sncl.genLtab(symbol_tbl)
      return ltab
   end

   -- gera o ncl, se houver erro, retorna os erros
   local ncl = sncl.genNCL(symbol_tbl)
   if not ncl then
      return gbl.erros
   end

   -- se o usuario passou a opcao "-s", imprimir a tabela de simbolos
   if args.show_symbol_table then
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
