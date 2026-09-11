local ServerFinder = {}

local findCallback
local joinCallback

function ServerFinder.SetCallbacks(findFn, joinFn)
    findCallback = typeof(findFn) == "function"
        and findFn
        or nil

    joinCallback = typeof(joinFn) == "function"
        and joinFn
        or nil
end

function ServerFinder.Find(username)
    if not findCallback then
        return nil, "Server Finder backend is not configured"
    end

    local success, result = pcall(
        findCallback,
        username
    )

    if not success then
        return nil, result
    end

    return result
end

function ServerFinder.Join(serverId)
    if not joinCallback then
        return false, "Server join backend is not configured"
    end

    return pcall(
        joinCallback,
        serverId
    )
end

return ServerFinder