
local resolve = { }

function resolve:makeDescriptor(regionName, symbolsTable)
  local newDescriptor = {
    _type = "descriptor",
    region = regionName,
    id = '__desc'..regionName
  }
  symbolsTable.head[newDescriptor.id] = newDescriptor
  return newDescriptor.id
end

function resolve:makeConnectorBind(xconn, bind)
  if xconn[bind._type][bind.role] then
    xconn[bind._type][bind.role] = xconn[bind._type][bind.role]+1
  else
    xconn[bind._type][bind.role] = 1
  end
  if xconn.id:find(bind.role:gsub('^%l', string.upper)) then
    xconn.id = xconn.id..'N'
  else
    xconn.id = xconn.id..bind.role:gsub('^%l', string.upper)
  end
  if bind.properties then
    for name, _ in pairs(bind.properties) do
      table.insert(xconn.properties, name)
    end
  end
end

function resolve:makeConnector(link, symbolsTable)
  local newConn = {
    _type = 'xconnector',
    id = '',
    condition = {},
    action = {},
    properties = {}
  }

  for _, cond in pairs(link.conditions) do
    self.makeConnBind(newConn, cond)
  end
  for _, act in pairs(link.actions) do
    self.makeConnBind(newConn, act)
  end
  if link.properties then
    for name, _ in pairs(link.properties) do
      table.insert(newConn.properties, name)
    end
  end

  -- TODO: Has to do all above to check if another equal
  -- connect is already created, wasting time. How to fix?

  if not symbolsTable.head[newConn.id] then
    symbolsTable.head[newConn.id] = newConn
  end

  return newConn.id
end

return resolve
