assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local Routines = {};
local RoutineToIDMap = {};

local Crabs1 = SetVector(286, 19, -1641);
local Crabs2 = SetVector(1197, 53, -446);
local Crabs3 = SetVector(-228, 24, -198);
local Crabs4 = SetVector(-1614, 42, -212);
local Crabs5 = SetVector(-683, 42, -584);
local Crabs6 = SetVector(-362, 36, -925);
local Crabs7 = SetVector(548, 20, 555);

local Orders = "Commander,escort the constructor\nwhile it builds a series of plasma\nbatteries,be careful of unstable\nterrain.";
local Scavs = "It appears that the local wildlife\nhas taken a dislike to us,protect\nthose extractors at all costs ";
local Const = "The terrain ahead is highly\nunstable guide the constructor\nthrough to nav beacon 3 .";
local Const2 = "Well done , one more left to\ngo,guide the constructor to\nnav beacon 4,but be\nquick,the alien fleet is\nalmost upon us. ";
local Fleet = "ATTENTION , we are getting reports\nthat the alien fleet is non-hostile\nrepeat,alien fleet is non-hostile,\nabort mission immediately .";
local NewOrders = "We don't have much time,we need\nto shut down the plasma batteries,\n you can to do this from\nthe radar tracking station\nhighlighted on your HUD.";
local Radar = "It's too late , we don't have time\n to shut the station down manually\nyou'll have to find another way\nto take it offline.";
local Win = "Well done you have shutdown the\nradar tracking system in time .";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,

    -- Objects
    dropship = nil,
    const = nil,
    collapse_1 = nil,
    collapse_2 = nil,
    collapse_3 = nil,
    collapse_4 = nil,
    collapse_5 = nil,
    collapse_6 = nil,
    nav_1 = nil,
    nav_2 = nil,
    nav_3 = nil,
    nav_4 = nil,
    scav1 = nil,
    scav2 = nil,
    scav3 = nil,
    scav4 = nil,
    Attacker = nil,
    rocks = nil,
    radar = nil,
    power = nil,
    player = nil,

    -- Variables

    -- Just end it already!
    endme = 0
}

function DefineRoutine(routineID, func, activeOnStart)
    if routineID == nil or Routines[routineID]~= nil then
        error("DefineRoutine: duplicate or invalid routineID: "..tostring(routineID));
    elseif func == nil then
        error("DefineRoutine: func is nil for id "..tostring(routineID), 2);
    else
        Routines[routineID] = func;
        RoutineToIDMap[func] = routineID;
        M.RoutineState[routineID] = 0;
        M.RoutineWakeTime[routineID] = 0.0;
        M.RoutineActive[routineID] = activeOnStart;
    end
end

function Advance(routineID, delay)
    routineID = routineID or error("Advance(): invalid routineID.", 2);
    SetState(routineID, M.RoutineState[routineID] + 1, delay);
end

function SetState(routineID, state, delay)
    routineID = routineID or error("SetState(): invalid routineID.", 2);
    delay = delay or 0.0;
    M.RoutineState[routineID] = state;
    M.RoutineWakeTime[routineID] = GetTime() + delay;
end

function Wait(routineID, delay)
    M.RoutineWakeTime[routineID] = GetTime() + delay;
end

function SetRoutineActive(routine, active)
    local routineID = RoutineToIDMap[routine] or routine or error("SetRoutineActive(): routine '"..tostring(routine).." not found.", 2);
    M.RoutineActive[routineID] = active;
end

function DefineRoutines()
    DefineRoutine(0, Main, true);
    DefineRoutine(1, CheckConstructor, true);
    DefineRoutine(2, CheckScav1, true);
    DefineRoutine(3, CheckScav2, true);
    DefineRoutine(4, CheckScav3, true);
    DefineRoutine(5, CheckScav4, true);
    DefineRoutine(6, CheckCollapse, true);
end

function Save()
    return M;
end

function Load(...)
    if select('#', ...) > 0 then
        M = ...
    end
end

function InitialSetup()
    M.TPS = EnableHighTPS();
    AllowRandomTracks(false);
    DefineRoutines();

    --Preload to reduce lag spikes when resources are used for the first time.
    local preloadODFs = {
        "TvCrab"
    };
    local preloadAudio = {
    };
    for k,v in pairs(preloadODFs) do
        PreloadODF(v);
    end
    for k,v in pairs(preloadAudio) do
        PreloadAudioMessage(v);
    end
end

function Update()
    for routineID,r in pairs(Routines) do
        if M.RoutineActive[routineID] and M.RoutineWakeTime[routineID] <= GetTime() then
            r(routineID, M.RoutineState[routineID]);
        end
    end
end

function Main(R, STATE)
    if (STATE == 0) then
        M.player = GetPlayerHandle();
        M.dropship = GetHandle("dropship");
        M.nav_1 = GetHandle("nav_1");
        M.nav_2 = GetHandle("nav_2");
        M.nav_3 = GetHandle("nav_3");
        M.nav_4 = GetHandle("nav_4");
        M.collapse_1 = GetHandle("collapse_1");
        M.collapse_2 = GetHandle("collapse_2");
        M.collapse_3 = GetHandle("collapse_3");
        M.collapse_4 = GetHandle("collapse_4");
        M.collapse_5 = GetHandle("collapse_5");
        M.collapse_6 = GetHandle("collapse_6");
        M.rocks = GetHandle("rocks");
        M.radar = GetHandle("radar");
        M.power = GetHandle("power");
        SetAnimation(M.dropship, "takeoff", 1);
        Advance(R, 3);
    elseif (STATE == 1) then
        StartAnimation(M.dropship);
        Advance(R, 10);
    elseif (STATE == 2) then
        RemoveObject(M.dropship);
        AddObjective(Orders, "white");
        Goto(M.const, M.nav_1, 1);
        SetObjectiveOn(M.const);
        Advance(R);
    elseif (STATE == 3) then -- Label: GO_TO_NAV1
        M.ValueMain24 = Distance3D(M.const, M.nav_1);
        if (M.ValueMain24 > 180) then
            SetState(R, 3); -- Goto label GO_TO_NAV1
            return;
        end
        Build(M.const, "IbplasBD1", 1);
    elseif (STATE == 4) then
        Dropoff(M.const, "tower_1", 1);
        Advance(R, 50);
    elseif (STATE == 5) then
        Goto(M.const, M.nav_2, 1);
        M.Attacker = BuildObject("TvCrab", 6, Crabs1);
        Attack(M.Attacker, M.scav1, 1);
        Advance(R, 2);
    elseif (STATE == 6) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs1);
        Attack(M.Attacker, M.scav1, 1);
        Advance(R, 2);
    elseif (STATE == 7) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs1);
        Attack(M.Attacker, M.scav2, 1);
        Advance(R, 2);
    elseif (STATE == 8) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs2);
        Attack(M.Attacker, M.scav3, 1);
        Advance(R, 2);
    elseif (STATE == 9) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs2);
        Attack(M.Attacker, M.scav4, 1);
        Advance(R, 2);
    elseif (STATE == 10) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs2);
        Attack(M.Attacker, M.scav4, 1);
        Advance(R, 6);
    elseif (STATE == 11) then
        CameraPath("camera_1", 1500, 2500, M.scav2);
        ClearObjectives();
        AddObjective(Scavs, "white");
        Advance(R, 115);
    elseif (STATE == 12) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs3);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 4);
    elseif (STATE == 13) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs3);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 4);
    elseif (STATE == 14) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs3);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 4);
    elseif (STATE == 15) then -- Label: GO_TO_NAV2
        Advance(R, 20);
    elseif (STATE == 16) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs3);
        Attack(M.Attacker, M.const, 1);
        M.ValueMain64 = Distance3D(M.const, M.nav_2);
        if (M.ValueMain64 > 180) then
            SetState(R, 15); -- Goto label GO_TO_NAV2
            return;
        end
        M.Attacker = BuildObject("TvCrab", 6, Crabs6);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 5);
    elseif (STATE == 17) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs6);
        Attack(M.Attacker, M.const, 1);
        Build(M.const, "IbplasBD1", 1);
    elseif (STATE == 18) then
        Dropoff(M.const, "tower_2", 1);
        M.Attacker = BuildObject("TvCrab", 6, Crabs6);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 5);
    elseif (STATE == 19) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs6);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 70);
    elseif (STATE == 20) then
        Goto(M.const, "path_1", 1);
        Advance(R);
    elseif (STATE == 21) then -- Label: GO_TO_ROCKS
        M.Attacker = BuildObject("TvCrab", 6, Crabs6);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 20);
    elseif (STATE == 22) then
        M.ValueMain83 = Distance3D(M.const, M.rocks);
        if (M.ValueMain83 > 80) then
            SetState(R, 21); -- Goto label GO_TO_ROCKS
            return;
        end
        Goto(M.const, M.rocks, 0);
        ClearObjectives();
        AddObjective(Const, "white");
        Advance(R);
    elseif (STATE == 23) then -- Label: GO_TO_NAV3
        M.Attacker = BuildObject("TvCrab", 6, Crabs4);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 15);
    elseif (STATE == 24) then
        M.Attacker = BuildObject("TvCrab", 6, Crabs5);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 10);
    elseif (STATE == 25) then
        M.ValueMain94 = Distance3D(M.const, M.nav_3);
        if (M.ValueMain94 > 80) then
            SetState(R, 23); -- Goto label GO_TO_NAV3
            return;
        end
        Build(M.const, "IbplasBD1", 1);
    elseif (STATE == 26) then
        Dropoff(M.const, "tower_3", 1);
        Advance(R, 50);
    elseif (STATE == 27) then
        Goto(M.const, M.nav_3, 0);
        ClearObjectives();
        AddObjective(Const2, "white");
        Advance(R);
    elseif (STATE == 28) then -- Label: NAV_4
        M.Attacker = BuildObject("TvCrab", 6, Crabs7);
        Attack(M.Attacker, M.const, 1);
        Advance(R, 20);
    elseif (STATE == 29) then
        M.ValueMain105 = Distance3D(M.const, M.nav_4);
        if (M.ValueMain105 > 80) then
            SetState(R, 28); -- Goto label NAV_4
            return;
        end
        ClearObjectives();
        AddObjective(Fleet, "red");
        Advance(R, 15);
    elseif (STATE == 30) then
        ClearObjectives();
        AddObjective(NewOrders, "Green");
        Advance(R, 6);
    elseif (STATE == 31) then
        CameraPath("camera_2", 1500, 3000, M.radar);
        Advance(R, 5);
    elseif (STATE == 32) then
        SetUserTarget(M.radar);
        StartCockpitTimer(205);
        Advance(R);
    elseif (STATE == 33) then -- Label: COUNT_DOWN
        M.ValueMain117 = Distance3D(M.player, M.radar);
        if (M.ValueMain117 < 80) then
            SetState(R, 34); -- Goto label MESSAGE
            return;
        end
        M.ValueMain119 = GetCockpitTimer();
        if (M.ValueMain119 > 0) then
            SetState(R, 33); -- Goto label COUNT_DOWN
            return;
        end
        FailMission(10, "FS04fail3.des");
        SetState(R, 37); -- Jump to label END
    elseif (STATE == 34) then -- Label: MESSAGE
        ClearObjectives();
        AddObjective(Radar, "white");
        Advance(R);
    elseif (STATE == 35) then -- Label: POWER
        M.ValueMain125 = IsAround(M.power);
        if (M.ValueMain125 == false) then
            SetState(R, 36); -- Goto label WIN
            return;
        end
        M.ValueMain127 = GetCockpitTimer();
        if (M.ValueMain127 > 0) then
            SetState(R, 35); -- Goto label POWER
            return;
        end
        FailMission(10, "FS04fail3.des");
        SetState(R, 37); -- Jump to label END
    elseif (STATE == 36) then -- Label: WIN
        ClearObjectives();
        AddObjective(Win, "green");
        SucceedMission(16, "FS04win.des");
        Advance(R);
    elseif (STATE == 37) then -- Label: END
    end
end

function CheckConstructor(R, STATE)
    if (STATE == 0) then -- Label: CONSTRUCTOR_IS_ALIVE
        M.const = GetHandle("const");
        M.ValueCheckConstructor2 = IsAround(M.const);
        if (M.ValueCheckConstructor2 == true) then
            SetState(R, 0); -- Goto label CONSTRUCTOR_IS_ALIVE
            return;
        end
        FailMission(10, "FS04fail1.des");
    end
end

function CheckScav1(R, STATE)
    if (STATE == 0) then -- Label: SCAV1_ALIVE
        M.scav1 = GetHandle("scav1");
        M.ValueCheckScav12 = IsAround(M.scav1);
        if (M.ValueCheckScav12 == true) then
            SetState(R, 0); -- Goto label SCAV1_ALIVE
            return;
        end
        FailMission(10, "FS04fail2.des");
    end
end

function CheckScav2(R, STATE)
    if (STATE == 0) then -- Label: SCAV2_ALIVE
        M.scav2 = GetHandle("scav2");
        M.ValueCheckScav22 = IsAround(M.scav2);
        if (M.ValueCheckScav22 == true) then
            SetState(R, 0); -- Goto label SCAV2_ALIVE
            return;
        end
        FailMission(10, "FS04fail2.des");
    end
end

function CheckScav3(R, STATE)
    if (STATE == 0) then -- Label: SCAV3_ALIVE
        M.scav3 = GetHandle("scav3");
        M.ValueCheckScav32 = IsAround(M.scav3);
        if (M.ValueCheckScav32 == true) then
            SetState(R, 0); -- Goto label SCAV3_ALIVE
            return;
        end
        FailMission(10, "FS04fail2.des");
    end
end

function CheckScav4(R, STATE)
    if (STATE == 0) then -- Label: SCAV4_ALIVE
        M.scav4 = GetHandle("scav4");
        M.ValueCheckScav42 = IsAround(M.scav4);
        if (M.ValueCheckScav42 == true) then
            SetState(R, 0); -- Goto label SCAV4_ALIVE
            return;
        end
        FailMission(10, "FS04fail2.des");
    end
end

function CheckCollapse(R, STATE)
    if (STATE == 0) then -- Label: MAIN_LOOP
        M.ValueCheckCollapse1 = Distance3D(M.const, M.collapse_1);
        if (M.ValueCheckCollapse1 > 40) then
            SetState(R, 3); -- Goto label NEXT_1
            return;
        end
        SetAnimation(M.collapse_1, "break", 1);
        Advance(R, 2);
    elseif (STATE == 1) then
        StartAnimation(M.collapse_1);
        Advance(R, 4);
    elseif (STATE == 2) then
        RemoveObject(M.collapse_1);
        Advance(R);
    elseif (STATE == 3) then -- Label: NEXT_1
        M.ValueCheckCollapse8 = Distance3D(M.const, M.collapse_2);
        if (M.ValueCheckCollapse8 > 40) then
            SetState(R, 6); -- Goto label NEXT_2
            return;
        end
        SetAnimation(M.collapse_2, "break", 1);
        Advance(R, 2);
    elseif (STATE == 4) then
        StartAnimation(M.collapse_2);
        Advance(R, 3);
    elseif (STATE == 5) then
        RemoveObject(M.collapse_2);
        Advance(R);
    elseif (STATE == 6) then -- Label: NEXT_2
        M.ValueCheckCollapse15 = Distance3D(M.const, M.collapse_3);
        if (M.ValueCheckCollapse15 > 40) then
            SetState(R, 9); -- Goto label NEXT_3
            return;
        end
        SetAnimation(M.collapse_3, "break", 1);
        Advance(R, 2);
    elseif (STATE == 7) then
        StartAnimation(M.collapse_3);
        Advance(R, 4);
    elseif (STATE == 8) then
        RemoveObject(M.collapse_3);
        Advance(R);
    elseif (STATE == 9) then -- Label: NEXT_3
        M.ValueCheckCollapse22 = Distance3D(M.const, M.collapse_4);
        if (M.ValueCheckCollapse22 > 40) then
            SetState(R, 12); -- Goto label NEXT_4
            return;
        end
        SetAnimation(M.collapse_4, "break", 1);
        Advance(R, 2);
    elseif (STATE == 10) then
        StartAnimation(M.collapse_4);
        Advance(R, 4);
    elseif (STATE == 11) then
        RemoveObject(M.collapse_4);
        Advance(R);
    elseif (STATE == 12) then -- Label: NEXT_4
        M.ValueCheckCollapse29 = Distance3D(M.const, M.collapse_5);
        if (M.ValueCheckCollapse29 > 40) then
            SetState(R, 15); -- Goto label NEXT_5
            return;
        end
        SetAnimation(M.collapse_5, "break", 1);
        Advance(R, 2);
    elseif (STATE == 13) then
        StartAnimation(M.collapse_5);
        Advance(R, 4);
    elseif (STATE == 14) then
        RemoveObject(M.collapse_5);
        Advance(R);
    elseif (STATE == 15) then -- Label: NEXT_5
        M.ValueCheckCollapse36 = Distance3D(M.const, M.collapse_6);
        if (M.ValueCheckCollapse36 > 40) then
            SetState(R, 0); -- Goto label MAIN_LOOP
            return;
        end
        SetAnimation(M.collapse_6, "break", 1);
        Advance(R, 2);
    elseif (STATE == 16) then
        StartAnimation(M.collapse_6);
        Advance(R, 4);
    elseif (STATE == 17) then
        RemoveObject(M.collapse_6);
    end
end
