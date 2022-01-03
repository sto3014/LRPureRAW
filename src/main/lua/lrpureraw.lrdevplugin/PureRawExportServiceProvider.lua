local LrTasks = import 'LrTasks'
local LrPrefs = import("LrPrefs")
local LrApplication = import 'LrApplication'
local LrDialogs = import("LrDialogs")
local LrPathUtils = import("LrPathUtils")
local LrFileUtils = import("LrFileUtils")

-------------------------------------------------------------------------------

local logger = require("Logger")
local LrMobdebug = import 'LrMobdebug' -- Import LR/ZeroBrane debug module
LrMobdebug.start()

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
-------------------------------------------------------------------------------

local PureRawExportServiceProvider = {}

-------------------------------------------------------------------------------

function PureRawExportServiceProvider.updateExportSettings (exportSettings)
    logger.trace("updateExportSettings")
    if (exportSettings.LR_format ~= "ORIGINAL" and exportSettings.LR_format ~= "DNG") then
        logger.trace("Init export format with value ORIGINAL")
        exportSettings.LR_format = "ORIGINAL"
    end
    prefs = LrPrefs.prefsForPlugin()
    prefs.export_destinationPathPrefix = exportSettings.LR_export_destinationPathPrefix
    prefs.export_destinationPathSuffix = exportSettings.LR_export_destinationPathSuffix
    prefs.export_destinationType = exportSettings.LR_export_destinationType
    prefs.export_useParentFolder = exportSettings.LR_export_useParentFolder
    prefs.export_useSubfolder = exportSettings.LR_export_useSubfolder
    prefs.format = exportSettings.LR_format
    prefs.DNG_compatibilityV3 = exportSettings.LR_DNG_compatibilityV3
    prefs.DNG_conversionMethod = exportSettings.LR_DNG_conversionMethod
    prefs.DNG_previewSize = exportSettings.LR_DNG_previewSize
    prefs.DNG_compressed = exportSettings.LR_DNG_compressed
    prefs.DNG_embedCache = exportSettings.LR_DNG_embedCache
    prefs.DNG_embedRAW = exportSettings.LR_DNG_embedRAW
    prefs.DNG_lossyCompression = exportSettings.LR_DNG_lossyCompression
    prefs.collisionHandling = exportSettings.LR_collisionHandling
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
            LrDialogs.message(LOC("$$$/LRPureRaw/Errors/ErrorExport=Error during export."), errorMessage, "critical")
            return true
        end
        lastFolder = currentFolder
    end
    logger.trace("hasSeveralSourceFolders() end")

    return false
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
        cmd = 'cmd  '
                .. '\"' .. prefs.scriptBeforePath .. "/" .. prefs.scriptBefore + '\" '
                .. '\"' .. cmdParams["errorFile"] .. '\" '
                .. '\"' .. cmdParams["sourceFolder"] .. '\" '
                .. '\"' .. cmdParams["targetFolder"] .. '\" '
                .. #photos .. ' '
                .. photosList
    else
        cmd = '\"' .. prefs.scriptBeforePath .. "/" .. prefs.scriptBefore .. '\" '
                .. '\"' .. cmdParams["errorFile"] .. '\" '
                .. '\"' .. cmdParams["sourceFolder"] .. '\" '
                .. '\"' .. cmdParams["targetFolder"] .. '\" '
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
        cmd = 'cmd  '
                .. '\"' .. prefs.scriptAfterPath .. "/" .. prefs.scriptAfter + '\" '
                .. '\"' .. cmdParams["errorFile"] .. '\" '
                .. '\"' .. cmdParams["sourceFolder"] .. '\" '
                .. '\"' .. cmdParams["targetFolder"] .. '\" '
                .. #images .. ' '
                .. imagesList
    else
        cmd = '\"' .. prefs.scriptAfterPath .. "/" .. prefs.scriptAfter .. '\" '
                .. '\"' .. cmdParams["errorFile"] .. '\" '
                .. '\"' .. cmdParams["sourceFolder"] .. '\" '
                .. '\"' .. cmdParams["targetFolder"] .. '\" '
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
local function getCmdParams()
    logger.trace("getCmdParams() start")
    local prefs = LrPrefs.prefsForPlugin()
    local cmdParams = {}
    cmdParams["errorFile"] = os.tmpname()
    local photo = LrApplication.activeCatalog():getTargetPhoto()
    cmdParams["sourceFolder"] = LrPathUtils.parent(photo:getRawMetadata("path"))
    cmdParams["targetFolder"] = prefs.export_destinationPathPrefix
    if (prefs.export_destinationPathSuffix ~= nil) then
        if (WIN_ENV) then
            cmdParams["targetFolder"] = cmdParams["targetFolder"] .. "\\" .. prefs.export_destinationPathSuffix
        else
            cmdParams["targetFolder"] = cmdParams["targetFolder"] .. "/" .. prefs.export_destinationPathSuffix
        end
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
    local prefs = LrPrefs.prefsForPlugin()

    local cmd
    if ( #images > 0) then
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
local function resetMetadata(catalog, exportContext)
    local prefs = LrPrefs.prefsForPlugin()
    local images = {}
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
PureRawExportServiceProvider
-------------------------------------------------------------------------------]]
function PureRawExportServiceProvider.processRenderedPhotos(functionContext,
                                                            exportContext)

    -- LrMobdebug.on()
    logger.trace("processRenderedPhotos() start")

    local prefs = LrPrefs.prefsForPlugin()
    if prefs.hasErrors then
        return
    end

    local catalog = LrApplication.activeCatalog()
    local photos = catalog:getTargetPhotos()

    -- force one source
    if (prefs.forceOneSource) then
        if (hasSeveralSourceFolders(photos)) then
            return
        end
    end

    initExportProgress(exportContext)

    -- command line params
    local cmdParams = getCmdParams()

    -- execut before script
    if (prefs.scriptBeforeExecute) then
        if (not executeBefore(photos, cmdParams)) then
            return
        end
    end

    -- reset metadata
    local images = resetMetadata(catalog, exportContext)

    -- execute after script
    if (prefs.scriptAfterExecute and #images > 0) then
        if (not executeAfter(images, cmdParams)) then
            return
        end
    end

    startDxoPureRAW(images)
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

