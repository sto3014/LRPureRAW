require("PluginInit")
local LrApplication = import("LrApplication")
local LrTasks = import 'LrTasks'
local LrLogger = import("LrLogger")
local LrPrefs = import("LrPrefs")
local logger = LrLogger("PureRawLrLogger")
logger:enable("logfile")
-- local LrMobdebug = import 'LrMobdebug' -- Import LR/ZeroBrane debug module
--
-- LrMobdebug.start()
function getSubFolder()
    local activeCatalog = LrApplication.activeCatalog()
    local photos = activeCatalog:getTargetPhotos()
    local subFolder
    local previousSubfolder = ""
    for _, photo in ipairs(photos) do
        subFolder = (photo:getPropertyForPlugin(PluginInit.pluginID, 'tourName'))
        if (subFolder == nil or subFolder == "") then
            subFolder = ""
            break
        else
            if (previousSubfolder == "") then
                previousSubfolder = subFolder
            else
                if (previousSubfolder ~= subFolder) then
                    subFolder = ""
                    break
                end
            end
        end
    end
    logger:trace("Chosen folder: " .. subFolder)
    return subFolder
end
function initSettings (exportSettings)
    if (exportSettings.LR_export_useSubfolder == true and exportSettings.LR_export_destinationPathSuffix == "") then
        subFolder = getSubFolder()
        exportSettings.LR_export_destinationPathSuffix = subFolder
    end
end
--
function postProcessRenderedPhotos(functionContext,
                                   exportContext)
    -- LrMobdebug.on()
    logger:trace("Start postProcessRenderedPhotos")
    prefs = LrPrefs.prefsForPlugin()
    pureRawPath = prefs.PureRawPath

    local exportSession = exportContext.exportSession
    local exportSettings = assert(exportContext.propertyTable)
    logger:trace("Export format is " .. exportSettings.LR_format)
    images = ""
    for i, rendition in exportContext:renditions { stopIfCanceled = true } do
        -- Wait for the upstream task to finish its work on this photo.
        local success, pathOrMessage = rendition:waitForRender()
        if success then
            logger:trace("Exported " .. pathOrMessage .. " successfully")
            images = images .. " " .. pathOrMessage
        else
            logger:trace(pathOrMessage .. " could not be exported")
        end
    end
    if (images ~= "") then
        cmd = '"' .. pureRawPath ..'"' .. images
        logger:trace("Execute " .. cmd)
        local status = LrTasks.execute(cmd)
    end
end

--
return {
    -- endDialog = initSettings,
    -- updateExportSettings = initSettings,
    processRenderedPhotos = postProcessRenderedPhotos,
    allowFileFormats = {
        "ORIGINAL",
    },
    hideSections = {
        "postProcessing",
        "video",
        "watermarking",
        "fileNaming",
        "fileSettings",
        "imageSettings",
        "outputSharpening",
        "metadata",
    },
}
