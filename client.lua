-- client.lua
local armedState = false
local customCam  = nil

-- head bone ID
local HEAD_BONE  = 12844  

-- tweak these for your perfect view:
local OFFSET_X = 0.00   -- right (+) / left (-)
local OFFSET_Y = 0.00   -- forward (+) / back (-)
local OFFSET_Z = -0.05  -- up (+) / down (-)
local CAM_FOV  = 75.0   -- ? zoom out to see more arm, ? zoom in

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        if not DoesEntityExist(ped) or IsEntityDead(ped) then goto cont end

        local wep     = GetSelectedPedWeapon(ped)
        local isArmed = wep ~= GetHashKey("WEAPON_UNARMED")

        if isArmed and not armedState then
            -- DRAW
            armedState = true

            -- spawn & activate our custom camera
            customCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            SetCamFov(customCam, CAM_FOV)
            SetCamActive(customCam, true)
            RenderScriptCams(true, false, 0, true, true)

        elseif not isArmed and armedState then
            -- HOLSTER
            armedState = false

            -- tear down and go back to the normal game camera
            RenderScriptCams(false, false, 0, true, true)
            if customCam then
                DestroyCam(customCam, false)
                customCam = nil
            end
        end

        if armedState and customCam then
            -- 1) position the cam at your head bone + offsets
            local pos = GetPedBoneCoords(ped, HEAD_BONE, OFFSET_X, OFFSET_Y, OFFSET_Z)
            SetCamCoord(customCam, pos.x, pos.y, pos.z)

            -- 2) pull the player's body rotation back to how it was (optional)
            --    Uncomment these lines if you still want to prevent body spin:
            -- local heading = GetEntityHeading(ped)
            -- SetEntityHeading(ped, heading)

            -- 3) let the user control the camera: match it to the standard gameplay cam's rotation
            local rot = GetGameplayCamRot(2)  
            SetCamRot(customCam, rot.x, rot.y, rot.z, 2)
        end

        ::cont::
    end
end)
