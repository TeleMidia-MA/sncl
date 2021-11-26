package = "sncl"
version = "1.0-0"
source = {
   url = "git://github.com/TeleMidia-MA/sncl.git"
}
description = {
   summary = "A tool that compiles sncl code to ncl",
   detailed = [[
     TO-DO: Descricao mais detalhada
   ]],
   homepage = "https://github.com/TeleMidia-MA/sNCL",
   maintainer = "Lucas de Macedo <lucastercas@gmail.com>",
   license = "GPL-3.0"
}
dependencies = {
   "lua >= 5.1",
   "lpeg",
   "luafilesystem",
   "ansicolors",
   "argparse",
   "lyaml"
}
build = {
   type = "builtin",
   modules = {
      sncl                   = "src/main.lua",
      ["sncl.utils"]         = "src/sncl/utils/utils.lua",
      ["sncl.pegdebug"]      = "src/sncl/utils/pegdebug.lua",
      ["sncl.inspect"]       = "src/sncl/utils/inspect.lua",
      --["process"] = "src/process.lua",
      ["sncl.grammar"]       = "src/sncl/grammar.lua",
      ["sncl.parsetree"]     = "src/sncl/parsetree.lua",
      ["sncl.generation"]    = "src/sncl/generation.lua",
      ["sncl.macro"]         = "src/sncl/macros.lua",
      ["sncl.template"]      = "src/sncl/templates.lua",
      ["sncl.preprocessing"] = "src/sncl/preprocessing.lua",
      ["sncl.resolve"]       = "src/sncl/resolve.lua",
      ["sncl.ltab"]          = "src/sncl/ltab.lua",
      ["sncl.globals"]       = "src/sncl/utils/globals.lua"
   },
   install = {
      bin = {
         "bin/sncl"
      }
   }
}
