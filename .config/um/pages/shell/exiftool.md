# exiftool --
{:data-section="shell"}
{:data-date="May 13, 2021"}
{:data-extra="Um Pages"}

## SYNOPSIS

`exiftool a.jpg`
: Extract information from a file

`exiftool -artist=me a.jpg`
: Writes Artist tag to a.jpg. Since no group is specified, EXIF:Artist will be written and all other existing Artist tags will be updated with the new value ("me").

`exiftool -artist=me a.jpg b.jpg c.jpg`
: Writes Artist tag to three image files.

`exiftool -artist=me c:/images`
: Writes Artist tag to all files in directory c:/images.

`exiftool -artist="Phil Harvey" -copyright="2011 Phil Harvey" a.jpg`
: Writes two tags to a.jpg.

`exiftool -a -u -g1 a.jpg`
: Print all meta information in an image, including duplicate and unknown tags, sorted by group (for family 1).

`exiftool -common dir`
: Print common meta information for all images in dir.

`exiftool -T -createdate -aperture -shutterspeed -iso DIR > out.txt`
: List meta information in tab-delimited column form for all images in directory DIR to an output text file named "out.txt".

`exiftool -s -ImageSize -ExposureTime b.jpg`
: Print ImageSize and ExposureTime tag names and values.

`exiftool -l -canon c.jpg d.jpg`
: Print standard Canon information from two image files.

`exiftool -r -w .txt -common pictures`
: Recursively extract common meta information from files in C directory, writing text output into files with the same names but with a C<.txt> extension.

`exiftool -b -ThumbnailImage image.jpg > thumbnail.jpg`
: Save thumbnail image from C to a file called C.

`exiftool -b -JpgFromRaw -w _JFR.JPG -ext CRW -r .`
: Recursively extract JPG image from all Canon CRW files in the current directory, adding C<_JFR.JPG> for the name of the output JPG files.

`exiftool -d "%r %a, %B %e, %Y" -DateTimeOriginal -S -s *.jpg`
: Print formatted date/time for all JPG files in the current directory.

exiftool -IFD1:XResolution -IFD1:YResolution image.jpg
: Extract image resolution from EXIF IFD1 information (thumbnail image IFD).

`exiftool "-*resolution*" image.jpg`
: Extract all tags with names containing the word "Resolution" from an image.

`exiftool -xmp:author:all -a image.jpg`
; Extract all author-related XMP information from an image.

`exiftool -xmp -b a.jpg > out.xmp`
: Extract complete XMP data record intact from a.jpg and write it to out.xmp using the special XMP tag (see the Extra Tags).

`exiftool -p "$filename has date $dateTimeOriginal" -q -f dir`
: Print one line of output containing the file name and DateTimeOriginal for each image in directory dir.

`exiftool -ee -p "$gpslatitude, $gpslongitude, $gpstimestamp" a.m2ts`
: Extract all GPS positions from an AVCHD video.

`exiftool -icc_profile -b -w icc image.jpg`
: Save complete ICC_Profile from an image to an output file with the same name and an extension of C<.icc>.

`exiftool -htmldump -w tmp/%f_%e.html t/images`
