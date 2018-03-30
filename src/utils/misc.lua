local utils= {}
local colors = require("ansicolors")

function utils.readFile(file)
   file = io.open(file, 'r')
   if not file then
      utils.printErro("Can't open file")
      return nil
   end
   local fileContent = file:read('*a')
   if not fileContent then
      utils.printErro("Can't read file")
      return nil
   end
   return fileContent
end

function utils.writeFile(file, content)
   file = io.open(file, "w")
   if not file then
      utils.printErro("Could not create output file")
      return nil
   end
   io.output(file)
   io.write(content)
   io.close(file)
end

function utils.printErro(errString, line)
   line = line or gblParserLine
   local file = gblInputFile or ""
   io.write(colors("%{bright}"..file..":"..line..": %{red}erro:%{reset} "..errString.."\n"))
   gblHasError = true
end


function utils.containValue(tbl, arg)
   for _, val in pairs(tbl) do
      if val == arg then
         return true
      end
   end
   return false
end

function utils.getIndex(tbl, arg)
   for pos, val in pairs(tbl) do
      if val == arg then
         return pos
      end
   end
   return nil
end

function utils.isMacroSon(ele)
   if ele._type == "macro" then
      return true
   else
      if ele.father then
         return utils.isMacroSon(ele.father)
      end
   end
   return false
end

return utils
