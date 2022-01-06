# LRPureRAW

---
_Lightroom Classic_ plug-in which add an export provider for _DxO RureRAW_.

## Features

---
* Export photos and start DxO PureRAW
* Set metadata (color, rating, flags) after export to identify the processed photos
* Predefined filters for PureRAW specific attributes

## Requirements

---
* _DxO PureRAW_ 1.X

## Installation

---
1. Download the zip archive for your operating system from [GitHub](https://github.com/sto3014/LRPureRAW/archive/refs/tags/1.5.0.0.zip).
2. Extract the archive in the download folder
3. Copy plug-in and resources into the configuration folder of Lightroom
    1. On Windows  
       Goto ```Downloads/LRPureRAW-1.5.0.0``` and execute install.bat.
       Install.bat copies the plug-in into:
       ```
       <User Home>\AppData\Roaming\Adobe\Lightroom\Modules\LRPureRAW.lrplugin
       ```
    2. On macOS
       Open a terminal window, change to ```Downloads/LRPureRAW-1.5.0.0``` and execute install.sh:
        ```
        -> ~ cd Downloads/LRPureRAW-1.5.0.0
        -> ./install.sh 
        ```
        Install.sh copies the plug-in into:
        ``` 
        ~/Library/Application Support/Adobe/Lightroom/Modules/LRPureRAW.lrplugin
        ```

4. Restart Lightroom

The plug-in and presets are now available for your user.

## Update

---
Same as installation. Be aware, that the export preset will be overwritten. So maybe you want to make a
backup and restore it after the update. You can find your the export preset in:
* Windows  
%APPDATA%\Adobe\Lightroom\Export Presets\PureRAW   
  Example: C:\users\janedoe\AppData\Roaming\Adobe\Lightroom\Export Presets\PureRAW   
  
* Mac   
~/Library/Application Support/Adobe/Lightroom/Export Presets/PureRAW   
  Example: /Users/janedoe/Library/Application Support/Adobe/Lightroom/Export Presets/PureRAW

## Usage

---
The basic workflow works roughly as follows:
* Select one or more photos
* Select File/Export…  
* Choose the _PureRAW Original_ preset  
* Select Export  
  
The selected photos are exported and retrieved in _DxO PureRAW_. 
* In _DxO PureRAW_ develop the photos.
* After the photos are processed, export them back to _Lightroom Classic_.  

Only unprocessed DNG and RAW photos are sent to _DxO PureRAW_. If you select other types as well, they are 
just ignored.

### Plugin Settings

#### DxO PureRAW
* On Windows
    * DxO PureRAW Executeable  
    Path to the exe file. The default value is ```C:\Program Files\DxO\DxO PureRAW\PureRawv1.exe```   
      If DxO PureRAW was installed in a different place you have to select the executable by yourself.
* On macOS
    * DxO PureRAW Application
      Path to the application. The default value is ```/Applications/DxO PureRAW.app```   
      If DxO PureRAW was installed in a different place you have to select the executable by yourself.
    * DxO PureRAW Executeable  
    The name of the executable. The default value is ```PureRawv1```
      
#### Set after export
In the plugin settings (_Plug-in Manager_) you can configure metadata which is set before the export.
This configuration supports:
* Color labels
* Ratings
* Flags

This data is set after the export has finished. I.e., the re-imported photos have the  
original metadata.

#### Scripts





### Export Preset

### Filter Preset
Additionally, there are three filter presets which may support your workflow:
* PureRAW (candidate)  
  Displays only photos which can be exported by the _PureRAW Original_ preset.
* PureRAW (excluded)  
  Displays only photos which were not processed. 
* PureRAW (only)  
Displays only processed photos.
  
## Troubleshooting

---
_LRPureRAW_ expects that _DxO PureRAW_ 1.0 is installed in the following directory:
* Windows  
  C:\Program Files\DxO\DxO PureRAW
* Mac   
  /Applications/DxO PureRaw.app    
  
If _DxO PureRAW_ is installed in a different place or is of different version, you must configure the installation directory 
  in the plugin settings of PureRAW in the Plug-in Manager.
  
## Known Issues

---
###Length of command line
The photos are sent to _DxO PureRAW_ via command line. The length of the command line is restricted in length. The 
more photos we sent, the longer the command line will be. The command line length limits are:
* Windows: 8191  
* Mac: 262144   
I.e., on Mac we do not have a real limit in amount of photos, but in Windows we have. 
Be as it is, even in Windows 100 photos should not be a problem to convert in one step.
  
###LR Import dialog will not be opened
When exporting the developed DxO photos from the _Pictures folder_ (or a subfolder of it) into Lightroom the 
Lightroom's import dialog will not be open. It seems to be a DxO PureRAW issue, because it can be reproduced by exporting 
any photo from this folder to Lightroom. 
Therefore, the default export path was changed to _Same folder as original photo_ in 1.0.2.2.
At the time this issue is documented only for Windows systems.