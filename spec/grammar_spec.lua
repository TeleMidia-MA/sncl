local grammar = require('sncl.grammar')

describe("#grammar basic", function()
  it("Should correctly generate a empty symbol table when passing empty string", function()
    local expected = {
      head = {},
      link = {},
      macro = {},
      macroCall = {},
      padding = {},
      presentation = {},
      template = {}
    }
    local snclString = ""
    local result = grammar.lpegMatch(snclString)
    assert.are.same(expected, result)
  end)
end)

