--
-- Created by IntelliJ IDEA.
-- User: Dieter Stockhausen
-- Date: 02.05.21
-- To change this template use File | Settings | File Templates.
--
local LrPrefs = import "LrPrefs"
local LrFileUtils = import "LrFileUtils"
local LrDialogs = import "LrDialogs"
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
local logger = require("Logger")
local utils = require("Utils")

local currentPrefs = { ["PureRawDir"] = true,
                       ["PureRawExe"] = true,
                       ["PureRawPath"] = true,
                       ["PureRawVersion"] = true,
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


--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function init()
    logger.trace("init() start")

    local prefs = LrPrefs.prefsForPlugin()
    -- Reset all
    --[[
    for key, value in pairs(prefs["< contents >"]) do
        prefs[key] = nil
    end
    ]]
    -- Reset persistent
    logger.trace("Delete old preferences:")
    for key, _ in pairs(prefs["< contents >"]) do
        if (not currentPrefs[key]) then
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
        if (prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0) then
            -- Default values since 18.03.2022
            prefs.PureRawDir = '/Applications/DxO PureRAW 2.app'
            prefs.PureRawExe = "PureRawv2"
            prefs.PureRawPath = prefs.PureRawDir .. "/Contents/MacOS/" .. prefs.PureRawExe
            if (LrFileUtils.exists(prefs.PureRawPath) ~= "file") then
                for i = 5, 1, -1 do
                    local tempPath
                    local tempExe
                    local tempDir
                    tempExe = "PureRawv" .. tostring(i)
                    if (i == 1) then
                        tempDir = "/Applications/DxO PureRAW.app"
                    else
                        tempDir = "/Applications/DxO PureRAW " .. tostring(i) .. ".app"
                    end
                    tempPath = tempDir .. "/Contents/MacOS/" .. tempExe
                    if (LrFileUtils.exists(tempPath) == "file") then
                        prefs.PureRawExe = tempExe
                        prefs.PureRawPath = tempPath
                        prefs.PureRawDir = tempDir
                        break
                    end
                end
            end
        end
    else
        --
        -- Windows
        --
        if (prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0) then
            -- Default values since 18.03.2022
            prefs.PureRawDir = "C:\\Program Files\\DxO\\DxO PureRAW 2"
            prefs.PureRawExe = "PureRawv2.exe"
            prefs.PureRawPath = prefs.PureRawDir .. "\\" .. prefs.PureRawExe
            if (LrFileUtils.exists(prefs.PureRawPath) ~= "file") then
                for i = 5, 1, -1 do
                    local tempPath
                    local tempExe
                    local tempDir
                    tempExe = "PureRawv" .. tostring(i) .. ".exe"
                    if (i == 1) then
                        tempDir = "C:\\Program Files\\DxO\\DxO PureRAW"
                    else
                        tempDir = "C:\\Program Files\\DxO\\DxO PureRAW " .. tostring(i)
                    end
                    tempPath = tempDir .. "\\" .. tempExe
                    if (LrFileUtils.exists(tempPath) == "file") then
                        prefs.PureRawExe = tempExe
                        prefs.PureRawPath = tempPath
                        prefs.PureRawDir = tempDir
                        break
                    end
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
    if ( prefs.PureRawVersion == nil) then
        if (prefs.PureRawDir ~= nil and prefs.PureRawDir:len() > 0) then
            prefs.PureRawVersion = utils.getPureRawVersion(prefs.PureRawDir)
        else
            prefs.PureRawVersion="2";
        end
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
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]

init()

