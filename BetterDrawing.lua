--// BetterDrawing Library (with Name ESP)
-- Designed for Roblox executors with Drawing API
-- by Isaiah (2025)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local DrawingObjects = {}
local Drawing = getgenv().Drawing
local HookFunction = getgenv().hookfunction

local BetterDrawing = {}
BetterDrawing.FLAG = "BETTER_DRAWING"
BetterDrawing.NameESP_Enabled = true
BetterDrawing.ESP_Objects = {}

if not (Drawing and HookFunction) then
    warn("[BetterDrawing] Drawing API not available.")
    return BetterDrawing
end

--// Hook Drawing.new to track flagged objects
local cleardrawcache = getgenv().cleardrawcache or (function()
    local DrawingNew; DrawingNew = HookFunction(Drawing.new, function(Type, PotentialFlag)
        local Object = DrawingNew(Type)

        if (PotentialFlag == BetterDrawing.FLAG) then
            table.insert(DrawingObjects, Object)
        end

        return Object
    end)

    return function()
        for _, Object in ipairs(DrawingObjects) do
            pcall(function() Object:Remove() end)
        end
        table.clear(DrawingObjects)
    end
end)()

--// Initialize frame loop
function BetterDrawing:Init(callback)
    RunService.PreRender:Connect(function()
        if callback then
            callback()
        end
        cleardrawcache()
    end)
end

--// Built-in Name ESP System
function BetterDrawing:EnableNameESP(state)
    self.NameESP_Enabled = state
end

function BetterDrawing:NameESP()
    self:Init(function()
        if not self.NameESP_Enabled then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))

                if onScreen then
                    local text = Drawing.new("Text", BetterDrawing.FLAG)
                    text.Center = true
                    text.Outline = true
                    text.Font = 1
                    text.Size = 18
                    text.Transparency = 1
                    text.Text = player.Name
                    text.Color = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                    text.Position = Vector2.new(pos.X, pos.Y)
                    text.Visible = true
                end
            end
        end
    end)
end

--// Utility cleanup
function BetterDrawing:Clear()
    cleardrawcache()
end

return BetterDrawing
