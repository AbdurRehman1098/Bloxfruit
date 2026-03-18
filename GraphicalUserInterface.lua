--[[
    GraphicalUserInterface.lua — Abdur Rehman Dev Edition
    Loads the original Adminus GUI then patches the title/branding.
--]]

-- Load original GUI from flerci42
local AdminusUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/flerci42/Adminus_FruitSniper_V2/refs/heads/main/GraphicalUserInterface.lua"
))()

-- ── Patch visible branding ────────────────────────────────────
local gui = game:GetService("CoreGui"):FindFirstChild("Adminus")

if gui then
    local main = gui:FindFirstChild("Main")
    if main then
        -- Main title label
        local title = main:FindFirstChild("Title")
        if title then
            title.Text = "Abdur Rehman Dev | BloxFruits"
        end

        -- Subtitle
        local sub = main:FindFirstChild("Subtitle")
        if sub then
            sub.Text = "Abdur Rehman Dev — Auto fruit sniper for Blox Fruits"
        end
    end
end

-- Return the UI table so FruitFinder.lua works identically
return AdminusUI
