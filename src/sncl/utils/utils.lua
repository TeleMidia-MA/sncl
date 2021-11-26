local colors = require('ansicolors')
local lpeg = require('lpeg')

local gbl = require('sncl.globals')

local R, P = lpeg.R, lpeg.P

local utils = {}

utils.checks = {
  buttons = R'09'+R'AZ'+P'*'+P'#'+P'MENU'+P'INFO'+P'GUIDE'+P'CURSOR_DOWN'
    +P'CURSOR_LEFT'+P'CURSOR_RIGHT'+P'CURSOR_UP'+P'CHANNEL_DOWN'+P'CHANNEL_UP'
    +P'VOLUME_DOWN'+P'VOLUME_UP'+P'ENTER'+P'RED'+P'GREEN'+P'YELLOW'+P'BLUE'
    +P'BLACK'+P'EXIT'+P'POWER'+P'REWIND'+P'STOP'+P'EJECT'+P'PLAY'+P'RECORD'+P'PAUSE',
  types = P'context'+P'media'+P'area'+P'region'+P'macro'
}

function utils.createSymbolTable()
  return {
    presentation = {},
    head = {},
    link = {},
    macro = {},
    macroCall = {},
    template = {},
    padding = {},
  }
end

function utils.containsValue(tbl, value)
  for _, val in pairs(tbl) do
    if val == value then
      return true
    end
  end
  return false
end

function utils.getIndex(tbl, value)
  for pos, val in pairs(tbl) do
    if val == value then
      return pos
    end
  end
  return nil
end

function utils.getElementsWithClass(elements, class)
  local tbl = {}
  for pos, val in pairs(elements) do
    -- When the elements from the yaml are parsed,
    -- they come without the id
    if not val.id then
      val.id = pos
    end
    if val.class == class then
      table.insert(tbl, val)
    end

  end
  return tbl
end

function utils.printError(errorString, line)
  line = line or gbl.parserLine
  local file = gbl.inputFile or ''
  io.write(colors('%{bright}'..file..':'..line..': %{red}erro:%{reset} '..errorString..'\n'))
  gbl.hasError = true
end

function utils:addProperty(element, name, value)
  if name == "_type" then return nil end
  if not element.properties then element.properties = {} end
  if element.properties[name] then
    return error(string.format("Property %s already declared", name))
  else
    element.properties[name] = value
  end
end

function utils:isIdUsed(id, symbolsTable)
  if symbolsTable.presentation[id] or symbolsTable.macro[id] or symbolsTable.head[id] then
    return true
  end
  return false
end

function utils:isMacroSon(element)
  if element._type == 'macro' then
    return true
  else
    if element.father then
      return self:isMacroSon(element.father)
    end
  end
  return false
end

function utils:getNumberOfParents(element, numFathers)
  if element.father then
    numFathers = self:getNumberOfParents(element.father, numFathers+1)
  end
  return numFathers
end

function utils:readFile(file)
  file = io.open(file, 'r')
  if not file then
    self.printErro('Error opening input file')
    return nil
  end
  local fileContent = file:read('*a')
  if not fileContent then
    self.printError('Error reading input')
    return nil
  end
  return fileContent
end

function utils:writeFile(file, content)
  file = io.open(file, "w")
  if not file then
    self.printErro('Error creating output file')
    return nil
  end
  io.output(file)
  io.write(content)
  io.close(file)
end

return utils
