#!/usr/bin/env bash
# Will be executed after Lightroom has successfully exported all photos.
# If this script returns an error (i.e. exit 1) Lightroom displays an error message
# Lightroom looks for a file named $TMPDIR/afterexport.err and displays it's content in this dialog
# The following parameters will be passed to this script:
# 1. Source directory - if more than one, only the first one is passed.
# 2. Target directory
# 3. Count exported images
# 4+ Image(s) - Name only, without path but with suffix: ANY-PHOTO.DNG