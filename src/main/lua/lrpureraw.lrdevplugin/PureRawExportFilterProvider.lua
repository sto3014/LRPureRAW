---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dieter stockhausen.
--- DateTime: 04.05.21 22:00
---
-------------------------------------------------------------------------------

local LrApplication = import 'LrApplication'
local LrPrefs = import("LrPrefs")

local logger = require("Logger")

-------------------------------------------------------------------------------

local PureRawExportFilterProvider = {}

-------------------------------------------------------------------------------
function PureRawExportFilterProvider.shouldRenderPhoto(exportSettings, photo)
    logger.trace("shouldRenderPhoto() start")
    local catalog = LrApplication.activeCatalog()

    local prefs = LrPrefs.prefsForPlugin()
    if (not prefs.processIsRunning) then
        prefs.processIsRunning = true
        prefs.processCountPhotos = #catalog:getTargetPhotos()
    end
    prefs.processCurrent = prefs.processCurrent + 1
    if (prefs.processCurrent == prefs.processCountPhotos) then
        prefs.processIsLatest = true
    end
    logger.trace("isRunning=" .. tostring(prefs.processIsRunning))
    logger.trace("countPhotos=" .. prefs.processCountPhotos)
    logger.trace("current=" .. prefs.processCurrent)
    logger.trace("isLatest=" .. tostring(prefs.processIsLatest))
    local excluded = false

    -- if nothing was selected, nothing should be exported.
    local tp = catalog:getTargetPhoto()
    if (tp == nil) then
        logger.trace("Nothing selected.")
        excluded = true
    end

    -- only DNG and RAW are allowed
    if (not excluded) then
        local fileFormat = photo:getRawMetadata("fileFormat")
        if (fileFormat == nil) then
            logger.trace("fileFormat is not set. So it seems not to be a DNG or RAW.")
            prefs.processCountExcludedFileFormat = prefs.processCountExcludedFileFormat + 1
            excluded = true
        end
        if (not excluded) then
            logger.trace("Filetype for " .. photo:getFormattedMetadata("fileName") .. ": " .. fileFormat)
            if (fileFormat ~= "DNG" and fileFormat ~= "RAW") then
                logger.trace("Photo is not a DNG or RAW. Skipped.")
                prefs.processCountExcludedFileFormat = prefs.processCountExcludedFileFormat + 1
                excluded = true
            end
        end
    end
    -- skipp if already processed
    if (not excluded) then
        local software = photo:getFormattedMetadata('software')
        if (software ~= nil) then
            logger.trace("Software: " .. software)
            if (software == "DxO PureRAW") then
                prefs.processCountExcludedAlreadyProcessed = prefs.processCountExcludedAlreadyProcessed + 1
                excluded = true
            end
        else
            logger.trace("Software is not set. So it is be expected to be not yet processed by DxO PureRAW.")
        end
    end
    -- virtual copy
    if (not excluded and prefs.excludeVirtualCopies) then
        local virtualCopy = photo:getRawMetadata('isVirtualCopy')
        logger.trace("Virtual copy: " .. tostring(virtualCopy))
        if ( virtualCopy) then
            logger.trace("Photo is virtual copy. Skipped.")
            prefs.processCountExcludedVirtualCopies = prefs.processCountExcludedVirtualCopies + 1
            excluded = true
        end
    end

    if (excluded) then
        prefs.processCountExcluded = prefs.processCountExcluded + 1
    else
        prefs.processPhotos[ #prefs.processPhotos + 1] = photo
    end
    logger.trace("countExcluded=" .. prefs.processCountExcluded)
    logger.trace("processPhotos=" .. tostring(#prefs.processPhotos))
    if (prefs.processIsLatest) then
        if (prefs.processCountExcluded > 0) then
            if (prefs.processCountExcluded == prefs.processCountPhotos) then
                logger.trace("All photos excluded")
            else
                logger.trace("Some photos excluded")
            end
        else
            logger.trace("No photos excluded")
        end
        prefs.processIsRunning = false
    end
    logger.trace("shouldRenderPhoto() end")
    return not excluded
end

-------------------------------------------------------------------------------

function PureRawExportFilterProvider.sectionForFilterInDialog(f, propertyTable)
    return {
        title = LOC("$$$/LRPurePath/Filter/Title=Filter for valid photos"),
        f:row {
            spacing = f:control_spacing(),
            f:static_text {
                title = LOC("$$$/LRPureRaw/Filter/Descr=Only unprocessed RAW and DNG photos will pass."),
                fill_horizontal = 1,
            },
        }
    }
end

-------------------------------------------------------------------------------

return PureRawExportFilterProvider