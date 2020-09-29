assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local Routines = {};
local RoutineToIDMap = {};

local SwarmSP1 = SetVector(1628, 2, 1586);
local SwarmSP2 = SetVector(-1715, -5, 1532);
local Serv_1 = SetVector(-1236, 2, -1728);
local Serv_2 = SetVector(-1294, 2, -1730);

local Orders_1 = "Lt Harker we have\nlost contact with outpost\none. Escort a repair team\nto the outpost, we need \nthat com bunker back online.";
local Orders_2 = "We're under attack , they're\neverywhere. Protect that repair\nteam at all costs, ensure they\nget safely back to base .";
local Orders_3 = "Build a scavenger and start making\nsome turrets a large enemy force\nis inbound ";
local Obsevation = " Something is wrong here\nall the trees are dying\nand there's no sign of any\nanimal life at all.";
local Comms = "We've lost comms with base,\nall this dust is screwing things\nup, continue with the mission\nwe'll contact base when we get\nthe bunker online.";
local Outpost = "What the hell has happened here,\nthe outpost is totally destroyed.\nBaker,Davidson and Mckenzie\ncheck the perimeter for hostiles. ";
local Warning_1 = "Warning :Stay in Formation.";
local Objective_1 = "Well done , The Repair Team\nhas arrived back safely.";
local WinText = "Well done You Have Survived\nFor Now !!";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,

    -- Objects
    IndexedObject = nil,
    Attacker = nil,
    Attacker0 = nil,
    Attacker1 = nil,
    Attacker2 = nil,
    Attacker3 = nil,
    Attacker4 = nil,
    Attacker5 = nil,
    Attacker6 = nil,
    Attacker7 = nil,
    Attacker8 = nil,
    Attackers = {},
    MyRecycler = nil,
    Wingman_1 = nil,
    Wingman_2 = nil,
    Leader = nil,
    RepTeam = nil,
    Player = nil,
    Hangar = nil,
    Outpost = nil,
    Bones = nil,
    Service_1 = nil,
    Service_2 = nil,
    GunTow = nil,
    GunTow2 = nil,
    LastWalk = nil,

    -- Variables
    Index = 0,
    AttackerCount = 0,
    WaveCount = 0,

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
    DefineRoutine(1, CheckLeader, true);
    DefineRoutine(2, CheckRepTeam, true);
    DefineRoutine(3, CheckMyRecyler, true);
    DefineRoutine(4, CheckHangar, true);
    DefineRoutine(5, SwarmAttack, false);
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
        "svscL_D",
        "ivserv_BD",
        "svscJ_D",
        "svscA_D",
        "svwlkL_D",
        "svscL_D",
        "svscJ_D"
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
        SetScrap(1, 0);
        AddObjective(Orders_1, "white");
        M.Outpost = GetHandle("Outpost");
        M.GunTow2 = GetHandle("GunTow2");
        M.GunTow = GetHandle("GunTow");
        M.Bones = GetHandle("Bones");
        M.Wingman_1 = GetHandle("Wingman_1");
        M.Wingman_2 = GetHandle("Wingman_2");
        Goto(M.RepTeam, "Rep_Path", 1);
        Advance(R, 10);
    elseif (STATE == 1) then
        Follow(M.Leader, M.RepTeam, 1);
        Follow(M.Wingman_1, M.Leader, 1);
        Follow(M.Wingman_2, M.Leader, 1);
        SetObjectiveOn(M.RepTeam);
        Goto(M.RepTeam, "PatrolRte_1", 1);
        Advance(R, 40);
    elseif (STATE == 2) then
        ClearObjectives();
        AddObjective(Obsevation, "white");
        Advance(R);
    elseif (STATE == 3) then -- Label: AT_BONES
        M.ValueMain20 = Distance3D(M.Leader, M.Player);
        if (M.ValueMain20 > 400) then
            SetState(R, 40); -- Goto label PLAYER_WARNING_1
            return;
        end
        Advance(R);
    elseif (STATE == 4) then -- Label: RETURN_1
        M.ValueMain22 = Distance3D(M.RepTeam, M.Bones);
        if (M.ValueMain22 > 100) then
            SetState(R, 3); -- Goto label AT_BONES
            return;
        end
        ClearObjectives();
        AddObjective(Comms, "white");
        Goto(M.RepTeam, "PatrolRte_2", 1);
        Advance(R);
    elseif (STATE == 5) then -- Label: AT_OUTPOST_YET
        M.ValueMain27 = Distance3D(M.Leader, M.Player);
        if (M.ValueMain27 > 400) then
            SetState(R, 42); -- Goto label PLAYER_WARNING_2
            return;
        end
        Advance(R);
    elseif (STATE == 6) then -- Label: RETURN_2
        M.ValueMain29 = Distance3D(M.RepTeam, M.Outpost);
        if (M.ValueMain29 > 80) then
            SetState(R, 5); -- Goto label AT_OUTPOST_YET
            return;
        end
        ClearObjectives();
        AddObjective(Outpost, "white");
        Patrol(M.Wingman_1, "Perimeter_Path", 1);
        Follow(M.Wingman_2, M.Wingman_1, 1);
        Advance(R, 20);
    elseif (STATE == 7) then
        M.Attacker = BuildObject("svscL_D", 5, SwarmSP1);
        Attack(M.Attacker, M.Wingman_1, 1);
        Advance(R, 35);
    elseif (STATE == 8) then
        ClearObjectives();
        AddObjective(Orders_2, "white");
        Attack(M.Wingman_1, M.Attacker, 0);
        Follow(M.Wingman_2, M.Wingman_1, 0);
        Advance(R, 10);
    elseif (STATE == 9) then -- Label: CREATE_GROUP
        Advance(R, 1);
    elseif (STATE == 10) then
        M.IndexedObject = BuildObject("svscL_D", 5, SwarmSP1);
        M.Attackers[M.Index] = M.IndexedObject;
        M.Index = 1 + M.Index;
        if (M.Index < 6) then
            SetState(R, 9); -- Goto label CREATE_GROUP
            return;
        end
        M.Index = 0;
        Advance(R);
    elseif (STATE == 11) then -- Label: SEND_ATTACK
        M.IndexedObject = M.Attackers[M.Index];
        Attack(M.IndexedObject, M.RepTeam, 1);
        M.Index = 1 + M.Index;
        if (M.Index < 6) then
            SetState(R, 11); -- Goto label SEND_ATTACK
            return;
        end
        M.Service_1 = BuildObject("ivserv_BD", 1, Serv_1);
        Goto(M.Service_1, "Rep_Path", 1);
        M.Service_2 = BuildObject("ivserv_BD", 1, Serv_2);
        Goto(M.Service_2, "Rep_Path", 1);
        Advance(R, 20);
    elseif (STATE == 12) then
        Goto(M.RepTeam, "EscPath_1", 1);
        SetRoutineActive(SwarmAttack, true);
        Advance(R);
    elseif (STATE == 13) then -- Label: CHECK_TEAM_POS
        Advance(R, 5);
    elseif (STATE == 14) then
        M.ValueMain62 = Distance3D(M.Leader, M.Player);
        if (M.ValueMain62 > 400) then
            SetState(R, 44); -- Goto label PLAYER_WARNING_3
            return;
        end
        Advance(R);
    elseif (STATE == 15) then -- Label: RETURN_3
        M.ValueMain64 = Distance3D(M.RepTeam, M.Hangar);
        if (M.ValueMain64 > 80) then
            SetState(R, 13); -- Goto label CHECK_TEAM_POS
            return;
        end
        SetRoutineActive(SwarmAttack, false);
        Goto(M.Leader, "Rep_Path", 1);
        ClearObjectives();
        AddObjective(Objective_1, "green");
        Advance(R, 10);
    elseif (STATE == 16) then
        SetRoutineActive(CheckRepTeam, false);
        SetObjectiveOff(M.RepTeam);
        Goto(M.Service_1, M.GunTow2, 0);
        Service(M.Service_2, M.Leader, 0);
        AddScrap(1, 40);
        ClearObjectives();
        AddObjective(Orders_3, "White");
        Advance(R, 20);
    elseif (STATE == 17) then
        Defend(M.Leader, M.GunTow2, 1);
        Advance(R);
    elseif (STATE == 18) then -- Label: SEND_WAVE
        SetRoutineActive(Main, true);
        M.Attacker1 = BuildObject("svscJ_D", 5, "attackers_2");
        Attack(M.Attacker1, M.MyRecycler, 0);
        Advance(R, 3);
    elseif (STATE == 19) then
        M.Attacker2 = BuildObject("svscA_D", 5, "attackers_2");
        Goto(M.Attacker2, M.MyRecycler, 1);
        Advance(R, 3);
    elseif (STATE == 20) then
        M.Attacker3 = BuildObject("svscA_D", 5, "attackers_2");
        Goto(M.Attacker3, M.MyRecycler, 1);
        Advance(R, 3);
    elseif (STATE == 21) then
        M.Attacker6 = BuildObject("svscA_D", 5, "attackers_1");
        Goto(M.Attacker6, M.Hangar, 1);
        Advance(R, 3);
    elseif (STATE == 22) then
        M.Attacker7 = BuildObject("svwlkL_D", 5, "attackers_1");
        Goto(M.Attacker7, M.Hangar, 1);
        Advance(R, 3);
    elseif (STATE == 23) then
        M.Attacker8 = BuildObject("svwlkL_D", 5, "attackers_1");
        SetMaxHealth(M.Attacker8, 5800);
        SetCurHealth(M.Attacker8, 5800);
        Goto(M.Attacker8, M.Hangar, 1);
        Advance(R, 50);
    elseif (STATE == 24) then
        M.WaveCount = 1 + M.WaveCount;
        if (M.WaveCount < 5) then
            SetState(R, 18); -- Goto label SEND_WAVE
            return;
        end
        M.LastWalk = BuildObject("svwlkL_D", 5, "attackers_2");
        Goto(M.LastWalk, M.MyRecycler, 1);
        Advance(R);
    elseif (STATE == 25) then -- Label: LASTWALK_POS
        Advance(R, 15);
    elseif (STATE == 26) then
        M.Attacker = BuildObject("svscA_D", 5, "attackers_2");
        Attack(M.Attacker, M.MyRecycler, 1);
        Advance(R, 2);
    elseif (STATE == 27) then
        M.Attacker = BuildObject("svscA_D", 5, "attackers_2");
        Attack(M.Attacker, M.MyRecycler, 1);
        Advance(R, 2);
    elseif (STATE == 28) then
        M.Attacker = BuildObject("svscA_D", 5, "attackers_2");
        Goto(M.Attacker, M.MyRecycler, 1);
        Advance(R, 2);
    elseif (STATE == 29) then
        M.Attacker = BuildObject("svscJ_D", 5, "attackers_1");
        Goto(M.Attacker, M.Hangar, 1);
        Advance(R, 2);
    elseif (STATE == 30) then
        M.Attacker = BuildObject("svscJ_D", 5, "attackers_1");
        Goto(M.Attacker, M.Hangar, 1);
        M.ValueMain120 = IsAround(M.GunTow);
        if (M.ValueMain120 == true) then
            SetState(R, 34); -- Goto label ATTACK_TOWER_1
            return;
        end
        Advance(R);
    elseif (STATE == 31) then -- Label: CHECK_TOW_2
        M.ValueMain122 = IsAround(M.GunTow2);
        if (M.ValueMain122 == true) then
            SetState(R, 37); -- Goto label ATTACK_TOWER_2
            return;
        end
        Advance(R);
    elseif (STATE == 32) then -- Label: CHECK_WALK
        M.ValueMain124 = IsAround(M.LastWalk);
        if (M.ValueMain124 == true) then
            SetState(R, 25); -- Goto label LASTWALK_POS
            return;
        end
        Advance(R, 100);
    elseif (STATE == 33) then
        ClearObjectives();
        AddObjective(WinText, "green");
        SucceedMission(16, "Winner.des");
        SetState(R, 46); -- Jump to label END
    elseif (STATE == 34) then -- Label: ATTACK_TOWER_1
        M.Attacker = BuildObject("svscA_D", 5, "attackers_1");
        Attack(M.Attacker, M.GunTow, 1);
        Advance(R, 2);
    elseif (STATE == 35) then
        M.Attacker = BuildObject("svscA_D", 5, "attackers_1");
        Attack(M.Attacker, M.GunTow, 1);
        Advance(R, 2);
    elseif (STATE == 36) then
        SetState(R, 31); -- Jump to label CHECK_TOW_2
    elseif (STATE == 37) then -- Label: ATTACK_TOWER_2
        M.Attacker = BuildObject("svscA_D", 5, "attackers_2");
        Attack(M.Attacker, M.GunTow2, 1);
        Advance(R, 2);
    elseif (STATE == 38) then
        M.Attacker = BuildObject("svscA_D", 5, "attackers_2");
        Attack(M.Attacker, M.GunTow2, 1);
        Advance(R, 2);
    elseif (STATE == 39) then
        SetState(R, 32); -- Jump to label CHECK_WALK
    elseif (STATE == 40) then -- Label: PLAYER_WARNING_1
        ClearObjectives();
        AddObjective(Warning_1, "red");
        Advance(R, 10);
    elseif (STATE == 41) then
        SetState(R, 4); -- Jump to label RETURN_1
    elseif (STATE == 42) then -- Label: PLAYER_WARNING_2
        ClearObjectives();
        AddObjective(Warning_1, "red");
        Advance(R, 10);
    elseif (STATE == 43) then
        SetState(R, 6); -- Jump to label RETURN_2
    elseif (STATE == 44) then -- Label: PLAYER_WARNING_3
        ClearObjectives();
        AddObjective(Warning_1, "red");
        Advance(R, 10);
    elseif (STATE == 45) then
        SetState(R, 15); -- Jump to label RETURN_3
    elseif (STATE == 46) then -- Label: END
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
        FailMission(10, "failtext.des");
    end
end

function CheckRepTeam(R, STATE)
    if (STATE == 0) then -- Label: TEAM_IS_ALIVE
        M.RepTeam = GetHandle("RepTeam");
        M.ValueCheckRepTeam2 = IsAround(M.RepTeam);
        if (M.ValueCheckRepTeam2 == true) then
            SetState(R, 0); -- Goto label TEAM_IS_ALIVE
            return;
        end
        FailMission(10, "failtext2.des");
    end
end

function CheckMyRecyler(R, STATE)
    if (STATE == 0) then -- Label: REC_IS_ALIVE
        M.MyRecycler = GetHandle("MyRecycler");
        M.ValueCheckMyRecyler2 = IsAround(M.MyRecycler);
        if (M.ValueCheckMyRecyler2 == true) then
            SetState(R, 0); -- Goto label REC_IS_ALIVE
            return;
        end
        FailMission(10, "failtext3.des");
    end
end

function CheckHangar(R, STATE)
    if (STATE == 0) then -- Label: HANGAR_IS_ALIVE
        M.Hangar = GetHandle("Hangar");
        M.ValueCheckHangar2 = IsAround(M.Hangar);
        if (M.ValueCheckHangar2 == true) then
            SetState(R, 0); -- Goto label HANGAR_IS_ALIVE
            return;
        end
        FailMission(10, "failtext.des");
    end
end

function SwarmAttack(R, STATE)
    if (STATE == 0) then -- Label: SWARM_ATTACK
        Advance(R, 35);
    elseif (STATE == 1) then
        M.Attacker = BuildObject("svscL_D", 5, SwarmSP1);
        Attack(M.Attacker, M.RepTeam, 1);
        Advance(R, 2);
    elseif (STATE == 2) then
        M.Attacker = BuildObject("svscL_D", 5, SwarmSP1);
        Attack(M.Attacker, M.RepTeam, 1);
        Advance(R, 2);
    elseif (STATE == 3) then
        M.Attacker = BuildObject("svscL_D", 5, SwarmSP1);
        Attack(M.Attacker, M.RepTeam, 1);
        Advance(R, 2);
    elseif (STATE == 4) then
        M.Attacker = BuildObject("svscJ_D", 5, SwarmSP2);
        Attack(M.Attacker, M.RepTeam, 1);
        Advance(R, 2);
    elseif (STATE == 5) then
        M.Attacker = BuildObject("svscJ_D", 5, SwarmSP2);
        Attack(M.Attacker, M.RepTeam, 1);
        SetState(R, 0); -- Jump to label SWARM_ATTACK
    elseif (STATE == 6) then
    end
end
