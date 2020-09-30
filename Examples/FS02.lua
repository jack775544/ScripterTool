assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local Routines = {};
local RoutineToIDMap = {};

local swarm1 = SetVector(1637, 2, -1203);
local swarm2 = SetVector(-1710, 3, 1575);
local swarm3 = SetVector(-319, 2, 1496);
local swarm4 = SetVector(1704, 2, -335);
local swarm5 = SetVector(1628, 2, 1586);
local Pilots = SetVector(-1079, 2, -1726);
local Reinf = SetVector(-1262, -14, -1841);

local Brief_1 = "The enemy have launched\na major offensive , many\nof our outposts have been overrun\nand we have lost control\nof the starport.";
local Brief_2 = "We are regrouping our\nforces at the central command\ncomplex , we are evacuating all\nnon essential personnel via APC.";
local Brief_3 = "Without dropships from the\nstarport we are unable to\nairlift the recycler out ,\nthis means you'll have to\nescort it to safety.";
local Orders_1 = "Protect the APC's while\nthey evacuate our troops\nthen escort the recycler back\nto central command.";
local Pilots = "Well, done our troops\nhave arrived safely ,\nnow you must escort the\nrecycler through the canyons ,\ngood luck.";
local Warning_1 = "Enemy turrets are blocking\n the way ahead , clear\nthem out so we can procede.";
local Turrets = "Well done , the turrets\nhave been eliminated\nwe may continue.";
local Force = "A large enemy force\nis blocking the way ahead,\nwe must neutralise them\nbefore we can move on .";
local WinText = "well done the recycler\nhas made it through.\nThe rest of the journey\nto central command is,\nclear of enemy forces .";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,

    -- Objects
    Recy = nil,
    Player = nil,
    Leader = nil,
    Barracks = nil,
    apc_1 = nil,
    apc_2 = nil,
    apc_3 = nil,
    TempPilot = nil,
    Attacker = nil,
    Enemy_1 = nil,
    Enemy_2 = nil,
    Enemy_3 = nil,
    Enemy_4 = nil,
    Enemy_5 = nil,
    Enemy_6 = nil,
    Enemy_7 = nil,
    Enemy_8 = nil,
    Enemy_9 = nil,
    Outpost = nil,
    Outpost_2 = nil,
    turr_1 = nil,
    turr_2 = nil,
    turr_3 = nil,
    turr_4 = nil,
    bones_1 = nil,
    Tank_1 = nil,
    Tank_2 = nil,
    Tank_3 = nil,
    Serv_1 = nil,

    -- Variables
    PilotCount = 0,

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
    DefineRoutine(1, CheckRecy, true);
    DefineRoutine(2, CheckLeader, true);
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
        "svscA_D",
        "ispilo",
        "svscJ_D",
        "ivtnk_BD",
        "ivserv_BD",
        "svwlkL_D",
        "svscL_D"
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
        M.Player = GetPlayerHandle();
        M.apc_1 = GetHandle("apc_1");
        M.apc_2 = GetHandle("apc_2");
        M.apc_3 = GetHandle("apc_3");
        M.Outpost = GetHandle("Outpost");
        M.Outpost_2 = GetHandle("Outpost_2");
        M.bones_1 = GetHandle("bones_1");
        M.turr_1 = GetHandle("turr_1");
        M.turr_2 = GetHandle("turr_2");
        M.turr_3 = GetHandle("turr_3");
        M.turr_4 = GetHandle("turr_4");
        SetScrap(1, 0);
        Defend(M.Leader, M.Recy, 1);
        Goto(M.Recy, "bay", 1);
        SetObjectiveOn(M.Recy);
        M.Attacker = BuildObject("svscA_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 5);
    elseif (STATE == 1) then
        M.Attacker = BuildObject("svscA_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        ClearObjectives();
        AddObjective(Brief_1, "white");
        Advance(R, 10);
    elseif (STATE == 2) then
        M.Attacker = BuildObject("svscA_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 5);
    elseif (STATE == 3) then
        M.Attacker = BuildObject("svscA_D", 5, swarm2);
        Goto(M.Attacker, M.apc_3, 0);
        ClearObjectives();
        AddObjective(Brief_2, "white");
        Advance(R, 5);
    elseif (STATE == 4) then
        M.Attacker = BuildObject("svscA_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 5);
    elseif (STATE == 5) then
        M.Attacker = BuildObject("svscA_D", 5, swarm2);
        Goto(M.Attacker, M.apc_3, 0);
        ClearObjectives();
        AddObjective(Brief_3, "white");
        Advance(R, 5);
    elseif (STATE == 6) then
        M.Attacker = BuildObject("svscA_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 5);
    elseif (STATE == 7) then
        M.Attacker = BuildObject("svscA_D", 5, swarm2);
        Goto(M.Attacker, M.apc_3, 0);
        ClearObjectives();
        AddObjective(Orders_1, "white");
        Advance(R, 5);
    elseif (STATE == 8) then
        M.Attacker = BuildObject("svscA_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 5);
    elseif (STATE == 9) then
        M.Attacker = BuildObject("svscA_D", 5, swarm2);
        Goto(M.Attacker, M.apc_3, 0);
        M.PilotCount = 0;
        Advance(R);
    elseif (STATE == 10) then -- Label: LOAD_APC_1
        M.PilotCount = 1 + M.PilotCount;
        if (M.PilotCount > 5) then
            SetState(R, 14); -- Goto label NEXT
            return;
        end
        M.TempPilot = BuildObject("ispilo", 1, Pilots);
        Goto(M.TempPilot, M.apc_1, 1);
        Advance(R);
    elseif (STATE == 11) then -- Label: CHECK_PILOT_POS1
        M.ValueMain58 = IsAround(M.apc_1);
        if (M.ValueMain58 == false) then
            SetState(R, 48); -- Goto label FAILURE1
            return;
        end
        M.ValueMain60 = IsAround(M.apc_2);
        if (M.ValueMain60 == false) then
            SetState(R, 48); -- Goto label FAILURE1
            return;
        end
        M.ValueMain62 = IsAround(M.apc_3);
        if (M.ValueMain62 == false) then
            SetState(R, 48); -- Goto label FAILURE1
            return;
        end
        M.ValueMain64 = IsAround(M.TempPilot);
        if (M.ValueMain64 == false) then
            SetState(R, 49); -- Goto label FAILURE2
            return;
        end
        M.Attacker = BuildObject("svscA_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 10);
    elseif (STATE == 12) then
        M.Attacker = BuildObject("svscJ_D", 5, swarm2);
        Goto(M.Attacker, M.apc_3, 0);
        Advance(R, 10);
    elseif (STATE == 13) then
        M.ValueMain72 = Distance3D(M.TempPilot, M.apc_1);
        if (M.ValueMain72 > 12) then
            SetState(R, 11); -- Goto label CHECK_PILOT_POS1
            return;
        end
        RemoveObject(M.TempPilot);
        SetState(R, 10); -- Jump to label LOAD_APC_1
    elseif (STATE == 14) then -- Label: NEXT
        Goto(M.apc_1, M.Outpost, 1);
        M.PilotCount = 0;
        Advance(R);
    elseif (STATE == 15) then -- Label: LOAD_APC_2
        M.PilotCount = 1 + M.PilotCount;
        if (M.PilotCount > 5) then
            SetState(R, 19); -- Goto label NEXT2
            return;
        end
        M.TempPilot = BuildObject("ispilo", 1, Pilots);
        Goto(M.TempPilot, M.apc_2, 1);
        Advance(R);
    elseif (STATE == 16) then -- Label: CHECK_PILOT_POS2
        M.ValueMain82 = IsAround(M.apc_2);
        if (M.ValueMain82 == false) then
            SetState(R, 48); -- Goto label FAILURE1
            return;
        end
        M.ValueMain84 = IsAround(M.apc_3);
        if (M.ValueMain84 == false) then
            SetState(R, 48); -- Goto label FAILURE1
            return;
        end
        M.ValueMain86 = IsAround(M.TempPilot);
        if (M.ValueMain86 == false) then
            SetState(R, 49); -- Goto label FAILURE2
            return;
        end
        M.Attacker = BuildObject("svscA_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 8);
    elseif (STATE == 17) then
        M.Attacker = BuildObject("svscJ_D", 5, swarm2);
        Goto(M.Attacker, M.apc_3, 0);
        Advance(R, 8);
    elseif (STATE == 18) then
        M.ValueMain94 = Distance3D(M.TempPilot, M.apc_2);
        if (M.ValueMain94 > 12) then
            SetState(R, 16); -- Goto label CHECK_PILOT_POS2
            return;
        end
        RemoveObject(M.TempPilot);
        SetState(R, 15); -- Jump to label LOAD_APC_2
    elseif (STATE == 19) then -- Label: NEXT2
        Goto(M.apc_2, M.Outpost, 1);
        M.PilotCount = 0;
        Advance(R);
    elseif (STATE == 20) then -- Label: LOAD_APC_3
        M.PilotCount = 1 + M.PilotCount;
        if (M.PilotCount > 5) then
            SetState(R, 24); -- Goto label NEXT3
            return;
        end
        M.TempPilot = BuildObject("ispilo", 1, Pilots);
        Goto(M.TempPilot, M.apc_3, 1);
        Advance(R);
    elseif (STATE == 21) then -- Label: CHECK_PILOT_POS3
        M.ValueMain104 = IsAround(M.apc_3);
        if (M.ValueMain104 == false) then
            SetState(R, 48); -- Goto label FAILURE1
            return;
        end
        M.ValueMain106 = IsAround(M.TempPilot);
        if (M.ValueMain106 == false) then
            SetState(R, 49); -- Goto label FAILURE2
            return;
        end
        M.Attacker = BuildObject("svscA_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 6);
    elseif (STATE == 22) then
        M.Attacker = BuildObject("svscA_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 8);
    elseif (STATE == 23) then
        M.ValueMain114 = Distance3D(M.TempPilot, M.apc_3);
        if (M.ValueMain114 > 12) then
            SetState(R, 21); -- Goto label CHECK_PILOT_POS3
            return;
        end
        RemoveObject(M.TempPilot);
        SetState(R, 20); -- Jump to label LOAD_APC_3
    elseif (STATE == 24) then -- Label: NEXT3
        Goto(M.apc_3, M.Outpost, 1);
        M.PilotCount = 0;
        Advance(R);
    elseif (STATE == 25) then -- Label: CHECK_APC
        M.Attacker = BuildObject("svscA_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 6);
    elseif (STATE == 26) then
        M.Attacker = BuildObject("svscJ_D", 5, swarm1);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 6);
    elseif (STATE == 27) then
        M.Attacker = BuildObject("svscA_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 8);
    elseif (STATE == 28) then
        M.ValueMain129 = Distance3D(M.apc_3, M.Outpost);
        if (M.ValueMain129 > 60) then
            SetState(R, 25); -- Goto label CHECK_APC
            return;
        end
        RemoveObject(M.apc_1);
        RemoveObject(M.apc_2);
        RemoveObject(M.apc_3);
        ClearObjectives();
        AddObjective(Pilots, "green");
        Advance(R, 15);
    elseif (STATE == 29) then
        M.Tank_1 = BuildObject("ivtnk_BD", 1, Reinf);
        Goto(M.Tank_1, M.Recy, 0);
        Advance(R, 4);
    elseif (STATE == 30) then
        M.Tank_2 = BuildObject("ivtnk_BD", 1, Reinf);
        Goto(M.Tank_2, M.Recy, 0);
        Advance(R, 4);
    elseif (STATE == 31) then
        M.Tank_3 = BuildObject("ivtnk_BD", 1, Reinf);
        Goto(M.Tank_3, M.Recy, 0);
        Advance(R, 4);
    elseif (STATE == 32) then
        M.Serv_1 = BuildObject("ivserv_BD", 1, Reinf);
        Goto(M.Serv_1, M.Recy, 0);
        Advance(R, 10);
    elseif (STATE == 33) then
        Goto(M.Recy, "recPath_1", 1);
        Advance(R);
    elseif (STATE == 34) then -- Label: CHECK_RECY_1
        M.Attacker = BuildObject("svscA_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 25);
    elseif (STATE == 35) then
        M.Attacker = BuildObject("svscJ_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 35);
    elseif (STATE == 36) then
        M.ValueMain156 = Distance3D(M.Recy, M.bones_1);
        if (M.ValueMain156 > 100) then
            SetState(R, 34); -- Goto label CHECK_RECY_1
            return;
        end
        ClearObjectives();
        AddObjective(Warning_1, "white");
        Advance(R, 15);
    elseif (STATE == 37) then
        M.Attacker = BuildObject("svwlkL_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        M.Attacker = BuildObject("svwlkL_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        M.Attacker = BuildObject("svwlkL_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R);
    elseif (STATE == 38) then -- Label: CHECK_TURRETS
        M.Attacker = BuildObject("svscJ_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 12);
    elseif (STATE == 39) then
        M.ValueMain170 = IsAround(M.turr_1);
        if (M.ValueMain170 == true) then
            SetState(R, 38); -- Goto label CHECK_TURRETS
            return;
        end
        M.ValueMain172 = IsAround(M.turr_2);
        if (M.ValueMain172 == true) then
            SetState(R, 38); -- Goto label CHECK_TURRETS
            return;
        end
        M.ValueMain174 = IsAround(M.turr_3);
        if (M.ValueMain174 == true) then
            SetState(R, 38); -- Goto label CHECK_TURRETS
            return;
        end
        M.ValueMain176 = IsAround(M.turr_4);
        if (M.ValueMain176 == true) then
            SetState(R, 38); -- Goto label CHECK_TURRETS
            return;
        end
        ClearObjectives();
        AddObjective(Turrets, "green");
        Advance(R, 15);
    elseif (STATE == 40) then
        Goto(M.Recy, "recPath_2", 1);
        Advance(R);
    elseif (STATE == 41) then -- Label: CHECK_RECY_2
        M.Attacker = BuildObject("svscJ_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        M.Attacker = BuildObject("svscA_D", 5, swarm3);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 22);
    elseif (STATE == 42) then
        M.Attacker = BuildObject("svscJ_D", 5, swarm2);
        Goto(M.Attacker, M.Recy, 0);
        M.Attacker = BuildObject("svscA_D", 5, swarm3);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 22);
    elseif (STATE == 43) then
        M.ValueMain192 = Distance3D(M.Recy, M.Outpost_2);
        if (M.ValueMain192 > 100) then
            SetState(R, 41); -- Goto label CHECK_RECY_2
            return;
        end
        ClearObjectives();
        AddObjective(Force, "white");
        Advance(R, 10);
    elseif (STATE == 44) then
        M.Enemy_1 = BuildObject("svwlkL_D", 5, swarm5);
        Goto(M.Enemy_1, M.Recy, 0);
        M.Enemy_2 = BuildObject("svwlkL_D", 5, swarm5);
        Goto(M.Enemy_2, M.Recy, 0);
        M.Enemy_3 = BuildObject("svwlkL_D", 5, swarm5);
        Goto(M.Enemy_3, M.Recy, 0);
        M.Enemy_4 = BuildObject("svwlkL_D", 5, swarm5);
        Goto(M.Enemy_4, M.Recy, 0);
        M.Enemy_5 = BuildObject("svwlkL_D", 5, swarm5);
        Goto(M.Enemy_5, M.Recy, 0);
        M.Enemy_6 = BuildObject("svscA_D", 5, swarm5);
        Goto(M.Enemy_6, M.Recy, 0);
        M.Enemy_7 = BuildObject("svscA_D", 5, swarm5);
        Goto(M.Enemy_7, M.Recy, 0);
        M.Enemy_8 = BuildObject("svscJ_D", 5, swarm5);
        Goto(M.Enemy_8, M.Recy, 0);
        M.Enemy_9 = BuildObject("svscJ_D", 5, swarm5);
        Goto(M.Enemy_9, M.Recy, 0);
        Advance(R);
    elseif (STATE == 45) then -- Label: CHECK_FORCES
        M.Attacker = BuildObject("svscL_D", 5, swarm4);
        Goto(M.Attacker, M.Recy, 0);
        Advance(R, 12);
    elseif (STATE == 46) then
        M.ValueMain218 = IsAround(M.Enemy_1);
        if (M.ValueMain218 == true) then
            SetState(R, 45); -- Goto label CHECK_FORCES
            return;
        end
        M.ValueMain220 = IsAround(M.Enemy_2);
        if (M.ValueMain220 == true) then
            SetState(R, 45); -- Goto label CHECK_FORCES
            return;
        end
        M.ValueMain222 = IsAround(M.Enemy_3);
        if (M.ValueMain222 == true) then
            SetState(R, 45); -- Goto label CHECK_FORCES
            return;
        end
        M.ValueMain224 = IsAround(M.Enemy_4);
        if (M.ValueMain224 == true) then
            SetState(R, 45); -- Goto label CHECK_FORCES
            return;
        end
        M.ValueMain226 = IsAround(M.Enemy_5);
        if (M.ValueMain226 == true) then
            SetState(R, 45); -- Goto label CHECK_FORCES
            return;
        end
        M.ValueMain228 = IsAround(M.Enemy_6);
        if (M.ValueMain228 == true) then
            SetState(R, 45); -- Goto label CHECK_FORCES
            return;
        end
        M.ValueMain230 = IsAround(M.Enemy_7);
        if (M.ValueMain230 == true) then
            SetState(R, 45); -- Goto label CHECK_FORCES
            return;
        end
        M.ValueMain232 = IsAround(M.Enemy_8);
        if (M.ValueMain232 == true) then
            SetState(R, 45); -- Goto label CHECK_FORCES
            return;
        end
        M.ValueMain234 = IsAround(M.Enemy_9);
        if (M.ValueMain234 == true) then
            SetState(R, 45); -- Goto label CHECK_FORCES
            return;
        end
        Goto(M.Recy, M.Outpost, 1);
        Advance(R, 60);
    elseif (STATE == 47) then
        ClearObjectives();
        AddObjective(WinText, "green");
        SucceedMission(16, "FS02win.des");
        SetState(R, 50); -- Jump to label END_MISSION
    elseif (STATE == 48) then -- Label: FAILURE1
        FailMission(10, "FS02fail1.des");
        SetState(R, 50); -- Jump to label END_MISSION
    elseif (STATE == 49) then -- Label: FAILURE2
        FailMission(10, "FS02fail2.des");
        SetState(R, 50); -- Jump to label END_MISSION
    elseif (STATE == 50) then -- Label: END_MISSION
    end
end

function CheckRecy(R, STATE)
    if (STATE == 0) then -- Label: REC_IS_ALIVE
        M.Recy = GetHandle("Recy");
        M.ValueCheckRecy2 = IsAround(M.Recy);
        if (M.ValueCheckRecy2 == true) then
            SetState(R, 0); -- Goto label REC_IS_ALIVE
            return;
        end
        FailMission(10, "FS02fail3.des");
    end
end

function CheckLeader(R, STATE)
    if (STATE == 0) then -- Label: LEAD_IS_ALIVE
        M.Leader = GetHandle("Leader");
        M.ValueCheckLeader2 = IsAround(M.Leader);
        if (M.ValueCheckLeader2 == true) then
            SetState(R, 0); -- Goto label LEAD_IS_ALIVE
            return;
        end
        FailMission(10, "FS02fail4.des");
    end
end
