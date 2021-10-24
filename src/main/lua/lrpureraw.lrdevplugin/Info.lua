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
        title = LOC("$$$/LRPurePath/Filter=Valid photos"),
        file = 'PureRawExportFilterProvider.lua', -- name of the file containing the filter definition script
        id = "noRejected", -- unique identifier for export filter
    },

    VERSION = { major = 1, minor = 0, revision = 2, build = 2, },

}
