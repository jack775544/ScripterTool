assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local Routines = {};
local RoutineToIDMap = {};


local startxt = "With LT Harker dead\nyou are now incharge\nof the recycler , however\nwe need to upgrade it first\nget those scavs deployed\nwhile you're waiting.";
local techtxt = "OK the recycler\nhas now been upgraded\nget it deployed and\nbegin the assualt on\nthe enemy installation\nto the north-west .";
local rec1txt = "Excellent work , the enemy\ninstallation has been neutralised\nour forces are now able to\nmove out of the canyon ,\nnow lets retake that StarPort .";
local allies = "Commander you better get some\ndefences up here , we've\ngot a large enemy force\nfurther up the canyon , and\nthey're closing fast .";
local WinText = "well done you have\ncleared the way\nto the Starport.";
local lastorders = "You have eliminated all enemy\nbases in this area, destroy the\nenemy force blocking the way\nto the starport, and\nany extra units that arrive.";

local M = {
    --Mission State
    RoutineState = {},
    RoutineWakeTime = {},
    RoutineActive = {},
    MissionOver = false,

    -- Objects
    Recycler = nil,
    Player = nil,
    EnemyRec1 = nil,
    EnemyRec2 = nil,
    Tech = nil,
    Turr1 = nil,
    Turr2 = nil,
    Turr3 = nil,
    Turr4 = nil,
    Turr5 = nil,
    Turr6 = nil,
    Rckt1 = nil,
    Rckt2 = nil,
    Rckt3 = nil,
    Rckt4 = nil,
    Walk1 = nil,
    Walk2 = nil,
    Walk3 = nil,
    Sct1 = nil,
    Sct2 = nil,
    Sct3 = nil,
    Tnk1 = nil,
    Tnk2 = nil,
    Attacker = nil,
    tow1 = nil,
    tow2 = nil,
    tow3 = nil,
    tow4 = nil,
    def1 = nil,
    def2 = nil,
    def3 = nil,
    def4 = nil,
    def5 = nil,
    Swalk1 = nil,
    Swalk2 = nil,
    Swalk3 = nil,
    Swalk4 = nil,
    star_nav = nil,

    -- Variables
    AttackerCount = 0,

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
    DefineRoutine(2, CheckRecy2, false);
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
        "svturr",
        "sbgtow",
        ">sbrecy_b",
        "ivrckt_BD",
        "ivwalk_BD",
        "ivsct_BD",
        "ivtnk_BD",
        "svscA_D",
        "svBrood_L",
        "svtank_L",
        "ibnav",
        "Svwalk_J2",
        "Svwalk_L2",
        "Svinst_L2",
        "Svartl_L2"
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
        M.Tech = GetHandle("Tech");
        Ally(5, 6);
        Ally(1, 2);
        SetScrap(1, 40);
        SetScrap(5, 20);
        SetScrap(6, 20);
        M.Turr1 = BuildObject("svturr", 6, "turr1");
        M.Turr2 = BuildObject("svturr", 6, "turr2");
        M.Turr3 = BuildObject("svturr", 6, "turr3");
        M.Turr4 = BuildObject("svturr", 6, "turr4");
        M.Turr5 = BuildObject("svturr", 6, "turr5");
        M.Turr6 = BuildObject("svturr", 6, "turr6");
        M.def1 = BuildObject("svturr", 6, "def1");
        M.def2 = BuildObject("svturr", 6, "def2");
        M.def3 = BuildObject("svturr", 6, "def3");
        M.def4 = BuildObject("svturr", 6, "def4");
        M.def5 = BuildObject("svturr", 6, "def5");
        M.tow1 = BuildObject("sbgtow", 5, "tow1");
        M.tow2 = BuildObject("sbgtow", 5, "tow2");
        M.tow3 = BuildObject("sbgtow", 5, "tow3");
        M.tow4 = BuildObject("sbgtow", 5, "tow4");
        ClearObjectives();
        AddObjective(startxt, "white");
        Goto(M.Recycler, "Rec_path1", 1);
        M.EnemyRec1 = BuildObject(">sbrecy_b", 5, "RecyclerEnemy");
        M.EnemyRec2 = BuildObject(">sbrecy_b", 6, "RecyclerEnemy2");
        Advance(R, 30);
    elseif (STATE == 1) then
        SetAIP("FS03.aip", 5);
        SetAIP("FS03b.aip", 6);
        Advance(R);
    elseif (STATE == 2) then -- Label: AT_TECH
        M.ValueMain31 = Distance3D(M.Recycler, M.Tech);
        if (M.ValueMain31 > 50) then
            SetState(R, 2); -- Goto label AT_TECH
            return;
        end
        Advance(R, 40);
    elseif (STATE == 3) then
        Goto(M.Recycler, "Rec_path1", 0);
        ClearObjectives();
        AddObjective(techtxt, "white");
        SetRoutineActive(CheckRecy2, true);
        Advance(R);
    elseif (STATE == 4) then -- Label: CHECK_ENEMY_REC
        M.ValueMain38 = IsAround(M.EnemyRec1);
        if (M.ValueMain38 == true) then
            SetState(R, 4); -- Goto label CHECK_ENEMY_REC
            return;
        end
        SetRoutineActive(CheckRecy2, false);
        ClearObjectives();
        AddObjective(rec1txt, "green");
        Advance(R, 10);
    elseif (STATE == 5) then
        M.Rckt1 = BuildObject("ivrckt_BD", 2, "spawn_1");
        M.Rckt2 = BuildObject("ivrckt_BD", 2, "spawn_1");
        M.Rckt3 = BuildObject("ivrckt_BD", 2, "spawn_1");
        M.Rckt4 = BuildObject("ivrckt_BD", 2, "spawn_1");
        Goto(M.Rckt1, "attack_1", 1);
        Goto(M.Rckt2, "attack_1", 1);
        Goto(M.Rckt3, "attack_1", 1);
        Goto(M.Rckt4, "attack_1", 1);
        Advance(R, 20);
    elseif (STATE == 6) then
        ClearObjectives();
        AddObjective(allies, "blue");
        M.Walk1 = BuildObject("ivwalk_BD", 2, "spawn_1");
        M.Walk2 = BuildObject("ivwalk_BD", 2, "spawn_1");
        M.Walk3 = BuildObject("ivwalk_BD", 2, "spawn_1");
        Goto(M.Walk1, "attack_2", 1);
        Goto(M.Walk2, "attack_2", 1);
        Goto(M.Walk3, "attack_2", 1);
        Advance(R, 15);
    elseif (STATE == 7) then
        M.Sct1 = BuildObject("ivsct_BD", 2, "spawn_1");
        M.Sct2 = BuildObject("ivsct_BD", 2, "spawn_1");
        M.Sct3 = BuildObject("ivsct_BD", 2, "spawn_1");
        Goto(M.Sct1, "attack_1", 1);
        Goto(M.Sct2, "attack_1", 1);
        Goto(M.Sct3, "attack_1", 1);
        Advance(R, 10);
    elseif (STATE == 8) then
        M.Tnk1 = BuildObject("ivtnk_BD", 2, "spawn_1");
        M.Tnk2 = BuildObject("ivtnk_BD", 2, "spawn_1");
        Goto(M.Tnk1, "attack_2", 1);
        Goto(M.Tnk2, "attack_2", 1);
        Advance(R, 30);
    elseif (STATE == 9) then
        M.Attacker = BuildObject("svscA_D", 5, "spawn_1");
        Goto(M.Attacker, M.Rckt1, 0);
        M.Attacker = BuildObject("svBrood_L", 5, "spawn_1");
        Goto(M.Attacker, M.Walk1, 0);
        Advance(R, 5);
    elseif (STATE == 10) then
        M.Attacker = BuildObject("svtank_L", 5, "spawn_1");
        Goto(M.Attacker, M.Rckt1, 0);
        M.Attacker = BuildObject("svtank_L", 5, "spawn_1");
        Goto(M.Attacker, M.Walk1, 0);
        Advance(R, 10);
    elseif (STATE == 11) then
        M.Attacker = BuildObject("svscA_D", 5, "spawn_1");
        Goto(M.Attacker, M.Rckt1, 0);
        M.Attacker = BuildObject("svscA_D", 5, "spawn_1");
        Goto(M.Attacker, M.Walk1, 0);
        Advance(R, 15);
    elseif (STATE == 12) then
        M.Attacker = BuildObject("svtank_L", 5, "spawn_1");
        Goto(M.Attacker, M.Rckt1, 0);
        M.Attacker = BuildObject("svtank_L", 5, "spawn_1");
        Goto(M.Attacker, M.Walk1, 0);
        Advance(R);
    elseif (STATE == 13) then -- Label: CHECK_ENEMY_REC2
        Advance(R, 20);
    elseif (STATE == 14) then
        M.AttackerCount = 1 + M.AttackerCount;
        if (M.AttackerCount > 15) then
            SetState(R, 19); -- Goto label CHECK_ENEMY_REC2B
            return;
        end
        M.Attacker = BuildObject("svscA_D", 5, "spawn_1");
        Goto(M.Attacker, "attack_1", 1);
        Advance(R, 5);
    elseif (STATE == 15) then
        M.Attacker = BuildObject("svBrood_L", 5, "spawn_1");
        Goto(M.Attacker, "attack_1", 1);
        Advance(R, 5);
    elseif (STATE == 16) then
        M.Attacker = BuildObject("svtank_L", 5, "spawn_1");
        Goto(M.Attacker, "attack_1", 1);
        Advance(R, 5);
    elseif (STATE == 17) then
        M.Attacker = BuildObject("svBrood_L", 5, "spawn_1");
        Goto(M.Attacker, M.Recycler, 0);
        Advance(R, 5);
    elseif (STATE == 18) then
        M.Attacker = BuildObject("svtank_L", 5, "spawn_1");
        Goto(M.Attacker, M.Recycler, 0);
        M.ValueMain110 = IsAround(M.EnemyRec2);
        if (M.ValueMain110 == true) then
            SetState(R, 13); -- Goto label CHECK_ENEMY_REC2
            return;
        end
        Advance(R);
    elseif (STATE == 19) then -- Label: CHECK_ENEMY_REC2B
        M.ValueMain112 = IsAround(M.EnemyRec2);
        if (M.ValueMain112 == true) then
            SetState(R, 19); -- Goto label CHECK_ENEMY_REC2B
            return;
        end
        Advance(R, 10);
    elseif (STATE == 20) then
        ClearObjectives();
        AddObjective(lastorders, "green");
        M.star_nav = BuildObject("ibnav", 1, "star_nav");
        SetObjectiveName(M.star_nav, "StarPort");
        SetObjectiveOn(M.star_nav);
        Goto(M.Rckt1, "star_nav", 1);
        Goto(M.Rckt2, "star_nav", 1);
        Goto(M.Rckt3, "star_nav", 1);
        Goto(M.Rckt4, "star_nav", 1);
        Goto(M.Walk1, "star_nav", 1);
        Goto(M.Walk2, "star_nav", 1);
        Goto(M.Walk3, "star_nav", 1);
        Goto(M.Sct1, "star_nav", 1);
        Goto(M.Sct2, "star_nav", 1);
        Goto(M.Sct3, "star_nav", 1);
        Goto(M.Tnk1, "star_nav", 1);
        Goto(M.Tnk2, "star_nav", 1);
        M.Swalk1 = BuildObject("Svwalk_J2", 5, "finalforce1");
        M.Swalk2 = BuildObject("Svwalk_L2", 5, "finalforce1");
        M.Attacker = BuildObject("Svinst_L2", 5, "finalforce1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("Svartl_L2", 5, "finalforce1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("Svinst_L2", 5, "finalforce1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("Svinst_L2", 5, "finalforce1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Attacker = BuildObject("Svinst_L2", 5, "finalforce1");
        Patrol(M.Attacker, "patrol_1", 1);
        M.Swalk3 = BuildObject("Svwalk_J2", 5, "finalforce2");
        M.Swalk4 = BuildObject("Svwalk_L2", 5, "finalforce2");
        M.Attacker = BuildObject("Svinst_L2", 5, "finalforce2");
        Patrol(M.Attacker, "patrol_2", 1);
        M.Attacker = BuildObject("Svartl_L2", 5, "finalforce2");
        Patrol(M.Attacker, "patrol_2", 1);
        M.Attacker = BuildObject("Svartl_L2", 5, "finalforce2");
        Patrol(M.Attacker, "patrol_2", 1);
        M.Attacker = BuildObject("Svartl_L2", 5, "finalforce2");
        Patrol(M.Attacker, "patrol_2", 1);
        Advance(R);
    elseif (STATE == 21) then -- Label: WALK_1
        Advance(R, 60);
    elseif (STATE == 22) then
        M.Attacker = BuildObject("svBrood_L", 5, "last_attackers");
        Goto(M.Attacker, M.Recycler, 0);
        Advance(R, 20);
    elseif (STATE == 23) then
        M.Attacker = BuildObject("svscA_D", 5, "last_attackers");
        Goto(M.Attacker, M.Recycler, 0);
        Advance(R, 20);
    elseif (STATE == 24) then
        M.ValueMain161 = IsAround(M.Swalk1);
        if (M.ValueMain161 == true) then
            SetState(R, 21); -- Goto label WALK_1
            return;
        end
        Advance(R);
    elseif (STATE == 25) then -- Label: WALK_2
        Advance(R, 20);
    elseif (STATE == 26) then
        M.Attacker = BuildObject("svscA_D", 5, "last_attackers");
        Goto(M.Attacker, M.Recycler, 0);
        M.ValueMain166 = IsAround(M.Swalk2);
        if (M.ValueMain166 == true) then
            SetState(R, 25); -- Goto label WALK_2
            return;
        end
        Advance(R);
    elseif (STATE == 27) then -- Label: WALK_3
        Advance(R, 20);
    elseif (STATE == 28) then
        M.Attacker = BuildObject("svBrood_L", 5, "last_attackers");
        Goto(M.Attacker, M.Recycler, 0);
        M.ValueMain171 = IsAround(M.Swalk3);
        if (M.ValueMain171 == true) then
            SetState(R, 27); -- Goto label WALK_3
            return;
        end
        Advance(R);
    elseif (STATE == 29) then -- Label: WALK_4
        Advance(R, 20);
    elseif (STATE == 30) then
        M.Attacker = BuildObject("svscA_D", 5, "last_attackers");
        Goto(M.Attacker, M.Recycler, 0);
        M.ValueMain176 = IsAround(M.Swalk4);
        if (M.ValueMain176 == true) then
            SetState(R, 29); -- Goto label WALK_4
            return;
        end
        Advance(R, 20);
    elseif (STATE == 31) then
        ClearObjectives();
        AddObjective(WinText, "green");
        SucceedMission(16, "FS03win.des");
    end
end

function CheckRecy(R, STATE)
    if (STATE == 0) then -- Label: REC_IS_ALIVE
        M.Recycler = GetHandle("Recycler");
        M.ValueCheckRecy2 = IsAround(M.Recycler);
        if (M.ValueCheckRecy2 == true) then
            SetState(R, 0); -- Goto label REC_IS_ALIVE
            return;
        end
        FailMission(10, "FS03fail.des");
    end
end

function CheckRecy2(R, STATE)
    if (STATE == 0) then -- Label: REC2_IS_ALIVE
        M.ValueCheckRecy21 = IsAround(M.EnemyRec2);
        if (M.ValueCheckRecy21 == true) then
            SetState(R, 0); -- Goto label REC2_IS_ALIVE
            return;
        end
        FailMission(10, "FS03fail2.des");
    end
end
