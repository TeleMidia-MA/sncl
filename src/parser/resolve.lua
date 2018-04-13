local resolve = {
   makeDesc = function(id, region, sT)
      sT.head[id] = {
         _type="descriptor",
         region=region,
         id = id
      }
   end,
}

return resolve
