local Context, Media, Area
do
  local _obj_0 = require('../presentation')
  Context, Media, Area = _obj_0.Context, _obj_0.Media, _obj_0.Area
end
describe('Presentation classes interaction', function()
  local media, context, area
  it('Ahould create media', function()
    media = Media('media1')
    return assert.same(media, {
      id = 'media1'
    })
  end)
  it('Ahould create Context', function()
    context = Context('context1')
    return assert.same(context, {
      id = 'context1'
    })
  end)
  it('Ahould create Area', function()
    area = Area('area1')
    return assert.same(area, {
      id = 'area1'
    })
  end)
  it('Area should be children of Media', function()
    media:addChildren(area)
    return assert.same(media, {
      id = 'media1',
      children = {
        [area.id] = {
          id = 'area1'
        }
      }
    })
  end)
  return it('Media should be children of Context', function()
    context:addChildren(media)
    return assert.same(context, {
      id = 'context1',
      children = {
        [media.id] = {
          id = 'media1',
          children = {
            [area.id] = {
              id = 'area1'
            }
          }
        }
      }
    })
  end)
end)
return describe('Presentation classes grammar', function()
  it('Should error when element dont have end', function()
    return assert.has_error(function()
      return sncl.parseText('media media_name')
    end)
  end)
  return it('Should not recognize chars not in the grammar', function()
    return assert.has_error(function()
      return sncl.parseText("media media_name end asd")
    end)
  end)
end)
