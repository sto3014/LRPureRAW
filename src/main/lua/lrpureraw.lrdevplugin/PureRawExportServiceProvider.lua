local LrTasks = import 'LrTasks'
local LrLogger = import("LrLogger")
local LrPrefs = import("LrPrefs")
local logger = LrLogger("PureRawLrLogger")
logger:enable("logfile")
-- local LrMobdebug = import 'LrMobdebug' -- Import LR/ZeroBrane debug module
--
-- LrMobdebug.start()
--
function saveSettings (exportSettings)
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
--
function initSettings (exportSettings)
    if (exportSettings.LR_format ~= "ORIGINAL" and exportSettings.LR_format ~= "DNG") then
        logger:trace("Init export format with value ORIGINAL")
        exportSettings.LR_format = "ORIGINAL"
    end
end
--
function postProcessRenderedPhotos(functionContext,
                                   exportContext)

    -- LrMobdebug.on()
    prefs = LrPrefs.prefsForPlugin()
    if prefs.hasErrors then
        return
    end

    logger:trace("Start postProcessRenderedPhotos")
    pureRawPath = prefs.PureRawPath
    pureRawExe = prefs.PureRawExe

    local exportSession = exportContext.exportSession
    local exportSettings = assert(exportContext.propertyTable)
    logger:trace("Export format is " .. exportSettings.LR_format)
    images = ""
    for i, rendition in exportContext:renditions { stopIfCanceled = true } do
        -- Wait for the upstream task to finish its work on this photo.
        local success, pathOrMessage = rendition:waitForRender()
        if success then
            logger:trace("Exported " .. pathOrMessage .. " successfully")
            images = images .. ' "' .. pathOrMessage .. '"'
        else
            logger:trace(pathOrMessage .. " could not be exported")
        end
    end
    if (images ~= "") then
        cmd = '"' .. pureRawPath .. '"' .. images
        if (WIN_ENV) then
            cmd = '"start /wait /min "DxO PureRAW" ' .. cmd
        end
        logger:trace("Execute " .. cmd)
        local status = LrTasks.execute(cmd)
    end
end

--
return {
    endDialog = saveSettings,
    updateExportSettings = initSettings,
    processRenderedPhotos = postProcessRenderedPhotos,
    allowFileFormats = {
        "ORIGINAL",
        "DNG",
    },
    hideSections = {
        "postProcessing",
        "video",
        "watermarking",
        "fileNaming",
        "imageSettings",
        "outputSharpening",
        "metadata",
    },
}
