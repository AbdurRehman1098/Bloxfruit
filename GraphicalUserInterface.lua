--[[
    GraphicalUserInterface.lua — Abdur Rehman Dev Edition
    Loads the original Adminus GUI then patches the title/branding.
--]]

-- Load original GUI (sets global `self` table internally)
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/flerci42/Adminus_FruitSniper_V2/refs/heads/main/GraphicalUserInterface.lua"
))()

-- ── Patch visible branding ────────────────────────────────────
-- `self` is now the global UI table set by the original script
task.wait(0.6)  -- wait for UI load animation to finish setting up

local gui = game:GetService("CoreGui"):FindFirstChild("Adminus")
if gui then
    local main = gui:FindFirstChild("Main")
    if main then
        local title = main:FindFirstChild("Title")
        if title then title.Text = "Abdur Rehman Dev | BloxFruits" end

        local sub = main:FindFirstChild("Subtitle")
        if sub then sub.Text = "Abdur Rehman Dev — Auto fruit sniper for Blox Fruits" end
    end
end

-- Return the global `self` table so FruitFinder gets Status, TweenStatus etc.
return self
