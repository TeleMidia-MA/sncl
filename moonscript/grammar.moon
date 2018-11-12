lpeg = require('lpeg')
moon = require('moon')
import C, Cc, Cb, Ct, Cg, Cs, Cf from lpeg
import V, P, R, S from lpeg

lpeg.locale(lpeg)

file = io.open('test.ncl')
content = file\read('*a')

grammar = {
   'start'
   space: lpeg.space^0
   alphanumeric: R('az', 'AZ', '09')

   _type: Cg(P'media' + P'context' + P'area', '_type')
   id: Cg(R('az', 'AZ', '__') * V'alphanumeric'^0, 'id')
   interface: P'.'*Cg(V'id', 'interface') * V'space'
   presentation: Cf(Ct( V'_type' * V'space' * V'id' * (V'interface' + V'space') *
      (Cg(Ct(V'presentation'^0), 'children') * V'space' * Cg(P'end', 'end'))), rawset) * V'space'


   condition: Cg(Ct(P'onBegin' * V'space' * V'id'), 'condition') * V'space' * P'do'
   action: Cg(Ct(P'start' * V'space' * V'id'), 'action')
   link: Cf(Ct(V'condition' * V'space' * V'action' * V'space' * Cg(P'end', 'end') *
      Cg(Cc'link', '_type')), rawset) * V'space'

   start: Ct((V'presentation' + V'link')^0)
}

moon.p(lpeg.match(grammar, content))
