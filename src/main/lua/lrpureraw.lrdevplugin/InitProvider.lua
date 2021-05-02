--
-- Created by IntelliJ IDEA.
-- User: Dieter Stockhausen
-- Date: 02.05.21
-- To change this template use File | Settings | File Templates.
--
local LrLogger = import 'LrLogger'

-- Logger
local logger = LrLogger('PureRawLrLogger') -- the log file name
logger:enable("logfile")

InitProvider = {
    vInfo = require("Info.lua")
}
local function resetPrefs()
    local LrPrefs = import("LrPrefs")
    local prefs = LrPrefs.prefsForPlugin()
    prefs.PureRawPath = nil
end

local function init()
    local LrPrefs = import("LrPrefs")
    local LrFileUtils = import("LrFileUtils")

    -- resetPrefs()

    logger:trace("Init...")
    local prefs = LrPrefs.prefsForPlugin()
    prefs.hasErrors = false

    local errorMessage = '\n'
    local errorNo = 0

    if (MAC_ENV) then
        --
        -- macOS
        --
        if prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0 then
            pureRawPath = '/Applications/DxO PureRAW.app/Contents/MacOS/PureRawv1'
            prefs.PureRawPath = pureRawPath
        end
    else
        --
        -- winOS
        --
        if prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0 then
            pureRawPath = 'C:\\Program Files\\DxO\\DxO PureRAW\\PureRawv1.exe'
            prefs.PureRawPath = pureRawPath
        end
    end

    if (prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0 or LrFileUtils.exists(prefs.PureRawPath) ~= "file") then
        errorNo = errorNo + 1
        errorMessage = errorMessage .. '\n' ..
                LOC("$$$$/LRPureRaw/Settings/PathNotExists=^1. Path to ^2 does not exist:", tostring(errorNo), "DxO PureRAW") .. "\n" .. prefs.PureRawPath .. "\n"
        prefs.hasErrors = true
    end

    logger:trace("Init done.")
end

init()

