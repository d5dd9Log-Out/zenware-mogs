local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local function getFolder()
    return ReplicatedStorage:FindFirstChild("ZenWareRemotes")
end

function Remotes.Get(name)
    local folder = getFolder()

    if not folder then
        return nil
    end

    local remote = folder:FindFirstChild(name)

    if remote and remote:IsA("RemoteEvent") then
        return remote
    end

    return nil
end

function Remotes.Fire(name, ...)
    local remote = Remotes.Get(name)

    if not remote then
        return false, "Remote not found: " .. tostring(name)
    end

    return pcall(function()
        remote:FireServer(...)
    end)
end

return Remotes