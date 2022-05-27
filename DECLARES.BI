DECLARE SUB PrintFooter(finfo$,dinfo$)
DECLARE SUB PrintAtCol (xCol%, txt$)
DECLARE SUB Dir2Pipe(arr$())
DECLARE SUB ProcessDirsAndFilesAndPrint (arrDir() AS STRING)
DECLARE SUB LocateCurCol (col%)
DECLARE SUB PrintBottomLine ()
DECLARE SUB PrintTopLine ()
DECLARE SUB PrintColSpacers ()
DECLARE SUB SetColorAndFormat4File (filename$, filesize$)
DECLARE FUNCTION CleanUpFileSize$ (fsize$)
DECLARE SUB SetFileColor (ext$)
DECLARE FUNCTION IsFreeDOS() AS INTEGER
DECLARE FUNCTION Is4DOSLoaded() AS INTEGER

