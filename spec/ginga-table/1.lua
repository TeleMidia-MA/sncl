ncl = {
   'context',
   'ncl',
   {'m2@lambda'},
   {
      {'media', 'm1', {src = 'samples/clock.ogv'}, {a1 = {'3s'}}},
      {'media', 'm2', {src = 'samples/gnu.png'}}
   },
   {
      {
         {
            {'start', 'm1@a1', {true}}
         },
         {
            {'stop', 'm1@lambda'},
            {'start', 'm2@lambda', nil, {delay = '0s', duration = '0s'}}
         }
      },
   }
}
