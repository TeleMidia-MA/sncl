lpeg.locale(lpeg)
local S, R, V, P = lpeg.S, lpeg.R, lpeg.V, lpeg.P
local Cg, Ct, C = lpeg.Cg, lpeg.Ct, lpeg.C

local SPC = V"Espacos"

currentElement = nil

snclGrammar = {
	"INICIAL";

	------ Bases ------
	OnlyEspace = P" ",
	Espacos = lpeg.space
	/function(str)
		if str == "\n" then
			linhaParser = linhaParser+1
		end
	end,
	Inteiro = R("09"),
	Alpha =  (R"az"+R"AZ"),
	AlphaNumeric = (V"Alpha"+P"@"+P"_"+P"/"+P"."+P"%"+P","+P"-"+V"Inteiro"),
	AlphaNumericSpace = (V"Alpha"+P"_"+P"/"+P"."+P"%"+P","+V"Inteiro"+SPC)^1,
	AlphaSpaces = (R"az"+R"AZ"+SPC)^1,
	String = (P"\""*V"AlphaNumericSpace"^-1*P"\""),

	End = (P"end" *(SPC)^0)
	/function()
		if currentElement ~= nil then
			currentElement:setEnd(true)
			if currentElement:getFather() == nil then
				currentElement = nil
			else
				currentElement = currentElement:getFather()
			end
		end
	end,

	------ REGION ------
	RegionId = (P"region" *V"OnlyEspace"^1 *V"AlphaNumeric"^1 *SPC^0)
	/function(str)
		local id = parseId(str)
		if tabelaSimbolos[id] == nil then
			local newRegion = Region.new(id)
			tabelaSimbolos[id] = newRegion
			tabelaSimbolos.regions[id] = tabelaSimbolos[id]
			if currentElement ~= nil then
				newRegion:setFather(currentElement)
				currentElement:addSon(newRegion)
				currentElement = newRegion
			else
				currentElement = newRegion
			end
		else
			utils.printErro("Id "..id.." already declared.")
		end
	end,
	RegionProperty = (V"AlphaNumeric"^1 *V"OnlyEspace"^0* P"=" *V"OnlyEspace"^0*V"String"*SPC^0)
	/function(str)
		str = str:gsub("%s+", "")
		local name, value = parseProperty(str)
		if currentElement ~= nil then
			currentElement:addProperty(name, value)
		else
			utils.printErro("No element")
		end
	end,
	Region = (V"RegionId" * (V"Region"+V"RegionProperty")^0 * V"End"^-1),
	------ REGION ------

	------ AREA ------
	AreaId = (P"area" *V"OnlyEspace"^1* V"AlphaNumeric"^1 *SPC^0)
	/function(str)
		local id = parseId(str)
		if tabelaSimbolos[id] == nil then
			local newArea = Area.new(id)
			tabelaSimbolos[id] = newArea
			tabelaSimbolos.body[id] = tabelaSimbolos[id]
			if currentElement ~= nil then
				newArea:setFather(currentElement)
				currentElement:addSon(newArea)
				currentElement = newArea
			else
				currentElement = newArea
			end
		else
			utils.printErro("Id "..id.." already declared.")
		end
	end,
	AreaProperty = (V"AlphaNumeric"^1*V"OnlyEspace"^0*P"="*V"OnlyEspace"^0*V"String"*SPC^0)
	/function(str)
		str = str:gsub("%s+", "")
		local name, value = parseProperty(str)
		if currentElement ~= nil then
			currentElement:addProperty(name, value)
		else
			utils.printErro("No element.")
		end
	end,
	Area = (V"AreaId" * V"AreaProperty"^0 *V"End"^-1),
	------ AREA ------

	------ MEDIA ------
	MediaId = (P"media" *V"OnlyEspace"^1* V"AlphaNumeric"^1 *SPC^0)
	/function(str)
		local id = parseId(str)
		if tabelaSimbolos[id] == nil then
			local newMedia = Media.new(id)
			tabelaSimbolos[id] = newMedia
			tabelaSimbolos.body[id] = tabelaSimbolos[id]
			if currentElement ~= nil then
				newMedia:setFather(currentElement)
				currentElement:addSon(newMedia)
				currentElement = newMedia
			else
				currentElement = newMedia
			end
		else
			utils.printErro("Id "..id.." already declared.")
		end
	end,
	MediaRegion = (P"rg" *V"OnlyEspace"^0* P"=" *V"OnlyEspace"^0* V"AlphaNumeric"^1 *SPC^0)
	/function(str)
		str = str:gsub("%s+", "")
		local name, value = parseProperty(str)
		if currentElement ~= nil then
			currentElement:addProperty(name, value)
		else
			utils.printErro("No element")
		end
	end,
	MediaProperty = (V"AlphaNumeric"^1 *V"OnlyEspace"^0* P"=" *V"OnlyEspace"^0*V"String"*SPC^0)
	/function(str)
		str = str:gsub("%s+", "")
		local name, value = parseProperty(str)
		if currentElement ~= nil then
			currentElement:addProperty(name, value)
		else
			utils.printErro("No element")
		end
	end,
	Media = (V"MediaId" * (V"Area"+V"MediaRegion"+V"MediaProperty")^0 * V"End"^-1),
	------ MEDIA ------

	------ CONTEXT ------
	ContextId = (P"context"*V"OnlyEspace"^1*V"AlphaNumeric"^1*SPC^0)
	/function(str)
		local id = parseId(str)
		if tabelaSimbolos[id] == nil then
			local newContext = Context.new(id)
			tabelaSimbolos[id] = newContext
			tabelaSimbolos.body[id] = tabelaSimbolos[id]
			if currentElement ~= nil then --Se tiver dentro de um elemento
				newContext:setFather(currentElement)
				currentElement:addSon(newContext)
				currentElement = newContext
			else --Se tiver fora de um elemento
				currentElement = newContext
			end
		else
			utils.printErro("Id "..id.." already declared.")
		end
	end,
	ContextProperty = (V"AlphaNumeric"^1*V"OnlyEspace"^0*P"="*V"OnlyEspace"^0*V"String"*SPC^0)
	/function(str)
		str = str:gsub("%s+", "")
		local name, value = parseProperty(str)
		if currentElement ~= nil then
			currentElement:addProperty(name, value)
		else
			utils.printErro("No element.")
		end
	end,
	Context = (V"ContextId" *(V"Port"+V"ContextProperty"+ V"Media"+V"Context")^0*V"End"^-1),
	------ CONTEXT ------

	------ ACTION ------
	ActionMedia = (V"AlphaNumeric"^1 *V"OnlyEspace"^1* V"AlphaNumeric"^1 *SPC^1)
	/function(str)
		parseLinkAction(str)
	end,
	ActionParam = (V"AlphaNumeric"^1 *V"OnlyEspace"^0* P"=" *V"OnlyEspace"^0* V"String"* SPC^0)
	/function(str)
		parseLinkActionParam(str)
	end,
	Action = ( V"ActionMedia"*V"ActionParam"^0 *V"End"^-1),
	------ ACTION ------

	------ LINK ------
	LinkCondition = (V"AlphaNumeric"^1 *V"OnlyEspace"^1* V"AlphaNumeric"^1* V"OnlyEspace"^0 *(P"and"+P"do")*V"OnlyEspace"^0 )
	/function(str)
		--print("LinkCondition: "..str)
		parseLinkCondition(str)
	end,
	LinkDo = ( (V"LinkCondition")^1 *SPC^0) 
	/function(str)
	end,
	LinkParam = (V"AlphaNumeric"^1 *V"OnlyEspace"^0* P"=" *V"OnlyEspace"^0* P"\""* V"AlphaNumericSpace"^-1 *P"\""* SPC^0)
	/function(str)
		parseLinkConditionParam(str)
		--print("LinkParam: "..str)
	end,
	Link = (V"LinkDo" *(V"Action"+V"LinkParam")^0 *V"End"^-1),
	------ LINK ------

	Port = (P"port" *V"OnlyEspace"^1* V"AlphaNumeric"^1*V"OnlyEspace"^1* V"AlphaNumeric"^1*SPC^0)
	/function(str)
		parsePort(str)
	end,

	-- START --
	INICIAL = SPC^0 * (V"Port"+V"Region"+V"Media"+V"Context"+V"Link")^0,
}
