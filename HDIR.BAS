'=======================================================
'
'  HotDIR V1.02 for FreeDOS  Written May-2022
'  In Kherson... Slava Ukraine!
'
'  (c)sadLogic 2022,   (c)Humankind!     FreeWARE!
'
'  Added support for DOS/4DOS            V1.02
'
'=======================================================
#lang "fblite"

OPTION EXPLICIT
'$DYNAMIC
'$INCLUDE: 'declares.bi'
'$INCLUDE: 'color.bi'
'$INCLUDE: 'string.bas'
'$INCLUDE: 'glob.bas'

'--- show we are starting
PRINT
COLOR CLR_RED: PRINT "Hot";
COLOR CLR_BRIGHTWHITE: PRINT "DIR";
COLOR CLR_WHITE: PRINT " Reloaded... V1.02 ";
COLOR CLR_BRIGHTWHITE: PRINT " --> Reading ";

DIM SHARED isFDOS%: isFDOS% = IsFreeDOS()
DIM SHARED is4DOS%: IF NOT isFDOS% THEN is4DOS% = is4DOSLoaded()

'DECLARE FUNCTION FileName4Dos2Dos(infile as string)

'--- pipe in the normal DOS DIR command
REDIM dirContent(0) AS STRING
Dir2Pipe dirContent$()

'--- on with the show, make it colorful
LOCATE ,26
COLOR CLR_WHITE : PRINT "- ";
IF isFDOS THEN
    COLOR CLR_YELLOW: PRINT "FreeDOS";
ELSEIF is4DOS THEN
    COLOR CLR_YELLOW: PRINT "4DOS";
ELSE
    COLOR CLR_YELLOW: PRINT " ;)";
END IF

COLOR CLR_WHITE: PRINT " - ";
COLOR CLR_CYAN : PRINT "sadLogic 2022"

'--- parse the array and print
ProcessDirsAndFilesAndPrint dirContent$()

'--- end, bub-bye!
COLOR CLR_WHITE
PRINT: PRINT ""
END


'=======================================================
'--- Subs and code and crap and junk
'=======================================================

SUB ProcessDirsAndFilesAndPrint (arrDir$())

    '--- find 'directory of' - print path
    DIM ndx AS INTEGER
    DIM tmp$, FindMe$
    FindMe$ = "Directory of"
    FOR ndx = 0 TO UBOUND(arrDir$)
        tmp$ = LTRIM$(arrDir$(ndx))
        IF INSTR(TMP$,FindMe$) THEN
            COLOR CLR_BRIGHTWHITE
            PRINT "Path: " + strRemove$(tmp$, FindMe$)
            EXIT FOR
        END IF
    NEXT

    '--- get dirs, files, total sizes and save to array
    DIM dirsTotal AS STRING, filesTotal AS STRING
    DIM dirsNdx AS INTEGER = 0
    DIM filesNdx AS INTEGER = 0
    REDIM dirs$(UBOUND(arrDir$))
    REDIM files$(UBOUND(arrDir$))

    FOR ndx = ndx + 1 TO UBOUND(arrDir$)

        tmp$ = trim$(arrDir$(ndx))

        IF tmp$ <> "" THEN

            IF INSTR(tmp$, "<DIR>") THEN
                dirs$(dirsNdx) = tmp$
                dirsNdx = dirsNdx + 1

            ELSEIF INSTR(tmp$, "e(s") AND NOT is4DOS THEN
                filesTotal = tmp$

            ELSEIF INSTR(tmp$, "iles") AND is4DOS THEN
               filesTotal = tmp$

            ELSEIF INSTR(tmp$, "r(s") AND NOT is4DOS THEN
                dirsTotal = tmp$

            ELSEIF INSTR(tmp$, "es fr") AND is4DOS THEN
                dirsTotal = tmp$

            ELSE
                files$(filesNdx) = tmp$
                filesNdx = filesNdx + 1

            END IF
        END IF
    NEXT

    '--- rezize arrays
    IF dirsNdx > 0 THEN REDIM PRESERVE dirs$(dirsNdx - 1)
    IF filesNdx > 0 THEN REDIM PRESERVE files$(filesNdx - 1)

    '--- nothing found
    IF dirsNdx = 0 AND filesNdx = 0 THEN
        PRINT "Whoops! File not found."
        EXIT SUB
    END IF

    PrintTopLine: PRINT: PrintColSpacers

    '--- now print pretty, dir's first
    DIM col as integer: col = 0
    IF dirsNdx <> 0 THEN
	FOR ndx = 0 TO UBOUND(dirs$)
	    LocateCurCol col

	    COLOR CLR_LIGHTMAGENTA
	    PRINT LEFT$(dirs$(ndx),13) + "<DIR>";

	    col = col + 1
	    IF col = 4 THEN
            PRINT '--- new line
            PrintColSpacers
            col = 0
	    END IF
	NEXT
    END IF

    '--- now files
    IF filesNdx <> 0 THEN
        DIM fname AS STRING, fsize AS STRING
        FOR ndx = 0 TO UBOUND(files$)
            LocateCurCol col

            fname$ = LEFT$(files$(ndx),12)
            fsize$ = MID$(files$(ndx),14,14)

            SetColorAndFormat4File fname$, Trim$(fsize$)
            PRINT fname$;

            col = col + 1
            IF col = 4 THEN
                PRINT '--- new line
                PrintColSpacers
                col = 0
            END IF
        NEXT
    END IF

    IF col <> 0 THEN PRINT '--- need a new line?
    PrintBottomLine: PRINT

    '--- all done
    PrintFooter filesTotal, dirsTotal
    COLOR CLR_WHITE


END SUB


SUB PrintFooter(finfo$,dinfo$)

    '--- needs some cleanup, but works

    DIM startndx%, endndx%

    IF NOT is4DOS THEN

        '--- footer with DOS and FreeDOS

        '--- have a nice day!
        DIM o1%, o2%
        o1% = POS(0): o2% = CSRLIN
        COLOR CLR_BRIGHTWHITE
        DIM niceDay AS STRING * 80
        RSET niceDay = "* Have a nice day *"
        PRINT niceDay;
        LOCATE o2%, o1%

        '--- get total file bytes
        startndx% = INSTR(finfo$,"  ")
        endndx% = INSTRREV(finfo$," ")
        COLOR CLR_YELLOW
        PRINT LEFT$(finfo$,INSTR$(2,finfo$,"  ")) + "  ";
        COLOR CLR_RED
        PRINT strREMOVE(TRIM$(MID$(finfo$,startndx%,endndx% - startndx%)),"bytes");
        COLOR CLR_YELLOW: PRINT " bytes ";
        COLOR CLR_WHITE : PRINT " **  ";

        '--- remove dir stuff, just free bytes
        startndx% = INSTR(dinfo$,")")
        endndx% = INSTRREV(dinfo$,"by")
        COLOR CLR_RED
        PRINT TRIM$(MID$(dinfo$,startndx% + 1,endndx% - startndx% - 1));
        COLOR CLR_YELLOW: PRINT " bytes free";

    ELSEIF is4DOS THEN

        '--- footer for 4DOS

        finfo$ = TRIM$(finfo$)
        startndx% = INSTR(finfo$," ")
        COLOR CLR_RED
        PRINT RTRIM$(LEFT$(finfo$, startndx%));
        endndx% = INSTR(finfo$,"dirs")
        COLOR CLR_YELLOW
        PRINT MID$(finfo$,startndx%, endndx%);

        COLOR CLR_WHITE:  PRINT "**    ";
        dinfo$ = TRIM$(dinfo$)
        endndx% = INSTR(dinfo$," ") - 2
        COLOR CLR_RED
        PRINT LEFT$(dinfo$, endndx%);
        COLOR CLR_YELLOW: PRINT " bytes free";

    END If


END SUB


SUB SetColorAndFormat4File (filename$, filesize$)

    '--- format fname, fsize for columns

    DIM ext AS STRING * 3
    DIM extfrmt AS STRING * 4
    DIM fsFormat AS STRING * 7
    DIM fname AS STRING * 8

    LSET ext = TRIM$(MID$(filename$,9, LEN(filename$) - 7))
    LSET fname = LEFT$(filename$,8)

    RSET extfrmt = "." + ext
    RSET fsFormat = CleanUpFileSize(filesize$)

    '--- return formated filename/size (byref)
    filename$ = fname + extfrmt + fsFormat

    SetFileColor ext

END SUB


SUB SetFileColor (ext$)

    '--- ext$ is passed in as STRING * 3
    SELECT CASE ext$
        CASE "TXT", "DOC"
            COLOR CLR_WHITE
        CASE "EXE"
            COLOR CLR_LIGHTBLUE
        CASE "COM"
            COLOR CLR_GREEN
        CASE "BAT"
            COLOR CLR_RED
        CASE "BAS", "PAS", "C", "ASM", "BI "
            COLOR CLR_LIGHTGREEN
        CASE "7Z ", "ARC", "ZIP"
            COLOR CLR_BROWN
        CASE "DBF"
            COLOR CLR_MAGENTA
        CASE "IDX", "NDX", "CDX"
            COLOR CLR_LIGHTCYAN
        CASE ELSE
            COLOR CLR_CYAN
    END SELECT

END SUB


FUNCTION CleanUpFileSize$ (fsize$)

    '--- make the file size fit in the column
    DIM tmp AS SINGLE
    tmp = VAL(strRemove(fsize$, ","))

    IF tmp > 9999999 THEN
        RETURN STR$(tmp / 1024) + "m"
    ELSE
        RETURN STR$(tmp)
    END IF

END FUNCTION


SUB PrintAtCol (xCol%, txt$)
    LOCATE , xCol%
    PRINT txt$;
END SUB


SUB PrintColSpacers ()

    DIM o1%, o2%
    o1% = POS(0)
    o2% = CSRLIN
    COLOR CLR_CYAN
    PrintAtCol 20, "³"
    PrintAtCol 40, "³"
    PrintAtCol 60, "³"
    LOCATE o2%, o1%

END SUB


SUB LocateCurCol (col%)

    '--- locates cursor for columns
    SELECT CASE col%
        CASE 0: LOCATE , 0
        CASE 1: LOCATE , 21
        CASE 2: LOCATE , 41
        CASE 3: LOCATE , 61
    END SELECT

END SUB


SUB PrintBottomLine
    COLOR CLR_CYAN
    DIM o1% = CSRLIN '--- Sometimes crlf BUG!
    PrintAtCol 0, STRING$(80, "Ä")
    LOCATE o1%  '--- Sometimes BUG!
    PrintAtCol 20, "Á"
    PrintAtCol 40, "Á"
    PrintAtCol 60, "Á"
END SUB


SUB PrintTopLine
    COLOR CLR_CYAN
    DIM o1% = CSRLIN '--- Sometime crlf BUG!
    PrintAtCol 0, STRING$(80, "Ä")
    LOCATE o1%  '--- Sometime BUG!
    PrintAtCol 20, "Â"
    PrintAtCol 40, "Â"
    PrintAtCol 60, "Â"
END SUB


FUNCTION Is4DOSLoaded() AS INTEGER

   '--- see if we are using 4DOS
   DIM tmp AS STRING = ENVIRON$("COMSPEC")
   IF INSTR(UCASE$(tmp),"4DOS") THEN RETURN TRUE
   RETURN FALSE

END FUNCTION


FUNCTION IsFreeDOS() AS INTEGER

   '--- see if we are running in FreeDOS
   DIM tmp AS STRING = ENVIRON$("AUTOFILE")
   IF LEN(tmp) <> 0 THEN RETURN TRUE
   RETURN FALSE

END FUNCTION


SUB Dir2Pipe (arr$())

    DIM cmdLine AS STRING = COMMAND(1)
    cmdLine = "dir " + cmdLine

    DIM fDOSenv AS STRING

    IF isFDOS THEN

        '--- FreeDOS has ENV settings for the DIR command so save them 1st
        '--- remove the /P (pause pages) if it exists
        fDOSenv = ENVIRON$("DIRCMD")
        '--- reset the env without /P
        SetENVIRON "DIRCMD=" + LTrim(strRemove(fDOSenv,"/P"))

    ELSEIF is4DOS% THEN

      '--- set output to single col normal - ucase
      cmdLine = "": cmdLine = "dir /nej " + cmdLine

    END IF

    OPEN PIPE cmdLine FOR INPUT AS #1

    REDIM arr$(50)
    DIM ndx AS INTEGER = 0

    DO WHILE ( NOT EOF(1) )
        LINE INPUT #1, arr$(ndx)
        ndx = ndx + 1
        IF ndx =  50 THEN REDIM PRESERVE arr$(100)
        IF ndx = 100 THEN REDIM PRESERVE arr$(500)
    LOOP

    IF isFDOS THEN
        '--- restore original FreeDOS DIR env settings
        SetENVIRON "DIRCMD=" + fDOSenv
    END IF

    '--- resize array
    REDIM PRESERVE arr$(ndx)

    CLOSE #1

END SUB


