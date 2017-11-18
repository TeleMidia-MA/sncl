sNCL full grammar specification
===============================

This page presents the grammar of the language. It follows the specification
used in LPeg, the tool used in the compiler for grammar especification. 

An **"+"** between elements means an *or*, an **"\*"** means an *and*.

**"("** and **")"** group elements together, and the repetition of the group,
or of a single element, is represented using the **"^"** operator, **"^1"**
means *one or more*, **"^0"** means *0 or more*, and **"^-1"** means *one or
none*.

Elements between "" are literals, the others are non-terminal.

::

   Start = (Comentario + Context + Media + Area + Port + Region + Link + Macro)^0

   Comentario = "--" * (AlphaNumeric + Punctuation)^0
   Propriedade = AlphaNumeric * ":" * (String + AlphaNumeric)

   Context = "context" * Id * (Comentario + Port + Propriedade + Media + Context + Link + MacroCall)^0 * "end"

   Media = "media" * Id *(Comentario + MacroCall + Area + Propriedade)^0 * end

   Area = "area" * Id * (Comentario + Propriedade)^0 * "end"

   Port = "port" * Id * AlphaNumeric

   Region = "region" * Id * (Comentario + Region + Propriedade + MacroCall)^0 * "end"

   Link = Condition^1 * (Comentario + Propriedade + Action)^0 * end

   Condition = AlphaNumeric * Id * TermCond
   TermCond = ("and" * Condition) + ("do")

   Action = AlphaNumeric * Id * (Comentario + Propriedade) * "end"

   Macro = "macro" Id * (Comentario * MacroCall * Propriedade + Media + Area + Context + Link + Port + Region)^0 * "end"

   MacroCall = "*" * AlphaNumeric * "(" * Params^-1 * ")"

   Params = AlphaNumeric * ("," * AlphaNumeric)^0


