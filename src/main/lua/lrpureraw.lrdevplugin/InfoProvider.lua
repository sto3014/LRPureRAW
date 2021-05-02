local LrView = import("LrView")
local LrPrefs = import("LrPrefs")

InfoProvider = {
    vInfo = require("Info.lua")
}

local function UpdateSettingsDialog(viewFactory, propertyTable)
    local prefs
    if _PLUGIN ~= nil and prefs == nil then
        prefs = LrPrefs.prefsForPlugin()
    else
        prefs = propertyTable
    end
    return {
      type(InfoProvider.vInfo.settingsSections) == "function" and InfoProvider.vInfo.settingsSections(LrView, prefs) or nil
    }
end
return {
    sectionsForTopOfDialog = UpdateSettingsDialog
}