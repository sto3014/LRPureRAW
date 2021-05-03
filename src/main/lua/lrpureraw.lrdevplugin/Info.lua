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
        enabledWhen = "photosSelected"
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
                                        prefs.hasErrors=true
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
            }
        end
    end,

}
