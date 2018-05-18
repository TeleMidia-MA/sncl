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
      ["main"]               = "src/main.lua",
      ["utils"]              = "src/utils/utils.lua",
      ["pegdebug"]           = "src/utils/pegdebug.lua",
      ["inspect"]            = "src/utils/inspect.lua",
      --["process"] = "src/process.lua",
      ["grammar"]     = "src/grammar.lua",
      ["parse-tree"]  = "src/parse-tree.lua",
      ["gen"]         = "src/gen.lua",
      ["macro"] = "src/macros.lua",
      ["template"] = "src/templates.lua",
      ["pre_process"] = "src/pre-process.lua",
      ["resolve"] = "src/resolve.lua",
      ["gen_lua"] = "src/ginga_lua.lua",
      ["globals"] = "src/utils/globals.lua"
   },
   install = {
      bin = {
         "src/bin/sncl"
      }
   }
}


