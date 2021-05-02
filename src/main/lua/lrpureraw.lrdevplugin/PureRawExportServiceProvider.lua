local LrTasks = import 'LrTasks'
local LrLogger = import("LrLogger")
local LrPrefs = import("LrPrefs")
local logger = LrLogger("PureRawLrLogger")
logger:enable("logfile")
-- local LrMobdebug = import 'LrMobdebug' -- Import LR/ZeroBrane debug module
--
-- LrMobdebug.start()
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
    -- endDialog = initSettings,
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
