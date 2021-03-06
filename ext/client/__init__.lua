function move_player(new_pos)
    NetEvents:Send('MovePlayer', new_pos)
end

Console:Register('Radius', 'Set the radius of possible spawn positions.', function(args)
    if #args == 1 then
        radius = tonumber(args[1])
        print("Setting radius to " .. tostring(radius))
        NetEvents:Send('SetRadius', radius)
    else
        print("Enter a single argument, a number in meters")
    end
end)

Events:Subscribe('Client:UpdateInput', function(deltaTime)
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_F4) then
        NetEvents:Send('Start')
    end
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_F5) then
        NetEvents:Send('PosGood')
    end
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_F6) then
        NetEvents:Send('PosBad')
    end
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_F7) then
        NetEvents:Send('Stop')
    end
end)

NetEvents:Subscribe('RaycastDown', function(start_pos)
    local to = start_pos:Clone()
    to.y = 0
    local ground = RaycastManager:Raycast(start_pos, to, RayCastFlags.DontCheckCharacter)
    NetEvents:Send('SpawnPosGround', ground.position)
end)

NetEvents:Subscribe('AllPositions', function(positions)
    print("{")
    for i = 1, #positions do
        local pos = positions[i]
        print("Vec3" .. tostring(pos) .. ", ")
    end
    print("}")
end)
