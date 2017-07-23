function parseId (str)
	local words = {}

	for word in str:gmatch("%S+") do -- Separar as palavras por espaco
		table.insert(words, word)
	end

	if #words == 2 then
		local id = words[2]
		return id
	else
		utils.printErro("Context nao pode ter mais de 2 Ids.")
		return nil
	end
end

function parseProperty (str)
	local sign = str:find("=")
	if sign then
		local name = str:sub(1, sign-1)
		local value = str:sub(sign+1)
		return name, value
	else
		return str
	end
end

function parseRefer (str)
	if currentElement then
		if (currentElement.getType() == "context" or 	currentElement.getType() == "media" or
				currentElement.getType() == "switch") then
			local sign = str:find("=")
			if sign then
				local value = str:sub(sign+1)
				local ponto = value:find("%.")
				local interface, media = nil, nil
				if ponto then
					interface = value:sub(ponto+1)
					media =  value:sub(1, ponto-1)
				end
				currentElement:setRefer (media, interface)
			end

		else
			utils.printErro("Refer only inside of Context, Switch or Media.", linhaParser)
		end
	else
		utils.printErro("Refer can not be declared outside of an element.", linhaParser)
	end
end

function separateByDot (str)
	local dot = str:find("%.")
	local beforeDot, afterDot = nil, nil
	if dot then
		beforeDot = str:sub(1,dot-1)
		afterDot = str:sub(dot+1)
		return beforeDot, afterDot
	else
		return str
	end
end

function parseLinkCondition (str)
	--Separar as palavras por espaco
	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, word)
	end

	if #words == 3 then
		local condition = words[1]
		local media= words[2]
		
		local condition, conditionParam = separateByDot(condition)
		local media, interface = separateByDot(media)

		if currentElement ~= nil then
			if currentElement:getType() == "link" then --Se for link, adicionar condicao
				local newCondition = Condition.new(condition, conditionParam, media, interface, linhaParser)
				newCondition:setFather(currentElement)
				currentElement:addCondition(newCondition)
			elseif currentElement.getType() == "context" then
				local newLink = Link.new(linhaParser)
				newLink:setFather(currentElement)
				currentElement:addSon(newLink)
				currentElement = newLink
				table.insert(tabelaSimbolos.body, newLink)

				local newCondition = Condition.new(condition, conditionParam, media, interface, linhaParser)
				newCondition:setFather(currentElement)
				currentElement:addCondition(newCondition)
			else
				utils.printErro("Link can only be declared inside of a Link.", linhaParser)
			end
		else
			local newLink = Link.new(linhaParser)
			newLink:setFather(currentElement)
			currentElement = newLink
			table.insert(tabelaSimbolos.body, newLink)

			local newCondition = Condition.new(condition, conditionParam, media, interface, linhaParser)
			newCondition:setFather(currentElement)
			currentElement:addCondition(newCondition)
		end
	end
end

function parseLinkAction (str)
	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, word)
	end
	local action = words[1]
	local media = words[2]
	local interface = nil

	local barra = media:find("%.")

	if barra then
		interface = media:sub(barra+1)
		media = media:sub(1, barra-1)
	end

	if currentElement ~= nil then
		if currentElement:getType() == "link" then
			local newAction = Action.new(action, media, interface, linhaParser)
			newAction:setFather(currentElement)
			currentElement:addAction(newAction)
			currentElement = newAction
		else
			utils.printErro("Action can only be declared inside of a link.", linhaParser)
		end
	else
		utils.printErro("Action can not be declared outside of a link", linhaParser)
	end
end

function parseLinkActionParam (str)
	str = str:gsub("%s+", "")
	local sign = str:find("=")
	local paramName = str:sub(1, sign-1)
	local paramValue = str:sub(sign+1)

	if currentElement ~= nil then
		if currentElement:getType() == "action" then
			currentElement:addParam(paramName, paramValue)
		else
			utils.printErro("Action parameter is not inside an action.")
		end
	else
		utils.printErro("Action parameter can only be declared inside of an action")
	end
end

function parsePort (str)
	local words = {}
	for word in str:gmatch("%S+") do
		table.insert(words, word)
	end

	local id = words[2]
	local media = words[3]
	local interface = nil

	local barra = media:find("%.")

	local newPort = nil

	if currentElement then
		if currentElement.getType() == "context" then
			newPort = Port.new(id, media, interface, currentElement, linhaParser)
			currentElement:addSon(newPort)
		else
			utils.printErro("Element can not have a port.")
		end
	else
		newPort = Port.new(id, media, nil)
	end

	if newPort ~= nil then
		tabelaSimbolos[id] = newPort
		tabelaSimbolos.body[id] = tabelaSimbolos[id]
	end
end

