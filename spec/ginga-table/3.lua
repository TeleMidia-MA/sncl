ncl = {
   'context',
   'ncl',

   {'m2@lambda'},

   {
      {'media', 'm1', 
         {src = 'samples/clock.ogv'}, 
         {a1 = {'3s'}
         }
      },
      {'media', 'm2', 
         {src = 'samples/gnu.png'}
      },
      {'context',
         'c1',
         {'m3@lambda'},
         {
            {'media', 'm3'}
         },
         {

         }
      },

      {
      }
   }
}

return ncl
