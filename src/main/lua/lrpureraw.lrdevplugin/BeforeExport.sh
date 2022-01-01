#!/usr/bin/env bash
# Will be executed before Lightroom starts to export the photos
# If this script returns an error (i.e. exit 1) the photos are not exported.
# If an error is returned Lightroom looks for a file named $TMPDIR/afterexport.err and displays it's content
# in a dialog
# The following parameters will be passed to this script:
# 1. Source directory - if more than one, only the first one is passed.
# 2. Target directory
# 3. Count photos which will be exported.
# 4+ Photo(s) - Name only, without path but with suffix: ANY-PHOTO.NEF