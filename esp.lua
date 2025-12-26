-- =====================================   BLOCKSPIN  ==================================================
-- =====================================================================================================

local UPDATE_INTERVAL = 0.1
local INVENTORY_TEXT_COLOR = Color3.new(1, 1, 1)
local DEFAULT_ESP_COLOR = Color3.new(1, 0, 0)

local Camera = workspace.CurrentCamera

-- ================= SCREEN SCALING =================

local function getInventoryPosition()
    local vp = Camera.ViewportSize
    return Vector2.new(
        math.floor(vp.X * 0.02), -- left padding (2%)
        math.floor(vp.Y * 0.22)  -- top padding (phone-safe)
    )
end

local function getInventoryFontSize()
    local vp = Camera.ViewportSize
    if vp.X < 700 then
        return 12 -- phone
    elseif vp.X < 1100 then
        return 14 -- tablet
    else
        return 16 -- PC
    end
end

-- ================= ITEM DATABASE =================

local ITEM_DATABASE = {
    {meshPattern = "c9_cube", displayName = "C9", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "glock_colt45", displayName = "Glock", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "uzi_cube", displayName = "UZI", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "m24_cube", displayName = "M24", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "revolver anaconda_cube", displayName = "Anaconda", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "mp5_cube", displayName = "MP5", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "firework launcher_cylinder", displayName = "FireworkL", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "remington_cube", displayName = "RemingtonSG", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "double barrel shotgun_cube", displayName = "Double/Sawnoff", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "rpg_cube", displayName = "RPG", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "p226_cube", displayName = "P226", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "huntingrifle_cube", displayName = "HuntingR", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "g3_cube", displayName = "G3", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "draco_cube", displayName = "Draco", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "ak47_cube", displayName = "AK47", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "crossbox_cube", displayName = "Crossbow", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "m16 aug_Cube", displayName = "Skorpion", color = DEFAULT_ESP_COLOR, isPrefix = true},
    {meshPattern = "aug_Cube", displayName = "M16", color = DEFAULT_ESP_COLOR, isPrefix = true},

    {meshPattern = "new melees_cylinder.002", displayName = "Sledge Hammer", color = Color3.new(1, 0.65, 0)},
    {meshPattern = "weapon tools_cylinder.005", displayName = "Shovel", color = Color3.new(1, 0.65, 0)},
    {meshPattern = "weapon tools_cube.005", displayName = "Machete", color = Color3.new(1, 0.65, 0)},
    {meshPattern = "weapon tools_cylinder", displayName = "Crowbar", color = Color3.new(1, 0.65, 0)},
    {meshPattern = "new melees_plane.003", displayName = "Butcher Knife", color = Color3.new(1, 0.65, 0)},
    {meshPattern = "weapon tools_cube.001", displayName = "Wrench", color = Color3.new(1, 0.65, 0)},
    {meshPattern = "new melees_cylinder.004", displayName = "Tactical Shovel", color = Color3.new(1, 1, 0)},
    {meshPattern = "new melees_plane.005", displayName = "Tactical Knife", color = Color3.new(1, 1, 0)},
    {meshPattern = "new melees_plane", displayName = "Tactical Axe", color = Color3.new(1, 1, 0)},
    {meshPattern = "weapon tools_cube.006", displayName = "Switchblade", color = Color3.new(1, 0.65, 0)},
    {meshPattern = "weapon tools_1.001", displayName = "Barbed Bat", color = Color3.new(1, 0, 0)},
    {meshPattern = "1a_Plane", displayName = "Combat Axe", color = Color3.new(1, 0, 0), isPrefix = true}
}

-- ================= INVENTORY DISPLAY =================

local displaytextinv = nil
local activeItemDrawings = {}

local function refreshinventory()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer or not localPlayer.Character then return end

    if not displaytextinv then
        displaytextinv = Drawing.new("Text")
        displaytextinv.Font = 2
        displaytextinv.Color = INVENTORY_TEXT_COLOR
        displaytextinv.Outline = true
        displaytextinv.Visible = true
    end

    displaytextinv.Position = getInventoryPosition()
    displaytextinv.Size = getInventoryFontSize()

    local DISPLAYENTRIES = {}

    for _, player in ipairs(game.Players:GetChildren()) do
        if not player:IsA("Player") then continue end

        local found = {}
        local list = {}

        local function scan(container)
            if not container then return end
            for _, tool in ipairs(container:GetChildren()) do
                if not tool:IsA("Tool") then continue end
                for _, part in ipairs(tool:GetChildren()) do
                    if string.sub(part.Name, 1, 7) == "Meshes/" then
                        local mesh = string.lower(string.sub(part.Name, 8))
                        for _, db in ipairs(ITEM_DATABASE) do
                            local pat = string.lower(db.meshPattern)
                            local match = db.isPrefix and mesh:sub(1, #pat) == pat or mesh == pat
                            if match and not found[db.displayName] then
                                found[db.displayName] = true
                                table.insert(list, "- " .. db.displayName)
                            end
                        end
                    end
                end
            end
        end

        scan(player.Backpack)
        scan(player.Character)

        if #list > 0 then
            table.insert(DISPLAYENTRIES, player.Name .. ":\n" .. table.concat(list, "\n"))
        end
    end

    displaytextinv.Text = (#DISPLAYENTRIES > 0) and table.concat(DISPLAYENTRIES, "\n\n") or " "
end

-- ================= MAIN LOOP =================

spawn(function()
    while true do
        pcall(refreshinventory)
        wait(UPDATE_INTERVAL)
    end
end)
