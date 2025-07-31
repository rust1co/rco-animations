local RSGCore = exports['rsg-core']:GetCoreObject()

local currentAnim = nil
local currentScenario = nil
local isAnimating = false
local isScenarioActive = false
local uiOpened = false
local testPed = nil
local testPedFemale = nil

local MALE_MODEL = GetHashKey(Config.MalePed)
local FEMALE_MODEL = GetHashKey(Config.FemalePed)

local function getEntityType(scenario)
    if scenario:find("WORLD_ANIMAL_") then
        return "animal"
    elseif scenario:find("PROP_") then
        return "prop"
    else
        return "ped"
    end
end

local function getAnimalModel(scenario)
    local animalName = scenario:match("WORLD_ANIMAL_(%w+)_")
    if not animalName then
        return `A_C_DOG`
    end
    local animalModelMap = {
        ["BEAR"] = `A_C_BEAR_01`,
        ["BEARBLACK"] = `A_C_BEAR_01`,
        ["BULL"] = `A_C_BULL_01`,
        ["COW"] = `A_C_COW`,
        ["BUFFALO"] = `A_C_BUFFALO_01`,
        ["DEER"] = `A_C_DEER`,
        ["ELK"] = `A_C_ELK_01`,
        ["MOOSE"] = `A_C_MOOSE_01`,
        ["HORSE"] = `A_C_HORSE`,
        ["DONKEY"] = `A_C_DONKEY_01`,
        ["BEAVER"] = `A_C_BEAVER_01`,
        ["GOAT"] = `A_C_GOAT_01`,
        ["PIG"] = `A_C_PIG_01`,
        ["SHEEP"] = `A_C_SHEEP_01`,
        ["DOG"] = `A_C_DOG`,
        ["WOLF"] = `A_C_WOLF`,
        ["COYOTE"] = `A_C_COYOTE_01`,
        ["FOX"] = `A_C_FOX_01`,
        ["BIG_CAT"] = `A_C_PANTHER_01`,
        ["PANTHER"] = `A_C_PANTHER_01`,
        ["COUGAR"] = `A_C_COUGAR_01`,
        ["POSSUM"] = `A_C_POSSUM_01`,
        ["RABBIT"] = `A_C_RABBIT_01`,
        ["RAT"] = `A_C_RAT_01`,
        ["EAGLE"] = `A_C_EAGLE_01`,
        ["CROW"] = `A_C_CROW_01`,
        ["PIGEON"] = `A_C_PIGEON_01`,
        ["SPARROW"] = `A_C_SPARROW_01`,
        ["PARROT"] = `A_C_PARROT_01`,
        ["HERON"] = `A_C_HERON_01`,
        ["DUCK"] = `A_C_DUCK_01`,
        ["BAT"] = `A_C_BAT_01`
    }
    local model = animalModelMap[animalName]
    if model then
        return model
    else
        return `A_C_DOG`
    end
end

local function getPropModel(scenario)
    local propModels = {
        ["PROP_HUMAN_SEAT_CHAIR_SHARPEN_AXE"] = `P_GRINDINGWHEEL01X`,
        ["PROP_HUMAN_REPAIR_WAGON_WHEEL_ON_LARGE"] = `P_WAGONWHEEL01X`,
        ["PROP_HUMAN_SEAT_CHAIR_READING"] = `P_CHAIR01X`,
        ["PROP_HUMAN_SEAT_CHAIR_KNIFE_BADASS"] = `P_CHAIR01X`,
        ["PROP_HUMAN_SEAT_BENCH_HARMONICA"] = `P_BENCH01X`,
        ["PROP_HUMAN_CAULDRON_SERVE_STEW"] = `P_CAULDRON01X`,
        ["PROP_HUMAN_CAULDRON_STIR"] = `P_CAULDRON01X`,
        ["PROP_CAMP_FIRE_SEATED_TEND_FIRE"] = `P_CAMPFIRE01X`,
        ["PROP_HUMAN_SEAT_CHAIR_TABLE_DRINKING_MOONSHINE"] = `P_TABLE01X`,
        ["PROP_PLAYER_MOONSHINE_SELF_SERVE_BAR"] = `P_BAR01X`,
        ["PROP_PLAYER_WASH_FACE_BARREL"] = `P_BARREL01X`,
        ["PROP_PLAYER_OPEN_CASHBOX"] = `P_CASHBOX01X`,
        ["PROP_PLAYER_PRPTY_SAVE_GAME"] = `P_SAVEGAME01X`
    }
    return propModels[scenario] or `P_CHAIR01X`
end

local function deleteTestPed()
    if testPed and DoesEntityExist(testPed) then
        if currentAnim then
            StopAnimTask(testPed, currentAnim.dict, currentAnim.name, 1.0)
        end
        if currentScenario then
            ClearPedTasksImmediately(testPed)
        end
        DeletePed(testPed)
        testPed = nil
    end
    if testPedFemale and DoesEntityExist(testPedFemale) then
        if currentAnim then
            StopAnimTask(testPedFemale, currentAnim.dict, currentAnim.name, 1.0)
        end
        if currentScenario then
            ClearPedTasksImmediately(testPedFemale)
        end
        DeletePed(testPedFemale)
        testPedFemale = nil
    end
    currentAnim = nil
    currentScenario = nil
    isAnimating = false
    isScenarioActive = false
end

local function createTestPed()
    deleteTestPed()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local forwardVector = GetEntityForwardVector(playerPed)
    local coords = {
        x = playerCoords.x + (forwardVector.x * 3.0),
        y = playerCoords.y + (forwardVector.y * 3.0),
        z = playerCoords.z - 1.0,
        w = playerHeading + 180.0
    }
    if coords.x == 0 and coords.y == 0 and coords.z == 0 then
        coords = {
            x = playerCoords.x + 3.0,
            y = playerCoords.y,
            z = playerCoords.z - 1.0,
            w = playerHeading + 180.0
        }
    end
    local selectedModel = MALE_MODEL
    RequestModel(selectedModel)
    local timeout = 0
    while not HasModelLoaded(selectedModel) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    if not HasModelLoaded(selectedModel) then
        return nil
    end
    local spawnedPed = CreatePed(selectedModel, coords.x, coords.y, coords.z, coords.w, false, false, 0, 0)
    if not DoesEntityExist(spawnedPed) then
        return nil
    end
    SetEntityAlpha(spawnedPed, 255, false)
    SetEntityCanBeDamaged(spawnedPed, false)
    FreezeEntityPosition(spawnedPed, true)
    SetRandomOutfitVariation(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetPedCanBeTargetted(spawnedPed, false)
    SetEntityVisible(spawnedPed, true, 0)
    SetEntityCollision(spawnedPed, false, false)
    testPed = spawnedPed
    return testPed
end

local function createTestPedWithGender(gender)
    deleteTestPed()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local forwardVector = GetEntityForwardVector(playerPed)
    local coords = {
        x = playerCoords.x + (forwardVector.x * 3.0),
        y = playerCoords.y + (forwardVector.y * 3.0),
        z = playerCoords.z - 1.0,
        w = playerHeading + 180.0
    }
    if coords.x == 0 and coords.y == 0 and coords.z == 0 then
        coords = {
            x = playerCoords.x + 3.0,
            y = playerCoords.y,
            z = playerCoords.z - 1.0,
            w = playerHeading + 180.0
        }
    end
    local selectedModel
    if gender == 'male' then
        selectedModel = MALE_MODEL
    else
        selectedModel = FEMALE_MODEL
    end
    RequestModel(selectedModel)
    local timeout = 0
    while not HasModelLoaded(selectedModel) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    if not HasModelLoaded(selectedModel) then
        return nil
    end
    local spawnedPed = CreatePed(selectedModel, coords.x, coords.y, coords.z, coords.w, false, false, 0, 0)
    if not DoesEntityExist(spawnedPed) then
        return nil
    end
    SetEntityAlpha(spawnedPed, 255, false)
    SetEntityCanBeDamaged(spawnedPed, false)
    FreezeEntityPosition(spawnedPed, true)
    SetRandomOutfitVariation(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetPedCanBeTargetted(spawnedPed, false)
    SetEntityVisible(spawnedPed, true, 0)
    SetEntityCollision(spawnedPed, false, false)
    testPed = spawnedPed
    return testPed
end

local function createBothGenderPeds()
    deleteTestPed()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local forwardVector = GetEntityForwardVector(playerPed)
    local coordsMale = {
        x = playerCoords.x + (forwardVector.x * 3.0),
        y = playerCoords.y + (forwardVector.y * 3.0),
        z = playerCoords.z - 1.0,
        w = playerHeading + 180.0
    }
    local coordsFemale = {
        x = playerCoords.x + (forwardVector.x * 3.0) - (forwardVector.y * 2.0),
        y = playerCoords.y + (forwardVector.y * 3.0) + (forwardVector.x * 2.0),
        z = playerCoords.z - 1.0,
        w = playerHeading + 180.0
    }
    RequestModel(MALE_MODEL)
    local timeout = 0
    while not HasModelLoaded(MALE_MODEL) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    if not HasModelLoaded(MALE_MODEL) then
        return nil, nil
    end
    RequestModel(FEMALE_MODEL)
    timeout = 0
    while not HasModelLoaded(FEMALE_MODEL) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    if not HasModelLoaded(FEMALE_MODEL) then
        return nil, nil
    end
    local spawnedMalePed = CreatePed(MALE_MODEL, coordsMale.x, coordsMale.y, coordsMale.z, coordsMale.w, false, false, 0, 0)
    if not DoesEntityExist(spawnedMalePed) then
        return nil, nil
    end
    SetEntityAlpha(spawnedMalePed, 255, false)
    SetEntityCanBeDamaged(spawnedMalePed, false)
    FreezeEntityPosition(spawnedMalePed, true)
    SetRandomOutfitVariation(spawnedMalePed, true)
    SetBlockingOfNonTemporaryEvents(spawnedMalePed, true)
    SetPedCanBeTargetted(spawnedMalePed, false)
    SetEntityVisible(spawnedMalePed, true, 0)
    SetEntityCollision(spawnedMalePed, false, false)
    local spawnedFemalePed = CreatePed(FEMALE_MODEL, coordsFemale.x, coordsFemale.y, coordsFemale.z, coordsFemale.w, false, false, 0, 0)
    if not DoesEntityExist(spawnedFemalePed) then
        DeletePed(spawnedMalePed)
        return nil, nil
    end
    SetEntityAlpha(spawnedFemalePed, 255, false)
    SetEntityCanBeDamaged(spawnedFemalePed, false)
    FreezeEntityPosition(spawnedFemalePed, true)
    SetRandomOutfitVariation(spawnedFemalePed, true)
    SetBlockingOfNonTemporaryEvents(spawnedFemalePed, true)
    SetPedCanBeTargetted(spawnedFemalePed, false)
    SetEntityVisible(spawnedFemalePed, true, 0)
    SetEntityCollision(spawnedFemalePed, false, false)
    testPed = spawnedMalePed
    testPedFemale = spawnedFemalePed
    return spawnedMalePed, spawnedFemalePed
end

local function createAnimal(scenario)
    deleteTestPed()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local forwardVector = GetEntityForwardVector(playerPed)
    local coords = {
        x = playerCoords.x + (forwardVector.x * 3.0),
        y = playerCoords.y + (forwardVector.y * 3.0),
        z = playerCoords.z - 1.0,
        w = playerHeading + 180.0
    }
    local animalModel = getAnimalModel(scenario)
    RequestModel(animalModel)
    local timeout = 0
    while not HasModelLoaded(animalModel) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    if not HasModelLoaded(animalModel) then
        return nil
    end
    local spawnedAnimal = CreatePed(animalModel, coords.x, coords.y, coords.z, coords.w, false, false, 0, 0)
    if not DoesEntityExist(spawnedAnimal) then
        return nil
    end
    Citizen.InvokeNative(0x283978A15512B2FE, spawnedAnimal, true)
    SetEntityAlpha(spawnedAnimal, 255, false)
    SetEntityCanBeDamaged(spawnedAnimal, false)
    FreezeEntityPosition(spawnedAnimal, true)
    SetBlockingOfNonTemporaryEvents(spawnedAnimal, true)
    SetPedCanBeTargetted(spawnedAnimal, false)
    SetEntityVisible(spawnedAnimal, true, 0)
    SetEntityCollision(spawnedAnimal, true, true)
    testPed = spawnedAnimal
    return spawnedAnimal
end

local function createProp(scenario)
    deleteTestPed()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local forwardVector = GetEntityForwardVector(playerPed)
    local coords = {
        x = playerCoords.x + (forwardVector.x * 3.0),
        y = playerCoords.y + (forwardVector.y * 3.0),
        z = playerCoords.z - 1.0,
        w = playerHeading + 180.0
    }
    local propModel = getPropModel(scenario)
    RequestModel(propModel)
    local timeout = 0
    while not HasModelLoaded(propModel) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    if not HasModelLoaded(propModel) then
        return nil
    end
    local spawnedProp = CreateObject(propModel, coords.x, coords.y, coords.z, false, false, false)
    if not DoesEntityExist(spawnedProp) then
        return nil
    end
    SetEntityHeading(spawnedProp, coords.w)
    SetEntityAlpha(spawnedProp, 255, false)
    FreezeEntityPosition(spawnedProp, true)
    SetEntityVisible(spawnedProp, true, 0)
    SetEntityCollision(spawnedProp, false, false)
    testPed = spawnedProp
    return spawnedProp
end

local function applyAnimation(dict, name)
    deleteTestPed()
    
    testPed = createTestPed()
    if not testPed or not DoesEntityExist(testPed) then
        return false, "Error creating test NPC"
    end
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(50)
    end
    if HasAnimDictLoaded(dict) then
        TaskPlayAnim(testPed, dict, name, 8.0, -8.0, -1, 1, 0, false, false, false)
        currentAnim = { dict = dict, name = name }
        isAnimating = true
        currentScenario = nil
        isScenarioActive = false
        return true
    else
        return false, "Error loading animation"
    end
end

local function applyScenario(scenario)
    if not testPed or not DoesEntityExist(testPed) then
        testPed = createTestPed()
        if not testPed then
            return false, "Error creating test NPC"
        end
    end
    if not DoesEntityExist(testPed) then
        return false, "NPC does not exist"
    end
    if isAnimating then
        StopAnimTask(testPed, currentAnim.dict, currentAnim.name, 1.0)
        isAnimating = false
        currentAnim = nil
    end
    TaskStartScenarioInPlace(testPed, scenario, 0, true, false, false, false)
    currentScenario = scenario
    isScenarioActive = true
    return true
end

local function applyScenarioWithConditional(scenario, conditionalAnim)
    local entityType = getEntityType(scenario)
    
    deleteTestPed()
    
    if entityType == "animal" then
        local animal = createAnimal(scenario)
        if not animal then
            return false, "Error creating animal"
        end
        local scenarioHash = GetHashKey(scenario)
        local conditionalAnimHash = GetHashKey(conditionalAnim)
        TaskStartScenarioInPlaceHash(testPed, scenarioHash, -1, true, conditionalAnimHash, -1.0, 0)
        currentScenario = scenario
        isScenarioActive = true
        return true
    end
    if entityType == "prop" then
        local prop = createProp(scenario)
        if not prop then
            return false, "Error creating prop"
        end
        currentScenario = scenario
        isScenarioActive = true
        return true
    end
    local hasBothGenders = false
    local file = LoadResourceFile(GetCurrentResourceName(), 'Scenarios.json')
    if file then
        local success, scenariosData = pcall(json.decode, file)
        if success and scenariosData and scenariosData[scenario] then
            local conditionalAnims = scenariosData[scenario]
            local hasMale = false
            local hasFemale = false
            for _, anim in ipairs(conditionalAnims) do
                if anim:find("_MALE_") or anim:find("_MALE") then
                    hasMale = true
                end
                if anim:find("_FEMALE_") or anim:find("_FEMALE") then
                    hasFemale = true
                end
            end
            hasBothGenders = hasMale and hasFemale
        end
    end
    if hasBothGenders then
        local malePed, femalePed = createBothGenderPeds()
        if not malePed or not femalePed then
            return false, "Error creating test NPCs"
        end
        if isAnimating then
            StopAnimTask(testPed, currentAnim.dict, currentAnim.name, 1.0)
            if testPedFemale then
                StopAnimTask(testPedFemale, currentAnim.dict, currentAnim.name, 1.0)
            end
            isAnimating = false
            currentAnim = nil
        end
        local scenarioHash = GetHashKey(scenario)
        local maleAnimHash = GetHashKey(conditionalAnim:gsub("_FEMALE_", "_MALE_"):gsub("_FEMALE", "_MALE"))
        TaskStartScenarioInPlaceHash(testPed, scenarioHash, -1, true, maleAnimHash, -1.0, 0)
        local femaleAnimHash = GetHashKey(conditionalAnim:gsub("_MALE_", "_FEMALE_"):gsub("_MALE", "_FEMALE"))
        TaskStartScenarioInPlaceHash(testPedFemale, scenarioHash, -1, true, femaleAnimHash, -1.0, 0)
        currentScenario = scenario
        isScenarioActive = true
        return true
    else
        if testPedFemale and DoesEntityExist(testPedFemale) then
            DeletePed(testPedFemale)
            testPedFemale = nil
        end
        
        if not testPed or not DoesEntityExist(testPed) then
            testPed = createTestPed()
            if not testPed then
                return false, "Error creating test NPC"
            end
        end
        if not DoesEntityExist(testPed) then
            return false, "NPC does not exist"
        end
        if isAnimating then
            StopAnimTask(testPed, currentAnim.dict, currentAnim.name, 1.0)
            isAnimating = false
            currentAnim = nil
        end
        local scenarioHash = GetHashKey(scenario)
        local conditionalAnimHash = GetHashKey(conditionalAnim)
        TaskStartScenarioInPlaceHash(testPed, scenarioHash, -1, true, conditionalAnimHash, -1.0, 0)
        currentScenario = scenario
        isScenarioActive = true
        return true
    end
end

local function applyScenarioWithProp(scenario, prop)
    if not testPed or not DoesEntityExist(testPed) then
        testPed = createTestPedWithGender(gender)
        if not testPed or not DoesEntityExist(testPed) then
            return false, "Error creating test NPC"
        end
    end
    if not DoesEntityExist(testPed) then
        return false, "NPC does not exist"
    end
    if isAnimating then
        StopAnimTask(testPed, currentAnim.dict, currentAnim.name, 1.0)
        isAnimating = false
        currentAnim = nil
    end
    local scenarioHash = GetHashKey(scenario)
    TaskStartScenarioInPlaceHash(testPed, scenarioHash, -1, true, 0, -1.0, 0)
    currentScenario = scenario
    isScenarioActive = true
    Wait(1000)
    GivePedScenarioProp(testPed, 0, prop, scenario, "", true)
    return true
end

function stopAnimation()
    if currentAnim and testPed and DoesEntityExist(testPed) then
        StopAnimTask(testPed, currentAnim.dict, currentAnim.name, 1.0)
    end
    if currentAnim and testPedFemale and DoesEntityExist(testPedFemale) then
        StopAnimTask(testPedFemale, currentAnim.dict, currentAnim.name, 1.0)
    end
    currentAnim = nil
    isAnimating = false
end

function stopScenario()
    if currentScenario and testPed and DoesEntityExist(testPed) then
        ClearPedTasksImmediately(testPed)
    end
    if currentScenario and testPedFemale and DoesEntityExist(testPedFemale) then
        ClearPedTasksImmediately(testPedFemale)
    end
    currentScenario = nil
    isScenarioActive = false
end

function openUI()
    if not uiOpened then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = "show" })
        uiOpened = true
    end
end

function closeUI()
    if uiOpened then
        stopAnimation()
        stopScenario()
        deleteTestPed()
        SetNuiFocus(false, false)
        SendNUIMessage({ type = "hide" })
        uiOpened = false
    end
end

RegisterNUICallback('applyAnimation', function(data, cb)
    if not uiOpened then
        cb({ success = false, error = 'Interface is not open' })
        return
    end
    local dict = data.dict
    local name = data.name
    if dict and name and dict ~= '' and name ~= '' then
        local success, error = applyAnimation(dict, name)
        if success then
            cb({ success = true })
        else
            cb({ success = false, error = error })
        end
    else
        cb({ success = false, error = 'Fill both fields' })
    end
end)

RegisterNUICallback('applyScenario', function(data, cb)
    if not uiOpened then
        cb({ success = false, error = 'Interface is not open' })
        return
    end
    local scenario = data.scenario
    if scenario and scenario ~= '' then
        local success, error = applyScenario(scenario)
        if success then
            cb({ success = true })
        else
            cb({ success = false, error = error })
        end
    else
        cb({ success = false, error = 'Fill the scenario field' })
    end
end)

RegisterNUICallback('stopAnimation', function(data, cb)
    if not uiOpened then
        cb({ success = false, error = 'Interface is not open' })
        return
    end
    stopAnimation()
    cb({ success = true })
end)

RegisterNUICallback('stopScenario', function(data, cb)
    if not uiOpened then
        cb({ success = false, error = 'Interface is not open' })
        return
    end
    stopScenario()
    cb({ success = true })
end)

RegisterNUICallback('applyScenarioFromList', function(data, cb)
    if not uiOpened then
        cb({ success = false, error = 'Interface is not open' })
        return
    end
    local scenario = data.scenario
    local gender = data.gender
    local conditionalAnim = data.conditionalAnim
    if scenario and scenario ~= '' then
        local success, error = applyScenarioWithConditional(scenario, conditionalAnim)
        if success then
            cb({ success = true })
        else
            cb({ success = false, error = error })
        end
    else
        cb({ success = false, error = 'Invalid data' })
    end
end)

RegisterNUICallback('searchScenarios', function(data, cb)
    if not uiOpened then
        cb({ success = false, error = 'Interface is not open' })
        return
    end
    local searchTerm = data.searchTerm
    if not searchTerm or searchTerm == '' then
        cb({ success = true, scenarios = {} })
        return
    end
    local scenarios = {}
    local file = LoadResourceFile(GetCurrentResourceName(), 'Scenarios.json')
    if file then
        local success, scenariosData = pcall(json.decode, file)
        if success and scenariosData then
            for scenarioName, conditionalAnims in pairs(scenariosData) do
                local shouldInclude = true
            if not scenarioName:find("PROP_")  then
                    local found = scenarioName:lower():find(searchTerm:lower())
                    if not found then
                        for _, anim in ipairs(conditionalAnims) do
                            if anim:lower():find(searchTerm:lower()) then
                                found = true
                                break
                            end
                        end
                    end
                    if found then
                        table.insert(scenarios, {
                            name = scenarioName,
                            conditional_anims = conditionalAnims
                        })
                    end
                end
            end
        end
    end
    cb({ success = true, scenarios = scenarios })
end)

RegisterNUICallback('applyPropScenario', function(data, cb)
    if not uiOpened then
        cb({ success = false, error = 'Interface is not open' })
        return
    end
    local scenario = data.scenario
    local gender = data.gender
    local prop = data.prop
    if scenario and scenario ~= '' and gender and gender ~= '' and prop and prop ~= '' then
        if not testPed or not DoesEntityExist(testPed) then
            testPed = createTestPedWithGender(gender)
            if not testPed or not DoesEntityExist(testPed) then
                cb({ success = false, error = 'Error creating test NPC' })
                return
            end
        end
        local success, error = applyScenarioWithProp(scenario, prop)
        if success then
            cb({ success = true })
        else
            cb({ success = false, error = error })
        end
    else
        cb({ success = false, error = 'Invalid data' })
    end
end)

RegisterNUICallback('closeUI', function(data, cb)
    closeUI()
    cb({ success = true })
end)

RegisterNUICallback('getScenarioDetails', function(data, cb)
    local scenarioName = data.scenarioName
    if not scenarioName then
        cb({success = false, error = 'Scenario name not provided'})
        return
    end
    local file = LoadResourceFile(GetCurrentResourceName(), 'Scenarios.json')
    if not file then
        cb({success = false, error = 'Could not load Scenarios.json file'})
        return
    end
    local success, scenarios = pcall(json.decode, file)
    if not success then
        cb({success = false, error = 'Error decoding Scenarios.json'})
        return
    end
    if scenarios[scenarioName] then
        local scenario = {
            name = scenarioName,
            conditional_anims = scenarios[scenarioName]
        }
        cb({success = true, scenario = scenario})
    else
        cb({success = false, error = 'Scenario not found'})
    end
end)



-- Event to open UI from server
RegisterNetEvent('rco-animations:openUI')
AddEventHandler('rco-animations:openUI', function()
    if not uiOpened then
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "show"
        })
        uiOpened = true
    else
        closeUI()
    end
end)



AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    closeUI()
end)