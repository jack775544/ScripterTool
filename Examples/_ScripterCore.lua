-- Replica of the replace method done in C++ in the scripter dll source
-- Not using the new ReplaceObject to keep existing behaviour the same
function _ScripterCore.replace(handle, odf, keepHealth)
    local team = GetTeamNum(handle);
    local position = GetPosition(handle);
    local velocity = GetVelocity(handle);
    local health = GetCurHealth(handle);
    local wasPlayer = IsPlayer(handle);
    local who = GetCurrentWho(handle);
    local command = GetCurrentCommand(handle);

    if (IsAround(handle)) then
        RemoveObject(handle);
    end

    local newHandle = BuildObject(odf, team, position);
    if (wasPlayer == true) then
        SetAsUser(newHandle, team);
    end

    SetVelocity(newHandle, velocity);

    if (keepHealth) then
        SetCurHealth(newHandle, health);
    end

    if (command == "CMD_ATTACK") then
        Attack(newHandle, who, 0);
    elseif (command == "CMD_FOLLOW") then
        Follow(newHandle, who, 0);
    elseif (command == "CMD_DEFEND") then
        Defend2(newHandle, who, 0);
    elseif (command == "CMD_LOOK_AT") then
        LookAt(newHandle, who, 0);
    elseif (command == "CMD_SERVICE") then
        Service(newHandle, who, 0);
    end

    return newHandle;
end