local LrView = import("LrView")
local LrPrefs = import("LrPrefs")
local LrDialogs = import("LrDialogs")
local LrPathUtils = import("LrPathUtils")
local LrFileUtils = import("LrFileUtils")
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
local logger = require("Logger")
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
function InfoProvider.sectionsForTopOfDialog(f, _)
    logger.trace("sectionsForTopOfDialog")

    local prefs = LrPrefs.prefsForPlugin()
    local bind = LrView.bind
    --
    -- Windows
    --
    if (WIN_ENV) then
        return {
            {
                title = LOC("$$$/LRPureRaw/Settings/PluginSettings=Plugin Settings"),
                bind_to_object = prefs,
                --
                -- Path to pureraw
                --
                f:row({
                    f:static_text({
                        title = LOC("$$$/LRPurePath/Settings/PathToPureRaw/WIN=DxO PureRAW executable"),
                        width_in_chars = 19,
                    }),
                    f:edit_field({
                        value = bind("PureRawPath"),
                        fill_horizontal = 1,
                        enabled = false
                    }),
                    f:push_button({
                        title = "...",
                        action = function()
                            local startDir
                            startDir = LrPathUtils.parent(LrPathUtils.parent(prefs.PureRawPath) or "")
                            local pureRawPath = LrDialogs.runOpenPanel({
                                title = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRaw/WIN=Select executable"),
                                prompt = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRaw/WIN=Select executable"),
                                canChooseFiles = true,
                                canChooseDirectories = false,
                                allowsMultipleSelection = false,
                                initialDirectory = startDir
                            })
                            if type(pureRawPath) == "table" and #pureRawPath > 0 then
                                prefs.PureRawPath = pureRawPath[1]
                                prefs.PureRawExe = LrPathUtils.leafName(pureRawPath[1])
                                prefs.PureRawDir = LrPathUtils.parent(pureRawPath[1])
                            end
                        end
                    })
                }),
                f:row({
                    f:static_text({
                        title = LOC("$$$/LRPurePath/Reset/Title=Set after export"),
                        width_in_chars = 19,
                    }),
                    f:group_box {
                        title = LOC("$$$/LRPureRaw/Reset/label=Color Label"),
                        fill_horizontal = 1,
                        spacing = f:control_spacing(),
                        size = "regular",
                        f:popup_menu {
                            value = bind("resetColorLabel"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = LOC("$$$/LRPureRaw/Reset/off=Off"), value = 'off' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/none=None"), value = 'none' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/red=Red"), value = 'red' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/yellow=Yellow"), value = 'yellow' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/green=Green"), value = 'green' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/blue=Blue"), value = 'blue' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/purple=Purple"), value = 'purple' },
                            }
                        },
                    },
                    f:group_box {
                        title = LOC("$$$/LRPureRaw/Reset/rating=Rating"),
                        fill_horizontal = 1,
                        spacing = f:control_spacing(),
                        size = "regular",
                        f:popup_menu {
                            value = bind("resetRating"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = LOC("$$$/LRPureRaw/Reset/off=Off"), value = 'off' },
                                { title = "0", value = "0" },
                                { title = "1", value = '1' },
                                { title = "2", value = '2' },
                                { title = "3", value = '3' },
                                { title = "4", value = '4' },
                                { title = "5", value = '5' },
                            }
                        },
                    },
                    f:group_box {
                        title = LOC("$$$/LRPureRaw/Reset/pickstatus=Flag"),
                        fill_horizontal = 1,
                        spacing = f:control_spacing(),
                        size = "regular",
                        f:popup_menu {
                            value = bind("resetPickStatus"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = LOC("$$$/LRPureRaw/Reset/off=Off"), value = 100 },
                                { title = LOC("$$$/LRPureRaw/Reset/Pick/flagged=Flagged"), value = 1 },
                                { title = LOC("$$$/LRPureRaw/Reset/Pick/unflagged=Unflagged"), value = 0 },
                                { title = LOC("$$$/LRPureRaw/Reset/Pick/rejected=Rejected"), value = -1 },
                            }
                        },
                    },
                }),
                -- Path to Scripts
                f:row({
                    f:static_text({
                        title = LOC("$$$/LRPureRaw/Settings/ScriptsTitle=Scripts"),
                        width_in_chars = 19,
                    }),
                    f:group_box({
                        title = LOC("$$$/LRPureRaw/Settings/ScriptBeforeTitle=Script before export:"),
                        fill_horizontal = 2,
                        spacing = f:control_spacing(),
                        size = "regular",
                        f:row({
                            f:edit_field({
                                value = LrView.bind("scriptBefore"),
                                fill_horizontal = 1,
                                enabled = false
                            }),
                            f:push_button({
                                title = "...",
                                action = function()
                                    local startDir
                                    startDir = prefs.scriptBeforePath
                                    local scriptBeforeFile = LrDialogs.runOpenPanel({
                                        title = LOC("$$$/LRPureRaw/Settings/ScriptBeforeSelect=Select script before export"),
                                        prompt = LOC("$$$/LRPureRaw/Settings/ScriptBeforeSelect=Select script before export"),
                                        canChooseFiles = true,
                                        canChooseDirectories = false,
                                        allowsMultipleSelection = false,
                                        initialDirectory = startDir
                                    })

                                    if type(scriptBeforeFile) == "table" and #scriptBeforeFile > 0 then
                                        prefs.scriptBefore = LrPathUtils.leafName(scriptBeforeFile[1])
                                        prefs.scriptBeforePath = LrPathUtils.parent(scriptBeforeFile[1])
                                    end
                                end
                            })
                        }),
                        f:checkbox {
                            title = LOC("$$$/LRPureRaw/Settings/ScriptBeforeExecuteTitle=Execute before export:"),
                            value = bind("scriptBeforeExecute"),
                        },
                    }),
                    f:group_box({
                        title = LOC("$$$/LRPureRaw/Settings/ScriptAfterTitle=Script after export:"),
                        fill_horizontal = 2,
                        spacing = f:control_spacing(),
                        size = "regular",
                        f:row({
                            f:edit_field({
                                value = bind("scriptAfter"),
                                fill_horizontal = 1,
                                enabled = false
                            }),
                            f:push_button({
                                title = "...",
                                action = function()
                                    local startDir
                                    startDir = prefs.scriptAfterPath
                                    local scriptAfterFile = LrDialogs.runOpenPanel({
                                        title = LOC("$$$/LRPureRaw/Settings/ScriptAfterSelect=Select script after export"),
                                        prompt = LOC("$$$/LRPureRaw/Settings/ScriptAfterSelect=Select script after export"),
                                        canChooseFiles = true,
                                        canChooseDirectories = false,
                                        allowsMultipleSelection = false,
                                        initialDirectory = startDir
                                    })

                                    if type(scriptAfterFile) == "table" and #scriptAfterFile > 0 then
                                        prefs.scriptAfter = LrPathUtils.leafName(scriptAfterFile[1])
                                        prefs.scriptAfterPath = LrPathUtils.parent(scriptAfterFile[1])
                                    end
                                end
                            })
                        }),
                        f:checkbox {
                            title = LOC("$$$/LRPureRaw/Settings/ScriptAfterExecuteTitle=Execute after export:"),
                            value = bind("scriptAfterExecute"),
                        },
                    })
                }),
            }
        }

    else
        --
        -- macOS
        --
        return {
            {

                title = LOC("$$$/LRPureRaw/Settings/PluginSettings=Plugin Settings"),
                bind_to_object = prefs,
                -- Path to pureraw
                f:row({
                    f:static_text({
                        title = LOC("$$$/LRPurePath/Settings/PathToPureRaw/MAC=DxO PureRAW directory"),
                        width_in_chars = 19,
                    }),
                    f:edit_field({
                        value = bind("PureRawDir"),
                        fill_horizontal = 1,
                        enabled = false
                    }),
                    f:push_button({
                        title = "...",
                        action = function()
                            local startDir
                            startDir = LrPathUtils.parent(prefs.PureRawDir) or ""
                            local pureRawDir = LrDialogs.runOpenPanel({
                                title = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRaw/MAC=Select DxO PureRAW application"),
                                prompt = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRaw/MAC=Select DxO PureRAW application"),
                                canChooseFiles = true,
                                canChooseDirectories = true,
                                allowsMultipleSelection = false,
                                initialDirectory = startDir
                            })

                            if type(pureRawDir) == "table" and #pureRawDir > 0 then
                                if (pureRawDir[1]:sub(-#".app") == ".app") then
                                    local pureRawExe = prefs.PureRawExe
                                    local newToolPath = pureRawDir[1] .. "/Contents/MacOS/" .. pureRawExe
                                    prefs.PureRawDir = pureRawDir[1]
                                    prefs.PureRawPath = newToolPath
                                    if LrFileUtils.exists(newToolPath) ~= "file" then
                                        prefs.hasErrors = true
                                        LrDialogs.message(LOC("$$$/LRPureRaw/Settings/NoFile=File not found"), LOC("$$$/LRPureRaw/Settings/NoExe=The folder chosen does not contain ^1.", pureRawExe), critical)
                                    end
                                else
                                    LrDialogs.message(LOC("$$$/LRPureRaw/Settings/BadPath=Path is incorrect"), LOC("$$$/LRPureRaw/Settings/NotAnApp=Selected file is not an application."), critical)
                                end

                            end
                        end
                    })
                }),
                -- Name of executable
                f:row({
                    f:static_text({
                        title = LOC("$$$/LRPurePath/Settings/PureRawExe/MAC=Executable"),
                        width_in_chars = 19,
                    }),
                    f:edit_field({
                        value = bind("PureRawExe"),
                        fill_horizontal = 1,
                        enabled = false
                    }),
                    f:push_button({
                        title = "...",
                        action = function()
                            local startDir
                            startDir = prefs.PureRawDir or ""
                            local pureRawExe = LrDialogs.runOpenPanel({
                                title = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRawExe/MAC=Select executable"),
                                prompt = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRawExe/MAC=Select executable"),
                                canChooseFiles = true,
                                canChooseDirectories = false,
                                allowsMultipleSelection = false,
                                initialDirectory = startDir
                            })
                            -- prefs.PureRawExe = LrPathUtils.leafName(pureRawExe[1])
                            if type(pureRawExe) == "table" and #pureRawExe > 0 then
                                if LrFileUtils.exists(pureRawExe[1]) == "file" then
                                    prefs.PureRawExe = LrPathUtils.leafName(pureRawExe[1])
                                    prefs.PureRawPath = prefs.PureRawDir .. "/Contents/MacOS/" .. pureRawExe
                                else
                                    LrDialogs.message(LOC("$$$/LRPureRaw/Settings/BadPath=Path is incorrect"), LOC("$$$/LRPureRaw/Settings/NoExe=The folder chosen does not contain ^1.", pureRawExe), "critical")
                                end
                            end

                        end
                    })

                }),
                f:row({

                    f:static_text({
                        title = LOC("$$$/LRPurePath/Reset/Title=Set after export"),
                        width_in_chars = 19,
                    }),
                    f:group_box {
                        title = LOC("$$$/LRPureRaw/Reset/label=Color Label"),
                        fill_horizontal = 1,
                        spacing = f:control_spacing(),
                        size = "regular",

                        f:popup_menu {
                            value = bind("resetColorLabel"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = LOC("$$$/LRPureRaw/Reset/off=Off"), value = 'off' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/none=None"), value = 'none' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/red=Red"), value = 'red' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/yellow=Yellow"), value = 'yellow' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/green=Green"), value = 'green' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/blue=Blue"), value = 'blue' },
                                { title = LOC("$$$/LRPureRaw/Reset/Label/purple=Purple"), value = 'purple' },
                            }
                        },
                    },
                    f:group_box {
                        title = LOC("$$$/LRPureRaw/Reset/rating=Rating"),
                        fill_horizontal = 1,
                        spacing = f:control_spacing(),
                        size = "regular",

                        f:popup_menu {
                            value = bind("resetRating"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = LOC("$$$/LRPureRaw/Reset/off=Off"), value = 'off' },
                                { title = "0", value = "0" },
                                { title = "1", value = '1' },
                                { title = "2", value = '2' },
                                { title = "3", value = '3' },
                                { title = "4", value = '4' },
                                { title = "5", value = '5' },
                            }
                        },
                    },
                    f:group_box {
                        title = LOC("$$$/LRPureRaw/Reset/pickstatus=Flag"),
                        fill_horizontal = 1,
                        spacing = f:control_spacing(),
                        size = "regular",

                        f:popup_menu {
                            value = bind("resetPickStatus"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = LOC("$$$/LRPureRaw/Reset/off=Off"), value = 100 },
                                { title = LOC("$$$/LRPureRaw/Reset/Pick/flagged=Flagged"), value = 1 },
                                { title = LOC("$$$/LRPureRaw/Reset/Pick/unflagged=Unflagged"), value = 0 },
                                { title = LOC("$$$/LRPureRaw/Reset/Pick/rejected=Rejected"), value = -1 },
                            }
                        },
                    },
                }),
                -- Path to Scripts
                f:row({
                    f:static_text({
                        title = LOC("$$$/LRPureRaw/Settings/ScriptsTitle=Scripts"),
                        width_in_chars = 19,
                    }),
                    f:group_box({
                        title = LOC("$$$/LRPureRaw/Settings/ScriptBeforeTitle=Script before export:"),
                        fill_horizontal = 2,
                        spacing = f:control_spacing(),
                        size = "regular",
                        f:row({
                            f:edit_field({
                                value = bind("scriptBefore"),
                                fill_horizontal = 1,
                                enabled = false
                            }),
                            f:push_button({
                                title = "...",
                                action = function()
                                    local startDir
                                    startDir = prefs.scriptBeforePath
                                    local scriptBeforeFile = LrDialogs.runOpenPanel({
                                        title = LOC("$$$/LRPureRaw/Settings/ScriptBeforeSelect=Select script before export"),
                                        prompt = LOC("$$$/LRPureRaw/Settings/ScriptBeforeSelect=Select script before export"),
                                        canChooseFiles = true,
                                        canChooseDirectories = false,
                                        allowsMultipleSelection = false,
                                        initialDirectory = startDir
                                    })

                                    if type(scriptBeforeFile) == "table" and #scriptBeforeFile > 0 then
                                        prefs.scriptBefore = LrPathUtils.leafName(scriptBeforeFile[1])
                                        prefs.scriptBeforePath = LrPathUtils.parent(scriptBeforeFile[1])
                                    end
                                end
                            })
                        }),
                        f:checkbox {
                            title = LOC("$$$/LRPureRaw/Settings/ScriptBeforeExecuteTitle=Execute before export:"),
                            value = bind("scriptBeforeExecute"),
                        },
                    }),
                    f:group_box({
                        title = LOC("$$$/LRPureRaw/Settings/ScriptAfterTitle=Script after export:"),
                        fill_horizontal = 2,
                        spacing = f:control_spacing(),
                        size = "regular",
                        f:row({
                            f:edit_field({
                                value = bind("scriptAfter"),
                                fill_horizontal = 1,
                                enabled = false
                            }),
                            f:push_button({
                                title = "...",
                                action = function()
                                    local startDir
                                    startDir = prefs.scriptAfterPath
                                    local scriptAfterFile = LrDialogs.runOpenPanel({
                                        title = LOC("$$$/LRPureRaw/Settings/ScriptAfterSelect=Select script after export"),
                                        prompt = LOC("$$$/LRPureRaw/Settings/ScriptAfterSelect=Select script after export"),
                                        canChooseFiles = true,
                                        canChooseDirectories = false,
                                        allowsMultipleSelection = false,
                                        initialDirectory = startDir
                                    })

                                    if type(scriptAfterFile) == "table" and #scriptAfterFile > 0 then
                                        prefs.scriptAfter = LrPathUtils.leafName(scriptAfterFile[1])
                                        prefs.scriptAfterPath = LrPathUtils.parent(scriptAfterFile[1])
                                    end
                                end
                            })
                        }),
                        f:checkbox {
                            title = LOC("$$$/LRPureRaw/Settings/ScriptAfterExecuteTitle=Execute after export:"),
                            value = bind("scriptAfterExecute"),
                        },
                    })
                }),
            }
        }
    end

end
--[[----------------------------------------------------------------------------
-----------------------------------------------------------------------------]]
return InfoProvider