local LrTasks = import 'LrTasks'
local LrPrefs = import("LrPrefs")
local LrApplication = import 'LrApplication'
local LrDialogs = import("LrDialogs")
local LrPathUtils = import("LrPathUtils")
local LrFileUtils = import ("LrFileUtils")

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
local function getPhotosList(photos)
    local list=""
    for _, photo in ipairs(photos) do
        if ( list == "") then
            list= photo:getFormattedMetadata("fileName")
        else
            list= list .. ' ' .. photo:getFormattedMetadata("fileName")
        end
    end
    return list
end
--[[----------------------------------------------------------------------------
PureRawExportServiceProvider
-------------------------------------------------------------------------------]]
function PureRawExportServiceProvider.processRenderedPhotos(functionContext,
                                                            exportContext)

    LrMobdebug.on()
    prefs = LrPrefs.prefsForPlugin()
    if prefs.hasErrors then
        return
    end

    logger.trace("Start processRenderedPhotos")

    -- force one source
    if (prefs.forceOneSource) then
        local catalog = LrApplication.activeCatalog()
        local photos = catalog:getTargetPhotos()
        local lastFolder = ""
        for _, photo in ipairs(photos) do
            local currentFolder = photo:getRawMetadata("path")
            logger.trace("Folder=" .. currentFolder)
            if (currentFolder ~= lastFolder) then
                local errorMessage = LOC("$$$/LRPureRaw/Errors/OneSource=Selected photos must reside to the same folder.")
                logger.trace(errorMessage)
                LrDialogs.message(LOC("$$$/LRPureRaw/Errors/ErrorExport=Error during export."), errorMessage, "critical")
                return
            end
        end
    end

    pureRawPath = prefs.PureRawPath
    pureRawExe = prefs.PureRawExe
    pureRawDir = prefs.PureRawDir



    local exportSession = exportContext.exportSession
    local exportSettings = assert(exportContext.propertyTable)
    local catalog = exportSession.catalog
    local nPhotos = exportSession:countRenditions()
    local progressScope = exportContext:configureProgress {
        title = nPhotos > 1 and
                LOC("$$$/LRPurePath/ProgressMany=Export ^1 photos for DxO PureRAW", nPhotos)
                or LOC "$$$/LRPurePath/ProgressOne=Export one photo for DxO PureRAW",
    }
    logger.trace("Export format is " .. exportSettings.LR_format)
    local images = ""
    logger.trace("Renditions: " .. exportSession:countRenditions())

    -- export scripts variables
    local errorFile = os.tmpname()
    local catalog = LrApplication.activeCatalog()
    local photo = catalog:getTargetPhoto()
    local sourceFolder = LrPathUtils.parent(photo:getRawMetadata("path"))
    logger.trace("sourceFolder=" .. tostring(sourceFolder))
    local targetFolder = prefs.export_destinationPathPrefix
    if ( prefs.export_destinationPathSuffix ~= nil) then
        if (WIN_ENV) then
            targetFolder = targetFolder .. "\\" .. prefs.export_destinationPathSuffix
        else
            targetFolder = targetFolder .. "/" .. prefs.export_destinationPathSuffix
        end
    end
    logger.trace("targetFolder" .. tostring(targetFolder))

    -- before export execute

    if ( prefs.scriptBeforeExecute) then
        local photos = catalog:getTargetPhotos()
        local photosList = getPhotosList(photos)
        local cmd
        if (WIN_ENV) then
            cmd = 'cmd  '
                    .. '\"' .. prefs.scriptBeforePath .. "/" .. prefs.scriptBefore + '\" '
                    .. '\"' .. errorFile.. '\" '
                    .. '\"' .. sourceFolder .. '\" '
                    .. '\"' .. targetFolder .. '\" '
                    .. #photos .. ' '
                    .. photosList
        else
            cmd = '\"' .. prefs.scriptBeforePath .. "/" .. prefs.scriptBefore .. '\" '
                    .. '\"' .. errorFile .. '\" '
                    .. '\"' .. sourceFolder .. '\" '
                    .. '\"' .. targetFolder .. '\" '
                    .. #photos .. ' '
                    .. photosList
        end
        logger.trace("Command line length: " .. cmd:len())
        logger.trace("Execute: " .. cmd)
        local status = LrTasks.execute(cmd)
        logger.trace("status=" .. tostring(status))
        if ( status ~= 0 ) then
            if ( LrFileUtils.exists( errorFile)) then
                local data = readfile( errorFile)
                LrDialogs.message(LOC("$$$/LRPureRaw/Errors/scriptBefore=Error executing before script ^n^1", prefs.scriptBeforePath .. "/" .. prefs.scriptBefore), data, 'critical')
            else
                LrDialogs.message(LOC("$$$/LRPureRaw/Errors/scriptBefore=Error executing before script ^n^1", prefs.scriptBeforePath .. "/" .. prefs.scriptBefore),
                        LOC("$$$/LRPureRaw/Errors/scriptBeforeUnknownError=Unknown error, because error message file ^1 not found.", errorFile), 'critical')
            end
            return
        end
    end
    --
    -- reset metadata
    catalog:withWriteAccessDo("Reset meta data", function()
        for i, rendition in exportContext:renditions { stopIfCanceled = true } do
            -- Wait for the upstream task to finish its work on this photo.
            local success, pathOrMessage = rendition:waitForRender()
            if success then
                logger.trace("Exported " .. pathOrMessage .. " successfully")
                images = images .. ' "' .. pathOrMessage .. '"'
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

    if ( prefs.scriptAfterExecute) then
        local photos = catalog:getTargetPhotos()
        local photosList = getPhotosList(photos)
        local cmd
        if (WIN_ENV) then
            cmd = 'cmd  '
                    .. '\"' .. prefs.scriptAfterPath .. "/" .. prefs.scriptAfter + '\" '
                    .. '\"' .. errorFile.. '\" '
                    .. '\"' .. sourceFolder .. '\" '
                    .. '\"' .. targetFolder .. '\" '
                    .. #photos .. ' '
                    .. photosList
        else
            cmd = '\"' .. prefs.scriptAfterPath .. "/" .. prefs.scriptAfter .. '\" '
                    .. '\"' .. errorFile .. '\" '
                    .. '\"' .. sourceFolder .. '\" '
                    .. '\"' .. targetFolder .. '\" '
                    .. #photos .. ' '
                    .. photosList
        end
        logger.trace("Command line length: " .. cmd:len())
        logger.trace("Execute: " .. cmd)
        local status = LrTasks.execute(cmd)
        logger.trace("status=" .. tostring(status))
        if ( status ~= 0 ) then
            if ( LrFileUtils.exists( errorFile)) then
                local data = readfile( errorFile)
                LrDialogs.message(LOC("$$$/LRPureRaw/Errors/script=Error executing script ^n^1", prefs.scriptAfterPath .. "/" .. prefs.scriptAfter), data, 'critical')
            else
                LrDialogs.message(LOC("$$$/LRPureRaw/Errors/script=Error executing script ^n^1", prefs.scriptAfterPath .. "/" .. prefs.scriptAfter),
                        LOC("$$$/LRPureRaw/Errors/scriptUnknownError=Unknown error, because error message file ^1 not found.", errorFile), 'critical')
            end
            return
        end
    end


    if (images ~= "") then
        -- local cmd = '"' .. pureRawPath .. '"' .. images
        if (WIN_ENV) then
            cmd = 'start /D ' .. '"' .. pureRawDir ..'"' .. ' ' .. pureRawExe .. images
        else
            cmd = 'open -a ' .. '"' .. pureRawPath .. '"' .. images
        end
        logger.trace("Command line length: " .. cmd:len())
        logger.trace("Execute: " .. cmd)
        local status = LrTasks.execute(cmd)
    end
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

