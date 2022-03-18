local LrTasks = import 'LrTasks'
local LrPrefs = import("LrPrefs")
local LrApplication = import 'LrApplication'
local LrDialogs = import("LrDialogs")
local LrPathUtils = import("LrPathUtils")
local LrFileUtils = import("LrFileUtils")

--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
local logger = require("Logger")
require("Debugger")
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]

local PureRawExportServiceProvider = {}

--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]

function PureRawExportServiceProvider.updateExportSettings (exportSettings)
    logger.trace("********** Start service provider DxO PureRAW **********")
    logger.trace("updateExportSettings() start")
    local prefs = LrPrefs.prefsForPlugin()
    logger.trace("Init process preferences.")
    prefs.process = {}
    prefs.process.FilterIsActive = false
    prefs.process.IsRunning = false
    prefs.process.CountExcluded = 0
    prefs.process.Current = 0
    prefs.process.IsLatest = false
    prefs.process.Photos = {}
    prefs.process.CountExcludedVirtualCopies = 0
    prefs.process.CountExcludedAlreadyProcessed = 0
    prefs.process.CountExcludedFileFormat = 0
    prefs.process.CountMissing = 0
    prefs.process.DiffFoldersCount = 0
    logger.trace("updateExportSettings() end")
end
--[[---------------------------------------------------------------------------
readfile
-----------------------------------------------------------------------------]]
local function readfile(path)
    logger.trace("read_file start")
    logger.trace("path=" .. path)

    local data = ""
    local f = assert(io.open(path, "r"))
    for line in f:lines() do
        logger.trace("line=" .. line)
        data = data .. line .. "\n"
    end
    f:close()
    logger.trace("read_file end")
    return data
end

--[[----------------------------------------------------------------------------
local function getPhotosList()
-------------------------------------------------------------------------------]]
local function getPhotoList(photos)
    local list = ""
    for _, photo in ipairs(photos) do
        if (list == "") then
            list = '"' .. photo:getRawMetadata("path") .. '"'
        else
            list = list .. ' ' .. '"' .. photo:getRawMetadata("path") .. '"'
        end
    end
    return list
end
--[[----------------------------------------------------------------------------
local function getImagesList()
-------------------------------------------------------------------------------]]
local function getImageList(images)
    local list = ""
    for _, image in ipairs(images) do
        if (list == "") then
            list = '"' .. image .. '"'
        else
            list = list .. ' ' .. '"' .. image .. '"'
        end
    end
    return list
end
--[[----------------------------------------------------------------------------
local function executeBefore()
-------------------------------------------------------------------------------]]
local function executeBefore(photos, cmdParams)
    logger.trace("executeBefore() start")

    local prefs = LrPrefs.prefsForPlugin()
    local photosList = getPhotoList(photos)
    local cmd
    if (WIN_ENV) then
        cmd = 'cmd  /C \"'
                .. '\"' .. prefs.scriptBeforePath .. "\\" .. prefs.scriptBefore .. '\" '
                .. '\"' .. cmdParams["errorFile"] .. '\" '
                .. '\"' .. cmdParams["sourceFolder"] .. '\" '
                .. '\"' .. cmdParams["targetFolder"] .. '\" '
                .. '\"' .. _PLUGIN.path .. '\" '
                .. #photos .. ' '
                .. photosList .. '\"'
    else
        cmd = '\"' .. prefs.scriptBeforePath .. "/" .. prefs.scriptBefore .. '\" '
                .. '\"' .. cmdParams["errorFile"] .. '\" '
                .. '\"' .. cmdParams["sourceFolder"] .. '\" '
                .. '\"' .. cmdParams["targetFolder"] .. '\" '
                .. '\"' .. _PLUGIN.path .. '\" '
                .. #photos .. ' '
                .. photosList
    end
    logger.trace("Command line length: " .. cmd:len())
    logger.trace("Execute: " .. cmd)
    local status = LrTasks.execute(cmd)
    logger.trace("status=" .. tostring(status))
    if (status ~= 0) then
        if (LrFileUtils.exists(cmdParams["errorFile"])) then
            local data = readfile(cmdParams["errorFile"])
            LrDialogs.message(LOC("$$$/LRPureRaw/Errors/scriptBefore=Error executing before script ^n^1", prefs.scriptBeforePath .. "/" .. prefs.scriptBefore), data, 'critical')
        else
            LrDialogs.message(LOC("$$$/LRPureRaw/Errors/scriptBefore=Error executing before script ^n^1", prefs.scriptBeforePath .. "/" .. prefs.scriptBefore),
                    LOC("$$$/LRPureRaw/Errors/scriptBeforeUnknownError=Unknown error, because error message file ^1 not found.", cmdParams["errorFile"]), 'critical')
        end
        return false
    end
    logger.trace("executeBefore() end")
    return true
end
--[[----------------------------------------------------------------------------
local function executeAfter()
-------------------------------------------------------------------------------]]
local function executeAfter(images, cmdParams)
    logger.trace("executeAfter() start")

    local prefs = LrPrefs.prefsForPlugin()
    local imagesList = getImageList(images)
    local cmd
    if (WIN_ENV) then
        cmd = 'cmd  /C \"'
                .. '\"' .. prefs.scriptAfterPath .. "\\" .. prefs.scriptAfter .. '\" '
                .. '\"' .. cmdParams["errorFile"] .. '\" '
                .. '\"' .. cmdParams["sourceFolder"] .. '\" '
                .. '\"' .. cmdParams["targetFolder"] .. '\" '
                .. '\"' .. _PLUGIN.path .. '\" '
                .. #images .. ' '
                .. imagesList .. '\"'
    else
        cmd = '\"' .. prefs.scriptAfterPath .. "/" .. prefs.scriptAfter .. '\" '
                .. '\"' .. cmdParams["errorFile"] .. '\" '
                .. '\"' .. cmdParams["sourceFolder"] .. '\" '
                .. '\"' .. cmdParams["targetFolder"] .. '\" '
                .. '\"' .. _PLUGIN.path .. '\" '
                .. #images .. ' '
                .. imagesList
    end
    logger.trace("Command line length: " .. cmd:len())
    logger.trace("Execute: " .. cmd)
    local status = LrTasks.execute(cmd)
    logger.trace("status=" .. tostring(status))
    if (status ~= 0) then
        if (LrFileUtils.exists(cmdParams["errorFile"])) then
            local data = readfile(cmdParams["errorFile"])
            LrDialogs.message(LOC("$$$/LRPureRaw/Errors/script=Error executing script ^n^1", prefs.scriptAfterPath .. "/" .. prefs.scriptAfter), data, 'critical')
        else
            LrDialogs.message(LOC("$$$/LRPureRaw/Errors/script=Error executing script ^n^1", prefs.scriptAfterPath .. "/" .. prefs.scriptAfter),
                    LOC("$$$/LRPureRaw/Errors/scriptUnknownError=Unknown error, because error message file ^1 not found.", cmdParams["errorFile"]), 'critical')
        end
        return false
    end
    logger.trace("executeAfter() end")
    return true
end
--[[----------------------------------------------------------------------------
local function defineCommandLineParams()
-------------------------------------------------------------------------------]]
local function getCmdParams(exportContext)
    logger.trace("getCmdParams() start")
    local exportSettings = assert(exportContext.propertyTable)

    local cmdParams = {}
    cmdParams["errorFile"] = os.tmpname()
    local photo = LrApplication.activeCatalog():getTargetPhoto()
    cmdParams["sourceFolder"] = LrPathUtils.parent(photo:getRawMetadata("path"))
    -- destination type specific folder und use subfolder checked are mandatory
    cmdParams["targetFolder"] = exportSettings.LR_export_destinationPathPrefix
    if (WIN_ENV) then
        cmdParams["targetFolder"] = cmdParams["targetFolder"] .. "\\" .. exportSettings.LR_export_destinationPathSuffix
    else
        cmdParams["targetFolder"] = cmdParams["targetFolder"] .. "/" .. exportSettings.LR_export_destinationPathSuffix
    end
    logger.trace("errorFile=" .. cmdParams["errorFile"])
    logger.trace("sourceFolder=" .. cmdParams["sourceFolder"])
    logger.trace("targetFolder" .. cmdParams["targetFolder"])
    logger.trace("getCmdParams() end")
    return cmdParams
end
--[[----------------------------------------------------------------------------
local function initExportProgress()
-------------------------------------------------------------------------------]]
local function initExportProgress(exportContext)
    logger.trace("initExportProgress() start")

    local exportSession = exportContext.exportSession
    local exportSettings = assert(exportContext.propertyTable)
    local nPhotos = exportSession:countRenditions()
    local progressScope = exportContext:configureProgress {
        title = nPhotos > 1 and
                LOC("$$$/LRPurePath/ProgressMany=Export ^1 photos for DxO PureRAW", nPhotos)
                or LOC "$$$/LRPurePath/ProgressOne=Export one photo for DxO PureRAW",
    }
    logger.trace("Export format is " .. exportSettings.LR_format)
    logger.trace("Renditions: " .. exportSession:countRenditions())
    logger.trace("initExportProgress() end")
end
--[[----------------------------------------------------------------------------
local function startDxoPureRAW()
-------------------------------------------------------------------------------]]
local function startDxoPureRAW(images)
    logger.trace("startDxoPureRAW() start")

    local prefs = LrPrefs.prefsForPlugin()

    local cmd
    if (#images > 0) then
        if (WIN_ENV) then
            cmd = 'start /D ' .. '"' .. prefs.PureRawDir .. '"' .. ' ' .. prefs.PureRawExe .. ' ' .. getImageList(images)
        else
            cmd = 'open -a ' .. '"' .. prefs.PureRawPath .. '"' .. ' ' .. getImageList(images)
        end
        logger.trace("Command line length: " .. cmd:len())
        logger.trace("Execute: " .. cmd)
        local status = LrTasks.execute(cmd)
    end

end
--[[----------------------------------------------------------------------------
local function resetMetadata()
-------------------------------------------------------------------------------]]
local function resetMetadata(exportContext)
    logger.trace("resetMetadata() start")
    local prefs = LrPrefs.prefsForPlugin()
    local images = {}
    local catalog = LrApplication.activeCatalog()
    catalog:withWriteAccessDo("Reset meta data", function()
        for i, rendition in exportContext:renditions { stopIfCanceled = true } do
            -- Wait for the upstream task to finish its work on this photo.
            local success, pathOrMessage = rendition:waitForRender()
            if success then
                logger.trace("Exported " .. pathOrMessage .. " successfully")

                images[#images + 1] = pathOrMessage

                local photo = rendition.photo
                if (prefs.resetColorLabel ~= "off") then
                    logger.trace("Set label color to " .. prefs.resetColorLabel)
                    photo:setRawMetadata("colorNameForLabel", prefs.resetColorLabel)
                end
                if (prefs.resetRating ~= "off") then
                    logger.trace("Set rating to " .. prefs.resetRating)
                    photo:setRawMetadata("rating", prefs.resetRating)
                end
                if (prefs.resetPickStatus ~= "off") then
                    logger.trace("Set pick status to " .. prefs.resetPickStatus)
                    photo:setRawMetadata("pickStatus", prefs.resetPickStatus)
                end
            else
                logger.trace(pathOrMessage .. " could not be exported")
            end
        end
    end)
    return images
end
--[[----------------------------------------------------------------------------
local function hasSeveralSourceFolders()
-------------------------------------------------------------------------------]]
local function hasSeveralSourceFolders(photos)
    logger.trace("hasSeveralSourceFolders() start")

    local lastFolder
    for _, photo in ipairs(photos) do
        local currentFolder = LrPathUtils.parent(photo:getRawMetadata("path"))
        logger.trace("folder=" .. currentFolder)
        if (lastFolder ~= nil and currentFolder ~= lastFolder) then
            local errorMessage = LOC("$$$/LRPureRaw/Errors/OneSource=Selected photos must reside to the same folder.")
            logger.trace(errorMessage)
            LrDialogs.message(LOC("$$$/LRPureRaw/Errors/ErrorAllExcluded=All photos were exclude."), errorMessage, "critical")
            return true
        end
        lastFolder = currentFolder
    end
    logger.trace("hasSeveralSourceFolders() end")

    return false
end

--[[----------------------------------------------------------------------------
local function validateExclude()
-------------------------------------------------------------------------------]]
local function validateExclude()
    logger.trace("validateExclude() start")
    local prefs = LrPrefs.prefsForPlugin()
    if (not prefs.process.FilterIsActive) then
        return true
    end
    if (prefs.process.CountExcluded > 0) then
        if (prefs.process.CountExcluded == prefs.process.CountPhotos) then
            LrDialogs.message(LOC("$$$/LRPureRaw/Errors/ErrorAllExcluded=All photos were excluded."),
                    LOC("$$$/LRPureRaw/Errors/ErrorAllExcludedDetails=Total: ^1^n^nWrong file format: ^2^nAlready processed: ^3^nVirtual copy: ^4^nMissing: ^5",
                            prefs.process.CountPhotos,
                            prefs.process.CountExcludedFileFormat,
                            prefs.process.CountExcludedAlreadyProcessed,
                            prefs.process.CountExcludedVirtualCopies,
                    prefs.process.CountMissing, "critical"))
            return false
        else
            if (LrDialogs.confirm(LOC("$$$/LRPureRaw/Errors/ErrorSomeExcluded=Some photos were excluded."),
                    LOC("$$$/LRPureRaw/Errors/ErrorExcludedDetails=Selected: ^1^n^nWrong file format: ^2^nAlready processed: ^3^nVirtual copy: ^4^nMissing: ^5^n^nContinue?",
                            prefs.process.CountPhotos,
                            prefs.process.CountExcludedFileFormat,
                            prefs.process.CountExcludedAlreadyProcessed,
                            prefs.process.CountExcludedVirtualCopies,
                            prefs.process.CountMissing)) == "cancel") then
                return false
            else
                return true
            end
        end
    else
        return true
    end
end
--[[----------------------------------------------------------------------------
local function validateDestinationType()
-------------------------------------------------------------------------------]]
local function validateDestinationType(exportContext)
    logger.trace("validateDestinationType() start")

    local exportSettings = assert(exportContext.propertyTable)

    if (exportSettings.LR_export_destinationType ~= "specificFolder") then
        LrDialogs.message(LOC("$$$/LRPureRaw/Errors/ErrorExport=Error during export."),
                LOC("$$$/LRPureRaw/Errors/ErrorDestinationType=When scripts are executed the \"Export to\" must be set to \"Specific folder\"."), "critical")
        return false
    end
    if (exportSettings.LR_export_destinationPathPrefix == nil) then
        LrDialogs.message(LOC("$$$/LRPureRaw/Errors/ErrorExport=Error during export."),
                LOC("$$$/LRPureRaw/Errors/ErrorDestinationType=When scripts are executed the \"Export to\" must be set to \"Specific folder\"."), "critical")
        return false
    end
    if (not exportSettings.LR_export_useSubfolder) then
        LrDialogs.message(LOC("$$$/LRPureRaw/Errors/ErrorExport=Error during export."),
                LOC("$$$/LRPureRaw/Errors/ErrorUseSubfolder=When scripts are executed \"Put in subfolder\" must be checked and a value must be defined for the subfolder.")
        , "critical")
        return false
    end
    if (exportSettings.LR_export_destinationPathSuffix == nil) then
        LrDialogs.message(LOC("$$$/LRPureRaw/Errors/ErrorExport=Error during export."),
                LOC("$$$/LRPureRaw/Errors/ErrorUseSubfolder=When scripts are executed \"Put in subfolder\" must be checked and a value must be defined for the subfolder.")
        , "critical")
        return false
    end
    return true

end
--[[----------------------------------------------------------------------------
PureRawExportServiceProvider
-------------------------------------------------------------------------------]]
function PureRawExportServiceProvider.processRenderedPhotos(functionContext,
                                                            exportContext)

    logger.trace("processRenderedPhotos() start")

    local prefs = LrPrefs.prefsForPlugin()
    if prefs.hasErrors then
        return
    end

    local photos
    if (prefs.process.FilterIsActive) then
        photos = prefs.process.Photos
    else
        photos = LrApplication.activeCatalog():getTargetPhotos()
    end

    -- force one source
    if (prefs.process.FilterIsActive and prefs.forceOneSource) then
        if (hasSeveralSourceFolders(photos)) then
            return
        end
    end

    if (prefs.process.FilterIsActive and (not validateExclude())) then
        return
    end

    initExportProgress(exportContext)

    local cmdParams
    if (prefs.scriptBeforeExecute or prefs.scriptAfterExecute) then
        if (not validateDestinationType(exportContext)) then
            return false
        end
        -- command line params
        cmdParams = getCmdParams(exportContext)
    end

    -- execut before script
    if (prefs.scriptBeforeExecute) then
        if (not executeBefore(photos, cmdParams)) then
            return
        end
    end

    -- reset metadata
    local images = resetMetadata(exportContext)

    -- execute after script
    if (prefs.scriptAfterExecute and #images > 0) then
        if (not executeAfter(images, cmdParams)) then
            return
        end
    end

    startDxoPureRAW(images)

    -- We don't need this table to be saved.
    prefs.process = nil

    logger.trace("processRenderedPhotos() end")

end

-------------------------------------------------------------------------------

PureRawExportServiceProvider.allowFileFormats = {
    "ORIGINAL",
    "DNG",
}

-------------------------------------------------------------------------------

PureRawExportServiceProvider.hideSections = {
    "postProcessing",
    "video",
    "watermarking",
    "fileNaming",
    "imageSettings",
    "outputSharpening",
    "metadata",
}

-------------------------------------------------------------------------------

return PureRawExportServiceProvider

