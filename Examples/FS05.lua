assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local Routines = {};
local RoutineToIDMap = {};


local Orders = "Blue Team will scout ahead for\nbiometal pools , we need you to\ndeploy the recycler and start\n setting up a base .";
local Pool1 = "This is Blue Team we have a pool\n for you , dropping Nav Beacon.";
local Pool2 = "We have another pool for you .";
local Pool3 = "Here's another pool , send out\nthe scavs while we search for more.";
local Ruins = "we're finding alien ruins, looks\n like they've been empty a long\ntime, we're finding remains of\nmilitary hardware must have been\na battle here.";
local Attacked = "Commander some of these defences\nare still operational , we are\nunder attack.";
local Attackers = "We have lost contact with team blue\nwe are detecting movement\njust north of their last known\nposition ,attempting to get\na visual of the area.";
local Mechana = "We seem to have accidentally\ntriggered some kind of ancient\nplanetary defense system prepare\nfor incoming attackers.";
local Snoop = "We need to shut these defence systems\ndown fast, we are picking up some\nstrange transmitions in\nthe area dispatching a snooper\nscout to investigate.";
local Snoop2 = "Commander the snooper scout has arrived,\nit will track down and identify\nthe source of the transmitions\nkeep this unit safe at all costs.";
local Coms = "Commander we've located the source of\nthe transmitions, it appears to be\nsome kind communications\nrelay, attempting to access the\nnetwork now.";
local Hacked = "We've managed to temporarily disable\nthe alien defence systems you have\napprox 30 minutes to take \nout the swarm base before they come\nback online.";
local WinText = "Well done commander, the Swarm\noutpost has been erradicated.";
local death1 = "DEPLOY NEAR THE BEACON NOT HALF\nA MILE AWAY,MISSION FAILED";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,

    -- Objects
    player = nil,
    Drop1 = nil,
    Drop2 = nil,
    Drop3 = nil,
    Drop4 = nil,
    recycler = nil,
    pool1 = nil,
    pool2 = nil,
    pool3 = nil,
    Tblue1 = nil,
    Tblue2 = nil,
    Tblue3 = nil,
    Tblue4 = nil,
    Attacker = nil,
    nav_1 = nil,
    nav_2 = nil,
    nav_3 = nil,
    ruin_1 = nil,
    MechanaFact = nil,
    coms = nil,
    power = nil,
    Snoop = nil,
    SwarmFact = nil,
    SwarmRec = nil,
    swarm_nav = nil,
    base_nav = nil,

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
    DefineRoutine(1, CheckRecy, true);
    DefineRoutine(2, CheckSnoop, false);
    DefineRoutine(3, Checkcoms, true);
    DefineRoutine(4, RecyDeploy, true);
    DefineRoutine(5, RemoveSnoop, false);
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
        "ivtank",
        "ivscout",
        "obfact",
        "obpgen",
        "svscout_L",
        "svscout_J",
        "ibnav",
        "svinst_L",
        "svscout_A",
        "svartl_L",
        "svtank_L",
        "ivsnoop_BD",
        "ibnav"
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
        Ally(1, 2);
        Ally(5, 6);
        Ally(5, 2);
        Ally(6, 2);
        M.player = GetPlayerHandle();
        M.Drop1 = GetHandle("Drop1");
        M.Drop2 = GetHandle("Drop2");
        M.Drop3 = GetHandle("Drop3");
        M.pool1 = GetHandle("pool1");
        M.pool2 = GetHandle("pool2");
        M.pool3 = GetHandle("pool3");
        M.ruin_1 = GetHandle("ruin_1");
        M.coms = GetHandle("coms");
        M.SwarmFact = GetHandle("SwarmFact");
        M.SwarmRec = GetHandle("SwarmRec");
        SetScrap(1, 40);
        SetTeamColor(2, 10, 10, 128);
        M.Tblue1 = BuildObject("ivtank", 2, "friend_1");
        SetObjectiveName(M.Tblue1, "Blue 1");
        M.Tblue2 = BuildObject("ivscout", 2, "friend_2");
        SetObjectiveName(M.Tblue2, "Blue 2");
        M.Tblue3 = BuildObject("ivscout", 2, "friend_3");
        SetObjectiveName(M.Tblue3, "Blue 3");
        M.Tblue4 = BuildObject("ivscout", 2, "friend_4");
        SetObjectiveName(M.Tblue4, "Blue 4");
        M.MechanaFact = BuildObject("obfact", 5, "FactEnemy");
        M.power = BuildObject("obpgen", 5, "pgen");
        SetAnimation(M.Drop1, "takeoff", 1);
        Advance(R, 3);
    elseif (STATE == 1) then
        StartAnimation(M.Drop1);
        Advance(R, 10);
    elseif (STATE == 2) then
        RemoveObject(M.Drop1);
        Advance(R, 3);
    elseif (STATE == 3) then
        SetAnimation(M.Drop2, "takeoff", 1);
        Advance(R, 3);
    elseif (STATE == 4) then
        StartAnimation(M.Drop2);
        Advance(R, 10);
    elseif (STATE == 5) then
        RemoveObject(M.Drop2);
        Advance(R, 3);
    elseif (STATE == 6) then
        SetAnimation(M.Drop3, "takeoff", 1);
        Advance(R, 3);
    elseif (STATE == 7) then
        StartAnimation(M.Drop3);
        Advance(R, 10);
    elseif (STATE == 8) then
        RemoveObject(M.Drop3);
        Advance(R, 3);
    elseif (STATE == 9) then
        AddObjective(Orders, "white");
        Follow(M.Tblue2, M.Tblue1, 1);
        Follow(M.Tblue3, M.Tblue1, 1);
        Follow(M.Tblue4, M.Tblue1, 1);
        Goto(M.Tblue1, "patrol_1", 1);
        Advance(R);
    elseif (STATE == 10) then -- Label: POOL_1
        M.Attacker = BuildObject("svscout_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 9);
    elseif (STATE == 11) then
        M.Attacker = BuildObject("svscout_J", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 9);
    elseif (STATE == 12) then
        M.Attacker = BuildObject("svscout_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 25);
    elseif (STATE == 13) then
        M.ValueMain60 = Distance3D(M.Tblue1, M.pool1);
        if (M.ValueMain60 > 80) then
            SetState(R, 10); -- Goto label POOL_1
            return;
        end
        Advance(R, 5);
    elseif (STATE == 14) then
        ClearObjectives();
        AddObjective(Pool1, "white");
        M.nav_1 = BuildObject("ibnav", 1, "nav1");
        SetObjectiveName(M.nav_1, "Pool 1");
        SetObjectiveOn(M.nav_1);
        Advance(R, 7);
    elseif (STATE == 15) then
        Goto(M.Tblue1, "patrol_2", 1);
        Advance(R);
    elseif (STATE == 16) then -- Label: POOL_2
        M.Attacker = BuildObject("svscout_J", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 9);
    elseif (STATE == 17) then
        M.Attacker = BuildObject("svinst_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 9);
    elseif (STATE == 18) then
        M.Attacker = BuildObject("svscout_A", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 32);
    elseif (STATE == 19) then
        M.ValueMain79 = Distance3D(M.Tblue1, M.pool2);
        if (M.ValueMain79 > 80) then
            SetState(R, 16); -- Goto label POOL_2
            return;
        end
        Advance(R, 5);
    elseif (STATE == 20) then
        ClearObjectives();
        AddObjective(Pool2, "white");
        M.nav_2 = BuildObject("ibnav", 1, "nav2");
        SetObjectiveName(M.nav_2, "Pool 2");
        SetObjectiveOn(M.nav_2);
        Advance(R, 7);
    elseif (STATE == 21) then
        Goto(M.Tblue1, "patrol_3", 1);
        Advance(R);
    elseif (STATE == 22) then -- Label: POOL_3
        M.Attacker = BuildObject("svartl_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 9);
    elseif (STATE == 23) then
        M.Attacker = BuildObject("svinst_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 9);
    elseif (STATE == 24) then
        M.Attacker = BuildObject("svscout_A", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 22);
    elseif (STATE == 25) then
        M.ValueMain98 = Distance3D(M.Tblue1, M.pool3);
        if (M.ValueMain98 > 80) then
            SetState(R, 22); -- Goto label POOL_3
            return;
        end
        Advance(R, 5);
    elseif (STATE == 26) then
        ClearObjectives();
        AddObjective(Pool3, "white");
        M.nav_3 = BuildObject("ibnav", 1, "nav3");
        SetObjectiveName(M.nav_3, "Pool 3");
        SetObjectiveOn(M.nav_3);
        Advance(R, 7);
    elseif (STATE == 27) then
        Goto(M.Tblue1, "patrol_4", 1);
        Advance(R);
    elseif (STATE == 28) then -- Label: RUIN_1
        M.Attacker = BuildObject("svartl_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 6);
    elseif (STATE == 29) then
        M.Attacker = BuildObject("svinst_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 6);
    elseif (STATE == 30) then
        M.Attacker = BuildObject("svtank_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 18);
    elseif (STATE == 31) then
        M.ValueMain117 = Distance3D(M.Tblue1, M.ruin_1);
        if (M.ValueMain117 > 80) then
            SetState(R, 28); -- Goto label RUIN_1
            return;
        end
        Ally(1, 6);
        CameraPath("camera_1", 1500, 2500, M.ruin_1);
        UnAlly(1, 6);
        Advance(R, 5);
    elseif (STATE == 32) then
        ClearObjectives();
        AddObjective(Ruins, "white");
        Advance(R, 7);
    elseif (STATE == 33) then
        Goto(M.Tblue1, "patrol_5", 1);
        Goto(M.Tblue2, "patrol_5", 1);
        Goto(M.Tblue3, "patrol_5", 1);
        Goto(M.Tblue4, "patrol_5", 1);
        UnAlly(5, 2);
        UnAlly(6, 2);
        Advance(R);
    elseif (STATE == 34) then -- Label: CHECK_BLUE1
        M.Attacker = BuildObject("svartl_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 5);
    elseif (STATE == 35) then
        M.Attacker = BuildObject("svinst_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 5);
    elseif (STATE == 36) then
        M.Attacker = BuildObject("svtank_L", 6, "swspawn_1");
        Goto(M.Attacker, M.recycler, 0);
        Advance(R, 15);
    elseif (STATE == 37) then
        M.ValueMain141 = GetHealth(M.Tblue1);
        if (M.ValueMain141 < 90) then
            SetState(R, 38); -- Goto label ATTACKED
            return;
        end
        SetState(R, 34); -- Jump to label CHECK_BLUE1
    elseif (STATE == 38) then -- Label: ATTACKED
        SetAIP("FS05.aip", 5);
        SetScrap(5, 50);
        ClearObjectives();
        AddObjective(Attacked, "red");
        Advance(R, 25);
    elseif (STATE == 39) then
        ClearObjectives();
        AddObjective(Attackers, "white");
        Advance(R, 25);
    elseif (STATE == 40) then
        Ally(1, 6);
        CameraPath("camera_2", 3500, 5500, M.MechanaFact);
        UnAlly(1, 6);
        Advance(R, 15);
    elseif (STATE == 41) then
        ClearObjectives();
        AddObjective(Mechana, "white");
        Advance(R, 250);
    elseif (STATE == 42) then
        ClearObjectives();
        AddObjective(Snoop, "white");
        Advance(R, 350);
    elseif (STATE == 43) then
        ClearObjectives();
        AddObjective(Snoop2, "white");
        SetAIP("FS05b.aip", 6);
        SetScrap(6, 40);
        M.Snoop = BuildObject("ivsnoop_BD", 2, "LZ");
        SetObjectiveOn(M.Snoop);
        Ally(5, 2);
        Advance(R, 20);
    elseif (STATE == 44) then
        SetRoutineActive(CheckSnoop, true);
        Goto(M.Snoop, "Snoop1", 1);
        M.Attacker = BuildObject("svartl_L", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 9);
    elseif (STATE == 45) then
        M.Attacker = BuildObject("svinst_L", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 9);
    elseif (STATE == 46) then
        M.Attacker = BuildObject("svscout_A", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 190);
    elseif (STATE == 47) then
        Goto(M.Snoop, "Snoop2", 1);
        M.Attacker = BuildObject("svartl_L", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 9);
    elseif (STATE == 48) then
        M.Attacker = BuildObject("svinst_L", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 9);
    elseif (STATE == 49) then
        M.Attacker = BuildObject("svscout_A", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 160);
    elseif (STATE == 50) then
        Goto(M.Snoop, "Snoop3", 1);
        M.Attacker = BuildObject("svartl_L", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 9);
    elseif (STATE == 51) then
        M.Attacker = BuildObject("svinst_L", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 9);
    elseif (STATE == 52) then
        M.Attacker = BuildObject("svscout_A", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 160);
    elseif (STATE == 53) then
        Goto(M.Snoop, M.coms, 1);
        M.Attacker = BuildObject("svartl_L", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 9);
    elseif (STATE == 54) then
        M.Attacker = BuildObject("svinst_L", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 9);
    elseif (STATE == 55) then
        M.Attacker = BuildObject("svscout_A", 6, "swspawn_1");
        Goto(M.Attacker, M.Snoop, 0);
        Advance(R, 10);
    elseif (STATE == 56) then -- Label: CHECK_SNOOP
        M.ValueMain211 = Distance3D(M.Snoop, M.coms);
        if (M.ValueMain211 > 60) then
            SetState(R, 56); -- Goto label CHECK_SNOOP
            return;
        end
        ClearObjectives();
        AddObjective(Coms, "white");
        Advance(R, 100);
    elseif (STATE == 57) then
        ClearObjectives();
        AddObjective(Hacked, "white");
        replace(power, "obpgen2", true); -- Could not translate
    elseif (STATE == 58) then
        Goto(M.Snoop, M.recycler, 1);
        SetRoutineActive(CheckSnoop, false);
        Advance(R, 5);
    elseif (STATE == 59) then
        SetRoutineActive(RemoveSnoop, true);
        StartCockpitTimer(1800);
        M.swarm_nav = BuildObject("ibnav", 1, "swarm_nav");
        SetObjectiveName(M.swarm_nav, "Swarm Base");
        SetObjectiveOn(M.swarm_nav);
        Advance(R);
    elseif (STATE == 60) then -- Label: COUNT_DOWN
        M.ValueMain227 = IsAround(M.SwarmRec);
        if (M.ValueMain227 == true) then
            SetState(R, 61); -- Goto label CONTINUE
            return;
        end
        M.ValueMain229 = IsAround(M.SwarmFact);
        if (M.ValueMain229 == false) then
            SetState(R, 62); -- Goto label WINNER
            return;
        end
        Advance(R);
    elseif (STATE == 61) then -- Label: CONTINUE
        M.ValueMain231 = GetCockpitTimer();
        if (M.ValueMain231 > 0) then
            SetState(R, 60); -- Goto label COUNT_DOWN
            return;
        end
        FailMission(10, "FS05fail1.des");
        SetState(R, 63); -- Jump to label END
    elseif (STATE == 62) then -- Label: WINNER
        ClearObjectives();
        AddObjective(WinText, "green");
        SucceedMission(16, "FS05win.des");
        Advance(R);
    elseif (STATE == 63) then -- Label: END
    end
end

function CheckRecy(R, STATE)
    if (STATE == 0) then
        M.recycler = GetHandle("recycler");
        Advance(R);
    elseif (STATE == 1) then -- Label: REC_IS_ALIVE
        M.ValueCheckRecy2 = IsAround(M.recycler);
        if (M.ValueCheckRecy2 == true) then
            SetState(R, 1); -- Goto label REC_IS_ALIVE
            return;
        end
        FailMission(10, "FS05fail2.des");
    end
end

function CheckSnoop(R, STATE)
    if (STATE == 0) then -- Label: SNOOP_IS_ALIVE
        M.ValueCheckSnoop1 = IsAround(M.Snoop);
        if (M.ValueCheckSnoop1 == true) then
            SetState(R, 0); -- Goto label SNOOP_IS_ALIVE
            return;
        end
        FailMission(10, "FS05fail3.des");
    end
end

function Checkcoms(R, STATE)
    if (STATE == 0) then -- Label: COMS_IS_ALIVE
        M.coms = GetHandle("coms");
        Advance(R, 10);
    elseif (STATE == 1) then
        M.ValueCheckcoms3 = IsAround(M.coms);
        if (M.ValueCheckcoms3 == true) then
            SetState(R, 0); -- Goto label COMS_IS_ALIVE
            return;
        end
        FailMission(10, "FS05fail5.des");
    end
end

function RecyDeploy(R, STATE)
    if (STATE == 0) then
        M.base_nav = BuildObject("ibnav", 1, "base");
        SetObjectiveName(M.base_nav, "Deploy Here");
        SetObjectiveOn(M.base_nav);
        M.recycler = GetHandle("recycler");
        Advance(R);
    elseif (STATE == 1) then -- Label: REC_DEPLOYED
        Advance(R, 10);
    elseif (STATE == 2) then
        M.ValueRecyDeploy6 = IsODF(M.recycler, "ibrecy_BD5");
        if (M.ValueRecyDeploy6 == false) then
            SetState(R, 1); -- Goto label REC_DEPLOYED
            return;
        end
        M.ValueRecyDeploy8 = Distance3D(M.recycler, M.base_nav);
        if (M.ValueRecyDeploy8 > 250) then
            SetState(R, 3); -- Goto label DEATH
            return;
        end
        SetState(R, 4); -- Jump to label FINNISHED
    elseif (STATE == 3) then -- Label: DEATH
        ClearObjectives();
        AddObjective(death1, "red");
        FailMission(10, "FS05fail4.des");
        Advance(R);
    elseif (STATE == 4) then -- Label: FINNISHED
        SetRoutineActive(RecyDeploy, false);
    end
end

function RemoveSnoop(R, STATE)
    if (STATE == 0) then -- Label: SNOOP_AT_REC
        Advance(R, 10);
    elseif (STATE == 1) then
        M.ValueRemoveSnoop2 = Distance3D(M.Snoop, M.recycler);
        if (M.ValueRemoveSnoop2 > 40) then
            SetState(R, 0); -- Goto label SNOOP_AT_REC
            return;
        end
        RemoveObject(M.Snoop);
        SetRoutineActive(RemoveSnoop, false);
    end
end
