local itemProps = {
    ["flag1"] = {"p_eaglependant01x", "mp001_s_mp_campflagpole01x", "prop_flag_us"},
 -- add your flag here. If you remove p_eaglependant01x, be sure to remove it from showFlag and showFlagwithoutanimation
}

local currentItem = nil 
local flag = nil
local flagOnGround = false 


local placeFlagPrompt = Uiprompt:new(`INPUT_PICKUP`, "Place flag")
local takeFlagPrompt = Uiprompt:new(`INPUT_DYNAMIC_SCENARIO`, "Take flag")
local hideFlagPrompt = Uiprompt:new(`INPUT_RELOAD`, "Hide flag")

placeFlagPrompt:setOnControlJustPressed(function(prompt)
    if flag then
        placeFlag()
    end
end)

takeFlagPrompt:setOnControlJustPressed(function(prompt)
    if flagOnGround then
        takeFlag()
    end
end)

hideFlagPrompt:setOnControlJustPressed(function(prompt)
    if flag and not flagOnGround then
        hideFlag()
    end
end)

UipromptManager:startEventThread()

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())  
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    if onScreen then
    	SetTextScale(0.40, 0.40)                                                                         
  		SetTextFontForCurrentCommand(1)
    	SetTextColor(255,255,255,255)                                                                      
    	SetTextCentre(1)
    	DisplayText(str,_x,_y)
    	local factor = (string.len(text)) / 225
        DrawSprite("feeds", "toast_bg", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 20, 20, 20, 200, 0)     
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        if flagOnGround then
            local flagCoords = GetEntityCoords(flag[2]) 
            local distance = #(playerCoords - flagCoords)
            if distance < 2.0 then
                DrawText3D(flagCoords.x, flagCoords.y, flagCoords.z + 2.5, "Press E")
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        if flag then
            local flagCoords = GetEntityCoords(flag[2]) 
            local distance = #(playerCoords - flagCoords) 
            if not flagOnGround and distance < 2.0 then
                placeFlagPrompt:setVisible(true)
                placeFlagPrompt:setEnabled(true) 
                hideFlagPrompt:setVisible(true)
                hideFlagPrompt:setEnabled(true) 
                takeFlagPrompt:setVisible(false)
                takeFlagPrompt:setEnabled(false) 
            elseif flagOnGround and distance < 2.0 then
                placeFlagPrompt:setVisible(false)
                placeFlagPrompt:setEnabled(false) 
                hideFlagPrompt:setVisible(false)
                hideFlagPrompt:setEnabled(false) 
                takeFlagPrompt:setVisible(true)
                takeFlagPrompt:setEnabled(true) 
            else
                placeFlagPrompt:setVisible(false)
                placeFlagPrompt:setEnabled(false) 
                hideFlagPrompt:setVisible(false)
                hideFlagPrompt:setEnabled(false) 
                takeFlagPrompt:setVisible(false)
                takeFlagPrompt:setEnabled(false) 
            end
        else
            placeFlagPrompt:setVisible(false)
            placeFlagPrompt:setEnabled(false) 
            hideFlagPrompt:setVisible(false)
            hideFlagPrompt:setEnabled(false) 
            takeFlagPrompt:setVisible(false)
            takeFlagPrompt:setEnabled(false) 
        end
    end
end)


function createProp(propName)
    local propHash = GetHashKey(propName)
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        Citizen.Wait(100)
    end
    local prop = CreateObject(propHash, 0, 0, 0, true, true, true)
    SetEntityAsMissionEntity(prop, true, true)
    return prop
end

function showFlag(item)
    local player = PlayerPedId()
    local props = itemProps[item]
    if props == nil then
        print("Item inconnu : " .. item)
        return
    end
    local prop1 = createProp(props[1])
    local prop2 = createProp(props[2])
    local prop3 = createProp(props[3])

    RequestAnimDict("mech_inspection@generic@lh@satchel")
    while not HasAnimDictLoaded("mech_inspection@generic@lh@satchel") do
        Citizen.Wait(100)
    end
    Citizen.InvokeNative(0xEA47FE3719165B94, player,"mech_inspection@generic@lh@satchel",  "enter", 1.0, 8.0, -1, 4, 0, 0, 0, 0)

    Citizen.Wait(1000)

    AttachEntityToEntity(prop1, player, GetEntityBoneIndexByName(player,"Skel_L_Hand"), 0.0 , -0.04 , 3.0, -99.4 , 0.0 , -69.9, false, false, false, true, 0, false) 
    AttachEntityToEntity(prop2, player, GetEntityBoneIndexByName(player,"Skel_L_Hand"), 0.0 , -0.04 , -0.72 , 0.0 , 0.0 , 0.0 , true, true, false, true, 0, false) 
    AttachEntityToEntity(prop3, player, GetEntityBoneIndexByName(player,"Skel_L_Hand"), 0.0  , -0.04 , 2.18 , 0.0 , 0.0, 0.0, true, true, false, true, 0, false) 

    flag = {prop1, prop2, prop3}
    currentItem = item 

 
    placeFlagPrompt:setVisible(true)
    takeFlagPrompt:setVisible(false)
end

function showFlagWithoutAnimation(item)
    local player = PlayerPedId()

    local props = itemProps[item]
    if props == nil then
        print("Item inconnu : " .. item)
        return
    end
    local prop1 = createProp(props[1])
    local prop2 = createProp(props[2])
    local prop3 = createProp(props[3])

    AttachEntityToEntity(prop1, player, GetEntityBoneIndexByName(player,"Skel_L_Hand"), 0.0 , -0.04 , 3.0, -99.4 , 0.0 , -69.9, false, false, false, true, 0, false) 
    AttachEntityToEntity(prop2, player, GetEntityBoneIndexByName(player,"Skel_L_Hand"), 0.0 , -0.04 , -0.72 , 0.0 , 0.0 , 0.0 , true, true, false, true, 0, false) 
    AttachEntityToEntity(prop3, player, GetEntityBoneIndexByName(player,"Skel_L_Hand"), 0.0  , -0.04 , 2.18 , 0.0 , 0.0, 0.0, true, true, false, true, 0, false) 

    flag = {prop1, prop2, prop3}
    currentItem = item 
 
    placeFlagPrompt:setVisible(true)
    takeFlagPrompt:setVisible(false)
end

function placeFlag()
    if not flagOnGround then 
    local player = PlayerPedId()
    RequestAnimDict("mech_skin@chicken@horse_satchel@stow@lt")
    while not HasAnimDictLoaded("mech_skin@chicken@horse_satchel@stow@lt") do
    Citizen.Wait(100)
    end
    Citizen.InvokeNative(0xEA47FE3719165B94, player,"mech_skin@chicken@horse_satchel@stow@lt", "fallback", 1.0, 8.0, -1, 4, 0, 0, 0, 0)
    Citizen.Wait(1000)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local zOffsets = {2.5, -1.22, 1.68}
    local forwardOffset = 0.8

       Citizen.Wait(1000)
   
    for i, prop in ipairs(flag) do
        DetachEntity(prop, true, true)
        local forwardVector = GetEntityForwardVector(PlayerPedId())
        local flagCoords = vector3(playerCoords.x + forwardVector.x * forwardOffset, playerCoords.y + forwardVector.y * forwardOffset, playerCoords.z + zOffsets[i])
        SetEntityCoords(prop, flagCoords.x, flagCoords.y, flagCoords.z)
        FreezeEntityPosition(prop, true)
    end
    flagOnGround = true 
   
    placeFlagPrompt:setVisible(false)
    takeFlagPrompt:setVisible(true)
    else
        TriggerEvent('vorp:TipRight', "Récupère le drapeau d'abord !", 3000)
    end
end

function hideFlag()
 
    if flagOnGround then 
        TriggerEvent('vorp:TipRight', "Le drapeau est au sol", 3000)
    else
    local player = PlayerPedId()
    RequestAnimDict("mech_inspection@generic@lh@satchel")
    while not HasAnimDictLoaded("mech_inspection@generic@lh@satchel") do
        Citizen.Wait(100)
    end
    Citizen.InvokeNative(0xEA47FE3719165B94, player,"mech_inspection@generic@lh@satchel", "exit_satchel", 1.0, 8.0, -1, 1, 0, 0, 0, 0)
    Citizen.Wait(1000)
    for i, prop in ipairs(flag) do 
        DeleteEntity(prop)
    end
    ClearPedTasks(player)
   
    flag = nil
    flagOnGround = false 
    end
end

function takeFlag()
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    local flagCoords = GetEntityCoords(flag[2]) 
    local distance = #(playerCoords - flagCoords) 
    if flagOnGround and distance < 2.0 then 
        local player = PlayerPedId()
        RequestAnimDict("mech_skin@chicken@horse_satchel@remove@lt")
        while not HasAnimDictLoaded("mech_skin@chicken@horse_satchel@remove@lt") do
        Citizen.Wait(100)
        end
        Citizen.InvokeNative(0xEA47FE3719165B94, player,"mech_skin@chicken@horse_satchel@remove@lt", "fallback", 1.0, 8.0, -1, 4, 0, 0, 0, 0)
        
        Citizen.Wait(1000)

        if flag then 
            for i, prop in ipairs(flag) do 
                DeleteEntity(prop)
            end
        end
        showFlagWithoutAnimation(currentItem)
        flagOnGround = false 

        placeFlagPrompt:setVisible(true)
        takeFlagPrompt:setVisible(false)
    else 
        TriggerEvent('vorp:TipRight', "Flag is to far !", 3000)
    end
end

RegisterNetEvent('event:showFlag')
AddEventHandler('event:showFlag', function(item)
    if flag then
        hideFlag()
    else  
        showFlag(item)
    end
end)

RegisterNetEvent('prop:placeFlag')
AddEventHandler('prop:placeFlag', function()
    if flag then
        placeFlag()
    else
        showFlag(currentItem)
    end
end)

RegisterCommand('placeflag', function()
    TriggerEvent('prop:placeFlag')
end, false)

RegisterCommand('takeflag', function()
    if flagOnGround then
        takeFlag(currentItem)
    end
end, false)


--[[RegisterNetEvent('event:deleteAllFlags')
AddEventHandler('event:deleteAllFlags', function()
    if flag then
        print("Suppression du drapeau...") 
        for i, prop in ipairs(flag) do 
            DeleteEntity(prop)
        end
        flag = nil
        flagOnGround = false
    end
end)]]


