# LRPureRAW

## Features
Lightroom Classic plugin which add an export provider for DxO RureRAW.

## Requirements
* DxO PureRAW must be installed

## Installation
* Download the zip archive for your operating system from [GitHub](https://github.com/sto3014/LRPureRAW/tree/main/target).
* Extract the archive into your home directory.  
* Restart Lightroom

The plugin and preset are now available for your user.
  
## Usage
The basic workflow works roughly as follows:
* Select one or more photos
* Select File/Export…  
* Choose the PureRAW Original preset  
* Select Export  
  
The selected photos are exported and then retrieved in PureRAW. In PureRAW develop the photos.
After the photos are processed, export them to Lightroom Classic.  

Only unprocessed DNG and RAW photos are sent to PureRAW. If you select other types as well, they are 
just ignored.  
In the plugin settings (Plug-in Manager) you can configure that metadata is set for photos which 
were exported. This configuration supports:
* Color Labels
* Ratings
* Flags 

This data is set after the export is done. I.e., the processed and reimported photos have the same 
metadata as the photos before they were change by the export. 

The standard export path from Lightroom to PureRAW is <user picture folder>/LR2PureRaw. You may change 
this in the PureRAW Original preset.

Additionally, there are three filter presets which may support your workflow:
* PureRAW (candidate)  
  Displays only photos which can be exported by the PureRAW Original preset
* PureRAW (excluded)  
  Displays only photos which were not processed. 
* PureRAW (only)  
Displays only processed photos
  
## Troubleshooting
LRPureRAW expects that DxO PureRAW 1.0 is installed in the following directory:
* Windows  
  C:\Programm Files\DxO\DxO PureRAW
* Mac   
  /Applications/DxO PureRaw.app    
  
If DxO PureRAW is installed in a different place, you must configure the installation directory 
  in the plugin settings of PureRAW in the Plug-in Manager.
  
## Known Issues
The photos are sent to DxO PureRAW via command line. The length of the commad line is restricted in length. The 
more photos we sent, the longer the command line is. The command line length limits are:
* Windows: 8191  
* Mac: 262144   

I.e., on Mac we have actually no limit in amount of photos, but in Windows we have. But even 100 photos should work in
  most of the cases.