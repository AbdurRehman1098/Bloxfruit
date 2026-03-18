--[[
    ╔══════════════════════════════════════════════════════════╗
    ║      ABDUR REHMAN DEV — WEBHOOK NOTIFIER                 ║
    ║  Run this ALONGSIDE FruitFinder.lua                     ║
    ║  Monitors Workspace → sends Discord webhook on detect   ║
    ╚══════════════════════════════════════════════════════════╝

    Execute WebhookNotifier.lua first, then FruitFinder.lua
--]]

-- ══════════════════════════════════════════════════════════════
--  ⚙️  CONFIG
-- ══════════════════════════════════════════════════════════════
local WEBHOOK_URL     = "https://discord.com/api/webhooks/1483939239380123809/FsvTNHa11Z-Zoyy9WlOPp5SXCHSxaf9XV1vA7lrPocMWkycnjKmEBc3j27llliFR3LC5"
local SCAN_INTERVAL   = 2    -- seconds between workspace scans
local NOTIFY_COOLDOWN = 90   -- seconds before re-pinging the same fruit

-- ══════════════════════════════════════════════════════════════
--  🍒 FRUIT RARITY  (same RareFruits as FruitFinder)
-- ══════════════════════════════════════════════════════════════
local RARE_FRUITS = {
    ["Dragon Fruit"]=true, ["Kitsune Fruit"]=true, ["Spirit Fruit"]=true,
    ["Venom Fruit"]=true,  ["Dough Fruit"]=true,   ["Shadow Fruit"]=true,
    ["Control Fruit"]=true,["Yeti Fruit"]=true,    ["Tiger Fruit"]=true,
    ["Gas Fruit"]=true,    ["T-Rex Fruit"]=true,   ["Mammoth Fruit"]=true,
    ["Gravity Fruit"]=true,["Leopard Fruit"]=true, ["Rumble Fruit"]=true,
    ["Sound Fruit"]=true,  ["Phoenix Fruit"]=true, ["Pain Fruit"]=true,
    ["Blizzard Fruit"]=true,
}

local FRUIT_EMOJI = {
    ["Dragon Fruit"]="🐲", ["Kitsune Fruit"]="🦊", ["Spirit Fruit"]="👁️",
    ["Venom Fruit"]="☠️",  ["Dough Fruit"]="🥖",   ["Shadow Fruit"]="🌚",
    ["Control Fruit"]="🎮",["Yeti Fruit"]="🏔️",   ["Tiger Fruit"]="🐯",
    ["Gas Fruit"]="🌫️",   ["T-Rex Fruit"]="🦖",   ["Mammoth Fruit"]="🐘",
    ["Gravity Fruit"]="🪐",["Leopard Fruit"]="🐆", ["Rumble Fruit"]="⚡",
    ["Sound Fruit"]="🎵",  ["Phoenix Fruit"]="🦅", ["Buddha Fruit"]="🧘",
    ["Magma Fruit"]="🌋",  ["Quake Fruit"]="💢",   ["Light Fruit"]="💡",
    ["Flame Fruit"]="🔥",  ["Ice Fruit"]="❄️",     ["Dark Fruit"]="🌑",
    ["Diamond Fruit"]="💎",["Love Fruit"]="❤️",    ["Spider Fruit"]="🕷️",
    ["Ghost Fruit"]="👻",  ["Barrier Fruit"]="🛡️", ["Rubber Fruit"]="🫧",
    ["Blizzard Fruit"]="🌨️",["Pain Fruit"]="😖",
}

-- ══════════════════════════════════════════════════════════════
--  📡  HTTP  (Xeno / KRNL / Fluxus / Synapse)
-- ══════════════════════════════════════════════════════════════
local HttpService = game:GetService("HttpService")
local RunService  = game:GetService("RunService")
local Players     = game:GetService("Players")
local Workspace   = game:GetService("Workspace")

local function getRequestFn()
    for _, name in ipairs({"request","http_request","syn_request"}) do
        local fn = getgenv and getgenv()[name]
        if type(fn) == "function" then return fn end
    end
    if type(request)      == "function" then return request      end
    if type(http_request) == "function" then return http_request end
    if type(syn_request)  == "function" then return syn_request  end
end

-- ══════════════════════════════════════════════════════════════
--  🛠️  HELPERS
-- ══════════════════════════════════════════════════════════════
local function getServerId()
    local ok, id = pcall(function() return game.JobId end)
    return (ok and id and #id > 0) and id or "N/A"
end

local function getPlayer()
    local lp = Players.LocalPlayer
    return lp and (lp.DisplayName .. " (`" .. lp.Name .. "`)") or "Unknown"
end

-- ══════════════════════════════════════════════════════════════
--  💬  EMBED + SEND
-- ══════════════════════════════════════════════════════════════
local function sendWebhook(fruitName, pos, action)
    local fn = getRequestFn()
    if not fn then return end

    local isRare  = RARE_FRUITS[fruitName]
    local emoji   = FRUIT_EMOJI[fruitName] or "🍑"
    local rarity  = isRare and "Legendary/Rare" or "Common"
    local color   = isRare and 0xE74C3C or 0x99AAB5
    local servId  = getServerId()

    local desc = table.concat({
        emoji .. " **" .. fruitName .. "** — `" .. rarity .. "`",
        "",
        "📍 **Position** `X:" .. math.floor(pos.X) .. "  Y:" .. math.floor(pos.Y) .. "  Z:" .. math.floor(pos.Z) .. "`",
        "🎯 **Action** " .. action,
        "👤 **Player** " .. getPlayer(),
        "",
        "🌐 **Server ID**",
        "```" .. servId .. "```",
    }, "\n")

    local payload = HttpService:JSONEncode({
        username   = "🍈 Abdur Rehman Dev",
        avatar_url = "https://static.wikia.nocookie.net/blox-piece/images/thumb/5/5f/Flame_Fruit.png/120px-Flame_Fruit.png",
        embeds = {{
            title       = emoji .. " Fruit Detected!",
            description = desc,
            color       = color,
            footer      = { text = "Abdur Rehman Dev • Fruit Notifier" },
            timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }},
    })

    pcall(fn, {
        Url     = WEBHOOK_URL,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = payload,
    })
end

-- ══════════════════════════════════════════════════════════════
--  🍑  DETECTION  (same logic as FruitFinder IsFruit)
-- ══════════════════════════════════════════════════════════════
local notified = {}  -- [instanceId] = os.time()

local function isFruit(tool)
    return tool:IsA("Tool")
        and tool:FindFirstChild("Handle") ~= nil
        and string.find(tool.Name, "Fruit") ~= nil
end

local function scan()
    local now = os.time()

    for _, v in ipairs(Workspace:GetChildren()) do
        if isFruit(v) then
            local id = tostring(v)
            if not notified[id] or (now - notified[id]) > NOTIFY_COOLDOWN then
                notified[id] = now
                local pos = v.Handle.Position
                local action = RARE_FRUITS[v.Name]
                    and "🔴 `Rare/Legendary spotted!`"
                    or  "⚪ `Common fruit found`"
                print("[ARD Notifier] 🍑 " .. v.Name .. " detected!")
                sendWebhook(v.Name, pos, action)
            end
        end
    end

    -- Cleanup old entries
    for id, ts in pairs(notified) do
        if now - ts > 600 then notified[id] = nil end
    end
end

-- ══════════════════════════════════════════════════════════════
--  🔁  LOOP
-- ══════════════════════════════════════════════════════════════
local timer = 0

print("╔═════════════════════════════════════════════╗")
print("║   🍈 Abdur Rehman Dev — Webhook Notifier    ║")
print("║   Run FruitFinder.lua alongside this!       ║")
print("╚═════════════════════════════════════════════╝")
print("[ARD Notifier] Server: " .. getServerId())

RunService.Heartbeat:Connect(function(dt)
    timer = timer + dt
    if timer < SCAN_INTERVAL then return end
    timer = 0
    pcall(scan)
end)

print("[ARD Notifier] ✅ Webhook monitoring active!")
