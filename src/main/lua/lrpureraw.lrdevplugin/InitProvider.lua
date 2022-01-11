--
-- Created by IntelliJ IDEA.
-- User: Dieter Stockhausen
-- Date: 02.05.21
-- To change this template use File | Settings | File Templates.
--
local LrPrefs = import "LrPrefs"
local LrFileUtils = import "LrFileUtils"
local LrDialogs = import "LrDialogs"

local logger = require("Logger")
-- local LrMobdebug = import 'LrMobdebug' -- Import LR/ZeroBrane debug module
-- LrMobdebug.start()


InitProvider = {
    vInfo = require("Info.lua")
}

function init()

    --    LrMobdebug.on()
    logger.trace("init() start")
    local currentPrefs = { ["PureRawDir"] = true,
                           ["PureRawExe"] = true,
                           ["PureRawPath"] = true,
                           ["excludeAlreadyProcessed"] = true,
                           ["excludeMissing"] = true,
                           ["excludeNoneDNG"] = true,
                           ["excludeVirtualCopies"] = true,
                           ["forceOneSource"] = true,
                           ["hasErrors"] = true,
                           ["resetColorLabel"] = true,
                           ["resetPickStatus"] = true,
                           ["resetRating"] = true,
                           ["scriptAfter"] = true,
                           ["scriptAfterExecute"] = true,
                           ["scriptAfterPath"] = true,
                           ["scriptBefore"] = true,
                           ["scriptBeforeExecute"] = true,
                           ["scriptBeforePath"] = true }

    local prefs = LrPrefs.prefsForPlugin()
    -- Reset all
--[[    for key, value in pairs(prefs["< contents >"]) do
        prefs[key] = nil
    end
    ]]
    -- Reset persistent
    logger.trace("Delete old preferences:")
    for key, value in pairs(prefs["< contents >"]) do
        if ( not currentPrefs[key] ) then
            logger.trace("   Delete key: " .. key)
            prefs[key] = nil
        end
    end

    prefs.hasErrors = false

    local errorMessage = '\n'
    local errorNo = 0

    if (MAC_ENV) then
        --
        -- macOS
        --
        if prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0 then
            pureRawDir = '/Applications/DxO PureRAW.app'
            prefs.PureRawDir = pureRawDir
        end
        if (prefs.PureRawExe == nil or prefs.PureRawExe:len() == 0) then
            prefs.PureRawExe = "PureRawv1"
        end
        prefs.PureRawPath = prefs.PureRawDir .. "/Contents/MacOS/" .. prefs.PureRawExe
        if (LrFileUtils.exists(prefs.PureRawPath) ~= "file") then
            for i = 1, 5, 1 do
                local tempPath = prefs.PureRawDir .. "/Contents/MacOS/" .. "PureRawv" .. tostring(i)
                if (LrFileUtils.exists(tempPath) == "file") then
                    prefs.PureRawExe = "PureRawv" .. tostring(i)
                    prefs.PureRawPath = tempPath
                end
            end
        end
    else
        --
        -- Windows
        --
        if prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0 then
            pureRawDir = 'C:\\Program Files\\DxO\\DxO PureRAW'
            prefs.PureRawDir = pureRawDir
        end
        if (prefs.PureRawExe == nil or prefs.PureRawExe:len() == 0) then
            prefs.PureRawExe = "PureRawv1.exe"
        end
        prefs.PureRawPath = prefs.PureRawDir .. "\\" .. prefs.PureRawExe
        if (LrFileUtils.exists(prefs.PureRawPath) ~= "file") then
            for i = 1, 5, 1 do
                local tempPath = prefs.PureRawDir .. "\\" .. "PureRawv" .. tostring(i) .. ".exe"
                if (LrFileUtils.exists(tempPath) == "file") then
                    prefs.PureRawExe = "PureRawv" .. tostring(i) .. ".exe"
                    prefs.PureRawPath = tempPath
                end
            end
        end
    end

    if (prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0 or LrFileUtils.exists(prefs.PureRawPath) ~= "file") then
        errorNo = errorNo + 1
        errorMessage = errorMessage .. '\n' ..
                LOC("$$$/LRPureRaw/Settings/PathNotExists=^1. Path to ^2 does not exist:", tostring(errorNo), "DxO PureRAW") .. "\n" .. prefs.PureRawPath .. "\n"
        prefs.hasErrors = true
    end

    if (prefs.hasErrors) then
        logger.trace("Has errors: \n" .. errorMessage)
        LrDialogs.message(LOC("$$$/LRPurePath/Init/Failed=PureRaw could not be initialised."), LOC("$$$/LRPurePath/Settings/BadSettings/message=One more more settings have wrong values:^1", errorMessage), "critical")
    end

    if (prefs.resetColorLabel == nil or prefs.resetColorLabel:len() == 0) then
        prefs.resetColorLabel = "off"
    end
    if (prefs.resetRating == nil or prefs.resetRating:len() == 0) then
        prefs.resetRating = "off"
    end
    if (prefs.resetPickStatus == nil) then
        prefs.resetPickStatus = 100
    end

    if (prefs.scriptBeforeExecute == nil) then
        prefs.scriptBeforeExecute = false
    end
    if (prefs.scriptAfterExecute == nil) then
        prefs.scriptAfterExecute = false
    end
    if (prefs.forceOneSource == nil) then
        prefs.forceOneSource = false
    end

    if (prefs.scriptBefore == nil) then
        if (WIN_ENV) then
            prefs.scriptBefore = "BeforeExport-Cleanup.cmd"
            prefs.scriptBeforePath = _PLUGIN.path .. "\\bin\\win"
        else
            prefs.scriptBefore = "BeforeExport-Cleanup.sh"
            prefs.scriptBeforePath = _PLUGIN.path .. "/bin/mac"
        end
    end
    if (prefs.scriptAfter == nil) then
        if (WIN_ENV) then
            prefs.scriptAfter = "AfterExport-CreateLink.cmd"
            prefs.scriptAfterPath = _PLUGIN.path .. "\\bin\\win"
        else
            prefs.scriptAfter = "AfterExport-CreateLink.sh"
            prefs.scriptAfterPath = _PLUGIN.path .. "/bin/mac"
        end
    end

    if (prefs.excludeVirtualCopies == nil) then
        prefs.excludeVirtualCopies = false
    end

    if (prefs.excludeAlreadyProcessed == nil) then
        prefs.excludeAlreadyProcessed = true
    end

    if (prefs.excludeNoneDNG == nil) then
        prefs.excludeNoneDNG = true
    end

    if (prefs.excludeMissing == nil) then
        prefs.excludeMissing = true
    end

    local tkeys = {}
    for k in pairs(prefs["< contents >"]) do
        table.insert(tkeys, k)
    end
    table.sort(tkeys)

    logger.trace("Saved preferences:")
    for _, key in ipairs(tkeys) do
        logger.trace("   " .. tostring(key) .. "=" .. tostring(prefs["< contents >"][key]))
    end
    logger.trace("Init done.")
end

init()

