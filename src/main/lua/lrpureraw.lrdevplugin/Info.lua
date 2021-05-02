return {

    LrSdkVersion = 3.0,
    LrSdkMinimumVersion = 2.0,
    LrToolkitIdentifier = 'at.homebrew.lrpureraw',

    LrPluginName = LOC "$$$/LRPureRaw/PluginName=PureRaw",
    LrInitPlugin = "InitProvider.lua",
    LrPluginInfoProvider = "InfoProvider.lua",
    LrExportServiceProvider = {
        title = "PureRaw",
        file = "PureRawExportServiceProvider.lua",
    },

    VERSION = { major = 1, minor = 0, revision = 0, build = 0, },

    settingsSections = function(LrView, prefs)

        local LrDialogs = import("LrDialogs")
        local LrPathUtils = import("LrPathUtils")
        local LrFileUtils = import("LrFileUtils")
        local viewFactory = LrView.osFactory()

        if (MAC_ENV) then
            -- PureRawPath_Title
            prefs.PureRawPath_Title = LOC("$$$/LRPurePath/Settings/PathToPureRaw/MAC=Path to DxO PurePAW")
        else
            -- PureRawPath_Title
            prefs.PureRawPath_Title = LOC("$$$/LRPurePath/Settings/PathToPureRaw/WIN=Path to DxO PurePAW")
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
                -- Path to purepaw
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
                                title = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRaw/WIN=Select DxO PureRAW program"),
                                prompt = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRaw/WIN=Select DxO PureRAW program"),
                                canChooseFiles = false,
                                canChooseDirectories = true,
                                allowsMultipleSelection = false,
                                initialDirectory = startDir
                            })
                            if type(pureRawPath) == "table" and #pureRawPath > 0 then
                                local pureRawExe
                                local newToolPath
                                pureRawExe = "PureRawv1.exe"
                                if (pureRawPath[1].match("(?i)DxO PureRAW$")) then
                                        newToolPath = LrPathUtils.child(pureRawPath[1], pureRawExe)
                                else
                                    newToolPath = LrPathUtils.child(pureRawPath[1], 'DxO/DxO PureRAW/' .. pureRawExe)
                                end
                                 if LrFileUtils.exists(newToolPath) == "file" then
                                    prefs.PureRawPath = newToolPath
                                else
                                    LrDialogs.message(LOC("$$$/LRPureRaw/Settings/BadPath=Path is incorrect"), LOC("$$$/LRPureRaw/Settings/NoExe=The folder chosen does not contain ^1.", pureRawExe), "critical")
                                end
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
                            startDir = LrPathUtils.parent(LrPathUtils.parent(LrPathUtils.parent(LrPathUtils.parent(prefs.PureRawPath) or "")))
                            local pureRawPath = LrDialogs.runOpenPanel({
                                title = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRaw/MAC=Select DxO PureRAW application"),
                                prompt = LOC("$$$/LRPureRaw/Settings/SelectDxOPureRaw/MAC=Select DxO PureRAW application"),
                                canChooseFiles = true,
                                canChooseDirectories = true,
                                allowsMultipleSelection = false,
                                initialDirectory = startDir
                            })
                            if type(pureRawPath) == "table" and #pureRawPath > 0 then
                                local pureRawExe
                                local newToolPath
                                pureRawExe = "PureRawv1"
                                if (pureRawPath[1].match("(?i)DxO PureRAW\.app$")) then
                                    newToolPath = LrPathUtils.child(pureRawPath[1], '/Contents/MacOS/' .. pureRawExe)
                                else
                                    newToolPath = LrPathUtils.child(pureRawPath[1], 'DxO PureRAW.app/Contents/MacOS/' .. pureRawExe)
                                end
                                if LrFileUtils.exists(newToolPath) == "file" then
                                    prefs.PureRawPath = newToolPath
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
