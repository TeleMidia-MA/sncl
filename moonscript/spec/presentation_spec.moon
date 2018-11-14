import Context, Media, Area from require'../presentation'
--moon = require('moon')

describe 'Presentation classes interaction', ->
   local media, context, area
   it 'Ahould create media', ->
      media = Media('media1')
      assert.same(media, {id:'media1'})

   it 'Ahould create Context', ->
      context = Context('context1')
      assert.same(context, {id:'context1'})

   it 'Ahould create Area', ->
      area = Area('area1')
      assert.same(area, {id:'area1'})

   it 'Area should be children of Media', ->
      media\addChildren(area)
      assert.same(media, {id:'media1', children:{ [area.id]:{ id:'area1' }}})

   --it 'Context should not be children of Media', ->
      --assert.has_error(media\addChildren(context), 'asdf')

   it 'Media should be children of Context', ->
      context\addChildren(media)
      assert.same(context, { id:'context1', children: { [media.id]: { id: 'media1', children:{ [area.id]:{ id:'area1'} } } } })

describe 'Presentation classes grammar', ->
   it 'Should error when element dont have end', ->
      assert.has_error(() -> sncl.parseText('media media_name'))

   it 'Should not recognize chars not in the grammar', ->
      assert.has_error(() -> sncl.parseText("media media_name end asd"))
