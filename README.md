space150 EOTM Wall
------------------

The space150 EOTM Wall is a player designed to loop the current employee of the month winner. The idea is that the manifest and video files are hosted in a AWS S3 bucket and the client programs download and play the videos locally.

Current implementations:

- tvos - For playback on a AppleTV
- osx - A OS X Screensaver

The aws-s3 directory contains the current manifest and video files hosted. 1080p in both portrait and landscape are supported.
