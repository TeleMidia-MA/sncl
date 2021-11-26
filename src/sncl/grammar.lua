local lpeg = require('lpeg')

local parseTree = require('sncl.parsetree')
local gbl = require('sncl.globals') local utils = require('sncl.utils')

lpeg.locale(lpeg)

-- TODO: macro m1(,,,,,) <- Isso é pra da erro

local V, P, R, S = lpeg.V, lpeg.P, lpeg.R, lpeg.S
local C, Ct, Cg = lpeg.C, lpeg.Ct, lpeg.Cg

local grammar = {
  lpegMatch = function(snclString)
    local symbolsTable = utils.createSymbolTable()
    local lpegGrammar = {
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
      Alphanumerics = R('az', 'AZ', '09', '__'),
      Numbers = P('0x') * R('09', 'af', 'AF')^1 * (S('uU')^-1 * S('lL')^2)^-1
        + R('09')^1 * (S('uU')^-1 * S('lL')^2)
        + (R('09')^1 * (P('.') * R('09')^1)^-1 + P('.') * R('09')^1) * (S('eE') * P('-')^-1 * R('09')^1)^-1,
      Symbols = S'%./-\\',

      End = P'end',
      Type = P'media'+'context'+'area'+'region'+'macro',
      ReservedCondition = P'onBegin'+'onEnd'+'onSelection',
      ReservedAction = P'start'+'stop'+'set',
      Reserved = V'Type'+V'ReservedAction'+V'ReservedCondition'+P'do',
      Id = R('az', 'AZ', '__') * V'Alphanumerics'^0,
      PropertyValue = (V'Letter'+V'Numbers'+V'Symbols')^0,
      Property = parseTree.makeProperty( (C(V'Id') *V'Spc'^0* P':' *V'Spc'^0*
        C(P'"'*V'PropertyValue'*P'"' + V'PropertyValue') * V'Spc'^0)),

      Port = V'Spc'^0*parseTree.makePort(P'port'* V'Spc'^1 * C(V'Id') * V'Spc'^1 * C(V'Id')*(P'.'*C(V'Id'))^-1, symbolsTable, false),

      PresentationElement = V'Spc'^0* parseTree:makePresentationElement(C(V'Reserved') *V'Spc'^1 * C(V'Id') *V'Spc'^1
        *(V'PresentationElement'+V'Port'+V'Property'+V'Link'+V'MacroCall'+V'Template'+V'Spc')^0 *C(V'End'), symbolsTable, false),

      Link = V'Spc'^0*
        parseTree.makeLink((V'Condition' *V'Spc'^1* ((V'Property'+V'Action')-V'End')^0 *C(V'End')*V'Spc'^0), symbolsTable, false),
      Condition = parseTree.makeBind(V'ConditionId' *V'Spc'^1* (V'RepeatCondition'+V'Spc')^0 *P'do','condition'),
      ConditionId = parseTree.makeRelationship(C(V'Reserved') *V'Spc'^1* (C(V'Id')*(P'.'*C(V'Id'))^-1)),
      RepeatCondition = P'and' *V'Spc'^1* V'ConditionId',
      Action = parseTree.makeBind(V'ActionId' *V'Spc'^1* (V'RepeatAction'+V'Spc')^0*
        (V'Property')^0* C(V'End') *V'Spc'^0, 'action'),
      ActionId = parseTree.makeRelationship(C(V'Reserved') *V'Spc'^1* (C(V'Id')*(P'.'*C(V'Id'))^-1)),
      RepeatAction = P'and' *V'Spc'^1*V'ActionId',

      MacroPort = V'Spc'^0*parseTree.makePort(P'port'* V'Spc'^1 * C(V'Id') * V'Spc'^1 * C(V'Id')*(P'.'*C(V'Id'))^-1, symbolsTable, true),
      MacroPresentationElement = V'Spc'^0* parseTree:makePresentationElement(C(V'Reserved') *V'Spc'^1 * C(V'Id') *V'Spc'^1
        *(V'MacroPresentationElement'+V'MacroPort'+V'Property'+V'MacroLink'+V'Template'+V'MacroCall'+V'Spc')^0 *C(V'End'), symbolsTable, true),
      MacroLink = (V'Spc'^0*
        parseTree.makeLink((V'Condition' *V'Spc'^1* ((V'Property'+V'Action')-V'End')^0 *C(V'End')*V'Spc'^0), symbolsTable, true)),
      Macro = V'Spc'^0* parseTree.makeMacro(P'macro' *V'Spc'^1* C(V'Id') *V'Spc'^0* V'Parameters'
        *V'Spc'^1* V'MacroBody'^-1 *V'Spc'^0* C(V'End'), symbolsTable),
      Parameters = P'('*  Ct(Cg( Ct(V'FieldParameters'^-1 * (',' * V'FieldParameters')^0),'parameters')) * P')',
      FieldParameters = V'Spc'^0*C(V'Id')*V'Spc'^0,
      --Field = ''' * Cs(((P(1) - ''') + P'''' / ''')^0) * ''' + C((1 - S',\n)'')^0),
      MacroBody = (V'MacroPresentationElement'+V'MacroLink'+V'Template')^0,

      MacroCall = V'Spc'^0*parseTree.makeMacroCall(C(V'Id') * V'Arguments', symbolsTable),
      Arguments = P'('*  Ct(( (V'FieldArgument'^-1 * (',' * V'FieldArgument')^0)) ) * P')',
      --FieldArguments = V'Spc'^0*P'''*C((V'Letter'+V'Digit'+V'Symbols'+S'[]')^0)*P'''*V'Spc'^0,
      FieldArgument = V'Spc'^0 * C(V'Reference'+V'Passed') * V'Spc'^0,
      Passed = P'"'*V'Reference'* P'"',
      Reference = (V'Alphanumerics'+P'/'+P'%'+P'@')^1,
      -- TODO: Can accept more things other than Id

      Template = V'Spc'^0*parseTree.makeTemplate(V'For'*V'Spc'^1*V'MacroCall'^0*V'Spc'^0* C(V'End'), symbolsTable),
      For = (P'for' *V'Spc'^1* C(V'Lower'^1) *V'Spc'^0* P'='* V'Spc'^0*C(V'Digit'^1)*V'Spc'^0*P','*V'Spc'^0* P'#'*C((V'Lower'+V'Digit')^1) *V'Spc'^1* P'do'),

      START = ((V'Spc'^0
        *Ct((V'Template'+V'Port'+V'Macro'+V'PresentationElement'+V'Link'+V'MacroCall')^0) * V'Spc'^0)
        *V'EOS')
        /function()
          return symbolsTable
        end,
    }

    if gbl._DEBUG_PEG then
      symbolsTable = lpeg.match(require('pegdebug').trace(lpegGrammar), snclString)
    else
      symbolsTable = lpeg.match(lpegGrammar, snclString)
    end
    if not symbolsTable then
      error("Error generating symbol table")
    end

    return symbolsTable
  end
}

return grammar

