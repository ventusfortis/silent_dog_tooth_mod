local Mod = RegisterMod("Silent Dog Tooth", 1)
local game = Game()
local level = game:GetLevel()
local hasTooth = false


local spriteSecret = Sprite()
spriteSecret:Load("gfx/dog_tooth_overlay.anm2", true)
local spriteRetro = Sprite()
spriteRetro:Load("gfx/dog_tooth_overlay2.anm2",true)

function Mod:checkRoom()
    local room = game:GetRoom()
    local result = 0
    local currRoom = level:GetCurrentRoom()
    if currRoom:GetDungeonRockIdx() ~= -1 then
        --print("Index: ", currRoom:GetDungeonRockIdx())
        local gridEntity = currRoom:GetGridEntity(currRoom:GetDungeonRockIdx())
        if gridEntity:GetType() >= 2 and gridEntity:GetType() <= 6 then -- Check if found entity is actually a rock
            result = 2
        end
    end
    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door ~= nil then
            local roomType = door.TargetRoomType
            local room = level:GetRoomByIdx(door.TargetRoomIndex)
            if (roomType == 7 or roomType == 8) and room.VisitedCount == 0 then
                result = 1
            end
        end
    end
    --print("result: ", result)
    return result
end

function renderAnimSecret()
    local player = game:GetPlayer(0)
    local pos = player.Position
    local renderPos = Isaac.WorldToScreen(pos)
    spriteSecret:Render(renderPos + Vector(0,-50), Vector.Zero, Vector.Zero)
    spriteSecret:Update()
end

function renderAnimDungeon()
    local player = game:GetPlayer(0)
    local pos = player.Position
    local renderPos = Isaac.WorldToScreen(pos)
    spriteRetro:Render(renderPos + Vector(0,-50), Vector.Zero, Vector.Zero)
    spriteRetro:Update()
end

function playAnimSecret()
    spriteSecret:Play("AnimSecret", true)
    --print("Played AnimSecret")
end

function playAnimDungeon()
    spriteRetro:Play("AnimDungeon", true)
    --print("Played AnimDungeon")
end

function manageAnimation()
    if Isaac.GetPlayer():HasCollectible(CollectibleType.COLLECTIBLE_DOG_TOOTH) then
        if not hasTooth then
            hasTooth = true
        end
        local result = Mod:checkRoom()
        -- print("result = ", result)
        if result == 1 then
            playAnimSecret()
            Mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderAnimSecret)
           -- print("Secret animation started")
        elseif result == 2 then
            playAnimDungeon()
            Mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderAnimDungeon)
            --print("Dungeon animation started")
        else
            Mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, renderAnimSecret)
            Mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, renderAnimDungeon)
            --print("Animation ended")
        end
    else
        if hasTooth then
            hasTooth = false
        Mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, renderAnimSecret)
        Mod:RemoveCallback(ModCallbacks.MC_POST_RENDER, renderAnimDungeon)
        --print("Animation ended")
        return
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, manageAnimation)


