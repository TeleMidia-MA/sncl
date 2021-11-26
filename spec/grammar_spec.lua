local grammar = require('sncl.grammar')

describe("#grammar", function()

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

  it("Should parse a empty #media", function()
    local expected = {
      presentation = {
        testMedia = {
          _type = "media",
          id = "testMedia",
          hasEnd = true,
        }
      }
    }
    local snclString = [[
    media testMedia
    end
    ]]
    local result = grammar.lpegMatch(snclString)
    assert.are.same(expected.presentation, result.presentation)
  end)

  it("Should parse a #media with attributes", function()
    local expected = {
      presentation = {
        testMediaAttributes = {
          _type = "media",
          id = "testMediaAttributes",
          src = '"../images/testImage.png"',
          descriptor = "testDescriptor",
          hasEnd = true,
        }
      }
    }
    local snclString = [[
    media testMediaAttributes
      descriptor: testDescriptor
      src: "../images/testImage.png"
    end
    ]]
    local result = grammar.lpegMatch(snclString)
    assert.are.same(expected.presentation, result.presentation)
  end)

  it("Should parse #media with properties", function ()
    local expected = {
      presentation = {
        testMediaProperties = {
          _type = "media",
          id = "testMediaProperties",
          hasEnd = true,
          properties = {
            focusIndex = '1',
            focusBorderWidth = '3',
            right = '10%'
          },
        }
      }
    }
    local snclString = [[
    media testMediaProperties
      focusIndex: 1
      focusBorderWidth: 3
      right: 10% 
    end
    ]]
    local result = grammar.lpegMatch(snclString)
    assert.are.same(expected.presentation, result.presentation)
  end)

end)

