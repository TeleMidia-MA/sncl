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
      sncl              = "src/main.lua",
      ["sncl.utils"]              = "src/utils/utils.lua",
      ["sncl.pegdebug"]           = "src/utils/pegdebug.lua",
      ["sncl.inspect"]            = "src/utils/inspect.lua",
      --["process"] = "src/process.lua",
      ["sncl.grammar"]     = "src/grammar.lua",
      ["sncl.parse_tree"]  = "src/parse-tree.lua",
      ["sncl.gen"]         = "src/gen.lua",
      ["sncl.macro"] = "src/macros.lua",
      ["sncl.template"] = "src/templates.lua",
      ["sncl.pre_process"] = "src/pre-process.lua",
      ["sncl.resolve"] = "src/resolve.lua",
      ["sncl.gen_lua"] = "src/ginga_lua.lua",
      ["sncl.globals"] = "src/utils/globals.lua"
   },
   install = {
      bin = {
         "src/bin/sncl"
      }
   }
}


