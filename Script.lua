
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ALLOWED_USER_ID = 4873361821 -- only run for this user id

local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Notification",
            Text = text or "",
            Duration = 5
        })
    end)
    print((title and (title..": ") or "") .. (text or ""))
end

local function fireProximityPrompts(targetName)
    if not fireproximityprompt then
        notify("Incompatible Exploit", "Your exploit does not support this command (missing fireproximityprompt)")
        return 0
    end

    local count = 0
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            local matchesName = false

            if targetName and type(targetName) == "string" and #targetName > 0 then
                if descendant.Name == targetName then
                    matchesName = true
                else
                    local p = descendant.Parent
                    if p and p.Name == targetName then
                        matchesName = true
                    end
                end
            else
                matchesName = true
            end

            if matchesName then
                pcall(function()
                    fireproximityprompt(descendant)
                end)
                count = count + 1
            end
        end
    end
    return count
end

-- Set a name to filter prompts (string), or set to nil to fire all prompts
local targetName = nil -- e.g. "DoorPrompt" or nil

-- Permission check
if not LocalPlayer or LocalPlayer.UserId ~= ALLOWED_USER_ID then
    notify("Permission Denied", "This script only runs for user id " .. tostring(ALLOWED_USER_ID))
    return
end

-- Start continuous loop (runs only for allowed user)
spawn(function()
    while true do
        local fired = fireProximityPrompts(targetName)
        -- optional: notify every N iterations or on first run; commented out to avoid spam
        -- notify("Fired Prompts", ("Fired %d prompts this pass"):format(fired))
        wait(1)
    end
end)
