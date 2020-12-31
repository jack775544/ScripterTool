assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();
local _ScripterCore = require('_ScripterCore');

local Routines = {};
local RoutineToIDMap = {};


local _Text1 = "Commander take your team to the\nlanding zone and clear out the\nswarm infestation, secure the\narea before the Phaer-Rhan\ndropships arrive.";
local _Text2 = "Well done commander the LZ is\nsecure, the Phaer-Rhan will\narrive shortly.";
local _Text3 = "Dammit, the swarm have gotten\nAA units along the canyon, they\nare tearing the dropships to\npieces, take out those swarm units\nimmediately.";
local _Text4 = "well done commander, we are\nrecieving a signal from a crashed\ndropship, go to the crashsite\nand escort the survivors to\nthe landing zone.";
local _Text5 = "Escort that Phaer-Rhan Overlord\nto the landing zone ,this\nunit is vital , another essential\nunit , the processor has also\njust arrived at the LZ.";
local _Text6 = "Well done , now help defend\nthe area while the Phaer_Rhan\nsetup base , make sure that\nprocessor is well protected .";
local _Text7 = "Excellent work, the Phaer Rhan\nnow have a factory built\nassist them in their attack on the\nSwarm base to the north.";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,

    -- Objects
    Object1 = nil,
    Object2 = nil,
    Object3 = nil,
    Object4 = nil,
    Object5 = nil,
    Object6 = nil,
    Object7 = nil,
    Object8 = nil,
    Object9 = nil,
    Object10 = nil,
    Object11 = nil,
    Object12 = nil,
    Object13 = nil,
    Object14 = nil,
    Object15 = nil,
    Object16 = nil,
    Object17 = nil,
    Object18 = nil,
    Object19 = nil,
    Object20 = nil,
    Object21 = nil,
    Object22 = nil,
    Object23 = nil,
    Object24 = nil,
    Object25 = nil,
    Object26 = nil,
    Object27 = nil,
    Object28 = nil,
    Object29 = nil,
    Object30 = nil,
    Object31 = nil,

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
    DefineRoutine(0, _Routine1, true);
    DefineRoutine(1, _Routine2, false);
    DefineRoutine(2, _Routine3, false);
    DefineRoutine(3, _Routine4, false);
    DefineRoutine(4, _Routine5, false);
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

function _Routine1(R, STATE)
    if (STATE == 0) then
        Ally(1, 2);
        M.Object1 = GetHandle("SwarmGT1");
        M.Object1 = GetHandle("SwarmGT2");
        M.Object1 = GetHandle("SwarmGT3");
        M.Object1 = GetHandle("SwarmGT4");
        M.Object1 = GetHandle("SwarmGT5");
        M.Object12 = GetHandle("SwarmAA_1");
        M.Object13 = GetHandle("SwarmAA_2");
        M.Object14 = GetHandle("SwarmAA_3");
        M.Object15 = GetHandle("SwarmAA_4");
        M.Object16 = GetHandle("SwarmAA_5");
        M.Object17 = GetHandle("SwarmAA_6");
        M.Object11 = BuildObject("ibnav", 1, "LZ");
        SetObjectiveName(M.Object11, "Landing Zone");
        SetObjectiveOn(M.Object11);
        ClearObjectives();
        AddObjective(_Text1, "white");
        SetAIP("FS06_s1.aip", 6);
        M.Object26 = BuildObject("svscA_D", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 1) then
        M.Object26 = BuildObject("svscA_D", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 2) then
        M.Object26 = BuildObject("svwalk_j", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 3) then
        M.Object26 = BuildObject("svwalk_j", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 4) then
        M.Object26 = BuildObject("svinst_J", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 5) then
        M.Object26 = BuildObject("svinst_J", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 6) then
        M.Object26 = BuildObject("svscA_D", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 7) then
        M.Object26 = BuildObject("svscA_D", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 8) then
        M.Object26 = BuildObject("svtank_J", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R, 2);
    elseif (STATE == 9) then
        M.Object26 = BuildObject("svtank_J", 6, "LZ");
        Goto(M.Object26, "attack_path", 1);
        Advance(R);
    elseif (STATE == 10) then -- Label: LOC_47
        Advance(R, 10);
    elseif (STATE == 11) then
        M.Value_Routine149 = IsAround(M.Object1);
        if (M.Value_Routine149 == 1) then
            SetState(R, 10); -- Goto label LOC_47
            return;
        end
        Advance(R);
    elseif (STATE == 12) then -- Label: LOC_50
        Advance(R, 10);
    elseif (STATE == 13) then
        M.Value_Routine152 = IsAround(M.Object2);
        if (M.Value_Routine152 == 1) then
            SetState(R, 12); -- Goto label LOC_50
            return;
        end
        Advance(R);
    elseif (STATE == 14) then -- Label: LOC_53
        Advance(R, 10);
    elseif (STATE == 15) then
        M.Value_Routine155 = IsAround(M.Object3);
        if (M.Value_Routine155 == 1) then
            SetState(R, 14); -- Goto label LOC_53
            return;
        end
        Advance(R);
    elseif (STATE == 16) then -- Label: LOC_56
        Advance(R, 10);
    elseif (STATE == 17) then
        M.Value_Routine158 = IsAround(M.Object4);
        if (M.Value_Routine158 == 1) then
            SetState(R, 16); -- Goto label LOC_56
            return;
        end
        Advance(R);
    elseif (STATE == 18) then -- Label: LOC_59
        Advance(R, 10);
    elseif (STATE == 19) then
        M.Value_Routine161 = IsAround(M.Object5);
        if (M.Value_Routine161 == 1) then
            SetState(R, 18); -- Goto label LOC_59
            return;
        end
        ClearObjectives();
        AddObjective(_Text2, "green");
        M.Object6 = BuildObject("PvDrop_01", 2, "drop_spawn");
        Goto(M.Object6, "drop_path", 1);
        Advance(R, 25);
    elseif (STATE == 20) then
        Ally(1, 6);
        CameraPath("camera_1", 6000, 2500, M.Object6);
        UnAlly(1, 6);
        M.Object7 = BuildObject("PvDrop_01b", 2, "drop_spawn");
        Goto(M.Object7, "drop_path", 1);
        Advance(R, 5);
    elseif (STATE == 21) then
        M.Object8 = BuildObject("PvDrop_01b", 2, "drop_spawn");
        Goto(M.Object8, "drop_path", 1);
        Advance(R, 45);
    elseif (STATE == 22) then
        ClearObjectives();
        AddObjective(_Text3, "red");
        Advance(R);
    elseif (STATE == 23) then -- Label: LOC_78
        Advance(R, 10);
    elseif (STATE == 24) then
        M.Value_Routine180 = IsAround(M.Object12);
        if (M.Value_Routine180 == 1) then
            SetState(R, 23); -- Goto label LOC_78
            return;
        end
        Advance(R);
    elseif (STATE == 25) then -- Label: LOC_81
        Advance(R, 10);
    elseif (STATE == 26) then
        M.Value_Routine183 = IsAround(M.Object13);
        if (M.Value_Routine183 == 1) then
            SetState(R, 25); -- Goto label LOC_81
            return;
        end
        Advance(R);
    elseif (STATE == 27) then -- Label: LOC_84
        Advance(R, 10);
    elseif (STATE == 28) then
        M.Value_Routine186 = IsAround(M.Object14);
        if (M.Value_Routine186 == 1) then
            SetState(R, 27); -- Goto label LOC_84
            return;
        end
        Advance(R);
    elseif (STATE == 29) then -- Label: LOC_87
        Advance(R, 10);
    elseif (STATE == 30) then
        M.Value_Routine189 = IsAround(M.Object15);
        if (M.Value_Routine189 == 1) then
            SetState(R, 29); -- Goto label LOC_87
            return;
        end
        Advance(R);
    elseif (STATE == 31) then -- Label: LOC_90
        Advance(R, 10);
    elseif (STATE == 32) then
        M.Value_Routine192 = IsAround(M.Object16);
        if (M.Value_Routine192 == 1) then
            SetState(R, 31); -- Goto label LOC_90
            return;
        end
        Advance(R);
    elseif (STATE == 33) then -- Label: LOC_93
        Advance(R, 10);
    elseif (STATE == 34) then
        M.Value_Routine195 = IsAround(M.Object17);
        if (M.Value_Routine195 == 1) then
            SetState(R, 33); -- Goto label LOC_93
            return;
        end
        M.Object18 = BuildObject("ibnav", 1, "crashsite");
        SetObjectiveName(M.Object18, "Crashsite");
        SetObjectiveOn(M.Object18);
        ClearObjectives();
        AddObjective(_Text4, "white");
        Advance(R, 5);
    elseif (STATE == 35) then
        M.Object19 = BuildObject("pvcons", 2, "crashsite");
        Advance(R, 5);
    elseif (STATE == 36) then
        M.Object21 = BuildObject("pvscout", 2, "crashsite");
        Advance(R, 5);
    elseif (STATE == 37) then
        M.Object22 = BuildObject("pvscout", 2, "crashsite");
        Advance(R, 5);
    elseif (STATE == 38) then
        M.Object23 = BuildObject("pvscout", 2, "crashsite");
        SetObjectiveOn(M.Object19);
        SetAIP("FS06_s2.aip", 6);
        SetScrap(6, 40);
        SetRoutineActive(_Routine4, true);
        Advance(R);
    elseif (STATE == 39) then -- Label: LOC_113
        M.Object10 = GetPlayerHandle();
        Advance(R, 15);
    elseif (STATE == 40) then
        M.Value_Routine1116 = Distance3D(M.Object10, M.Object19);
        if (M.Value_Routine1116 > 80) then
            SetState(R, 39); -- Goto label LOC_113
            return;
        end
        ClearObjectives();
        AddObjective(_Text5, "white");
        Advance(R, 5);
    elseif (STATE == 41) then
        Goto(M.Object19, "LZ", 1);
        Advance(R, 3);
    elseif (STATE == 42) then
        Follow(M.Object21, M.Object19, 1);
        Advance(R, 3);
    elseif (STATE == 43) then
        Follow(M.Object22, M.Object19, 1);
        Advance(R, 3);
    elseif (STATE == 44) then
        Follow(M.Object23, M.Object19, 1);
        Advance(R, 3);
    elseif (STATE == 45) then
        M.Object9 = BuildObject("PvDrop_03", 2, "drop");
        Advance(R, 5);
    elseif (STATE == 46) then
        M.Object20 = BuildObject("PvProc", 2, "proc");
        Advance(R, 5);
    elseif (STATE == 47) then
        SetRoutineActive(_Routine5, true);
        SetObjectiveOn(M.Object20);
        Advance(R, 5);
    elseif (STATE == 48) then
        M.Object25 = BuildObject("PvPgen", 2, "dropoff1");
        Goto(M.Object25, "Pow1", 1);
        Advance(R, 5);
    elseif (STATE == 49) then
        M.Object24 = BuildObject("PvGtow", 2, "dropoff2");
        Advance(R);
    elseif (STATE == 50) then -- Label: LOC_139
        Advance(R, 5);
    elseif (STATE == 51) then
        DistPath(Object25, "Pow1"); -- Could not translate
    elseif (STATE == 52) then
        if (M.Value_Routine1116 > 5) then
            SetState(R, 50); -- Goto label LOC_139
            return;
        end
        SetAnimation(M.Object25, "deploy", 1);
        Advance(R, 2);
    elseif (STATE == 53) then
        StartAnimation(M.Object25);
        Advance(R, 10);
    elseif (STATE == 54) then
        M.Object25 = _ScripterCore.replace(M.Object25, "pbpgen", 0);
        Goto(M.Object24, "GT1", 1);
        Advance(R, 5);
    elseif (STATE == 55) then -- Label: LOC_149
        Advance(R, 5);
    elseif (STATE == 56) then
        DistPath(Object24, "GT1"); -- Could not translate
    elseif (STATE == 57) then
        if (M.Value_Routine1116 > 5) then
            SetState(R, 55); -- Goto label LOC_149
            return;
        end
        SetAnimation(M.Object24, "deploy", 1);
        Advance(R, 2);
    elseif (STATE == 58) then
        StartAnimation(M.Object24);
        Advance(R, 10);
    elseif (STATE == 59) then
        M.Object24 = _ScripterCore.replace(M.Object24, "pbgtow", 0);
        Advance(R);
    elseif (STATE == 60) then -- Label: LOC_157
        Advance(R, 15);
    elseif (STATE == 61) then
        M.Value_Routine1159 = Distance3D(M.Object19, M.Object11);
        if (M.Value_Routine1159 > 80) then
            SetState(R, 60); -- Goto label LOC_157
            return;
        end
        ClearObjectives();
        AddObjective(_Text6, "white");
        Advance(R, 10);
    elseif (STATE == 62) then
        Goto(M.Object20, "Processor", 1);
        SetAIP("FS06_s3.aip", 6);
        Advance(R);
    elseif (STATE == 63) then -- Label: LOC_165
        Advance(R, 5);
    elseif (STATE == 64) then
        DistPath(Object20, "Processor"); -- Could not translate
    elseif (STATE == 65) then
        if (M.Value_Routine1159 > 8) then
            SetState(R, 63); -- Goto label LOC_165
            return;
        end
        SetAnimation(M.Object20, "deploy", 1);
        Advance(R, 5);
    elseif (STATE == 66) then
        StartAnimation(M.Object20);
        Advance(R, 10);
    elseif (STATE == 67) then
        M.Object20 = _ScripterCore.replace(M.Object20, "pbproc", 0);
        SetScrap(2, 40);
        SetRoutineActive(_Routine2, true);
        SetAIP("FS06_p1.aip", 2);
        SetRoutineActive(_Routine3, true);
        M.Value_Routine1178 = IsAround(M.Object21);
        if (M.Value_Routine1178 == 1) then
            SetState(R, 70); -- Goto label LOC_184
            return;
        end
        Advance(R);
    elseif (STATE == 68) then -- Label: LOC_179
        M.Value_Routine1180 = IsAround(M.Object22);
        if (M.Value_Routine1180 == 1) then
            SetState(R, 71); -- Goto label LOC_186
            return;
        end
        Advance(R);
    elseif (STATE == 69) then -- Label: LOC_181
        M.Value_Routine1182 = IsAround(M.Object23);
        if (M.Value_Routine1182 == 1) then
            SetState(R, 72); -- Goto label LOC_188
            return;
        end
        SetState(R, 73); -- Jump to label LOC_189
    elseif (STATE == 70) then -- Label: LOC_184
        Patrol(M.Object21, "Patrol_1", 1);
        SetState(R, 68); -- Jump to label LOC_179
    elseif (STATE == 71) then -- Label: LOC_186
        Patrol(M.Object22, "Patrol_1", 1);
        SetState(R, 69); -- Jump to label LOC_181
    elseif (STATE == 72) then -- Label: LOC_188
        Patrol(M.Object23, "Patrol_1", 1);
        Advance(R);
    elseif (STATE == 73) then -- Label: LOC_189
        Advance(R, 5);
    elseif (STATE == 74) then
        M.Value_Routine1191 = IsAround(M.Object28);
        if (M.Value_Routine1191 == 0) then
            SetState(R, 73); -- Goto label LOC_189
            return;
        end
        ClearObjectives();
        AddObjective(_Text7, "white");
        M.Object31 = BuildObject("ivwalk_BD", 1, "Friends");
        SetGroup(Object31, 7); -- Could not translate
    elseif (STATE == 75) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 76) then
        M.Object31 = BuildObject("ivwalk_BD", 1, "Friends");
        SetGroup(Object31, 7); -- Could not translate
    elseif (STATE == 77) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 78) then
        M.Object31 = BuildObject("ivwalk_BD", 1, "Friends");
        SetGroup(Object31, 7); -- Could not translate
    elseif (STATE == 79) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 80) then
        M.Object31 = BuildObject("ivserv_BD", 1, "Friends");
        SetGroup(Object31, 8); -- Could not translate
    elseif (STATE == 81) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 82) then
        M.Object31 = BuildObject("ivserv_BD", 1, "Friends");
        SetGroup(Object31, 8); -- Could not translate
    elseif (STATE == 83) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 84) then
        M.Object31 = BuildObject("ivrdev_BD", 1, "Friends");
        SetGroup(Object31, 9); -- Could not translate
    elseif (STATE == 85) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 86) then
        M.Object31 = BuildObject("ivrdev_BD", 1, "Friends");
        SetGroup(Object31, 9); -- Could not translate
    elseif (STATE == 87) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 88) then
        M.Object31 = BuildObject("ivrdev_BD", 1, "Friends");
        SetGroup(Object31, 9); -- Could not translate
    elseif (STATE == 89) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 90) then
        M.Object31 = BuildObject("ivtnk4_BD", 1, "Friends");
        SetGroup(Object31, 6); -- Could not translate
    elseif (STATE == 91) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 92) then
        M.Object31 = BuildObject("ivtnk4_BD", 1, "Friends");
        SetGroup(Object31, 6); -- Could not translate
    elseif (STATE == 93) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 94) then
        M.Object31 = BuildObject("ivtur_BD", 1, "Friends");
        SetGroup(Object31, 5); -- Could not translate
    elseif (STATE == 95) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 96) then
        M.Object31 = BuildObject("ivtur_BD", 1, "Friends");
        SetGroup(Object31, 5); -- Could not translate
    elseif (STATE == 97) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 98) then
        M.Object31 = BuildObject("ivtur_BD", 1, "Friends");
        SetGroup(Object31, 5); -- Could not translate
    elseif (STATE == 99) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 100) then
        M.Object31 = BuildObject("ivtur_BD", 1, "Friends");
        SetGroup(Object31, 5); -- Could not translate
    elseif (STATE == 101) then
        Goto(M.Object31, "LZ", 0);
        Advance(R, 2);
    elseif (STATE == 102) then
    end
end

function _Routine2(R, STATE)
    if (STATE == 0) then -- Label: LOC_251
        Advance(R, 5);
    elseif (STATE == 1) then
        M.Object27 = GetHandle("unnamed_pbrecy");
        M.Value_Routine23 = IsAround(M.Object27);
        if (M.Value_Routine23 == 0) then
            SetState(R, 4); -- Goto label LOC_264
            return;
        end
        Advance(R, 5);
    elseif (STATE == 2) then
        M.Object28 = GetHandle("unnamed_pbfact");
        M.Value_Routine27 = IsAround(M.Object28);
        if (M.Value_Routine27 == 0) then
            SetState(R, 9); -- Goto label LOC_271
            return;
        end
        Advance(R, 5);
    elseif (STATE == 3) then
        M.Object30 = GetHandle("unnamed_pbarmo");
        M.Value_Routine211 = IsAround(M.Object30);
        if (M.Value_Routine211 == 0) then
            SetState(R, 14); -- Goto label LOC_278
            return;
        end
        SetState(R, 0); -- Jump to label LOC_251
    elseif (STATE == 4) then -- Label: LOC_264
        Build(M.Object19, "pbrecy", 1);
    elseif (STATE == 5) then
        Dropoff(M.Object19, "PRcyard", 1);
        Advance(R, 5);
    elseif (STATE == 6) then -- Label: LOC_267
        GetCommand(Object19); -- Could not translate
    elseif (STATE == 7) then
        if (M.Value_Routine211 == 0) then
            SetState(R, 8); -- Goto label LOC_270
            return;
        end
        SetState(R, 6); -- Jump to label LOC_267
    elseif (STATE == 8) then -- Label: LOC_270
        SetState(R, 0); -- Jump to label LOC_251
    elseif (STATE == 9) then -- Label: LOC_271
        Build(M.Object19, "pbfact", 1);
    elseif (STATE == 10) then
        Dropoff(M.Object19, "PRfact", 1);
        Advance(R, 5);
    elseif (STATE == 11) then -- Label: LOC_274
        GetCommand(Object19); -- Could not translate
    elseif (STATE == 12) then
        if (M.Value_Routine211 == 0) then
            SetState(R, 13); -- Goto label LOC_277
            return;
        end
        SetState(R, 11); -- Jump to label LOC_274
    elseif (STATE == 13) then -- Label: LOC_277
        SetState(R, 0); -- Jump to label LOC_251
    elseif (STATE == 14) then -- Label: LOC_278
        Build(M.Object19, "pbarmo", 1);
    elseif (STATE == 15) then
        Dropoff(M.Object19, "PRArm", 1);
        Advance(R, 5);
    elseif (STATE == 16) then -- Label: LOC_281
        GetCommand(Object19); -- Could not translate
    elseif (STATE == 17) then
        if (M.Value_Routine211 == 0) then
            SetState(R, 18); -- Goto label LOC_284
            return;
        end
        SetState(R, 16); -- Jump to label LOC_281
    elseif (STATE == 18) then -- Label: LOC_284
        SetState(R, 0); -- Jump to label LOC_251
    elseif (STATE == 19) then
    end
end

function _Routine3(R, STATE)
    if (STATE == 0) then -- Label: LOC_286
        M.Object29 = GetHandle("SwarmRec");
        Advance(R, 10);
    elseif (STATE == 1) then
        M.Value_Routine33 = IsAround(M.Object29);
        if (M.Value_Routine33 == 1) then
            SetState(R, 0); -- Goto label LOC_286
            return;
        end
        SucceedMission(10, "FS06win.des");
    end
end

function _Routine4(R, STATE)
    if (STATE == 0) then -- Label: LOC_292
        Advance(R, 10);
    elseif (STATE == 1) then
        M.Value_Routine42 = IsAround(M.Object19);
        if (M.Value_Routine42 == 1) then
            SetState(R, 0); -- Goto label LOC_292
            return;
        end
        FailMission(10, "FS06fail1.des");
    end
end

function _Routine5(R, STATE)
    if (STATE == 0) then -- Label: LOC_297
        Advance(R, 10);
    elseif (STATE == 1) then
        M.Value_Routine52 = IsAround(M.Object20);
        if (M.Value_Routine52 == 1) then
            SetState(R, 0); -- Goto label LOC_297
            return;
        end
        FailMission(10, "FS06fail2.des");
    end
end
