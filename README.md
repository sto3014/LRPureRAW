# LRPureRAW

## Features
_Lightroom Classic_ plug-in which add an export provider for _DxO RureRAW_.

## Requirements
* _DxO PureRAW_ must be installed

## Installation
* Download the zip archive for your operating system from [GitHub](https://github.com/sto3014/LRPureRAW/tree/main/target).
* Extract the archive into your home directory.  
* Restart Lightroom

The plug-in and presets are now available for your user.
  
## Usage
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

In the plugin settings (_Plug-in Manager_) you can configure metadata which is set before the export.
This configuration supports:
* Color labels
* Ratings
* Flags 

This data is set after the export has finished. I.e., the re-imported photos have the  
original metadata. 


Additionally, there are three filter presets which may support your workflow:
* PureRAW (candidate)  
  Displays only photos which can be exported by the _PureRAW Original_ preset.
* PureRAW (excluded)  
  Displays only photos which were not processed. 
* PureRAW (only)  
Displays only processed photos.
  
## Troubleshooting
_LRPureRAW_ expects that _DxO PureRAW_ 1.0 is installed in the following directory:
* Windows  
  C:\Program Files\DxO\DxO PureRAW
* Mac   
  /Applications/DxO PureRaw.app    
  
If _DxO PureRAW_ is installed in a different place or is of different version, you must configure the installation directory 
  in the plugin settings of PureRAW in the Plug-in Manager.
  
## Known Issues
The photos are sent to _DxO PureRAW_ via command line. The length of the command line is restricted in length. The 
more photos we sent, the longer the command line will be. The command line length limits are:
* Windows: 8191  
* Mac: 262144   

I.e., on Mac we do not have a real limit in amount of photos, but in Windows we have. 
Be as it is, even in Windows 100 photos should not be a problem to convert in one step.