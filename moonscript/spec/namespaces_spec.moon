import sncl from require('../main')

describe 'Testing namespaces', ->
   it 'Should recognize XML namespaces', ->
      assert.has_no.errors(()->sncl.parseText('media media_123-456 end'))
      assert.has_no.errors(()->sncl.parseText('context _context-2._interface-_3 end'))

   it 'Should error on reserved words', ->
      assert.has_error(()->sncl.parseText('context context end'))
      assert.has_error(()->sncl.parseText('media media end'))
      assert.has_error(()->sncl.parseText('media onBegin end'))
      assert.has_error(()->sncl.parseText('media media1.context end'))

