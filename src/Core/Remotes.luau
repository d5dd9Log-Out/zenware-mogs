local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local function folder()
    return ReplicatedStorage:FindFirstChild("ZenWareRemotes")
end

function Remotes.Get(name)
    local f = folder()

    if not f then
        return nil
    end

    local remote = f:FindFirstChild(name)

    if remote and remote:IsA("RemoteEvent") then
        return remote
    end

    return nil
end

function Remotes.Fire(name, arg)
    local remote = Remotes.Get(name)

    if not remote then
        return false, "Remote not found: " .. tostring(name)
    end

    local ok, err = pcall(function()
        if arg == nil then
            remote:FireServer()
        else
            remote:FireServer(arg)
        end
    end)

    return ok, err
end

return Remotes