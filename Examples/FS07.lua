assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _ScripterCore = require('_ScripterCore');

local Routines = {};
local RoutineToIDMap = {};


local Orders1 = "Commander setup base at the nav\nbeacon,prevent the swarm from\nleaving the infested zone.\nDo not enter this zone\nmechana defenses are still active.";
local death1 = "NEAR THE BEACON NOT HALF\nA MILE AWAY,MISSION FAILED";
local EDF = "Commander the EDF base to the\neast has been compromised,their\nRecycler is lost,take your\nforces and defend the area\nuntil a replacement arrives.";
local NewOrders = "Well done the breach is sealed\nhowever a significant swarm force\nhas broken through find\nand eliminate them,they\nwere last spotted moving north.";
local SwarmDead = "The Swarm force has been\ndestroyed.We are picking up\npowerful energy readings from\nthe ruins in this sector\ninvestigate and find the source.";
local Probe = "Commander whatever the hell\nthat thing is, guard it\nwith your life,backup is on\nit's way.";
local Orders2 = "We've dropped a nav at the\nlast known position of the\nswarm force,a powerful energy\nsource in the area is\nblocking our scans.";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,
    AddObjectData = nil,

    -- Objects
    Probe = nil,
    Player = nil,
    Recycler = nil,
    Attacker = nil,
    Attacker2 = nil,
    t3rec = nil,
    t3Recycler = nil,
    t3fact = nil,
    t3power1 = nil,
    t3power2 = nil,
    t3power3 = nil,
    t3com1 = nil,
    t3com2 = nil,
    t3GT1 = nil,
    t3GT2 = nil,
    t3GT3 = nil,
    PRproc = nil,
    PRfact = nil,
    PRcyard = nil,
    PRpow_1 = nil,
    PRpow_2 = nil,
    PRpow_3 = nil,
    PRpow_4 = nil,
    PRGT_1 = nil,
    PRGT_2 = nil,
    PRGT_3 = nil,
    PRGT_4 = nil,
    PRGT_5 = nil,
    PRmine_1 = nil,
    PRmine_2 = nil,
    PRmine_3 = nil,
    PRcons = nil,
    base_nav = nil,
    swarm_nav = nil,
    Brec = nil,
    PlayerFac = nil,
    PlayerPow = nil,
    PlayerBay = nil,
    PlayerArmo = nil,
    PRoverlord = nil,
    Sbuild = nil,
    Swalk1 = nil,
    Swalk2 = nil,
    Backup1 = nil,
    Backup = nil,
    PRserv_1 = nil,
    PRserv_2 = nil,
    Mlead1 = nil,
    Mlead2 = nil,
    Mwing1 = nil,
    Mwing2 = nil,
    Mwing3 = nil,
    Mwing4 = nil,
    Mwing5 = nil,
    SwarmRec = nil,
    newguy = nil,

    -- Variables

    -- Return Variables
    ValueMain57 = nil,
    ValueMain59 = nil,
    ValueMain75 = nil,
    ValueMain87 = nil,
    ValueMain91 = nil,
    ValueMain94 = nil,
    ValueMain111 = nil,
    ValueMain131 = nil,
    ValueMain145 = nil,
    ValueMain214 = nil,
    ValueMain217 = nil,
    ValueMain220 = nil,
    ValueMain223 = nil,
    ValueMain229 = nil,
    ValueMain299 = nil,
    ValueMain301 = nil,
    ValueCheckOverlord2 = nil,
    ValueCheckRecy2 = nil,
    ValueCheckT3Recy2 = nil,
    ValueCheckProbe2 = nil,
    ValueCheckBackup2 = nil,
    Valuechanges11 = nil,
    Valuechanges13 = nil,
    Valuechanges1 = nil,
    Valuechanges3 = nil,

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
    DefineRoutine("SwarmAttackWaves1", SwarmAttackWaves1, false);
    DefineRoutine("SwarmAttackWaves2", SwarmAttackWaves2, false);
    DefineRoutine("CheckOverlord", CheckOverlord, false);
    DefineRoutine("CheckRecy", CheckRecy, true);
    DefineRoutine("CheckT3Recy", CheckT3Recy, false);
    DefineRoutine("CheckProbe", CheckProbe, false);
    DefineRoutine("CheckBackup", CheckBackup, false);
    DefineRoutine("new1", new1, true);
    DefineRoutine("changes1", changes1, false);
    DefineRoutine("new", new, false);
    DefineRoutine("changes", changes, false);
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
        "ibfact",
        "ibrecy",
        "ibpgen",
        "ibcbun",
        "ibgtow",
        "pbproc",
        "pbfact",
        "pbrecy",
        "pbpgen",
        "pbgtow",
        "pbsturr",
        "pbmturr",
        "pvcons",
        "pvserv",
        "Svcons",
        "ibnav",
        "svscL_D",
        "svtank_J",
        "svinst_J",
        "svwalk_J",
        "svwalk_L",
        "ivrecy",
        "Sbrecy00",
        "svtank_J2",
        "svinst_J2",
        "svwalk_J2",
        "OvCruise",
        "OvBeam",
        "pvrckt2",
        "pvtank",
        "pvscout",
        "pvrckt",
        "pvmisl",
        "OvMisl",
        "Ovwalk",
        "svscL_D",
        "svartl_J",
        "svinst_J",
        "svwalk_J"
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
        Ally(1, 2);
        Ally(1, 3);
        Ally(2, 3);
        Ally(5, 6);
        Ally(5, 2);
        SetScrap(1, 40);
        SetScrap(2, 40);
        SetScrap(3, 40);
        SetScrap(5, 40);
        M.Probe = GetHandle("Probe");
        M.Recycler = GetHandle("Recycler");
        M.t3fact = BuildObject("ibfact", 3, "t3fact");
        M.t3rec = BuildObject("ibrecy", 3, "t3rec");
        M.t3power1 = BuildObject("ibpgen", 3, "t3power1");
        M.t3power2 = BuildObject("ibpgen", 3, "t3power2");
        M.t3power3 = BuildObject("ibpgen", 3, "t3power3");
        M.t3com1 = BuildObject("ibcbun", 3, "t3com1");
        M.t3com2 = BuildObject("ibcbun", 3, "t3com2");
        M.t3GT1 = BuildObject("ibgtow", 3, "t3GT1");
        M.t3GT2 = BuildObject("ibgtow", 3, "t3GT2");
        M.t3GT3 = BuildObject("ibgtow", 3, "t3GT3");
        M.PRproc = BuildObject("pbproc", 2, "PRproc");
        M.PRfact = BuildObject("pbfact", 2, "PRfact");
        M.PRcyard = BuildObject("pbrecy", 2, "PRcyard");
        M.PRpow_1 = BuildObject("pbpgen", 2, "PRpow_1");
        M.PRpow_2 = BuildObject("pbpgen", 2, "PRpow_2");
        M.PRpow_3 = BuildObject("pbpgen", 2, "PRpow_3");
        M.PRpow_3 = BuildObject("pbpgen", 2, "PRpow_4");
        M.PRGT_1 = BuildObject("pbgtow", 2, "PRGT_1");
        M.PRGT_2 = BuildObject("pbgtow", 2, "PRGT_2");
        M.PRGT_3 = BuildObject("pbgtow", 2, "PRGT_3");
        M.PRGT_4 = BuildObject("pbgtow", 2, "PRGT_4");
        M.PRGT_4 = BuildObject("pbgtow", 2, "PRGT_5");
        M.PRmine_1 = BuildObject("pbsturr", 2, "PRmine_1");
        M.PRmine_2 = BuildObject("pbmturr", 2, "PRmine_2");
        M.PRmine_3 = BuildObject("pbsturr", 2, "PRmine_3");
        M.PRoverlord = BuildObject("pvcons", 2, "PRove");
        M.PRserv_1 = BuildObject("pvserv", 2, "PRserv_1");
        M.PRserv_2 = BuildObject("pvserv", 2, "PRserv_2");
        M.Sbuild = BuildObject("Svcons", 5, "Sbuild");
        SetAIP("FS07_s1.aip", 5);
        M.base_nav = BuildObject("ibnav", 1, "base");
        SetObjectiveName(M.base_nav, "Base Area");
        SetObjectiveOn(M.base_nav);
        ClearObjectives();
        AddObjective(Orders1, "white");
        SetAIP("FS07_e1.aip", 3);
        SetAIP("FS07_p1.aip", 2);
        SetRoutineActive(CheckOverlord, true);
        Advance(R);
    elseif (STATE == 1) then -- Label: REC_DEPLOYED
        M.Attacker = BuildObject("svscL_D", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.Recycler, 1);
        M.Attacker = BuildObject("svscL_D", 5, "swarmSpawn_2");
        Attack(M.Attacker, M.PRcyard, 1);
        M.Attacker = BuildObject("svscL_D", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3rec, 1);
        Advance(R, 10);
    elseif (STATE == 2) then
        M.ValueMain57 = IsODF(M.Recycler, "ibrecy_BD");
        if (M.ValueMain57 == false) then
            SetState(R, 1); -- Goto label REC_DEPLOYED
            return;
        end
        M.ValueMain59 = Distance3D(M.Recycler, M.base_nav);
        if (M.ValueMain59 > 250) then
            SetState(R, 3); -- Goto label DEATH
            return;
        end
        SetState(R, 4); -- Jump to label CONTINUE_1
    elseif (STATE == 3) then -- Label: DEATH
        ClearObjectives();
        AddObjective(death1, "red");
        FailMission(10, "FS07fail1.des");
        SetState(R, 40); -- Jump to label END
    elseif (STATE == 4) then -- Label: CONTINUE_1
        Advance(R, 8);
    elseif (STATE == 5) then
        M.Attacker = BuildObject("svscL_D", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.Recycler, 1);
        Advance(R, 8);
    elseif (STATE == 6) then
        M.Attacker = BuildObject("svscL_D", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.Recycler, 1);
        M.Attacker = BuildObject("svscL_D", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3rec, 1);
        M.PlayerPow = GetHandle("unnamed_ibpgenBD");
        M.ValueMain75 = IsAround(M.PlayerPow);
        if (M.ValueMain75 == false) then
            SetState(R, 4); -- Goto label CONTINUE_1
            return;
        end
        SetRoutineActive(SwarmAttackWaves1, true);
        Advance(R);
    elseif (STATE == 7) then -- Label: CONTINUE_2
        Advance(R, 9);
    elseif (STATE == 8) then
        M.Attacker = BuildObject("svtank_J", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.Recycler, 1);
        Advance(R, 9);
    elseif (STATE == 9) then
        M.Attacker = BuildObject("svscL_D", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.Recycler, 1);
        M.Attacker = BuildObject("svtank_J", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3fact, 1);
        M.PlayerFac = GetHandle("unnamed_ibfactBD");
        M.ValueMain87 = IsAround(M.PlayerFac);
        if (M.ValueMain87 == false) then
            SetState(R, 7); -- Goto label CONTINUE_2
            return;
        end
        SetRoutineActive(SwarmAttackWaves2, true);
        Advance(R);
    elseif (STATE == 10) then -- Label: CONTINUE_3
        M.PlayerBay = GetHandle("unnamed_ibsbayBD");
        M.ValueMain91 = IsAround(M.PlayerBay);
        if (M.ValueMain91 == true) then
            SetState(R, 12); -- Goto label PART_2
            return;
        end
        M.PlayerArmo = GetHandle("unnamed_ibarmoBD");
        M.ValueMain94 = IsAround(M.PlayerArmo);
        if (M.ValueMain94 == false) then
            SetState(R, 10); -- Goto label CONTINUE_3
            return;
        end
        SetRoutineActive(new1, false);
        Advance(R, 10);
    elseif (STATE == 11) then
        SetRoutineActive(new, true);
        Advance(R);
    elseif (STATE == 12) then -- Label: PART_2
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.t3rec, 1);
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_2");
        Attack(M.Attacker, M.t3rec, 1);
        M.Attacker = BuildObject("svwalk_J", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3GT1, 1);
        Advance(R, 15);
    elseif (STATE == 13) then
        M.Attacker = BuildObject("svwalk_J", 5, "swarmSpawn_2");
        Attack(M.Attacker, M.t3GT3, 1);
        M.Attacker = BuildObject("svwalk_L", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3fact, 1);
        Advance(R, 15);
    elseif (STATE == 14) then
        M.ValueMain111 = IsAround(M.t3rec);
        if (M.ValueMain111 == true) then
            SetState(R, 12); -- Goto label PART_2
            return;
        end
        UnAlly(5, 2);
        ClearObjectives();
        AddObjective(EDF, "red");
        SetRoutineActive(SwarmAttackWaves1, false);
        SetRoutineActive(SwarmAttackWaves2, false);
        M.t3Recycler = BuildObject("ivrecy", 3, "t3Recycler");
        Goto(M.t3Recycler, "t3rec_path1", 1);
        SetObjectiveOn(M.t3Recycler);
        SetRoutineActive(CheckT3Recy, true);
        Advance(R);
    elseif (STATE == 15) then -- Label: T3REC_AT_PRBASE
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.t3Recycler, 1);
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_2");
        Attack(M.Attacker, M.t3Recycler, 1);
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3Recycler, 1);
        M.Attacker = BuildObject("svtank_J", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3Recycler, 1);
        Advance(R, 55);
    elseif (STATE == 16) then
        M.ValueMain131 = GetCurrentCommand(M.t3Recycler);
        if (M.ValueMain131 == 0) then
            SetState(R, 17); -- Goto label FINNISHED_MOVING
            return;
        end
        SetState(R, 15); -- Jump to label T3REC_AT_PRBASE
    elseif (STATE == 17) then -- Label: FINNISHED_MOVING
        Advance(R, 45);
    elseif (STATE == 18) then
        Goto(M.t3Recycler, "t3rec_path2", 1);
        Advance(R);
    elseif (STATE == 19) then -- Label: T3REC_AT_BASE
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.t3Recycler, 1);
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_2");
        Attack(M.Attacker, M.t3Recycler, 1);
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3Recycler, 1);
        M.Attacker = BuildObject("svtank_J", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3Recycler, 1);
        Advance(R, 55);
    elseif (STATE == 20) then
        M.ValueMain145 = GetDistance(M.t3Recycler, "t3rec");
        if (M.ValueMain145 > 30) then
            SetState(R, 19); -- Goto label T3REC_AT_BASE
            return;
        end
        M.SwarmRec = BuildObject("Sbrecy00", 5, "SwarmRec");
        SetAIP("FS07_s2.aip", 5);
        Ally(2, 5);
        Ally(3, 5);
        M.Attacker = BuildObject("svtank_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("svtank_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("svtank_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("svtank_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("svinst_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("svinst_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("svwalk_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("svwalk_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker2 = BuildObject("svtank_J2", 5, "Sforce_2");
        Patrol(M.Attacker2, "patrol_2", 1);
        M.Attacker2 = BuildObject("svtank_J2", 5, "Sforce_2");
        Patrol(M.Attacker2, "patrol_2", 1);
        M.Attacker2 = BuildObject("svtank_J2", 5, "Sforce_2");
        Patrol(M.Attacker2, "patrol_2", 1);
        M.Attacker2 = BuildObject("svinst_J2", 5, "Sforce_2");
        Patrol(M.Attacker2, "patrol_2", 1);
        M.Attacker2 = BuildObject("svinst_J2", 5, "Sforce_2");
        Patrol(M.Attacker2, "patrol_2", 1);
        M.Attacker2 = BuildObject("svinst_J2", 5, "Sforce_2");
        Patrol(M.Attacker2, "patrol_2", 1);
        M.Swalk1 = BuildObject("svwalk_J2", 5, "Sforce_2");
        Patrol(M.Swalk1, "patrol_2", 1);
        M.Swalk2 = BuildObject("svwalk_J2", 5, "Sforce_2");
        Patrol(M.Swalk2, "patrol_2", 1);
        M.Attacker = BuildObject("svtank_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_3", 1);
        M.Attacker = BuildObject("svtank_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_3", 1);
        M.Attacker = BuildObject("svtank_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_3", 1);
        M.Attacker2 = BuildObject("svinst_J2", 5, "Sforce_2");
        Patrol(M.Attacker2, "patrol_3", 1);
        M.Attacker2 = BuildObject("svinst_J2", 5, "Sforce_2");
        Patrol(M.Attacker2, "patrol_3", 1);
        M.Attacker2 = BuildObject("svinst_J2", 5, "Sforce_2");
        Patrol(M.Attacker2, "patrol_3", 1);
        M.Attacker = BuildObject("svwalk_J2", 5, "Sforce_1");
        Patrol(M.Attacker, "patrol_3", 1);
        M.Attacker = BuildObject("svwalk_J2", 5, "Sforce_2");
        Patrol(M.Attacker, "patrol_3", 1);
        SetAnimation(M.t3Recycler, "deploy", 1);
        Advance(R, 2);
    elseif (STATE == 21) then
        StartAnimation(M.t3Recycler);
        Advance(R, 10);
    elseif (STATE == 22) then
        M.t3Recycler = _ScripterCore.replace(M.t3Recycler, "ibrecy", false);
        SetAIP("FS07_e1.aip", 3);
        ClearObjectives();
        AddObjective(NewOrders, "green");
        Advance(R, 60);
    elseif (STATE == 23) then
        M.swarm_nav = BuildObject("ibnav", 1, "swarm_pos");
        SetObjectiveName(M.swarm_nav, "Swarm Force");
        SetObjectiveOn(M.swarm_nav);
        ClearObjectives();
        AddObjective(Orders2, "white");
        Advance(R);
    elseif (STATE == 24) then -- Label: CHECK_SWARM_FORCE
        Advance(R, 10);
    elseif (STATE == 25) then
        M.ValueMain214 = IsAround(M.Sbuild);
        if (M.ValueMain214 == true) then
            SetState(R, 24); -- Goto label CHECK_SWARM_FORCE
            return;
        end
        Advance(R);
    elseif (STATE == 26) then -- Label: CHECK_SWARM_FORCE2
        Advance(R, 10);
    elseif (STATE == 27) then
        M.ValueMain217 = IsAround(M.Swalk1);
        if (M.ValueMain217 == true) then
            SetState(R, 26); -- Goto label CHECK_SWARM_FORCE2
            return;
        end
        Advance(R);
    elseif (STATE == 28) then -- Label: CHECK_SWARM_FORCE3
        Advance(R, 10);
    elseif (STATE == 29) then
        M.ValueMain220 = IsAround(M.Swalk2);
        if (M.ValueMain220 == true) then
            SetState(R, 28); -- Goto label CHECK_SWARM_FORCE3
            return;
        end
        Advance(R);
    elseif (STATE == 30) then -- Label: CHECK_SWARM_FORCE4
        Advance(R, 10);
    elseif (STATE == 31) then
        M.ValueMain223 = IsAround(M.SwarmRec);
        if (M.ValueMain223 == true) then
            SetState(R, 30); -- Goto label CHECK_SWARM_FORCE4
            return;
        end
        ClearObjectives();
        AddObjective(SwarmDead, "green");
        Advance(R);
    elseif (STATE == 32) then -- Label: SEARCH_RUINS
        M.Player = GetPlayerHandle();
        Advance(R, 10);
    elseif (STATE == 33) then
        M.ValueMain229 = Distance3D(M.Player, M.Probe);
        if (M.ValueMain229 > 350) then
            SetState(R, 32); -- Goto label SEARCH_RUINS
            return;
        end
        CameraPath("camera_1", 5800, 6000, M.Probe);
        Advance(R, 10);
    elseif (STATE == 34) then
        ClearObjectives();
        AddObjective(Probe, "green");
        SetTeamNum(M.Probe, 1);
        SetRoutineActive(CheckProbe, true);
        M.Mlead1 = BuildObject("OvCruise", 6, "m_sp1");
        Goto(M.Mlead1, M.Probe, 1);
        M.Mwing1 = BuildObject("OvBeam", 6, "m_sp1");
        Follow(M.Mwing1, M.Mlead1, 1);
        M.Mwing2 = BuildObject("OvBeam", 6, "m_sp1");
        Follow(M.Mwing2, M.Mlead1, 1);
        M.Mlead2 = BuildObject("OvCruise", 6, "m_sp2");
        Goto(M.Mlead2, M.Probe, 1);
        M.Mwing3 = BuildObject("OvBeam", 6, "m_sp2");
        Follow(M.Mwing3, M.Mlead2, 1);
        M.Mwing4 = BuildObject("OvBeam", 6, "m_sp2");
        Follow(M.Mwing4, M.Mlead2, 1);
        Advance(R, 20);
    elseif (STATE == 35) then
        Ally(5, 2);
        Ally(6, 2);
        M.Backup1 = BuildObject("pvrckt2", 2, "b_sp");
        Goto(M.Backup1, "probe_path", 1);
        M.Backup = BuildObject("pvtank", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvtank", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvtank", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvtank", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvtank", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvtank", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvscout", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvscout", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvscout", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvrckt", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvrckt", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvmisl", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvmisl", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvmisl", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        M.Backup = BuildObject("pvmisl", 2, "b_sp");
        Follow(M.Backup, M.Backup1, 1);
        SetRoutineActive(CheckBackup, true);
        Advance(R);
    elseif (STATE == 36) then -- Label: BACKUP
        M.Mlead1 = BuildObject("OvCruise", 6, "m_sp1");
        Goto(M.Mlead1, M.Probe, 1);
        M.Mwing1 = BuildObject("OvBeam", 6, "m_sp1");
        Follow(M.Mwing1, M.Mlead1, 1);
        M.Mwing2 = BuildObject("OvMisl", 6, "m_sp1");
        Follow(M.Mwing2, M.Mlead1, 1);
        Advance(R, 45);
    elseif (STATE == 37) then
        M.Mlead2 = BuildObject("OvCruise", 6, "m_sp1");
        Goto(M.Mlead2, M.Probe, 1);
        M.Mwing3 = BuildObject("OvBeam", 6, "m_sp1");
        Follow(M.Mwing3, M.Mlead2, 1);
        M.Mwing4 = BuildObject("Ovwalk", 6, "m_sp1");
        Attack(M.Mwing4, M.Probe, 1);
        Advance(R, 45);
    elseif (STATE == 38) then
        M.ValueMain299 = Distance3D(M.Backup1, M.Probe);
        if (M.ValueMain299 > 950) then
            SetState(R, 36); -- Goto label BACKUP
            return;
        end
        Advance(R);
    elseif (STATE == 39) then -- Label: ARRIVE
        M.ValueMain301 = Distance3D(M.Backup1, M.Probe);
        if (M.ValueMain301 > 350) then
            SetState(R, 39); -- Goto label ARRIVE
            return;
        end
        SucceedMission(10, "FS07win.des");
        Advance(R);
    elseif (STATE == 40) then -- Label: END
    end
end

function SwarmAttackWaves1(R, STATE)
    if (STATE == 0) then -- Label: SWARM_1
        M.PlayerPow = GetHandle("unnamed_ibpgenBD");
        M.Attacker = BuildObject("svscL_D", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.Recycler, 1);
        Advance(R, 15);
    elseif (STATE == 1) then
        M.Attacker = BuildObject("svscL_D", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3GT1, 1);
        Advance(R, 15);
    elseif (STATE == 2) then
        M.Attacker = BuildObject("svartl_J", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.PlayerPow, 1);
        Advance(R, 15);
    elseif (STATE == 3) then
        SetState(R, 0); -- Jump to label SWARM_1
    elseif (STATE == 4) then
    end
end

function SwarmAttackWaves2(R, STATE)
    if (STATE == 0) then -- Label: SWARM_2
        M.PlayerFac = GetHandle("unnamed_ibfactBD");
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.Recycler, 1);
        M.Attacker = BuildObject("svinst_J", 5, "swarmSpawn_3");
        Attack(M.Attacker, M.t3fact, 1);
        Advance(R, 15);
    elseif (STATE == 1) then
        M.Attacker = BuildObject("svwalk_J", 5, "swarmSpawn_1");
        Attack(M.Attacker, M.PlayerFac, 1);
        Advance(R, 15);
    elseif (STATE == 2) then
        SetState(R, 0); -- Jump to label SWARM_2
    elseif (STATE == 3) then
    end
end

function CheckOverlord(R, STATE)
    if (STATE == 0) then -- Label: OVERLORD_IS_ALIVE
        Advance(R, 10);
    elseif (STATE == 1) then
        M.ValueCheckOverlord2 = IsAround(M.PRoverlord);
        if (M.ValueCheckOverlord2 == true) then
            SetState(R, 0); -- Goto label OVERLORD_IS_ALIVE
            return;
        end
        FailMission(10, "FS07fail2.des");
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
        FailMission(10, "FS07fail3.des");
    end
end

function CheckT3Recy(R, STATE)
    if (STATE == 0) then -- Label: T3RECY_IS_ALIVE
        Advance(R, 10);
    elseif (STATE == 1) then
        M.ValueCheckT3Recy2 = IsAround(M.t3Recycler);
        if (M.ValueCheckT3Recy2 == true) then
            SetState(R, 0); -- Goto label T3RECY_IS_ALIVE
            return;
        end
        FailMission(10, "FS07fail4.des");
    end
end

function CheckProbe(R, STATE)
    if (STATE == 0) then -- Label: PROBE_IS_ALIVE
        Advance(R, 10);
    elseif (STATE == 1) then
        M.ValueCheckProbe2 = IsAround(M.Probe);
        if (M.ValueCheckProbe2 == true) then
            SetState(R, 0); -- Goto label PROBE_IS_ALIVE
            return;
        end
        FailMission(10, "FS07fail5.des");
    end
end

function CheckBackup(R, STATE)
    if (STATE == 0) then -- Label: BACKUP_IS_ALIVE
        Advance(R, 10);
    elseif (STATE == 1) then
        M.ValueCheckBackup2 = IsAround(M.Backup1);
        if (M.ValueCheckBackup2 == true) then
            SetState(R, 0); -- Goto label BACKUP_IS_ALIVE
            return;
        end
        FailMission(10, "FS07fail6.des");
    end
end

function new1(R, STATE)
    if (STATE == 0) then
        Advance(R, 10);
    elseif (STATE == 1) then
        M.AddObjectData = { "changes1", "newguy" }; -- Activate AddObject hook, audit this code manually
    end
end

function changes1(R, STATE)
    if (STATE == 0) then -- Label: START1
        M.Valuechanges11 = GetTeamNum(M.newguy);
        if (M.Valuechanges11 == 3) then
            SetState(R, 1); -- Goto label OVER1
            return;
        end
        M.Valuechanges13 = GetTeamNum(M.newguy);
        if (M.Valuechanges13 == 6) then
            SetState(R, 1); -- Goto label OVER1
            return;
        end
        SetSkill(M.newguy, 2);
        Advance(R);
    elseif (STATE == 1) then -- Label: OVER1
        SetRoutineActive(changes1, false);
        SetState(R, 0); -- Jump to label START1
    elseif (STATE == 2) then
    end
end

function new(R, STATE)
    if (STATE == 0) then
        Advance(R, 10);
    elseif (STATE == 1) then
        M.AddObjectData = { "changes", "newguy" }; -- Activate AddObject hook, audit this code manually
    end
end

function changes(R, STATE)
    if (STATE == 0) then -- Label: START
        M.Valuechanges1 = GetTeamNum(M.newguy);
        if (M.Valuechanges1 == 3) then
            SetState(R, 1); -- Goto label OVER
            return;
        end
        M.Valuechanges3 = GetTeamNum(M.newguy);
        if (M.Valuechanges3 == 6) then
            SetState(R, 1); -- Goto label OVER
            return;
        end
        SetSkill(M.newguy, 3);
        Advance(R);
    elseif (STATE == 1) then -- Label: OVER
        SetRoutineActive(changes, false);
        SetState(R, 0); -- Jump to label START
    elseif (STATE == 2) then
    end
end
