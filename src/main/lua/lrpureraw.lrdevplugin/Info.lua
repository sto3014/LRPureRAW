return {

    LrSdkVersion = 3.0,
    LrSdkMinimumVersion = 2.0,
    LrToolkitIdentifier = 'at.homebrew.lrpureraw',

    LrPluginName = LOC "$$$/LRPureRaw/PluginName=PureRaw",
    LrInitPlugin = "InitProvider.lua",
    LrPluginInfoProvider = "InfoProvider.lua",
    LrExportServiceProvider = {
        title = "DxO PureRAW",
        file = "PureRawExportServiceProvider.lua",
    },
    LrExportMenuItems = {
        title = "$$$/LRPureRaw/MenuAction/Export=Export to DxO PureRAW",
        file = "ExportToDxOPureRAWMenuAction.lua",
        enabledWhen = "photosSelected",
    },
    LrExportFilterProvider = {
            title = "DxO PureRAW", -- the string that appears in the export filter section of the export dialog in LR
            file = 'PureRawExportFilterProvider.lua', -- name of the file containing the filter definition script
            id = "noRejected",  -- unique identifier for export filter
    },

    VERSION = { major = 1, minor = 0, revision = 0, build = 0, },

    settingsSections = function(LrView, prefs)
        local LrDialogs = import("LrDialogs")
        local LrPathUtils = import("LrPathUtils")
        local LrFileUtils = import("LrFileUtils")
        local viewFactory = LrView.osFactory()
        local LrPrefs = import("LrPrefs")
        if (MAC_ENV) then
            -- PureRawPath_Title
            prefs.PureRawDir_Title = LOC("$$$/LRPurePath/Settings/PathToPureRaw/MAC=DxO PureRAW directory")
            prefs.PureRawExe_Title = LOC("$$$/LRPurePath/Settings/PureRawExe/MAC=Executable")
        else
            -- PureRawPath_Title
            prefs.PureRawPath_Title = LOC("$$$/LRPurePath/Settings/PathToPureRaw/WIN=DxO PureRAW executable")
        end

        local bind = LrView.bind
        --
        -- Windows
        --
        if (WIN_ENV) then
            return {
                title = LOC("$$$/LRPureRaw/Settings/PluginSettings=Plugin Settings"),
                bind_to_object = prefs,
                --
                -- Path to pureraw
                --
                viewFactory:row({
                    viewFactory:static_text({
                        title = bind("PureRawPath_Title"),
                        width_in_chars = 19,
                        -- fill_horizontal = 1,
                        -- height_in_lines = -1
                    }),
                    viewFactory:edit_field({
                        value = LrView.bind("PureRawPath"),
                        fill_horizontal = 1,
                        enabled = false
                    }),
                    viewFactory:push_button({
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
                viewFactory:row({
                    viewFactory:group_box {
                        title = "Popup Menu",
                        fill_horizontal = 1,
                        spacing = viewFactory:control_spacing(),
                        viewFactory:popup_menu {
                            value = bind("resetColorLabel"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = "not used", value = 'ignore' },
                                { title = "red", value = '1' },
                                { title = "yellow", value = '2' },
                                { title = "green", value = '3' },
                                { title = "blue", value = '4' },
                                { title = "purple", value = '6' },
                                { title = "purple", value = '6' },
                                { title = "custom", value = 'custom' },
                            }
                        },
                        viewFactory:static_text {
                            fill_horizontal = 1,
                            title = bind("resetColorLabel"), -- bound to same key as current selection
                        },
                    },
                }),
            }
        else
            --
            -- macOS
            --
            return {
                title = LOC("$$$/LRPureRaw/Settings/PluginSettings=Plugin Settings"),
                bind_to_object = prefs,
                -- Path to pureraw
                viewFactory:row({
                    viewFactory:static_text({
                        title = bind("PureRawDir_Title"),
                        width_in_chars = 19,
                        -- fill_horizontal = 1,
                        -- height_in_lines = -1
                    }),
                    viewFactory:edit_field({
                        value = LrView.bind("PureRawDir"),
                        fill_horizontal = 1,
                        enabled = false
                    }),
                    viewFactory:push_button({
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
                                if (string.find(pureRawDir[1], ".app") ~= nil) then
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
                viewFactory:row({
                    viewFactory:static_text({
                        title = bind("PureRawExe_Title"),
                        width_in_chars = 19,
                        -- fill_horizontal = 1,
                        -- height_in_lines = -1
                    }),
                    viewFactory:edit_field({
                        value = LrView.bind("PureRawExe"),
                        fill_horizontal = 1,
                        enabled = false
                    }),
                    viewFactory:push_button({
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
                viewFactory:row({
                    viewFactory:static_text({
                        title = "Reset metadata",
                        width_in_chars = 19,
                        -- fill_horizontal = 1,
                        -- height_in_lines = -1
                    }),
                    viewFactory:group_box {
                        title = "Color label",
                        fill_horizontal = 1,
                        spacing = viewFactory:control_spacing(),
                        viewFactory:popup_menu {
                            value = bind("resetColorLabel"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = "off", value = 'off' },
                                { title = "none", value = 'none' },
                                { title = "red", value = 'red' },
                                { title = "yellow", value = 'yellow' },
                                { title = "green", value = 'green' },
                                { title = "blue", value = 'blue' },
                                { title = "purple", value = 'purple' },
                            }
                        },
                    },
                    viewFactory:group_box {
                        title = "Rating",
                        fill_horizontal = 1,
                        spacing = viewFactory:control_spacing(),
                        viewFactory:popup_menu {
                            value = bind("resetRating"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = "off", value = 'off' },
                                { title = "0", value = "0" },
                                { title = "1", value = '1' },
                                { title = "2", value = '2' },
                                { title = "3", value = '3' },
                                { title = "4", value = '4' },
                                { title = "5", value = '5' },
                            }
                        },
                    },
                    viewFactory:group_box {
                        title = "Pick Status",
                        fill_horizontal = 1,
                        spacing = viewFactory:control_spacing(),
                        viewFactory:popup_menu {
                            value = bind("resetPickStatus"), -- current value bound to same key as static text
                            items = { -- the menu items and their values
                                { title = "off", value = 100 },
                                { title = "flagged", value = 1 },
                                { title = "unflagged", value = 0 },
                                { title = "rejected", value = -1 },
                            }
                        },
                    },
                }),
            }
        end
    end,

}
