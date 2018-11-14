local moon = require('moon')
local lpeg = require('lpeg')
local Context, Media, Area
do
  local _obj_0 = require('presentation')
  Context, Media, Area = _obj_0.Context, _obj_0.Media, _obj_0.Area
end
local Link, Action, Condition
do
  local _obj_0 = require('link')
  Link, Action, Condition = _obj_0.Link, _obj_0.Action, _obj_0.Condition
end
local grammar
grammar = require('grammar').grammar
local __DEBUG__ = false
local readFile
readFile = function(path)
  return io.open(path):read('*a')
end
local parseText
parseText = function(text)
  local symbol_table
  symbol_table = lpeg.match(grammar, text)
  if __DEBUG__ then
    moon.p(symbol_table)
  end
  if not symbol_table then
    error('Error parsing input', 2)
  end
  return symbol_table
end
local create_element
create_element = function(grammar_ele)
  if grammar_ele == nil then
    return nil
  end
  local new_ele
  local _exp_0 = grammar_ele._type
  if 'context' == _exp_0 then
    print('creating context')
    new_ele = Context(grammar_ele.id)
  elseif 'media' == _exp_0 then
    print('creating media')
    new_ele = Media(grammar_ele.id)
  else
    return nil, 'Wrong Type'
  end
  for k, v in pairs(grammar_ele) do
    if k == 'children' then
      local new_child = create_element(v[1])
      if new_child ~= nil then
        new_ele:addChildren(new_child)
      end
    end
  end
  return new_ele
end
local createObjects
createObjects = function(symbol_table)
  for _index_0 = 1, #symbol_table do
    local element = symbol_table[_index_0]
    local new_element
    new_element = create_element(element)
    moon.p(new_element)
  end
end
local symbol_table = parseText(readFile('test.sncl'))
moon.p(symbol_table)
local sncl = {
  readFile = readFile,
  parseText = parseText
}
return {
  sncl = sncl
}
