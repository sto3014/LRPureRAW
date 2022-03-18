# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0.0] - 2021-05-05

Creation.

### Added
### Changed
### Fixed

## [1.0.1.0] - 2021-05-15
### Added
* Progress bar for export.
* Export process does not wait for PureRaw to end.
### Changed
### Fixed

## [1.0.1.1] - 2021-06-01
### Fixed
Installation packages were not up to date.

## [1.0.2.0] - 2021-06-01
### Fixed
On Windows PureRaw only started when it was the default application for *.dng files.

## [1.0.2.1] - 2021-08-18
### Fixed
If the software metadata tag is not set, an exception is thrown.

## [1.0.2.2] - 2021-10-24
### Changed
Changed the default export path from _Picutures folder_ to _Same folder as original photo_. 
See known issues in README.

## [1.0.2.3] - 2021-12-30
Only the documentation has changed. No need to update.
### Added
### Changed
### Fixed
Fix installation chapter in README.md 

## [1.5.0.0] - 2022-01-06
### Added
* Execute custom scripts before/after export.
* Example implementation of custom scripts: Processed photos are exported in the original photo folder.
* Add additional filter/validation for export preset
  * Exclude virtual copies
  * Force one source
### Changed
### Fixed

## [1.5.1.0] - 2022-01-14
### Added
* New standard filter: Missing photos are excluded.
### Changed
### Fixed
* Fixed missing titles in export filter.
* Fixed error when only missing photos were exported.

## [1.5.2.0] - 2022-03-18
### Added
* Support for DxO PureRAW 2
### Changed
### Fixed
