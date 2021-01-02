assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _ScripterCore = require('_ScripterCore');

local Routines = {};
local RoutineToIDMap = {};


local Orders = "The Swarm is attempting to escape\ntake out those launchers\nwe've dropped navs to help you,\nbe quick, time is short.";
local Orders2 = "Well done Commander, now build a\nbase and destroy the\nremaining swarm forces, a\nrecycler is on it's way\nto you.";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,
    AddObjectData = nil,

    -- Objects
    S1recy = nil,
    S2recy = nil,
    launcher1 = nil,
    launcher2 = nil,
    launcher3 = nil,
    Player = nil,
    Nav1 = nil,
    Nav2 = nil,
    Nav3 = nil,
    BaseNav = nil,
    Recycler = nil,
    PRover = nil,
    PRproc = nil,
    PRgt1 = nil,
    PRgt2 = nil,
    PRgt3 = nil,
    PRgt4 = nil,
    PRgt5 = nil,
    PRsbay = nil,
    PRcom = nil,
    PRserv1 = nil,
    PRserv2 = nil,
    PRserv3 = nil,
    Turr1 = nil,
    Turr2 = nil,
    Turr3 = nil,

    -- Variables

    -- Return Variables
    ValueMain38 = nil,
    ValueMain40 = nil,
    ValueMain44 = nil,
    ValueMain46 = nil,
    ValueMain50 = nil,
    ValueMain52 = nil,
    ValueMain79 = nil,
    ValueMain81 = nil,
    ValueCheckRecy2 = nil,

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
    DefineRoutine("CheckRecy", CheckRecy, false);
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
        "sbrecy00",
        "pbproc",
        "Pvcons",
        "Pbgtow",
        "Pbcoms",
        "Pbsbay",
        "Pvserv",
        "ibnav",
        "ivrecyBD",
        "ivtur_BD"
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
        Ally(5, 6);
        Ally(1, 2);
        M.S1recy = GetHandle("S1recy");
        M.launcher1 = GetHandle("launcher1");
        M.launcher2 = GetHandle("launcher2");
        M.launcher3 = GetHandle("launcher3");
        M.S2recy = BuildObject("sbrecy00", 5, "S2recy");
        M.PRproc = BuildObject("pbproc", 2, "PRproc");
        M.PRover = BuildObject("Pvcons", 2, "PRover");
        M.PRgt1 = BuildObject("Pbgtow", 2, "PRgt1");
        M.PRgt2 = BuildObject("Pbgtow", 2, "PRgt2");
        M.PRgt3 = BuildObject("Pbgtow", 2, "PRgt3");
        M.PRgt4 = BuildObject("Pbgtow", 2, "PRgt4");
        M.PRgt5 = BuildObject("Pbgtow", 2, "PRgt5");
        M.PRcom = BuildObject("Pbcoms", 2, "PRcom");
        M.PRsbay = BuildObject("Pbsbay", 2, "PRsbay");
        M.PRserv1 = BuildObject("Pvserv", 2, "PRover");
        M.PRserv2 = BuildObject("Pvserv", 2, "PRover");
        M.PRserv3 = BuildObject("Pvserv", 2, "PRover");
        SetScrap(2, 40);
        SetScrap(5, 40);
        SetScrap(6, 40);
        SetAIP("FS08_s1.aip", 6);
        SetAIP("FS08_s2.aip", 5);
        SetAIP("FS08_p1.aip", 2);
        M.Nav1 = BuildObject("ibnav", 1, "Nav1");
        SetObjectiveName(M.Nav1, "Launcher1");
        SetObjectiveOn(M.Nav1);
        M.Nav2 = BuildObject("ibnav", 1, "Nav2");
        SetObjectiveName(M.Nav2, "Launcher2");
        SetObjectiveOn(M.Nav2);
        M.Nav3 = BuildObject("ibnav", 1, "Nav3");
        SetObjectiveName(M.Nav3, "Launcher3");
        SetObjectiveOn(M.Nav3);
        ClearObjectives();
        AddObjective(Orders, "white");
        StartCockpitTimer(600);
        Advance(R);
    elseif (STATE == 1) then -- Label: COUNT_DOWN
        M.ValueMain38 = IsAround(M.launcher1);
        if (M.ValueMain38 == false) then
            SetState(R, 2); -- Goto label COUNT_DOWN2
            return;
        end
        M.ValueMain40 = GetCockpitTimer();
        if (M.ValueMain40 > 0) then
            SetState(R, 1); -- Goto label COUNT_DOWN
            return;
        end
        FailMission(10, "FS08fail1.des");
        SetState(R, 8); -- Jump to label END
    elseif (STATE == 2) then -- Label: COUNT_DOWN2
        M.ValueMain44 = IsAround(M.launcher2);
        if (M.ValueMain44 == false) then
            SetState(R, 3); -- Goto label COUNT_DOWN3
            return;
        end
        M.ValueMain46 = GetCockpitTimer();
        if (M.ValueMain46 > 0) then
            SetState(R, 2); -- Goto label COUNT_DOWN2
            return;
        end
        FailMission(10, "FS08fail1.des");
        SetState(R, 8); -- Jump to label END
    elseif (STATE == 3) then -- Label: COUNT_DOWN3
        M.ValueMain50 = IsAround(M.launcher3);
        if (M.ValueMain50 == false) then
            SetState(R, 4); -- Goto label NEXT
            return;
        end
        M.ValueMain52 = GetCockpitTimer();
        if (M.ValueMain52 > 0) then
            SetState(R, 3); -- Goto label COUNT_DOWN3
            return;
        end
        FailMission(10, "FS08fail1.des");
        SetState(R, 8); -- Jump to label END
    elseif (STATE == 4) then -- Label: NEXT
        StopCockpitTimer();
        SetObjectiveOff(M.Nav1);
        SetObjectiveOff(M.Nav2);
        SetObjectiveOff(M.Nav3);
        M.BaseNav = BuildObject("ibnav", 1, "BaseNav");
        SetObjectiveName(M.BaseNav, "Deploy Recycler Here");
        SetObjectiveOn(M.BaseNav);
        ClearObjectives();
        AddObjective(Orders2, "green");
        Advance(R, 10);
    elseif (STATE == 5) then
        M.Recycler = BuildObject("ivrecyBD", 1, "Recycler");
        M.Turr1 = BuildObject("ivtur_BD", 1, "Recycler");
        M.Turr2 = BuildObject("ivtur_BD", 1, "Recycler");
        M.Turr3 = BuildObject("ivtur_BD", 1, "Recycler");
        SetAIP("FS08_s3.aip", 6);
        SetAIP("FS08_s4.aip", 5);
        SetAIP("FS08_p2.aip", 2);
        SetScrap(1, 40);
        Goto(M.Recycler, M.BaseNav, 0);
        Follow(M.Turr1, M.Recycler, 0);
        Follow(M.Turr2, M.Recycler, 0);
        Follow(M.Turr3, M.Recycler, 0);
        SetRoutineActive(CheckRecy, true);
        Advance(R);
    elseif (STATE == 6) then -- Label: CHECK_SWARM1
        M.ValueMain79 = IsAround(M.S1recy);
        if (M.ValueMain79 == true) then
            SetState(R, 6); -- Goto label CHECK_SWARM1
            return;
        end
        Advance(R);
    elseif (STATE == 7) then -- Label: CHECK_SWARM2
        M.ValueMain81 = IsAround(M.S2recy);
        if (M.ValueMain81 == true) then
            SetState(R, 7); -- Goto label CHECK_SWARM2
            return;
        end
        SucceedMission(10, "FS08win.des");
        Advance(R);
    elseif (STATE == 8) then -- Label: END
    end
end

function CheckRecy(R, STATE)
    if (STATE == 0) then -- Label: RECY_IS_ALIVE
        Advance(R, 10);
    elseif (STATE == 1) then
        M.ValueCheckRecy2 = IsAround(M.Recycler);
        if (M.ValueCheckRecy2 == true) then
            SetState(R, 0); -- Goto label RECY_IS_ALIVE
            return;
        end
        FailMission(10, "FS08fail2.des");
    end
end
