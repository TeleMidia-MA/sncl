package = "sncl"
version = "0.4-0"

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
      ["main"]               = "src/main.lua",
      ["utils"]              = "src/utils/misc.lua",
      ["pegdebug"]           = "src/utils/pegdebug.lua",
      ["inspect"]            = "src/utils/inspect.lua",
      ["process"] = "src/parser/process.lua",
      ["grammar"]     = "src/parser/grammar.lua",
      ["parse-tree"]  = "src/parser/parse-tree.lua",
      ["gen"]         = "src/parser/gen.lua",
   },
   install = {
      bin = {
         "src/bin/sncl"
      }
   }
}


