local LrTasks = import 'LrTasks'
local LrLogger = import("LrLogger")
local LrPrefs = import("LrPrefs")
-------------------------------------------------------------------------------

local logger = require("Logger")
-- local LrMobdebug = import 'LrMobdebug' -- Import LR/ZeroBrane debug module
-- LrMobdebug.start()

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

-------------------------------------------------------------------------------

function PureRawExportServiceProvider.processRenderedPhotos(functionContext,
                                                            exportContext)

    --LrMobdebug.on()
    prefs = LrPrefs.prefsForPlugin()
    if prefs.hasErrors then
        return
    end

    logger.trace("Start processRenderedPhotos")
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

