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

## Best practice

---
### Validation
DxO PureRAW only supports RAW files
* from [cameras and lenses which are supported](https://www.dxo.com/supported-cameras/)
* RAW files and none linear DNG files  
  The RAW or DNG which comes out of your camera are none linear. But if you create a panorama in Lightroom you get 
  a linear DNG. Also, an output file from DxO PureRAW is a linear DNG.  

This plug-in can support your workflow by filtering not valid photos and inform you during export that some photos 
were rejected. See [Filter for valid photos](#filter-for-valid-photos)

  


### Plugin Settings

#### DxO PureRAW
In this section the pathes for the DxO PureRAW executable are defined.
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
In this section you can configure metadata which is set before the export. This configuration supports:
* Color labels
* Ratings
* Flags

This data is set after the export has finished. I.e., the re-imported photos have the  
original metadata.

#### Scripts
In the script section you can define scripts which run before or directly after the Lightroom export.
The standard script which can be executed before the export is ```BeforeExport-Cleanup.cmd``` on Windows and 
```BeforeExport-Cleanup.sh``` on macOS. For after export it is ```AfterExport-CreateLink.bat``` 
respectively ```AfterExport-CreateLink```.  
The ```Execute``` check-box activates/deactivates the corresponding script.

### Export Preset
The ```PureRAW Original``` preset is responsible for the export. It uses the service provider ```DxO PureRAW``` 
(```Export to``` field on top of page).  
It provides 3 sections
* [Export location](#Export_location)  
  This is a standard Lightroom section.
* [File settings](#File_settings)
  This is a standard Lightroom section.
* [Filter for valid photos](#Filter_for_valid_photos)  
  Post Process-Action "PureRAW / Valid Photos"

If you change this export preset you should add it as a new preset, because the ```PureRAW Original``` may be 
overwritten on subsequent updates.

If you create an export preset from the scratch and use the service provider ```DxO PureRAW``` you must add the post 
process-action ```Valid Photos``` as well, if you want to use it.  

#### Export location`
The ```Export Location``` decides to where the files are
exported. The possible settings are the same as for other presets. There is only one restriction: If any script is running
during export, the location must be set to ```Special folder```, ```Export to``` must be checked, and the folder must have a
value. 

#### File settings
The file settings are restricted to two image formats: ```Original``` and ```DNG```
Best is to work with ```Original```, just because of the nameing of the files. E.g, if you work with NEF or CRW files
the exported files keep the suffix as well as the processed file which come from DxO PureRAW. This makes life a bit less 
confusing.
By the way, if your camera ist not supported, it does not help to convert it to an DNG file. DxO PureRAW will reject it
anyway.

#### Filter for valid photos
The ```Filter for valid photos``` register defines 4 filter options:  
* Other formats  
  Only DNGs or RAW files will pass this filter. The RAW filter does not differentiate between camera types. I.e., even
  if DxO PureRAW does not support a camera type, the RAW file of this camera type will be exported.
  The filter is always set to true and you can't change it. It is displayed just for clearness.
* Already processed
  A photo which was already exported by DxO PureRAW will be ignored. This filter compares the (EXIF) property 
  ```Software```. If the value is ```DxO PureRAW``` it will be rejected.
  The filter is always set to true and you can't change it. It is displayed just for clearness.
* Exclude virtual copies
  A virtual copy may probably not what you want to be exported. It might make more sense to process the original photo
  make a virtual copy of the processed photo and sync the settings.
* Force one source  
If you select photos which reside in multiple folders it makes it hard to import the processed photos back to Lightroom.
  It is even more confusing if you use the ```AfterExport-CreateLink``` script. In this case the processed photos will be 
  stored into any of the original folders.  
  Therefore, it is a good idea for the most workflows to check this option.


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