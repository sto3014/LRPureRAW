local LrApplication = import("LrApplication")
local LrTasks = import("LrTasks")
local LrExportSession = import("LrExportSession")
local LrPrefs = import("LrPrefs")

local logger = require("Logger")
local filterProvider = require("PureRawExportFilterProvider")
local utils = require("Utils")

LrTasks.startAsyncTask(function()
    prefs = LrPrefs.prefsForPlugin()
    if prefs.hasErrors then
        return
    end
    logger.trace("Exporting to DxO PureRAW")

    local exportSettings = {
        LR_exportServiceProvider = "at.homebrew.lrpureraw",
        LR_exportServiceProviderTitle = "DxO PureRAW",
        LR_format = "ORIGINAL",
        LR_tiff_compressionMethod = "compressionMethod_None",
        LR_minimizeEmbeddedMetadata = false,
        LR_metadata_keywordOptions = "lightroomHierarchical",
        LR_minimizeEmbeddedMetadata = false,
        LR_removeLocationMetadata = false,
        LR_export_destinationPathPrefix = prefs.export_destinationPathPrefix,
        LR_export_destinationPathSuffix = prefs.export_destinationPathSuffix,
        LR_export_destinationType = prefs.export_destinationType,
        LR_export_useParentFolder = prefs.export_useParentFolder,
        LR_export_useSubfolder = prefs.export_useSubfolder,
        LR_DNG_compatibilityV3 = prefs.LR_DNG_compatibilityV3,
        LR_DNG_conversionMethod = prefs.DNG_conversionMethod,
        LR_DNG_previewSize = prefs.DNG_previewSize,
        LR_DNG_compressed = prefs.DNG_compressed,
        LR_DNG_embedCache = prefs.DNG_embedCache,
        LR_DNG_embedRAW = prefs.DNG_embedRAW,
        LR_DNG_lossyCompression = prefs.DNG_lossyCompression,
        LR_collisionHandling = prefs.collisionHandling
    }

    local activeCatalog = LrApplication.activeCatalog()
    local targetPhotos = activeCatalog.targetPhotos
    local filmstrip = {}
    local index = 1
    for i, photo in ipairs(targetPhotos) do
        if (filterProvider.shouldRenderPhoto(exportSettings, photo)) then
            filmstrip[index] = photo
            index = index + 1
        end
    end
    if ( utils.arraySize(filmstrip)  >0 ) then
        local exportSession = LrExportSession({
            exportSettings = exportSettings,
            photosToExport = filmstrip
        })
        exportSession:doExportOnCurrentTask()

    end
end)
