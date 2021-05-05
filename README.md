# LRPureRAW

# Features
Lightroom Classic plugin which add an export provider for DxO RureRAW.

# Prerequsites
* DxO PureRAW must be installed

# Installation
Clone the LRPureRAW repository or download the zip archive from [GitHub](https://github.com/sto3014/LRPureRAW)
Execute the install script for your operating system:
* install.sh for Mac
* install.bat for Windows  

The script extracts the corresponding zip archive (target/LRPureRAW1.0.0_mac.zip or 
  target/LRPureRAW1.0.0_win.zip) into your user directory

# Usage
The basic workflow works roughly as follows:
* Select one or more photos
* Select File/Export…  
* Choose the PureRAW Original preset  
* Select Export  
  
The selected photos are exported and then retrieved in PureRAW. In PureRAW develop the photos by accepting
the standard target (DxO subfolder). After the photos are processed export these back to Lightroom Classic.  

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
it in the PureRAW Original preset.

Additionally there are three filter presets which may support your workflow:
* PureRAW (candidate)  
  Displays only photos which can be exported by the PureRAW Original preset
* PureRAW (excluded)  
  Displays only photos which were not processed. 
* PureRAW (only)  
Displays only processed photos
  

  
