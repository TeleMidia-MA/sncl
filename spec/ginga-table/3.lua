cl = {
   'context',
   'ncl',

   -- list of ports
   {'m2@lambda'},

   -- list of children
   {
      {'media', 'm1', {src = 'samples/clock.ogv'}, {a1 = {'3s'}}},
      {'media', 'm2', {src = 'samples/gnu.png'}},
      {'context',
         'c1',
         -- list of inner ctx ports
         {'m3@lambda'},
         -- list of inner ctx children
         {{'media', 'm3'}},
         -- no links (could be nil instead of empty table)
         {}
      },

      -- list of links
      {
      }
   }
}
