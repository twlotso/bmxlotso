local chopping = false
local scrapDepo = Config.Blips.scrapDepo
local scrapProcessor = Config.Blips.scrapProcessor
local scrapSeller = Config.Blips.scrapSeller

RegisterNetEvent('ledjo-ferrailleur:getscrapStage', function(stage, state, k)
    Config.carLocations[k][stage] = state
end)

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(3)
    end
end

local function axe()
    local ped = PlayerPedId()
    local pedWeapon = GetSelectedPedWeapon(ped)

    for k, v in pairs(Config.Axe) do
        if pedWeapon == k then
            return true
        end
    end

    if Config.NotificationType == "ESX" then
        ESX.ShowNotification(Config.Alerts["error_axe"], "error", 3000)
    elseif Config.NotificationType == "ox_lib" then
        lib.notify({
            description = Config.Alerts["error_axe"],
            type = "error",
            duration = 3000,
        })
    end
end

local function Chopscrap(k)
    local animDict = "mp_ped_interaction"
    local animName = "handshake_guy_b"
    local trClassic = PlayerPedId()
    local choptime = scrapJob.ChoppingcarTimer
    chopping = true

    local success = lib.progressBar({
        duration = choptime,
        label = Config.Alerts["chopping_car"],
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            mouse = false,
            combat = true
        },
        anim = {
            dict = 'mp_ped_interaction',
            clip = 'handshake_guy_b'
        },
    })

    if success then
        TriggerServerEvent('ledjo-ferrailleur:setscrapStage', "isChopped", true, k)
        TriggerServerEvent('ledjo-ferrailleur:setscrapStage', "isOccupied", false, k)
        TriggerServerEvent('ledjo-ferrailleur:recivescrap')
        TriggerServerEvent('ledjo-ferrailleur:setChoppedTimer')
        chopping = false
        return true
    else
        ClearPedTasks(trClassic)
        TriggerServerEvent('ledjo-ferrailleur:setscrapStage', "isOccupied", false, k)
        chopping = false
        return false
    end
    TriggerServerEvent('ledjo-ferrailleur:setscrapStage', "isOccupied", true, k)
    CreateThread(function()
        while chopping do
            loadAnimDict(animDict)
            TaskPlayAnim(trClassic, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
            Wait(3000)
        end
    end)
end

RegisterNetEvent('ledjo-ferrailleur:StartChopping', function()
    for k, v in pairs(Config.carLocations) do
        if not Config.carLocations[k]["isChopped"] then
            if axe() then
                Chopscrap(k)
            end
        end
    end
end)

if Config.Job then
    CreateThread(function()
        for k, v in pairs(Config.carLocations) do
            exports["qtarget"]:AddBoxZone("cars" .. k, v.coords, 1.5, 1.5, {
                name = "cars" .. k,
                heading = 40,
                minZ = v.coords["z"] - 2,
                maxZ = v.coords["z"] + 2,
                debugPoly = false
            }, {
                options = {
                    {
                        action = function()
                            if axe() then
                                Chopscrap(k)
                            end
                        end,
                        event = "ledjo-ferrailleur:StartChopping",
                        icon = "fa fa-hand",
                        label = Config.Alerts["car_label"],
                        job = "scrapjack",
                        canInteract = function()
                            if v["isChopped"] or v["isOccupied"] then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.0
            })

        end
    end)
    exports['qtarget']:AddBoxZone("scrapjackdepo", scrapDepo.targetZone, 1, 1, {
        name = "scrapjackdepo",
        heading = scrapDepo.targetHeading,
        debugPoly = false,
        minZ = scrapDepo.minZ,
        maxZ = scrapDepo.maxZ,
    }, {
        options = {
            {
                event = "ledjo-ferrailleur:bossmenu",
                icon = "Fas Fa-hands",
                label = Config.Alerts["depo_label"],
                job = "scrapjack",
            },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("scrapProcessor", scrapProcessor.targetZone, 1, 1, {
        name = "scrapProcessor",
        heading = scrapProcessor.targetHeading,
        debugPoly = false,
        minZ = scrapProcessor.minZ,
        maxZ = scrapProcessor.maxZ,
    }, {
        options = {
            {
                event = "ledjo-ferrailleur:processormenu",
                icon = "Fas Fa-hands",
                label = Config.Alerts["mill_label"],
                job = "scrapjack",
            },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("scrapSeller", scrapSeller.targetZone, 1, 1, {
        name = "scrapProcessor",
        heading = scrapSeller.targetHeading,
        debugPoly = false,
        minZ = scrapSeller.minZ,
        maxZ = scrapSeller.maxZ,
    }, {
        options = {
            {
                type = "server",
                event = "ledjo-ferrailleur:sellItems",
                icon = "fa fa-usd",
                label = Config.Alerts["scrap_Seller"],
                job = "scrapjack",
            },
        },
        distance = 1.0
    })
else
    CreateThread(function()
        for k, v in pairs(Config.carLocations) do
            exports["qtarget"]:AddBoxZone("cars" .. k, v.coords, 1.5, 1.5, {
                name = "cars" .. k,
                heading = 40,
                minZ = v.coords["z"] - 2,
                maxZ = v.coords["z"] + 2,
                debugPoly = false
            }, {
                options = {
                    {
                        action = function()
                            if axe() then
                                Chopscrap(k)
                            end
                        end,
                        type = "client",
                        event = "ledjo-ferrailleur:StartChopping",
                        icon = "fa fa-hand",
                        label = Config.Alerts["car_label"],
                        canInteract = function()
                            if v["isChopped"] or v["isOccupied"] then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.0
            })

        end
    end)
    exports['qtarget']:AddBoxZone("scrapjackdepo", scrapDepo.targetZone, 1, 1, {
        name = "scrapjackdepo",
        heading = scrapDepo.targetHeading,
        debugPoly = false,
        minZ = scrapDepo.minZ,
        maxZ = scrapDepo.maxZ,
    }, {
        options = {
        {
          type = "client",
          event = "ledjo-ferrailleur:bossmenu",
          icon = "Fas Fa-hands",
          label = Config.Alerts["depo_label"],
        },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("scrapProcessor", scrapProcessor.targetZone, 1, 1, {
        name = "scrapProcessor",
        heading = scrapProcessor.targetHeading,
        debugPoly = false,
        minZ = scrapProcessor.minZ,
        maxZ = scrapProcessor.maxZ,
    }, {
        options = {
        {
          type = "client",
          event = "ledjo-ferrailleur:processormenu",
          icon = "Fas Fa-hands",
          label = Config.Alerts["mill_label"],
        },
        },
        distance = 1.0
    })
    exports['qtarget']:AddBoxZone("scrapSeller", scrapSeller.targetZone, 1, 1, {
        name = "scrapProcessor",
        heading = scrapSeller.targetHeading,
        debugPoly = false,
        minZ = scrapSeller.minZ,
        maxZ = scrapSeller.maxZ,
    }, {
        options = {
        {
          type = "server",
          event = "ledjo-ferrailleur:sellItems",
          icon = "fa fa-usd",
          label = Config.Alerts["scrap_Seller"],
        },
        },
        distance = 1.0
    })
end

RegisterNetEvent('ledjo-ferrailleur:vehicle', function()
    local vehicle = scrapDepo.Vehicle
    local coords = scrapDepo.VehicleCoords
    local TR = PlayerPedId()
    RequestModel(vehicle)
    while not HasModelLoaded(vehicle) do
        Wait(0)
    end
    if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
        local JobVehicle = CreateVehicle(vehicle, coords, 45.0, true, false)
        SetVehicleHasBeenOwnedByPlayer(JobVehicle,  true)
        SetEntityAsMissionEntity(JobVehicle,  true,  true)
        Config.FuelSystem(JobVehicle, 100.0)
        local id = NetworkGetNetworkIdFromEntity(JobVehicle)
        DoScreenFadeOut(1500)
        Wait(1500)
        SetNetworkIdCanMigrate(id, true)
        TaskWarpPedIntoVehicle(TR, JobVehicle, -1)
        DoScreenFadeIn(1500)
    else
        if Config.NotificationType == "ESX" then
            ESX.ShowNotification(Config.Alerts["depo_blocked"], "error", 3000)
        elseif Config.NotificationType == "ox_lib" then
            lib.notify({
                description = Config.Alerts["depo_blocked"],
                type = "error",
                duration = 3000,
            })
        end
    end
end)

RegisterNetEvent('ledjo-ferrailleur:removevehicle', function()
    local TR92 = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(TR92,true)
    SetEntityAsMissionEntity(TR92,true)
    DeleteVehicle(vehicle)
    if Config.NotificationType == "ESX" then
        ESX.ShowNotification(Config.Alerts["depo_stored"], "success", 3000)
    elseif Config.NotificationType == "ox_lib" then
        lib.notify({
            description = Config.Alerts["depo_stored"],
            type = "success",
            duration = 3000,
        })
    end
end)

RegisterNetEvent('ledjo-ferrailleur:getaxe', function()
    TriggerServerEvent('ledjo-ferrailleur:BuyAxe')
end)

RegisterNetEvent('ledjo-ferrailleur:bossmenu', function()
    if Config.UseOxLib then
        print('kokot')
        lib.registerContext({
            id = 'ledjo-ferrailleur:bossmenu',
            title = Config.Alerts["vehicle_header"],
            options = {
                -- {
                --     title = Config.Alerts["vehicle_text"],
                --     event = 'ledjo-ferrailleur:vehicle',
                -- },
                -- {
                --     title = Config.Alerts["remove_text"],
                --     event = 'ledjo-ferrailleur:removevehicle',
                -- },
                {
                    title = Config.Alerts["battleaxe_text"],
                    event = 'ledjo-ferrailleur:getaxe',
                },
            },
        })
        lib.showContext('ledjo-ferrailleur:bossmenu')
    elseif not Config.UseOxLib then
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_menu', {
            title    = Config.Alerts["vehicle_header"],
            align    = 'top-left',
            elements = {
                {label = Config.Alerts["vehicle_text"], event = 'ledjo-ferrailleur:vehicle'},
                {label = Config.Alerts["remove_text"], event = 'ledjo-ferrailleur:removevehicle'},
                {label = Config.Alerts["battleaxe_text"], event = 'ledjo-ferrailleur:getaxe'},
        }}, function(data, menu)
            TriggerEvent(data.current.event)
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end
end)

RegisterNetEvent('ledjo-ferrailleur:processormenu', function()
    if Config.UseOxLib then
        lib.registerContext({
            id = 'ledjo-ferrailleur:processormenu',
            title = Config.Alerts["scrap_mill"],
            options = {
                {
                    title = Config.Alerts["scrap_text"],
                    event = 'ledjo-ferrailleur:processor',
                    description = Config.Alerts["scrap_text_description"],
                    metadata = {Config.Alerts["scrap_text_description_meta_data"]},
                },
            },
        })
        lib.showContext('ledjo-ferrailleur:processormenu')
    elseif not Config.UseOxLib then
        print('Server not using Ox Lib')
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_menu', {
            title    = Config.Alerts["scrap_mill"],
            align    = 'top-left',
            elements = {
                {label = Config.Alerts["scrap_text"], event = 'ledjo-ferrailleur:processor'},
                {label = Config.Alerts["remove_text"], event = 'ledjo-ferrailleur:removevehicle'},
                {label = Config.Alerts["battleaxe_text"], event = 'ledjo-ferrailleur:getaxe'},
        }}, function(data, menu)
            TriggerEvent(data.current.event)
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
    end
end)

RegisterNetEvent('ledjo-ferrailleur:processor', function()
    ESX.TriggerServerCallback('ledjo-ferrailleur:scrap', function(scrap)
        if scrap then
            local success = lib.progressBar({
                duration = scrapJob.ProcessingTime,
                label = Config.Alerts['scrap_progressbar'],
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    mouse = false,
                    combat = true
                },
                anim = {
                    dict = 'missheistdockssetup1clipboard@idle_a',
                    clip = 'idle_a'
                },
            })
        
            if success then
                TriggerServerEvent("ledjo-ferrailleur:scrapprocessed")
                return true
            else
                if Config.NotificationType == "ESX" then
                    ESX.ShowNotification(Config.Alerts['cancel'], "error", 3000)
                elseif Config.NotificationType == "ox_lib" then
                    lib.notify({
                        description = Config.Alerts['cancel'],
                        type = "error",
                        duration = 3000,
                    })
                end
                return false
            end
        else
            if Config.NotificationType == "ESX" then
                ESX.ShowNotification(Config.Alerts['error_scrap'], "error", 3000)
            elseif Config.NotificationType == "ox_lib" then
                lib.notify({
                    description = Config.Alerts['error_scrap'],
                    type = "error",
                    duration = 3000,
                })
            end
        end
    end)
end)
