local lpeg = require('lpeg')
local C, Cc, Cb, Ct, Cg, Cs, Cf
C, Cc, Cb, Ct, Cg, Cs, Cf = lpeg.C, lpeg.Cc, lpeg.Cb, lpeg.Ct, lpeg.Cg, lpeg.Cs, lpeg.Cf
local V, P, R, S
V, P, R, S = lpeg.V, lpeg.P, lpeg.R, lpeg.S
lpeg.locale(lpeg)
local symbol_table = { }
local grammar = {
  'start',
  space = lpeg.space ^ 0,
  space_required = lpeg.space,
  alphanumeric = R('az', 'AZ', '09'),
  alpha = R('az', 'AZ'),
  ["end"] = Cg(P('end'), 'end'),
  reserved_aux = (P('context') + P('media') + P('area') + P('do') + P('end') + P('onBegin') + P('onEnd') + P('start') + P('stop')),
  reserved_words = (V('reserved_aux') * lpeg.space) + V('reserved_aux') * P('.'),
  id_chars_start = S('_') + V('alpha'),
  id_chars = S('_-:') + V('alphanumeric'),
  id = Cg((P(V('id_chars_start') * (V('id_chars')) ^ 0)), 'id') - P(V('reserved_words')),
  interface = P('.') * Cg(V('id'), 'interface') * V('space'),
  id_and_interface = V('id') * (V('interface') + V('space')),
  name = Cg(V('alphanumeric'), 'name') * V('space'),
  value = Cg(V('alphanumeric'), 'value') * V('space'),
  property = Cg(Ct(V('name') * V('space') * P(':') * V('space') * V('value'), 'property') - P('end')) * V('space'),
  _type = Cg(P('media') + P('context') + P('area'), '_type'),
  presentation = Cf(Ct(V('_type') * V('space') * V('id_and_interface') * Cg(Ct((V('presentation') + V('link') + V('property')) ^ 0), 'children') * V('space') * V('end')), rawset) * V('space'),
  condition = Cg(Ct(P('onBegin') * V('space') * V('id_and_interface')), 'condition') * V('space') * P('do'),
  action = Cg(Ct(P('start') * V('space') * V('id_and_interface') * V('space') * V('end')), 'action'),
  link = Cf(Ct(V('condition') * V('space') * V('action') * V('space') * V('end') * Cg(Cc('link'), '_type')), rawset) * V('space'),
  start = Ct((V('presentation') + V('link')) ^ 0) * V('space') * P(-1)
}
return {
  grammar = grammar
}
