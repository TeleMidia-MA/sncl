local nclGen = require('sncl.generation')

describe("NCL #generation", function()

  describe("#head Elements", function()
  end)

  describe("#body Elements", function()

    describe("#media element", function()
      it("Should generate a #media with attributes", function()
        local mockMediaTable = {
          _type = "media",
          id = "testMedia",
          src = "testImage.png",
        }
        local expectedMockMediaNCL = '<media id="testMedia" src="testImage.png"></media>'
        local result = nclGen:presentation(mockMediaTable, {}, "")
        assert.are.equal(expectedMockMediaNCL, result)
      end)
      it("Should generate a #media with properties", function()
        local mockMedia = {
          _type = "media",
          id = "testMedia",
          properties = { left = "10%" }
        }
        local expectedMockMediaNCL = '<media id="testMedia">   <property name="left" value="10%" /></media>'
        local result = nclGen:presentation(mockMedia, {}, "")
        assert.are.equal(expectedMockMediaNCL, result)
      end)
    end)

  end)

end)
