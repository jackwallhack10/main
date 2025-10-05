-- BetterDrawing Library (with optional Name ESP support)
-- Preserves hook & auto-cleanup for Drawing.new objects

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local DrawingObjects = {}
local Drawing = getgenv().Drawing
local HookFunction = getgenv().hookfunction

local BetterDrawing = {}
BetterDrawing.FLAG = "BETTER_DRAWING"
BetterDrawing.NameESP_Enabled = true

if not (Drawing and HookFunction) then
    warn("[BetterDrawing] Drawing API not found!")
    return BetterDrawing
end

-- Hook Drawing.new to track objects flagged with FLAG
local cleardrawcache = getgenv().cleardrawcache or (function()
    local DrawingNew
    DrawingNew = HookFunction(Drawing.new, function(Type, PotentialFlag)
        local Object = DrawingNew(Type)
        if PotentialFlag == BetterDrawing.FLAG then
            table.insert(DrawingObjects, Object)
        end
        return Object
    end)

    return function()
        for _, obj in ipairs(DrawingObjects) do
            pcall(function() obj:Remove() end)
        end
        table.clear(DrawingObjects)
    end
end)()

-- Initialize PreRender loop
function BetterDrawing:Init(callback)
    RunService.PreRender:Connect(function()
        if callback then
            callback()
        end
        cleardrawcache()
    end)
end

-- Enable or disable Name ESP
function BetterDrawing:EnableNameESP(state)
    self.NameESP_Enabled = state
end

-- Name ESP rendering helper
function BetterDrawing:RenderNameESP(font, size, offset)
    font = font or 1
    size = size or 18
    offset = offset or Vector3.new(0, 3, 0)

    self:Init(function()
        if not self.NameESP_Enabled then return end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position + offset)
                    if onScreen then
                        local text = Drawing.new("Text", BetterDrawing.FLAG)
                        text.Center = true
                        text.Outline = true
                        text.Font = font
                        text.Size = size
                        text.Color = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
                        text.Position = Vector2.new(pos.X, pos.Y)
                        text.Text = player.Name
                        text.Visible = true
                    end
                end
            end
        end
    end)
end

-- Cleanup all objects immediately
function BetterDrawing:Clear()
    cleardrawcache()
end

return BetterDrawing
