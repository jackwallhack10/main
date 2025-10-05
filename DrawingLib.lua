--// Custom Drawing Library
-- Save this as DrawingLib.lua or paste at top of your script

local DrawingLib = {}
DrawingLib.Objects = {}
DrawingLib.Settings = {
    Font = 2, -- Default font (0-3)
    Color = Color3.fromRGB(255, 255, 255),
    Transparency = 1,
    Size = 18,
    Outline = true,
    Center = true,
}

-- Create a new Drawing object
function DrawingLib:New(class, properties)
    local obj = Drawing.new(class)
    for prop, val in pairs(self.Settings) do
        pcall(function() obj[prop] = val end)
    end
    if properties then
        for prop, val in pairs(properties) do
            pcall(function() obj[prop] = val end)
        end
    end
    table.insert(self.Objects, obj)
    return obj
end

-- Change global default settings dynamically
function DrawingLib:SetDefault(prop, value)
    if self.Settings[prop] ~= nil then
        self.Settings[prop] = value
    end
end

-- Hide all drawings (useful for toggles)
function DrawingLib:HideAll(state)
    for _, obj in ipairs(self.Objects) do
        pcall(function()
            obj.Visible = not state
        end)
    end
end

-- Cleanup all drawings
function DrawingLib:Clear()
    for _, obj in ipairs(self.Objects) do
        pcall(function()
            obj:Remove()
        end)
    end
    self.Objects = {}
end

return DrawingLib
