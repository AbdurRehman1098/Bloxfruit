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

-- ── Patch Discord invite link ──────────────────────────────────
-- Override CopyLinkButton so clicking it copies our Discord invite
local DISCORD_LINK = "https://discord.gg/8GcSpAcVYm"

task.spawn(function()
    task.wait(1)  -- wait for original script to wire up its click handlers

    local gui2 = game:GetService("CoreGui"):FindFirstChild("Adminus")
    if gui2 then
        local main2 = gui2:FindFirstChild("Main")
        if main2 then
            local holder = main2:FindFirstChild("Holder")
            if holder then
                local settings = holder:FindFirstChild("settings")
                if settings then
                    local copyBtn = settings:FindFirstChild("CopyLinkButton")
                    if copyBtn then
                        -- Update visible label
                        local title5 = copyBtn:FindFirstChild("Title")
                        if title5 then title5.Text = "Discord Invite" end

                        local value4 = copyBtn:FindFirstChild("Value")
                        if value4 then value4.Text = "discord.gg/8GcSpAcVYm" end

                        -- Override click — Interact is the transparent full-size TextButton
                        local interact = copyBtn:FindFirstChild("Interact")
                        if interact then
                            -- Disconnect original connections by replacing with a fresh one
                            interact.MouseButton1Click:Connect(function()
                                setclipboard(DISCORD_LINK)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Return the global `self` table so FruitFinder gets Status, TweenStatus etc.
return self
