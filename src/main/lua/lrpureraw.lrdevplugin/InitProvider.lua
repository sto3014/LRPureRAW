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
    prefs.PureRawDir = nil
    prefs.PureRawExe = nil

end

local function init()
    local LrPrefs = import("LrPrefs")
    local LrFileUtils = import("LrFileUtils")
    local LrDialogs = import "LrDialogs"

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
            pureRawDir = '/Applications/DxO PureRAW.app'
            prefs.PureRawDir = pureRawDir
        end
        if ( prefs.PureRawExe==nil or prefs.PureRawExe:len() ==0) then
            prefs.PureRawExe="PureRawv1"
        end
        prefs.PureRawPath = prefs.PureRawDir .. "/Contents/MacOS/" .. prefs.PureRawExe
    else
        --
        -- winOS
        --
        if prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0 then
            pureRawDir = 'C:\\Program Files\\DxO\\DxO PureRAW'
            prefs.PureRawDir = pureRawDir
        end
        if ( prefs.PureRawExe==nil or prefs.PureRawExe:len() ==0) then
            prefs.PureRawExe="PureRawv1.exe"
        end
        prefs.PureRawPath = prefs.PureRawDir .. "\\" .. prefs.PureRawExe
    end

    logger:trace("PureRawPath: " .. prefs.PureRawPath .. " (" .. tostring(LrFileUtils.exists(prefs.PureRawPath)) .. ")")

    if (prefs.PureRawPath == nil or prefs.PureRawPath:len() == 0 or LrFileUtils.exists(prefs.PureRawPath) ~= "file") then
        errorNo = errorNo + 1
        errorMessage = errorMessage .. '\n' ..
                LOC("$$$/LRPureRaw/Settings/PathNotExists=^1. Path to ^2 does not exist:", tostring(errorNo), "DxO PureRAW") .. "\n" .. prefs.PureRawPath .. "\n"
        prefs.hasErrors = true
    end

    if (prefs.hasErrors) then
        logger:trace("Has errors: \n" .. errorMessage)
        LrDialogs.message(LOC("$$$/LRPurePath/Init/Failed=PureRaw could not be initialised."), LOC("$$$/LRPurePath/Settings/BadSettings/message=One more more settings have wrong values:^1", errorMessage), "critical")
    end

    if ( prefs.export_destinationPathPrefix==nil or prefs.export_destinationPathPrefix:len() ==0) then
        prefs.export_destinationPathPrefix=""
    end
    if ( prefs.export_destinationPathSuffix==nil or prefs.export_destinationPathSuffix:len() ==0) then
        prefs.export_destinationPathSuffix="LR2PureRAW"
    end
    if ( prefs.export_destinationType==nil or prefs.export_destinationType:len() ==0) then
        prefs.export_destinationType="pictures"
    end
    if ( prefs.export_useParentFolder==nil) then
        prefs.export_useParentFolder=false
    end
    if ( prefs.export_useSubfolder==nil) then
        prefs.export_useSubfolder=true
    end
    if ( prefs.format==nil or prefs.format:len()==0) then
        prefs.format="ORIGINAL"
    end
    if ( prefs.DNG_compatibilityV3==nil) then
        prefs.DNG_compatibilityV3=201588736
    end
    if ( prefs.DNG_conversionMethod==nil or prefs.DNG_conversionMethod:len()==0) then
        prefs.DNG_conversionMethod="preserveRAW"
    end
    if ( prefs.DNG_previewSize==nil or prefs.DNG_previewSize:len()==0) then
        prefs.DNG_previewSize="medium"
    end
    if ( prefs.DNG_compressed==nil) then
        prefs.DNG_compressed=true
    end
    if ( prefs.DNG_embedCache==nil) then
        prefs.DNG_embedCache=true
    end
    if ( prefs.DNG_embedRAW==nil) then
        prefs.DNG_embedRAW=false
    end
    if ( prefs.DNG_lossyCompression==nil) then
        prefs.DNG_lossyCompression=true
    end
    if ( prefs.collisionHandling==nil or prefs.collisionHandling:len()==0) then
        prefs.collisionHandling="overwrite"
    end

    logger:trace("Init done.")
end

init()

