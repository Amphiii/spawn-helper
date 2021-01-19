

radius = 10
start_pos = nil
cur_pos = nil
positions = {}

function move_player(player, pos)
    if player ~= nil then
        -- Move the player to the new position
        player.soldier:SetPosition(pos)
    else
        print("Could not find current player!")
    end
end

function generate_new_spawn(player)
    -- Generate polar coordinates
    local r = MathUtils:GetRandom(0, radius)
    local theta = MathUtils:GetRandom(0, 2 * math.pi)

    -- Convert to cartesian
    local x = r * math.sin(theta)
    local z = r * math.cos(theta)

    -- Use the client to make a raycast
    -- This helps us calculate the new Y value without clipping into the floor
    local start_pos_elevated = Vec3(start_pos.x + x, start_pos.y + 5, start_pos.z + z)
    NetEvents:SendTo('RaycastDown', player, start_pos_elevated)
end

NetEvents:Subscribe('SpawnPosGround', function(player, ground)
    -- Set the current pos and move the player
    cur_pos = ground
    move_player(player, ground)
    -- Print the current status
    ChatManager:SendMessage("Number of spawn points recorded: " .. tostring(#positions))
    ChatManager:SendMessage('Spawn Helper: F5 = good, F6 = bad, F7 to stop')
end)

NetEvents:Subscribe('SetRadius', function(player, radius)
    -- Set the global radius
    radius = 10
end)

NetEvents:Subscribe('Start', function(player)
    -- Set the global start_pos
    start_pos = player.soldier.worldTransform.trans
    print("Starting spawn helper at position" .. tostring(start_pos))
    -- Empty the position list
    positions = {}
    -- Move the player to a new position
    local new_pos = generate_new_spawn(player)
end)

NetEvents:Subscribe('PosGood', function(player)
    -- Append the current player position to the positions table
    positions[#positions + 1] = player.soldier.worldTransform.trans
    -- Move the player to a new position
    local new_pos = generate_new_spawn(player)
end)

NetEvents:Subscribe('PosBad', function(player)
    -- Move the player to a new position
    local new_pos = generate_new_spawn(player)
end)

NetEvents:Subscribe('Stop', function(player)
    -- Send all recorded positions to the player
    ChatManager:SendMessage("Printing positions to console...")
    NetEvents:SendTo('AllPositions', player, positions)
end)

NetEvents:Subscribe('MovePlayer', function(player, new_pos)
    move_player(player, new_pos)
end)

Events:Subscribe('Player:Respawn', function(player)
    ChatManager:SendMessage('Spawn Helper: F4 to start, F5 = good, F6 = bad, F7 to stop')
    ChatManager:SendMessage('Type "list" in the console to see spawn helper commands')
end)
