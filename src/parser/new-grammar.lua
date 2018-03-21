local lpeg = require"lpeg"
local inspect = require"inspect"

local line = 1

--[[
-- V = variable
-- P
-- R = Range(Any char in the range)
-- C = capture
-- S = Set(Any char in the set)
-- Ct = Table Capture
--]]
local V, P, R, C, S = lpeg.V, lpeg.P, lpeg.R, lpeg.C, lpeg.S

local Ct, Cg, Cs = lpeg.Ct, lpeg.Cg, lpeg.Cs

function makeProperty(str)
   return str / function(name, value)
      return {_type="property",name=name, value = value}
   end
end

function makePresentationElement(str)
   return str / function(_type, id, ...)
      local tb = {...}
      local element = {_type=_type, id=id, hasEnd = tb[#tb], ...}
      table.remove(element, #element) -- Remover o "end"
      return element
   end
end

function makeRelationship(str)
   return str/ function(role, media, ...)
      local tb = {...}
      return {role=role, component=media}
   end
end
function makeRelationshipElement(str, _type)
   return str/function(...)
      local tb = {...}
      local element = {_type = _type,...}
      --print_table(element)
      return element
   end
end

grammar = require('pegdebug').trace({
   "START";
   Any = P(1),
   EOS = -V"Any",
   Spc = S(" \t\n")
   /function(st)
      if st == '\n' then
         line = line+1
      end
   end,
   Digit = R("09"),
   Lower = R("az"),
   Upper = R("AZ"),
   Letter = V"Lower" + V"Upper",
   Alnum = R("az", "AZ", "09", "__"),
   Num = P("0x") * R("09", "af", "AF") ^ 1 * (S("uU") ^ -1 * S("lL") ^ 2) ^ -1 + R("09") ^ 1 * (S("uU") ^ -1 * S("lL") ^ 2) + (R("09") ^ 1 * (P(".") * R("09") ^ 1) ^ -1 + P(".") * R("09") ^ 1) * (S("eE") * P("-") ^ -1 * R("09") ^ 1) ^ -1,

   End = P"end"
   /function()
   end,
   Reserved = (P"media"+"context"+"area"+"region"+"onBegin"+"onEnd"+"start"+"stop"+"do"),
   Id = (R("az", "AZ", "__") * V"Alnum"^0),

   PresentationElement = V"Spc"^0*makePresentationElement(C(V"Reserved") *V"Spc"^1 * C(V"Id") *V"Spc"^1
   *(V"PresentationElement" + V"Property"+V"Spc")^0
   *C(V"End")),

   PropertyValue = (V"Letter"+V"Num")^1,
   Property = makeProperty( (C(V"Id") *V"Spc"^0* P":" *V"Spc"^0* C(V"PropertyValue") * V"Spc"^0) ),

   Condition = makeRelationshipElement(V"ConditionId" *V"Spc"^1* (V"RepeatCondition"+V"Spc")^0 *P"do","condition"),
   ConditionId = makeRelationship(C(V"Reserved") *V"Spc"^1* C(V"Id"), "condition"),
   RepeatCondition = P"and" *V"Spc"^1* V"ConditionId",

   Action = makeRelationshipElement(V"ActionId" *V"Spc"^1* (V"RepeatAction"+V"Spc")^0*
      (V"Property")^0* 
      C(V"End") *V"Spc"^0, "action"),
   RepeatAction = (P"and" *V"Spc"^1*V"ActionId"),
   ActionId = makeRelationship(C(V"Reserved") *V"Spc"^1* C(V"Id"),"action"),

   Link = V"Spc"^0*Ct(V"Condition" *V"Spc"^1* ((V"Property"+V"Action")-V"End")^0 *C(V"End")*V"Spc"^0),

   START = V"Spc"^0*Ct((V"PresentationElement"+V"Link")^1) * V"Spc"^0
   /function(str, str1)
      print_table(str)
      print("Line:", line)
   end,

   -- START =  Ct((V"PresentationElement"+V"Spc")^1 * V"EOS")
   -- /function(a1, a2)
   --    print"============================================"
   --    print"START:"
   --    print_table(a1)
   -- end,
})


function print_table(node)
    -- to make output beautiful
    local function tab(amt)
        local str = ""
        for i=1,amt do
            str = str .. "\t"
        end
        return str
    end

    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. tab(depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. tab(depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. tab(depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. tab(depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    print(output_str)
end
