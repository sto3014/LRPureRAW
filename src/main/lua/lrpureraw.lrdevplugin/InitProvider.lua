--
-- Created by IntelliJ IDEA.
-- User: Dieter Stockhausen
-- Date: 02.05.21
-- To change this template use File | Settings | File Templates.
--
local LrDialogs = import("LrDialogs")

local logger = require("Logger")

InitProvider = {
    vInfo = require("Info.lua")
}
function resetPrefs()
    local LrPrefs = import("LrPrefs")
    local prefs = LrPrefs.prefsForPlugin()
    prefs.hasErrors = nil
    prefs.PureRawPath = nil
    prefs.PureRawDir = nil
    prefs.PureRawExe = nil
    prefs.export_destinationPathPrefix = nil
    prefs.export_destinationPathSuffix = nil
    prefs.export_destinationType = nil
    prefs.export_useParentFolder = nil
    prefs.export_useSubfolder = nil
    prefs.format = nil
    prefs.DNG_compatibilityV3 = nil
    prefs.DNG_conversionMethod = nil
    prefs.DNG_previewSize = nil
    prefs.DNG_compressed = nil
    prefs.DNG_embedCache = nil
    prefs.DNG_embedRAW = nil
    prefs.DNG_lossyCompression = nil
    prefs.collisionHandling = nil
    prefs.resetColorLabel = nil
    prefs.resetRating = nil
    prefs.resetPickStatus = nil
    prefs.scriptBeforeExecute = nil
    prefs.scriptAfterExecute = nil
    prefs.forceOneSource = nil
    prefs.scriptBefore = nil
    prefs.scriptAfter = nil
    prefs.scriptBeforePath = nil
    prefs.scriptAfterPath = nil
    prefs.excludeVirtualCopies = nil
end

function init()
    local LrPrefs = import "LrPrefs"
    local LrFileUtils = import "LrFileUtils"
    local LrDialogs = import "LrDialogs"

    -- resetPrefs()

    logger.trace("Init...")
    local prefs = LrPrefs.prefsForPlugin()
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
            for i=1,2,1 do
                local tempPath = prefs.PureRawDir .. "/Contents/MacOS/" .. "PureRawv" .. tostring(i)
                if (LrFileUtils.exists(tempPath) == "file") then
                    prefs.PureRawExe = "PureRawv" .. tostring(i)
                end
            end
        end
    else
        --
        -- winOS
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
            for i=1,2,1 do
                local tempPath = prefs.PureRawDir .. "\\" .. "PureRawv" .. tostring(i) .. ".exe"
                if (LrFileUtils.exists(tempPath) == "file") then
                    prefs.PureRawExe = "PureRawv" .. tostring(i) .. ".exe"
                end
            end
        end
    end

    logger.trace("PureRawPath: " .. prefs.PureRawPath .. " (" .. tostring(LrFileUtils.exists(prefs.PureRawPath)) .. ")")

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

    if (prefs.export_destinationPathPrefix == nil or prefs.export_destinationPathPrefix:len() == 0) then
        prefs.export_destinationPathPrefix = ""
    end
    if (prefs.export_destinationPathSuffix == nil or prefs.export_destinationPathSuffix:len() == 0) then
        prefs.export_destinationPathSuffix = "LR2PureRAW"
    end
    if (prefs.export_destinationType == nil or prefs.export_destinationType:len() == 0) then
        prefs.export_destinationType = "pictures"
    end
    if (prefs.export_useParentFolder == nil) then
        prefs.export_useParentFolder = false
    end
    if (prefs.export_useSubfolder == nil) then
        prefs.export_useSubfolder = true
    end
    if (prefs.format == nil or prefs.format:len() == 0) then
        prefs.format = "ORIGINAL"
    end
    if (prefs.DNG_compatibilityV3 == nil) then
        prefs.DNG_compatibilityV3 = 201588736
    end
    if (prefs.DNG_conversionMethod == nil or prefs.DNG_conversionMethod:len() == 0) then
        prefs.DNG_conversionMethod = "preserveRAW"
    end
    if (prefs.DNG_previewSize == nil or prefs.DNG_previewSize:len() == 0) then
        prefs.DNG_previewSize = "medium"
    end
    if (prefs.DNG_compressed == nil) then
        prefs.DNG_compressed = true
    end
    if (prefs.DNG_embedCache == nil) then
        prefs.DNG_embedCache = true
    end
    if (prefs.DNG_embedRAW == nil) then
        prefs.DNG_embedRAW = false
    end
    if (prefs.DNG_lossyCompression == nil) then
        prefs.DNG_lossyCompression = true
    end
    if (prefs.collisionHandling == nil or prefs.collisionHandling:len() == 0) then
        prefs.collisionHandling = "overwrite"
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

    prefs.processIsRunning = false
    prefs.processCountExcluded = 0
    prefs.processCurrent = 0
    prefs.processIsLatest = false
    prefs.processPhotos = {}
    prefs.processCountExcludedVirtualCopies = 0
    prefs.processCountExcludedAlreadyProcessed = 0
    prefs.processCountExcludedFileFormat = 0
    logger.trace("Init done.")
end

init()

