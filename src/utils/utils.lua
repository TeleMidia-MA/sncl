local colors = require('ansicolors')
local lpeg = require('lpeg')
local gbl = require('globals')

local R, P = lpeg.R, lpeg.P

local utils = {
   lpegMatch = function(grammar, input)
      if _DEBUG_PEG then
         parsed = lpeg.match(require("pegdebug").trace(grammar), snclInput)
      else
         parsed = lpeg.match(grammar, input)
      end
      return parsed
   end,

   containValue = function(tbl, arg)
      for _, val in pairs(tbl) do
         if val == arg then
            return true
         end
      end
      return false
   end,

   getIndex = function(tbl, arg)
      for pos, val in pairs(tbl) do
         if val == arg then
            return pos
         end
      end
      return nil
   end,

   isMacroSon = function(ele)
      if ele._type == "macro" then
         return true
      else
         if ele.father then
            return utils.isMacroSon(ele.father)
         end
      end
      return false
   end,

   getNumberOfParents = function(ele, f)
      if ele.father then
         f =  utils.getNumberOfParents(ele.father, f+1)
      end
      return f
   end,

   getElementsWithClass = function(elements, class)
      local tbl = {}
      for pos, val in pairs(elements) do
         if not val.id then -- Quando os elementos vem do yaml, eles vem sem id, pq o id eh o index
            val.id = pos
         end
         if val.class == class then
            table.insert(tbl, val)
         end
      end
      return tbl
   end,

   addProperty = function(element, name, value)
      if name ~="_type" then
         if element.properties[name] then
            utils.printErro(string.format("Property %s already declared"))
            return nil
         else
            -- Se for rg, entao é uma regiao
            -- nesse caso, o descritor tem q ser criado
            if name == 'src' then
               element.src = value
            elseif name == 'type' then
               element.type = value
            else
               element.properties[name] = value
            end
         end
      end
   end,

   isIdUsed = function(id, sT)
      if sT.presentation[id] or sT.macro[id] or sT.head[id]then
         utils.printErro(string.format("Id %s already declared", id))
         return true
      end
      return false
   end,

   checks = {
      buttons = R"09"+R"AZ"+P"*"+P"#"+P"MENU"+P"INFO"+P"GUIDE"+P"CURSOR_DOWN"
      +P"CURSOR_LEFT"+P"CURSOR_RIGHT"+P"CURSOR_UP"+P"CHANNEL_DOWN"+P"CHANNEL_UP"
      +P"VOLUME_DOWN"+P"VOLUME_UP"+P"ENTER"+P"RED"+P"GREEN"+P"YELLOW"+P"BLUE"
      +P"BLACK"+P"EXIT"+P"POWER"+P"REWIND"+P"STOP"+P"EJECT"+P"PLAY"+P"RECORD"+P"PAUSE",
      types = P"context"+P"media"+P"area"+P"region"+P"macro"
   },

}

function utils:printErro(errString, line)
   local line = line or gbl.parserLine
   local file = gbl.inputFile or ""
   io.write(colors("%{bright}"..file..":"..line..": %{red}erro:%{reset} "..errString.."\n"))
   self.hasError = true
end

function utils:readFile(file)
   file = io.open(file, 'r')
   if not file then
      self.printErro("Can't open file")
      return nil
   end
   local fileContent = file:read('*a')
   if not fileContent then
      self.printErro("Can't read file")
      return nil
   end
   return fileContent
end

function utils:writeFile(file, content)
   file = io.open(file, "w")
   if not file then
      self.printErro("Could not create output file")
      return nil
   end
   io.output(file)
   io.write(content)
   io.close(file)
end
return utils