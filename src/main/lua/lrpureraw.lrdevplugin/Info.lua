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

    LrExportFilterProvider = {
        title = LOC("$$$/LRPurePath/Filter=Valid photos"),
        file = 'PureRawExportFilterProvider.lua', -- name of the file containing the filter definition script
        id = "at.homebrew.lrpureraw", -- unique identifier for export filter
    },

    VERSION = { major = 1, minor = 5, revision = 1, build = 0, },

}
