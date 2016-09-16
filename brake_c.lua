local alpha = 100 -- MARKER ALPHA

function table.removeValue(theTable,value)
	for index, tableVal in ipairs(theTable) do
		if tableVal == value then
			table.remove(theTable,index)
		end
	end
end
function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

local streamedInCars = {}
function onCarStreamIn()
	if getElementType(source) ~= "vehicle" then return end
	if getVehicleType(source) ~= "Automobile" then return end
	table.removeValue(streamedInCars,source)
	table.insert(streamedInCars,source)
end
addEventHandler("onClientElementStreamIn",root,onCarStreamIn)


function onCarStreamOut()
	if getElementType(source) ~= "vehicle" then return end
	table.removeValue(streamedInCars,source)
end
addEventHandler("onClientElementStreamOut",root,onCarStreamOut)
addEventHandler("onClientElementDestroy",root,onCarStreamOut)



function addAllStreamedInCars()
	for _, veh in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(veh) and getVehicleType(veh) == "Automobile" then
			table.insert(streamedInCars,veh)
		end
	end
end
addAllStreamedInCars()

function destroyDataElement(element,data)
	if not element or not isElement(element) then return end
	if not getElementData(element,data) then return end
	if isElement(getElementData(element,data)) then
		destroyElement(getElementData(element,data))
	end
	setElementData(element,data,false,false)
end

function destroyCoronaElement(element,data)
	if not element or not isElement(element) then return end
	if not getElementData(element,data) then return end
	if isElement(getElementData(element,data)) then
		exports.custom_coronas:destroyCorona(getElementData(element,data))
	end
	setElementData(element,data,false,false)
end



function handleAllVehicles()
	for _, veh in ipairs(streamedInCars) do
		checkForBraking(veh)
	end
end
addEventHandler("onClientPreRender",root,handleAllVehicles)



function getVehicleGear(veh)    
    if (veh) then
        local vehicleGear = getVehicleCurrentGear(veh)
        
        return tonumber(vehicleGear)
    else
        return 0
    end
end


function drawCoronaPosition(veh)

local model = getElementModel(veh)

local corona1,corona2,corona3,corona4 = getElementData(veh,"leftlight"), getElementData(veh,"rightlight"),getElementData(veh,"leftlight2"), getElementData(veh,"rightlight2")

corona1x,corona1y,corona1z = getPositionFromElementOffset(veh,lights_table[model .. "x"],lights_table[model .. "y"],lights_table[model .. "z"])
corona2x,corona2y,corona2z = getPositionFromElementOffset(veh,lights_table[model .. "x2"],lights_table[model .. "y2"],lights_table[model .. "z2"])

exports.custom_coronas:setCoronaPosition(corona1,corona1x,corona1y,corona1z)
exports.custom_coronas:setCoronaPosition(corona2,corona2x,corona2y,corona2z)


if lights_table[model .. "x3"] then
corona3x,corona3y,corona3z = getPositionFromElementOffset(veh,lights_table[model .. "x3"],lights_table[model .. "y3"],lights_table[model .. "z3"])
corona4x,corona4y,corona4z = getPositionFromElementOffset(veh,lights_table[model .. "x4"],lights_table[model .. "y4"],lights_table[model .. "z4"])

exports.custom_coronas:setCoronaPosition(corona3,corona3x,corona3y,corona3z)
exports.custom_coronas:setCoronaPosition(corona4,corona4x,corona4y,corona4z)
end




end


function checkForBraking(veh)
    local ped = getVehicleOccupant(veh,0)
	if not ped then return end
	local model = getElementModel(veh)
	if not lights_table[model .. "x"] then return end
	
    if getPedControlState(ped,"brake_reverse") then
        if not isElement(getElementData(veh,"leftlight")) then
        setElementData(veh,"leftlight",exports.custom_coronas:createCorona(1, 1, 1, 0.4, 220,0,0,alpha),false)
        setElementData(veh,"rightlight",exports.custom_coronas:createCorona(1, 1, 1, 0.4, 220,0,0,alpha),false)
		setElementData(veh,"leftlight2",exports.custom_coronas:createCorona(1, 1, 1, 0.4, 220,0,0,alpha),false)
		setElementData(veh,"rightlight2",exports.custom_coronas:createCorona(1, 1, 1, 0.4, 220,0,0,alpha),false)
	
		
		end
		drawCoronaPosition(veh)
    end
	
	if getVehicleGear(veh) == 0 then
		exports.custom_coronas:setCoronaColor(getElementData(veh,"leftlight"),255, 255, 255, alpha)
		exports.custom_coronas:setCoronaColor(getElementData(veh,"rightlight"),255, 255, 255, alpha)
		exports.custom_coronas:setCoronaColor(getElementData(veh,"leftlight2"),255, 255, 255, alpha)
		exports.custom_coronas:setCoronaColor(getElementData(veh,"rightlight2"),255, 255, 255, alpha)
	else
		exports.custom_coronas:setCoronaColor(getElementData(veh,"leftlight"),220,0,0,alpha)
		exports.custom_coronas:setCoronaColor(getElementData(veh,"rightlight"),220,0,0,alpha)
		exports.custom_coronas:setCoronaColor(getElementData(veh,"leftlight2"),220,0,0,alpha)
		exports.custom_coronas:setCoronaColor(getElementData(veh,"rightlight2"),220,0,0,alpha)
	end
	
	if getPedControlState(ped,"brake_reverse") == false then
        destroyCoronaElement(veh,"leftlight")
        destroyCoronaElement(veh,"rightlight")
        destroyCoronaElement(veh,"leftlight2")
        destroyCoronaElement(veh,"rightlight2")
	end
end
