assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _ScripterCore = require('_ScripterCore');

local Routines = {};
local RoutineToIDMap = {};


local Orders1 = "Protect the Recycler convoy as\nit makes it's way through the\njungle. The more swarm AA units\nyou destroy the more dropships\nwe can send in.";
local AA1Dead = "Well done you've taken out a\ngroup of AA units , A Dropship\n with reinforcements is on it's\nway down to you.";
local AtBase = "Congratulations you made it\nthrough , now establish a base\n and take out the swarm\ninstallation to the\nnorth west.";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,
    AddObjectData = nil,

    -- Objects
    drop = nil,
    escort1 = nil,
    escort2 = nil,
    escort3 = nil,
    escort4 = nil,
    recy = nil,
    attacker = nil,
    swarmAA1 = nil,
    swarmAA2 = nil,
    swarmAA3 = nil,
    swarmAA4 = nil,
    swarmAA5 = nil,
    swarmAA6 = nil,
    swarmAA7 = nil,
    swarmAA8 = nil,
    swarmAA9 = nil,
    swarmAA10 = nil,
    reinforce = nil,
    swarmrec = nil,

    -- Variables

    -- Return Variables
    ValueMain39 = nil,
    ValueMain51 = nil,
    ValueMain63 = nil,
    ValueMain78 = nil,
    ValueMain92 = nil,
    ValueCheckAA14 = nil,
    ValueCheckAA16 = nil,
    ValueCheckAA18 = nil,
    ValueCheckAA23 = nil,
    ValueCheckAA25 = nil,
    ValueCheckAA34 = nil,
    ValueCheckAA36 = nil,
    ValueCheckAA38 = nil,
    ValueCheckAA43 = nil,
    ValueCheckAA45 = nil,
    ValueCheckrec3 = nil,

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
    DefineRoutine("Main", Main, true);
    DefineRoutine("CheckAA1", CheckAA1, true);
    DefineRoutine("CheckAA2", CheckAA2, true);
    DefineRoutine("CheckAA3", CheckAA3, true);
    DefineRoutine("CheckAA4", CheckAA4, true);
    DefineRoutine("Checkrec", Checkrec, true);
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
        "svscout_L",
        "svscout_J",
        "svtank_L",
        "svinst_J",
        "sbrecy00",
        "ivsct_BD",
        "ivserv_BD",
        "ivserv_BD",
        "ivsct_BD",
        "ivtnk_BD",
        "ivltankBD"
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

function AddObject(handle)
    if (M.AddObjectData == nil) then
        return;
    end
    
    local routine = Routines[M.AddObjectData[1]];
    local handleName = M.AddObjectData[2];

    M[handleName] = handle;
    SetRoutineActive(routine, true)
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
        M.recy = GetHandle("recy");
        M.escort1 = GetHandle("escort1");
        M.escort2 = GetHandle("escort2");
        M.escort3 = GetHandle("escort3");
        M.escort4 = GetHandle("escort4");
        SetScrap(1, 40);
        Goto(M.recy, "recpath_1", 1);
        Advance(R, 2);
    elseif (STATE == 1) then
        Follow(M.escort1, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 2) then
        Follow(M.escort2, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 3) then
        Follow(M.escort3, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 4) then
        Follow(M.escort4, M.recy, 1);
        ClearObjectives();
        AddObjective(Orders1, "white");
        M.attacker = BuildObject("svscA_D", 6, "swarm1");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 5) then
        M.attacker = BuildObject("svscA_D", 6, "swarm1");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 6) then
        M.attacker = BuildObject("svscout_L", 6, "swarm1");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 7) then
        M.attacker = BuildObject("svscout_L", 6, "swarm1");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 8) then
        M.attacker = BuildObject("svscout_L", 6, "swarm1");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 9) then -- Label: IN_TRANSIT
        M.attacker = BuildObject("svscout_L", 6, "swarm2");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 10) then
        M.attacker = BuildObject("svscout_L", 6, "swarm2");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 50);
    elseif (STATE == 11) then
        M.ValueMain39 = GetCurrentCommand(M.recy);
        if (M.ValueMain39 == 0) then
            SetState(R, 12); -- Goto label FINNISHED_MOVING
            return;
        end
        SetState(R, 9); -- Jump to label IN_TRANSIT
    elseif (STATE == 12) then -- Label: FINNISHED_MOVING
        Advance(R, 40);
    elseif (STATE == 13) then
        Goto(M.recy, "recpath_2", 1);
        Advance(R, 10);
    elseif (STATE == 14) then -- Label: IN_TRANSIT2
        M.attacker = BuildObject("svscout_L", 6, "swarm2");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 15) then
        M.attacker = BuildObject("svscout_L", 6, "swarm2");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 50);
    elseif (STATE == 16) then
        M.ValueMain51 = GetCurrentCommand(M.recy);
        if (M.ValueMain51 == 0) then
            SetState(R, 17); -- Goto label FINNISHED_MOVING2
            return;
        end
        SetState(R, 14); -- Jump to label IN_TRANSIT2
    elseif (STATE == 17) then -- Label: FINNISHED_MOVING2
        Advance(R, 40);
    elseif (STATE == 18) then
        Goto(M.recy, "recpath_3", 1);
        Advance(R, 10);
    elseif (STATE == 19) then -- Label: IN_TRANSIT3
        M.attacker = BuildObject("svscout_J", 6, "swarm3");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 20) then
        M.attacker = BuildObject("svtank_L", 6, "swarm3");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 50);
    elseif (STATE == 21) then
        M.ValueMain63 = GetCurrentCommand(M.recy);
        if (M.ValueMain63 == 0) then
            SetState(R, 22); -- Goto label FINNISHED_MOVING3
            return;
        end
        SetState(R, 19); -- Jump to label IN_TRANSIT3
    elseif (STATE == 22) then -- Label: FINNISHED_MOVING3
        Advance(R, 40);
    elseif (STATE == 23) then
        Goto(M.recy, "recpath_4", 1);
        Advance(R, 10);
    elseif (STATE == 24) then -- Label: IN_TRANSIT4
        M.attacker = BuildObject("svscout_J", 6, "swarm4");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 25) then
        M.attacker = BuildObject("svtank_L", 6, "swarm4");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 2);
    elseif (STATE == 26) then
        M.attacker = BuildObject("svinst_J", 6, "swarm4");
        Attack(M.attacker, M.recy, 1);
        Advance(R, 50);
    elseif (STATE == 27) then
        M.ValueMain78 = GetCurrentCommand(M.recy);
        if (M.ValueMain78 == 0) then
            SetState(R, 28); -- Goto label FINNISHED_MOVING4
            return;
        end
        SetState(R, 24); -- Jump to label IN_TRANSIT4
    elseif (STATE == 28) then -- Label: FINNISHED_MOVING4
        Advance(R, 20);
    elseif (STATE == 29) then
        Goto(M.recy, "base", 0);
        Goto(M.escort1, "base", 0);
        Goto(M.escort2, "base", 0);
        Goto(M.escort3, "base", 0);
        Goto(M.escort4, "base", 0);
        ClearObjectives();
        AddObjective(AtBase, "green");
        M.swarmrec = BuildObject("sbrecy00", 6, "swarmrec");
        SetScrap(6, 40);
        SetAIP("FS09_s1.aip", 6);
        Advance(R);
    elseif (STATE == 30) then -- Label: CHECK_SWARMREC
        M.ValueMain92 = IsAround(M.swarmrec);
        if (M.ValueMain92 == true) then
            SetState(R, 30); -- Goto label CHECK_SWARMREC
            return;
        end
        SucceedMission(10, "FS09win.des");
    end
end

function CheckAA1(R, STATE)
    if (STATE == 0) then
        M.swarmAA1 = GetHandle("swarmAA1");
        M.swarmAA2 = GetHandle("swarmAA2");
        M.swarmAA3 = GetHandle("swarmAA3");
        Advance(R);
    elseif (STATE == 1) then -- Label: AA1_IS_ALIVE
        M.ValueCheckAA14 = IsAround(M.swarmAA1);
        if (M.ValueCheckAA14 == true) then
            SetState(R, 1); -- Goto label AA1_IS_ALIVE
            return;
        end
        M.ValueCheckAA16 = IsAround(M.swarmAA2);
        if (M.ValueCheckAA16 == true) then
            SetState(R, 1); -- Goto label AA1_IS_ALIVE
            return;
        end
        M.ValueCheckAA18 = IsAround(M.swarmAA3);
        if (M.ValueCheckAA18 == true) then
            SetState(R, 1); -- Goto label AA1_IS_ALIVE
            return;
        end
        ClearObjectives();
        AddObjective(AA1Dead, "green");
        Advance(R, 15);
    elseif (STATE == 2) then
        M.reinforce = BuildObject("ivsct_BD", 1, "troops");
        SetGroup(M.reinforce, 5);
        M.reinforce = BuildObject("ivsct_BD", 1, "troops");
        SetGroup(M.reinforce, 5);
        M.reinforce = BuildObject("ivserv_BD", 1, "troops");
        SetGroup(M.reinforce, 6);
    end
end

function CheckAA2(R, STATE)
    if (STATE == 0) then
        M.swarmAA4 = GetHandle("swarmAA4");
        M.swarmAA5 = GetHandle("swarmAA5");
        Advance(R);
    elseif (STATE == 1) then -- Label: AA2_IS_ALIVE
        M.ValueCheckAA23 = IsAround(M.swarmAA4);
        if (M.ValueCheckAA23 == true) then
            SetState(R, 1); -- Goto label AA2_IS_ALIVE
            return;
        end
        M.ValueCheckAA25 = IsAround(M.swarmAA5);
        if (M.ValueCheckAA25 == true) then
            SetState(R, 1); -- Goto label AA2_IS_ALIVE
            return;
        end
        ClearObjectives();
        AddObjective(AA1Dead, "green");
        Advance(R, 15);
    elseif (STATE == 2) then
        M.reinforce = BuildObject("ivserv_BD", 1, "troops");
        SetGroup(M.reinforce, 6);
        M.reinforce = BuildObject("ivsct_BD", 1, "troops");
        SetGroup(M.reinforce, 5);
        M.reinforce = BuildObject("ivsct_BD", 1, "troops");
        SetGroup(M.reinforce, 5);
    end
end

function CheckAA3(R, STATE)
    if (STATE == 0) then
        M.swarmAA6 = GetHandle("swarmAA6");
        M.swarmAA7 = GetHandle("swarmAA7");
        M.swarmAA8 = GetHandle("swarmAA8");
        Advance(R);
    elseif (STATE == 1) then -- Label: AA3_IS_ALIVE
        M.ValueCheckAA34 = IsAround(M.swarmAA6);
        if (M.ValueCheckAA34 == true) then
            SetState(R, 1); -- Goto label AA3_IS_ALIVE
            return;
        end
        M.ValueCheckAA36 = IsAround(M.swarmAA7);
        if (M.ValueCheckAA36 == true) then
            SetState(R, 1); -- Goto label AA3_IS_ALIVE
            return;
        end
        M.ValueCheckAA38 = IsAround(M.swarmAA8);
        if (M.ValueCheckAA38 == true) then
            SetState(R, 1); -- Goto label AA3_IS_ALIVE
            return;
        end
        ClearObjectives();
        AddObjective(AA1Dead, "green");
        Advance(R, 15);
    elseif (STATE == 2) then
        M.reinforce = BuildObject("ivtnk_BD", 1, "troops");
        SetGroup(M.reinforce, 7);
        M.reinforce = BuildObject("ivtnk_BD", 1, "troops");
        SetGroup(M.reinforce, 7);
        M.reinforce = BuildObject("ivtnk_BD", 1, "troops");
        SetGroup(M.reinforce, 7);
    end
end

function CheckAA4(R, STATE)
    if (STATE == 0) then
        M.swarmAA9 = GetHandle("swarmAA9");
        M.swarmAA10 = GetHandle("swarmAA10");
        Advance(R);
    elseif (STATE == 1) then -- Label: AA4_IS_ALIVE
        M.ValueCheckAA43 = IsAround(M.swarmAA9);
        if (M.ValueCheckAA43 == true) then
            SetState(R, 1); -- Goto label AA4_IS_ALIVE
            return;
        end
        M.ValueCheckAA45 = IsAround(M.swarmAA10);
        if (M.ValueCheckAA45 == true) then
            SetState(R, 1); -- Goto label AA4_IS_ALIVE
            return;
        end
        ClearObjectives();
        AddObjective(AA1Dead, "green");
        Advance(R, 15);
    elseif (STATE == 2) then
        M.reinforce = BuildObject("ivltankBD", 1, "troops");
        SetGroup(M.reinforce, 8);
        M.reinforce = BuildObject("ivltankBD", 1, "troops");
        SetGroup(M.reinforce, 8);
        M.reinforce = BuildObject("ivltankBD", 1, "troops");
        SetGroup(M.reinforce, 8);
    end
end

function Checkrec(R, STATE)
    if (STATE == 0) then
        M.recy = GetHandle("recy");
        Advance(R);
    elseif (STATE == 1) then -- Label: REC_IS_ALIVE
        Advance(R, 10);
    elseif (STATE == 2) then
        M.ValueCheckrec3 = IsAround(M.recy);
        if (M.ValueCheckrec3 == true) then
            SetState(R, 1); -- Goto label REC_IS_ALIVE
            return;
        end
        FailMission(10, "FS09fail1.des");
    end
end
