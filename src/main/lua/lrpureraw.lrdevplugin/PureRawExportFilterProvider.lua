---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by dieter stockhausen.
--- DateTime: 04.05.21 22:00
---
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
local LrApplication = import 'LrApplication'
local LrPrefs = import("LrPrefs")
local LrView = import("LrView")
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]

local logger = require("Logger")
require("Debugger")

--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
local PureRawExportFilterProvider = {}
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function PureRawExportFilterProvider.shouldRenderPhoto(exportSettings, photo)
    logger.trace("shouldRenderPhoto() start")

    local catalog = LrApplication.activeCatalog()

    local prefs = LrPrefs.prefsForPlugin()

    prefs.process.FilterIsActive = true

    if (not prefs.process.IsRunning) then
        prefs.process.IsRunning = true
        prefs.process.CountPhotos = #catalog:getTargetPhotos()
    end
    prefs.process.Current = prefs.process.Current + 1
    if (prefs.process.Current == prefs.process.CountPhotos) then
        prefs.process.IsLatest = true
    end
    logger.trace("isRunning=" .. tostring(prefs.process.IsRunning))
    logger.trace("countPhotos=" .. prefs.process.CountPhotos)
    logger.trace("current=" .. prefs.process.Current)
    logger.trace("isLatest=" .. tostring(prefs.process.IsLatest))
    local excluded = false

    -- if nothing was selected, nothing should be exported.
    local tp = catalog:getTargetPhoto()
    if (tp == nil) then
        logger.trace("Nothing selected.")
        excluded = true
    end

    -- only DNG and RAW are allowed
    if (not excluded and prefs.excludeNoneDNG) then
        local fileFormat = photo:getRawMetadata("fileFormat")
        if (fileFormat == nil) then
            logger.trace("fileFormat is not set. So it seems not to be a DNG or RAW.")
            prefs.process.CountExcludedFileFormat = prefs.process.CountExcludedFileFormat + 1
            excluded = true
        end
        if (not excluded) then
            logger.trace("Filetype for " .. photo:getFormattedMetadata("fileName") .. ": " .. fileFormat)
            if (fileFormat ~= "DNG" and fileFormat ~= "RAW") then
                logger.trace("Photo is not a DNG or RAW. Skipped.")
                prefs.process.CountExcludedFileFormat = prefs.process.CountExcludedFileFormat + 1
                excluded = true
            end
        end
    end
    -- skipp if already processed
    if (not excluded and prefs.excludeAlreadyProcessed) then
        local software = photo:getFormattedMetadata('software')
        if (software ~= nil) then
            logger.trace("Software: " .. software)
            if (software == "DxO PureRAW") then
                prefs.process.CountExcludedAlreadyProcessed = prefs.process.CountExcludedAlreadyProcessed + 1
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
        if (virtualCopy) then
            logger.trace("Photo is virtual copy. Skipped.")
            prefs.process.CountExcludedVirtualCopies = prefs.process.CountExcludedVirtualCopies + 1
            excluded = true
        end
    end

    if (not excluded and prefs.excludeMissing) then
        if (photo:checkPhotoAvailability()) then
            logger.trace("Photo missing: " .. tostring(false))
        else
            logger.trace("Photo missing: " .. tostring(true))
            prefs.process.CountMissing = prefs.process.CountMissing + 1
            excluded = true
        end
    end

    if (excluded) then
        prefs.process.CountExcluded = prefs.process.CountExcluded + 1
    else
        prefs.process.Photos[#prefs.process.Photos + 1] = photo
    end
    logger.trace("countExcluded=" .. prefs.process.CountExcluded)
    logger.trace("processPhotos=" .. tostring(#prefs.process.Photos))
    if (prefs.process.IsLatest) then
        if (prefs.process.CountExcluded > 0) then
            if (prefs.process.CountExcluded == prefs.process.CountPhotos) then
                logger.trace("All photos excluded")
            else
                logger.trace("Some photos excluded")
            end
        else
            logger.trace("No photos excluded")
        end
        prefs.process.IsRunning = false
    end
    logger.trace("shouldRenderPhoto() end")
    return not excluded
end

--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]


function PureRawExportFilterProvider.sectionForFilterInDialog(f, propertyTable)
    logger.trace("sectionForFilterInDialog() start")
    local prefs = LrPrefs.prefsForPlugin()
    local bind = LrView.bind
    return
    {
        title = LOC("$$$/LRPurePath/Filter/Title=Filter for valid photos"),
        bind_to_object = prefs,
        f:row({
            spacing = f:control_spacing(),
            f:static_text {
                title = LOC("$$$/LRPureRaw/Filter/Descr=Only valid photos will be exported."),
                fill_horizontal = 1,
            },
        }),

        -- Missing
        f:row({
            f:static_text({
                title = LOC("$$$/LRPureRaw/Settings/MissingTitle=Missing:"),
                width_in_chars = 19,
            }),
            f:checkbox {
                title = LOC("$$$/LRPureRaw/Settings/MissingExclude=Exclude missing photos"),
                value = bind("excludeMissing"),
                enabled = false,
            },
        }),
        -- Other formats
        f:row({
            f:static_text({
                title = LOC("$$$/LRPureRaw/Settings/NoneDNGTitle=Other formats:"),
                width_in_chars = 19,
            }),
            f:checkbox {
                title = LOC("$$$/LRPureRaw/Settings/NoneDNGExclude=Exclude formats, which are not of type DNG and RAW"),
                value = bind("excludeNoneDNG"),
                enabled = false,
            },
        }),
        -- Already processed
        f:row({
            f:static_text({
                title = LOC("$$$/LRPureRaw/Settings/AlreadyProcessedTitle=Already processed:"),
                width_in_chars = 19,
            }),
            f:checkbox {
                title = LOC("$$$/LRPureRaw/Settings/AlreadyProcessedExclude=Exclude photos which are already processed"),
                value = bind("excludeAlreadyProcessed"),
                enabled = false,
            },
        }),
        -- Virtual copy
        f:row({
            f:static_text({
                title = LOC("$$$/LRPureRaw/Settings/VirtualCopiesTitle=Virtual copies:"),
                width_in_chars = 19,
            }),
            f:checkbox {
                title = LOC("$$$/LRPureRaw/Settings/VirtualCopiesExclude=Exclude virtual copies"),
                value = bind("excludeVirtualCopies"),
            },
        }),
        -- Source folder
        f:row({
            f:static_text({
                title = LOC("$$$/LRPureRaw/Settings/OneSourceTitle=Source folder:"),
                width_in_chars = 19,
            }),
            f:checkbox {
                title = LOC("$$$/LRPureRaw/Settings/OneSourceForceTitle=Force unique folder"),
                value = bind("forceOneSource"),
            },
        })
    }
end

--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]


return PureRawExportFilterProvider