local lpeg = require('lpeg')
local pT = require('sncl.parse_tree')
local gbl = require('sncl.globals')
local utils = require('sncl.utils')
lpeg.locale(lpeg)

-- TODO: macro m1(,,,,,) <- Isso é pra da erro

local V, P, R, S = lpeg.V, lpeg.P, lpeg.R, lpeg.S
local C, Ct, Cg = lpeg.C, lpeg.Ct, lpeg.Cg

local gr = {
   lpegMatch = function(grammar, input)
      local sT = utils.createSymbolTable()
      grammar = {
         'START';
         Any = P(1),
         EOS = -V'Any',
         Spc = lpeg.space
         /function(st)
            if st == '\n' then
               gbl.parser_line = gbl.parser_line+1
            end
         end,
         Digit = lpeg.digit,
         Lower = R'az',
         Upper = R'AZ',
         Letter = V'Lower' + V'Upper',
         Alnum = R('az', 'AZ', '09', '__'),
         Num = P('0x') * R('09', 'af', 'AF')^1 * (S('uU')^-1 * S('lL')^2)^-1
         + R('09')^1 * (S('uU')^-1 * S('lL')^2)
         + (R('09')^1 * (P('.') * R('09')^1)^-1 + P('.') * R('09')^1) * (S('eE') * P('-')^-1 * R('09')^1)^-1,
         Symbols = S'%./-\\',

         End = P'end',
         Type = P'media'+'context'+'area'+'region'+'macro',
         ReservedCondition = P'onBegin'+'onEnd'+'onSelection',
         ReservedAction = P'start'+'stop'+'set',
         Reserved = V'Type'+V'ReservedAction'+V'ReservedCondition'+P'do',
         Id = R('az', 'AZ', '__') * V'Alnum'^0,
         PropertyValue = (V'Letter'+V'Num'+V'Symbols')^0,
         Property = pT.makeProperty( (C(V'Id') *V'Spc'^0* P':' *V'Spc'^0*
            C(P'"'*V'PropertyValue'*P'"' + V'PropertyValue') * V'Spc'^0)),

         Port = V'Spc'^0*pT.makePort(P'port'* V'Spc'^1 * C(V'Id') * V'Spc'^1 * C(V'Id')*(P'.'*C(V'Id'))^-1, sT, false),

         PresentationElement = V'Spc'^0* pT.makePresentationElement(C(V'Reserved') *V'Spc'^1 * C(V'Id') *V'Spc'^1
            *(V'PresentationElement'+V'Port'+V'Property'+V'Link'+V'MacroCall'+V'Template'+V'Spc')^0 *C(V'End'), sT, false),

         Link = V'Spc'^0*
         pT.makeLink((V'Condition' *V'Spc'^1* ((V'Property'+V'Action')-V'End')^0 *C(V'End')*V'Spc'^0), sT, false),
         Condition = pT.makeBind(V'ConditionId' *V'Spc'^1* (V'RepeatCondition'+V'Spc')^0 *P'do','condition'),
         ConditionId = pT.makeRelationship(C(V'Reserved') *V'Spc'^1* (C(V'Id')*(P'.'*C(V'Id'))^-1)),
         RepeatCondition = P'and' *V'Spc'^1* V'ConditionId',
         Action = pT.makeBind(V'ActionId' *V'Spc'^1* (V'RepeatAction'+V'Spc')^0*
            (V'Property')^0* C(V'End') *V'Spc'^0, 'action'),
         ActionId = pT.makeRelationship(C(V'Reserved') *V'Spc'^1* (C(V'Id')*(P'.'*C(V'Id'))^-1)),
         RepeatAction = P'and' *V'Spc'^1*V'ActionId',

         MacroPort = V'Spc'^0*pT.makePort(P'port'* V'Spc'^1 * C(V'Id') * V'Spc'^1 * C(V'Id')*(P'.'*C(V'Id'))^-1, sT, true),
         MacroPresentationElement = V'Spc'^0* pT.makePresentationElement(C(V'Reserved') *V'Spc'^1 * C(V'Id') *V'Spc'^1
            *(V'MacroPresentationElement'+V'MacroPort'+V'Property'+V'MacroLink'+V'Template'+V'MacroCall'+V'Spc')^0 *C(V'End'), sT, true),
         MacroLink = (V'Spc'^0*
            pT.makeLink((V'Condition' *V'Spc'^1* ((V'Property'+V'Action')-V'End')^0 *C(V'End')*V'Spc'^0), sT, true)),
         Macro = V'Spc'^0* pT.makeMacro(P'macro' *V'Spc'^1* C(V'Id') *V'Spc'^0* V'Parameters'
            *V'Spc'^1* V'MacroBody'^-1 *V'Spc'^0* C(V'End'), sT),
         Parameters = P'('*  Ct(Cg( Ct(V'FieldParameters'^-1 * (',' * V'FieldParameters')^0),'parameters')) * P')',
         FieldParameters = V'Spc'^0*C(V'Id')*V'Spc'^0,
         --Field = ''' * Cs(((P(1) - ''') + P'''' / ''')^0) * ''' + C((1 - S',\n)'')^0),
         MacroBody = (V'MacroPresentationElement'+V'MacroLink'+V'Template')^0,

         MacroCall = V'Spc'^0*pT.makeMacroCall(C(V'Id') * V'Arguments', sT),
         Arguments = P'('*  Ct(( (V'FieldArgument'^-1 * (',' * V'FieldArgument')^0)) ) * P')',
         --FieldArguments = V'Spc'^0*P'''*C((V'Letter'+V'Digit'+V'Symbols'+S'[]')^0)*P'''*V'Spc'^0,
         FieldArgument = V'Spc'^0 * C(V'Reference'+V'Passed') * V'Spc'^0,
         Passed = P'"'*V'Reference'* P'"',
         Reference = (V'Alnum'+P'/'+P'%'+P'@')^1,
         -- TODO: Can accept more things other than Id

         Template = V'Spc'^0*pT.makeTemplate(V'For'*V'Spc'^1*V'MacroCall'^0*V'Spc'^0* C(V'End'), sT),
         For = (P'for' *V'Spc'^1* C(V'Lower'^1) *V'Spc'^0* P'='* V'Spc'^0*C(V'Digit'^1)*V'Spc'^0*P','*V'Spc'^0* P'#'*C((V'Lower'+V'Digit')^1) *V'Spc'^1* P'do'),

         START = ((V'Spc'^0
               *Ct((V'Template'+V'Port'+V'Macro'+V'PresentationElement'+V'Link'+V'MacroCall')^0) * V'Spc'^0)
            *V'EOS')
         /function()
            return sT
         end,
      }
      if gbl._DEBUG_PEG then
         sT = lpeg.match(require('pegdebug').trace(grammar), input)
      else
         sT = lpeg.match(grammar, input)
      end
      return sT
   end

}
return gr


