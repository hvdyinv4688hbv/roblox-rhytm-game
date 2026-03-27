-- roblox studio luau
local poisonous = false
local damage = 50

if poisonous then
    local p_dmg = damage / 50 -- poison damage per tick
    for num = 1, 6 do
        player.Health = player.Health - p_dmg
        task.wait(1)
    end
elseif not poisonous do
    player.Health = player.Health - damage
end
