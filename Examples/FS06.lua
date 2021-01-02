assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _ScripterCore = require('_ScripterCore');

local Routines = {};
local RoutineToIDMap = {};


local Orders = "Commander take your team to the\nlanding zone and clear out the\nswarm infestation, secure the\narea before the Phaer-Rhan\ndropships arrive.";
local Dropships = "Well done commander the LZ is\nsecure, the Phaer-Rhan will\narrive shortly.";
local Canyon = "Dammit, the swarm have gotten\nAA units along the canyon, they\nare tearing the dropships to\npieces, take out those swarm units\nimmediately.";
local Crashsite = "well done commander, we are\nrecieving a signal from a crashed\ndropship, go to the crashsite\nand escort the survivors to\nthe landing zone.";
local Crashsite2 = "Escort that Phaer-Rhan Overlord\nto the landing zone ,this\nunit is vital , another essential\nunit , the processor has also\njust arrived at the LZ.";
local LandingZone = "Well done , now help defend\nthe area while the Phaer_Rhan\nsetup base , make sure that\nprocessor is well protected .";
local BaseUp = "Excellent work, the Phaer Rhan\nnow have a factory built\nassist them in their attack on the\nSwarm base to the north.";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,
    AddObjectData = nil,

    -- Objects
    SwarmGT1 = nil,
    SwarmGT2 = nil,
    SwarmGT3 = nil,
    SwarmGT4 = nil,
    SwarmGT5 = nil,
    PRDrop1 = nil,
    PRDrop2 = nil,
    PRDrop3 = nil,
    PRDrop4 = nil,
    player = nil,
    LZ_nav = nil,
    SwarmAA_1 = nil,
    SwarmAA_2 = nil,
    SwarmAA_3 = nil,
    SwarmAA_4 = nil,
    SwarmAA_5 = nil,
    SwarmAA_6 = nil,
    Crash_nav = nil,
    PRConst = nil,
    PRProc = nil,
    PRescort1 = nil,
    PRescort2 = nil,
    PRescort3 = nil,
    PRGtow1 = nil,
    PRPgen1 = nil,
    Attacker = nil,
    Prec = nil,
    Pfact = nil,
    SwarmRec = nil,
    Parmo = nil,
    Friend = nil,

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
    DefineRoutine(1, PhaerRhanAI, false);
    DefineRoutine(2, checkswarm, false);
    DefineRoutine(3, CheckOverlord, false);
    DefineRoutine(4, CheckProc, false);
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
        "ibnav",
        "svscA_D",
        "svwalk_j",
        "svinst_J",
        "svtank_J",
        "PvDrop_01",
        "PvDrop_01b",
        "pvcons",
        "pvscout",
        "PvDrop_03",
        "PvProc",
        "PvPgen",
        "PvGtow",
        "ivwalk_BD",
        "ivserv_BD",
        "ivrdev_BD",
        "ivtnk4_BD",
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

function Update()
    for routineID,r in pairs(Routines) do
        if M.RoutineActive[routineID] and M.RoutineWakeTime[routineID] <= GetTime() then
            r(routineID, M.RoutineState[routineID]);
        end
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

function Main(R, STATE)
    if (STATE == 0) then
        Ally(1, 2);
        M.SwarmGT1 = GetHandle("SwarmGT1");
        M.SwarmGT1 = GetHandle("SwarmGT2");
        M.SwarmGT1 = GetHandle("SwarmGT3");
        M.SwarmGT1 = GetHandle("SwarmGT4");
        M.SwarmGT1 = GetHandle("SwarmGT5");
        M.SwarmAA_1 = GetHandle("SwarmAA_1");
        M.SwarmAA_2 = GetHandle("SwarmAA_2");
        M.SwarmAA_3 = GetHandle("SwarmAA_3");
        M.SwarmAA_4 = GetHandle("SwarmAA_4");
        M.SwarmAA_5 = GetHandle("SwarmAA_5");
        M.SwarmAA_6 = GetHandle("SwarmAA_6");
        M.LZ_nav = BuildObject("ibnav", 1, "LZ");
        SetObjectiveName(M.LZ_nav, "Landing Zone");
        SetObjectiveOn(M.LZ_nav);
        ClearObjectives();
        AddObjective(Orders, "white");
        SetAIP("FS06_s1.aip", 6);
        M.Attacker = BuildObject("svscA_D", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 1) then
        M.Attacker = BuildObject("svscA_D", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 2) then
        M.Attacker = BuildObject("svwalk_j", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 3) then
        M.Attacker = BuildObject("svwalk_j", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 4) then
        M.Attacker = BuildObject("svinst_J", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 5) then
        M.Attacker = BuildObject("svinst_J", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 6) then
        M.Attacker = BuildObject("svscA_D", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 7) then
        M.Attacker = BuildObject("svscA_D", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 8) then
        M.Attacker = BuildObject("svtank_J", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 9) then
        M.Attacker = BuildObject("svtank_J", 6, "LZ");
        Goto(M.Attacker, "attack_path", 1);
        Advance(R);
    elseif (STATE == 10) then -- Label: GT1_ALIVE
        Advance(R, 10);
    elseif (STATE == 11) then
        M.ValueMain49 = IsAround(M.SwarmGT1);
        if (M.ValueMain49 == true) then
            SetState(R, 10); -- Goto label GT1_ALIVE
            return;
        end
        Advance(R);
    elseif (STATE == 12) then -- Label: GT2_ALIVE
        Advance(R, 10);
    elseif (STATE == 13) then
        M.ValueMain52 = IsAround(M.SwarmGT2);
        if (M.ValueMain52 == true) then
            SetState(R, 12); -- Goto label GT2_ALIVE
            return;
        end
        Advance(R);
    elseif (STATE == 14) then -- Label: GT3_ALIVE
        Advance(R, 10);
    elseif (STATE == 15) then
        M.ValueMain55 = IsAround(M.SwarmGT3);
        if (M.ValueMain55 == true) then
            SetState(R, 14); -- Goto label GT3_ALIVE
            return;
        end
        Advance(R);
    elseif (STATE == 16) then -- Label: GT4_ALIVE
        Advance(R, 10);
    elseif (STATE == 17) then
        M.ValueMain58 = IsAround(M.SwarmGT4);
        if (M.ValueMain58 == true) then
            SetState(R, 16); -- Goto label GT4_ALIVE
            return;
        end
        Advance(R);
    elseif (STATE == 18) then -- Label: GT5_ALIVE
        Advance(R, 10);
    elseif (STATE == 19) then
        M.ValueMain61 = IsAround(M.SwarmGT5);
        if (M.ValueMain61 == true) then
            SetState(R, 18); -- Goto label GT5_ALIVE
            return;
        end
        ClearObjectives();
        AddObjective(Dropships, "green");
        M.PRDrop1 = BuildObject("PvDrop_01", 2, "drop_spawn");
        Goto(M.PRDrop1, "drop_path", 1);
        Advance(R, 25);
    elseif (STATE == 20) then
        Ally(1, 6);
        CameraPath("camera_1", 6000, 2500, M.PRDrop1);
        UnAlly(1, 6);
        M.PRDrop2 = BuildObject("PvDrop_01b", 2, "drop_spawn");
        Goto(M.PRDrop2, "drop_path", 1);
        Advance(R, 5);
    elseif (STATE == 21) then
        M.PRDrop3 = BuildObject("PvDrop_01b", 2, "drop_spawn");
        Goto(M.PRDrop3, "drop_path", 1);
        Advance(R, 45);
    elseif (STATE == 22) then
        ClearObjectives();
        AddObjective(Canyon, "red");
        Advance(R);
    elseif (STATE == 23) then -- Label: AA1_ALIVE
        Advance(R, 10);
    elseif (STATE == 24) then
        M.ValueMain80 = IsAround(M.SwarmAA_1);
        if (M.ValueMain80 == true) then
            SetState(R, 23); -- Goto label AA1_ALIVE
            return;
        end
        Advance(R);
    elseif (STATE == 25) then -- Label: AA2_ALIVE
        Advance(R, 10);
    elseif (STATE == 26) then
        M.ValueMain83 = IsAround(M.SwarmAA_2);
        if (M.ValueMain83 == true) then
            SetState(R, 25); -- Goto label AA2_ALIVE
            return;
        end
        Advance(R);
    elseif (STATE == 27) then -- Label: AA3_ALIVE
        Advance(R, 10);
    elseif (STATE == 28) then
        M.ValueMain86 = IsAround(M.SwarmAA_3);
        if (M.ValueMain86 == true) then
            SetState(R, 27); -- Goto label AA3_ALIVE
            return;
        end
        Advance(R);
    elseif (STATE == 29) then -- Label: AA4_ALIVE
        Advance(R, 10);
    elseif (STATE == 30) then
        M.ValueMain89 = IsAround(M.SwarmAA_4);
        if (M.ValueMain89 == true) then
            SetState(R, 29); -- Goto label AA4_ALIVE
            return;
        end
        Advance(R);
    elseif (STATE == 31) then -- Label: AA5_ALIVE
        Advance(R, 10);
    elseif (STATE == 32) then
        M.ValueMain92 = IsAround(M.SwarmAA_5);
        if (M.ValueMain92 == true) then
            SetState(R, 31); -- Goto label AA5_ALIVE
            return;
        end
        Advance(R);
    elseif (STATE == 33) then -- Label: AA6_ALIVE
        Advance(R, 10);
    elseif (STATE == 34) then
        M.ValueMain95 = IsAround(M.SwarmAA_6);
        if (M.ValueMain95 == true) then
            SetState(R, 33); -- Goto label AA6_ALIVE
            return;
        end
        M.Crash_nav = BuildObject("ibnav", 1, "crashsite");
        SetObjectiveName(M.Crash_nav, "Crashsite");
        SetObjectiveOn(M.Crash_nav);
        ClearObjectives();
        AddObjective(Crashsite, "white");
        Advance(R, 5);
    elseif (STATE == 35) then
        M.PRConst = BuildObject("pvcons", 2, "crashsite");
        Advance(R, 5);
    elseif (STATE == 36) then
        M.PRescort1 = BuildObject("pvscout", 2, "crashsite");
        Advance(R, 5);
    elseif (STATE == 37) then
        M.PRescort2 = BuildObject("pvscout", 2, "crashsite");
        Advance(R, 5);
    elseif (STATE == 38) then
        M.PRescort3 = BuildObject("pvscout", 2, "crashsite");
        SetObjectiveOn(M.PRConst);
        SetAIP("FS06_s2.aip", 6);
        SetScrap(6, 40);
        SetRoutineActive(CheckOverlord, true);
        Advance(R);
    elseif (STATE == 39) then -- Label: AT_CRASHSITE
        M.player = GetPlayerHandle();
        Advance(R, 15);
    elseif (STATE == 40) then
        M.ValueMain116 = Distance3D(M.player, M.PRConst);
        if (M.ValueMain116 > 80) then
            SetState(R, 39); -- Goto label AT_CRASHSITE
            return;
        end
        ClearObjectives();
        AddObjective(Crashsite2, "white");
        Advance(R, 5);
    elseif (STATE == 41) then
        Goto(M.PRConst, "LZ", 1);
        Advance(R, 3);
    elseif (STATE == 42) then
        Follow(M.PRescort1, M.PRConst, 1);
        Advance(R, 3);
    elseif (STATE == 43) then
        Follow(M.PRescort2, M.PRConst, 1);
        Advance(R, 3);
    elseif (STATE == 44) then
        Follow(M.PRescort3, M.PRConst, 1);
        Advance(R, 3);
    elseif (STATE == 45) then
        M.PRDrop4 = BuildObject("PvDrop_03", 2, "drop");
        Advance(R, 5);
    elseif (STATE == 46) then
        M.PRProc = BuildObject("PvProc", 2, "proc");
        Advance(R, 5);
    elseif (STATE == 47) then
        SetRoutineActive(CheckProc, true);
        SetObjectiveOn(M.PRProc);
        Advance(R, 5);
    elseif (STATE == 48) then
        M.PRPgen1 = BuildObject("PvPgen", 2, "dropoff1");
        Goto(M.PRPgen1, "Pow1", 1);
        Advance(R, 5);
    elseif (STATE == 49) then
        M.PRGtow1 = BuildObject("PvGtow", 2, "dropoff2");
        Advance(R);
    elseif (STATE == 50) then -- Label: DEPLOY_POWER
        Advance(R, 5);
    elseif (STATE == 51) then
        M.ValueMain141 = GetDistance(M.PRPgen1, "Pow1");
        if (M.ValueMain141 > 5) then
            SetState(R, 50); -- Goto label DEPLOY_POWER
            return;
        end
        SetAnimation(M.PRPgen1, "deploy", 1);
        Advance(R, 2);
    elseif (STATE == 52) then
        StartAnimation(M.PRPgen1);
        Advance(R, 10);
    elseif (STATE == 53) then
        M.PRPgen1 = _ScripterCore.replace(M.PRPgen1, "pbpgen", false);
        Goto(M.PRGtow1, "GT1", 1);
        Advance(R, 5);
    elseif (STATE == 54) then -- Label: DEPLOY_GT
        Advance(R, 5);
    elseif (STATE == 55) then
        M.ValueMain151 = GetDistance(M.PRGtow1, "GT1");
        if (M.ValueMain151 > 5) then
            SetState(R, 54); -- Goto label DEPLOY_GT
            return;
        end
        SetAnimation(M.PRGtow1, "deploy", 1);
        Advance(R, 2);
    elseif (STATE == 56) then
        StartAnimation(M.PRGtow1);
        Advance(R, 10);
    elseif (STATE == 57) then
        M.PRGtow1 = _ScripterCore.replace(M.PRGtow1, "pbgtow", false);
        Advance(R);
    elseif (STATE == 58) then -- Label: AT_LZ
        Advance(R, 15);
    elseif (STATE == 59) then
        M.ValueMain159 = Distance3D(M.PRConst, M.LZ_nav);
        if (M.ValueMain159 > 80) then
            SetState(R, 58); -- Goto label AT_LZ
            return;
        end
        ClearObjectives();
        AddObjective(LandingZone, "white");
        Advance(R, 10);
    elseif (STATE == 60) then
        Goto(M.PRProc, "Processor", 1);
        SetAIP("FS06_s3.aip", 6);
        Advance(R);
    elseif (STATE == 61) then -- Label: AT_DEPLOY
        Advance(R, 5);
    elseif (STATE == 62) then
        M.ValueMain167 = GetDistance(M.PRProc, "Processor");
        if (M.ValueMain167 > 8) then
            SetState(R, 61); -- Goto label AT_DEPLOY
            return;
        end
        SetAnimation(M.PRProc, "deploy", 1);
        Advance(R, 5);
    elseif (STATE == 63) then
        StartAnimation(M.PRProc);
        Advance(R, 10);
    elseif (STATE == 64) then
        M.PRProc = _ScripterCore.replace(M.PRProc, "pbproc", false);
        SetScrap(2, 40);
        SetRoutineActive(PhaerRhanAI, true);
        SetAIP("FS06_p1.aip", 2);
        SetRoutineActive(checkswarm, true);
        M.ValueMain178 = IsAround(M.PRescort1);
        if (M.ValueMain178 == true) then
            SetState(R, 67); -- Goto label PATROL_1
            return;
        end
        Advance(R);
    elseif (STATE == 65) then -- Label: CHECK_ESCORT2
        M.ValueMain180 = IsAround(M.PRescort2);
        if (M.ValueMain180 == true) then
            SetState(R, 68); -- Goto label PATROL_2
            return;
        end
        Advance(R);
    elseif (STATE == 66) then -- Label: CHECK_ESCORT3
        M.ValueMain182 = IsAround(M.PRescort3);
        if (M.ValueMain182 == true) then
            SetState(R, 69); -- Goto label PATROL_3
            return;
        end
        SetState(R, 70); -- Jump to label END
    elseif (STATE == 67) then -- Label: PATROL_1
        Patrol(M.PRescort1, "Patrol_1", 1);
        SetState(R, 65); -- Jump to label CHECK_ESCORT2
    elseif (STATE == 68) then -- Label: PATROL_2
        Patrol(M.PRescort2, "Patrol_1", 1);
        SetState(R, 66); -- Jump to label CHECK_ESCORT3
    elseif (STATE == 69) then -- Label: PATROL_3
        Patrol(M.PRescort3, "Patrol_1", 1);
        Advance(R);
    elseif (STATE == 70) then -- Label: END
        Advance(R, 5);
    elseif (STATE == 71) then
        M.ValueMain191 = IsAround(M.Pfact);
        if (M.ValueMain191 == false) then
            SetState(R, 70); -- Goto label END
            return;
        end
        ClearObjectives();
        AddObjective(BaseUp, "white");
        M.Friend = BuildObject("ivwalk_BD", 1, "Friends");
        SetGroup(M.Friend, 7);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 72) then
        M.Friend = BuildObject("ivwalk_BD", 1, "Friends");
        SetGroup(M.Friend, 7);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 73) then
        M.Friend = BuildObject("ivwalk_BD", 1, "Friends");
        SetGroup(M.Friend, 7);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 74) then
        M.Friend = BuildObject("ivserv_BD", 1, "Friends");
        SetGroup(M.Friend, 8);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 75) then
        M.Friend = BuildObject("ivserv_BD", 1, "Friends");
        SetGroup(M.Friend, 8);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 76) then
        M.Friend = BuildObject("ivrdev_BD", 1, "Friends");
        SetGroup(M.Friend, 9);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 77) then
        M.Friend = BuildObject("ivrdev_BD", 1, "Friends");
        SetGroup(M.Friend, 9);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 78) then
        M.Friend = BuildObject("ivrdev_BD", 1, "Friends");
        SetGroup(M.Friend, 9);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 79) then
        M.Friend = BuildObject("ivtnk4_BD", 1, "Friends");
        SetGroup(M.Friend, 6);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 80) then
        M.Friend = BuildObject("ivtnk4_BD", 1, "Friends");
        SetGroup(M.Friend, 6);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 81) then
        M.Friend = BuildObject("ivtur_BD", 1, "Friends");
        SetGroup(M.Friend, 5);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 82) then
        M.Friend = BuildObject("ivtur_BD", 1, "Friends");
        SetGroup(M.Friend, 5);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 83) then
        M.Friend = BuildObject("ivtur_BD", 1, "Friends");
        SetGroup(M.Friend, 5);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 84) then
        M.Friend = BuildObject("ivtur_BD", 1, "Friends");
        SetGroup(M.Friend, 5);
        Goto(M.Friend, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 85) then
    end
end

function PhaerRhanAI(R, STATE)
    if (STATE == 0) then -- Label: PR_MAIN
        Advance(R, 5);
    elseif (STATE == 1) then
        M.Prec = GetHandle("unnamed_pbrecy");
        M.ValuePhaerRhanAI3 = IsAround(M.Prec);
        if (M.ValuePhaerRhanAI3 == false) then
            SetState(R, 4); -- Goto label BUILD_CYARD
            return;
        end
        Advance(R, 5);
    elseif (STATE == 2) then
        M.Pfact = GetHandle("unnamed_pbfact");
        M.ValuePhaerRhanAI7 = IsAround(M.Pfact);
        if (M.ValuePhaerRhanAI7 == false) then
            SetState(R, 8); -- Goto label BUILD_FACT
            return;
        end
        Advance(R, 5);
    elseif (STATE == 3) then
        M.Parmo = GetHandle("unnamed_pbarmo");
        M.ValuePhaerRhanAI11 = IsAround(M.Parmo);
        if (M.ValuePhaerRhanAI11 == false) then
            SetState(R, 12); -- Goto label BUILD_ARMO
            return;
        end
        SetState(R, 0); -- Jump to label PR_MAIN
    elseif (STATE == 4) then -- Label: BUILD_CYARD
        Build(M.PRConst, "pbrecy", 1);
    elseif (STATE == 5) then
        Dropoff(M.PRConst, "PRcyard", 1);
        Advance(R, 5);
    elseif (STATE == 6) then -- Label: CONSTRUCTING_CYARD
        M.ValuePhaerRhanAI17 = GetCurrentCommand(M.PRConst);
        if (M.ValuePhaerRhanAI17 == 0) then
            SetState(R, 7); -- Goto label FINNISHED_CYARD
            return;
        end
        SetState(R, 6); -- Jump to label CONSTRUCTING_CYARD
    elseif (STATE == 7) then -- Label: FINNISHED_CYARD
        SetState(R, 0); -- Jump to label PR_MAIN
    elseif (STATE == 8) then -- Label: BUILD_FACT
        Build(M.PRConst, "pbfact", 1);
    elseif (STATE == 9) then
        Dropoff(M.PRConst, "PRfact", 1);
        Advance(R, 5);
    elseif (STATE == 10) then -- Label: CONSTRUCTING_FACT
        M.ValuePhaerRhanAI24 = GetCurrentCommand(M.PRConst);
        if (M.ValuePhaerRhanAI24 == 0) then
            SetState(R, 11); -- Goto label FINNISHED_FACT
            return;
        end
        SetState(R, 10); -- Jump to label CONSTRUCTING_FACT
    elseif (STATE == 11) then -- Label: FINNISHED_FACT
        SetState(R, 0); -- Jump to label PR_MAIN
    elseif (STATE == 12) then -- Label: BUILD_ARMO
        Build(M.PRConst, "pbarmo", 1);
    elseif (STATE == 13) then
        Dropoff(M.PRConst, "PRArm", 1);
        Advance(R, 5);
    elseif (STATE == 14) then -- Label: CONSTRUCTING_ARMO
        M.ValuePhaerRhanAI31 = GetCurrentCommand(M.PRConst);
        if (M.ValuePhaerRhanAI31 == 0) then
            SetState(R, 15); -- Goto label FINNISHED_ARMO
            return;
        end
        SetState(R, 14); -- Jump to label CONSTRUCTING_ARMO
    elseif (STATE == 15) then -- Label: FINNISHED_ARMO
        SetState(R, 0); -- Jump to label PR_MAIN
    elseif (STATE == 16) then
    end
end

function checkswarm(R, STATE)
    if (STATE == 0) then -- Label: SWARM_IS_ALIVE
        M.SwarmRec = GetHandle("SwarmRec");
        Advance(R, 10);
    elseif (STATE == 1) then
        M.Valuecheckswarm3 = IsAround(M.SwarmRec);
        if (M.Valuecheckswarm3 == true) then
            SetState(R, 0); -- Goto label SWARM_IS_ALIVE
            return;
        end
        SucceedMission(10, "FS06win.des");
    end
end

function CheckOverlord(R, STATE)
    if (STATE == 0) then -- Label: OVERLORD_IS_ALIVE
        Advance(R, 10);
    elseif (STATE == 1) then
        M.ValueCheckOverlord2 = IsAround(M.PRConst);
        if (M.ValueCheckOverlord2 == true) then
            SetState(R, 0); -- Goto label OVERLORD_IS_ALIVE
            return;
        end
        FailMission(10, "FS06fail1.des");
    end
end

function CheckProc(R, STATE)
    if (STATE == 0) then -- Label: PROC_IS_ALIVE
        Advance(R, 10);
    elseif (STATE == 1) then
        M.ValueCheckProc2 = IsAround(M.PRProc);
        if (M.ValueCheckProc2 == true) then
            SetState(R, 0); -- Goto label PROC_IS_ALIVE
            return;
        end
        FailMission(10, "FS06fail2.des");
    end
end
