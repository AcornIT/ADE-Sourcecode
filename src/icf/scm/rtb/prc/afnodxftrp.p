&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation ("PSC"),       *
* 14 Oak Park, Bedford, MA 01730, and other contributors as listed   *
* below.  All Rights Reserved.                                       *
*                                                                    *
* The Initial Developer of the Original Code is PSC.  The Original   *
* Code is Progress IDE code released to open source December 1, 2000.*
*                                                                    *
* The contents of this file are subject to the Possenet Public       *
* License Version 1.0 (the "License"); you may not use this file     *
* except in compliance with the License.  A copy of the License is   *
* available as of the date of this notice at                         *
* http://www.possenet.org/license.html                               *
*                                                                    *
* Software distributed under the License is distributed on an "AS IS"*
* basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. You*
* should refer to the License for the specific language governing    *
* rights and limitations under the License.                          *
*                                                                    *
* Contributors:                                                      *
*                                                                    *
*********************************************************************/
/*------------------------------------------------------------------------

  File: afnodxftrp.p

  Description: Noddy Procedure to add XFTR's to all required programs

  Purpose: This noddy will read every program (.w,.i,.p) in the specified directory
           and sub-directories. For each found program, it will check for the
           existance of a line
           "&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS"
           which means it is a program we must process (a window or structured
           include/procedure). The end of this line is the name of the object we
           must use in any XFTR's we insert.

           If the program is a template, the code section starting
           &ANALYZE-SUSPEND _PROCEDURE-SETTINGS
           will contain a line starting with "   Type:" and the word "Template"
           should exist on that line if it is a template.
           Templates will have an XFTR written to above the definition section
           just below the "&Scoped-define WINDOW-NAME" to instantiate the

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Check Version Notes Wizard" procedure _INLINE
/* Actions: af/cod/aftemwizcw.w ? ? ? ? */
/* MIP Update Version Notes Wizard
Check object version notes.
af/cod/aftemwizpw.w
*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

           wizard controller on open.

           All programs will have 1 XFTR written to just above the
           ***********************  Control Definitions  *********** section
           to add the Program Definition Comment Block Wizard to the edit list
           option in the section editor.

           All programs will have 1 XFTR written to just above the 
           "&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS" line that will
           update the object name and version on save of the object.

           If the object exists in roundtable, we will read the object to get the
           current version and automatically update the definition section with
           these details.

  Parameters:   <none>

  History:
  --------
  (v:010000)    Task:          46   UserRef:    AS0
                Date:   15/01/1998  Author:     Anthony Swindells

  Update Notes: Created from Template aftemprocp.p


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

{af/sup/afproducts.i}

DEFINE STREAM ls_output.
DEFINE STREAM ls_find.
DEFINE STREAM ls_file.
DEFINE STREAM ls_inpsrc.
DEFINE STREAM ls_outsrc.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 1.99
         WIDTH              = 40.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

DEFINE VARIABLE lv_directory AS CHARACTER FORMAT "X(60)":U
    LABEL "Start Directory: " NO-UNDO.
DEFINE VARIABLE lv_recurse AS LOGICAL INITIAL YES
    LABEL "Recurse Sub-directores: " NO-UNDO.

DEFINE VARIABLE lv_file_list            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_filename             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_nopath_filename      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_line                 AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_string               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_xftr_filename        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_start_line_numbers   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_end_line_numbers     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_start_line_texts     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_end_line_texts       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_loop                 AS INTEGER NO-UNDO.
DEFINE VARIABLE lv_loop2                AS INTEGER NO-UNDO.
DEFINE VARIABLE lv_template             AS LOGICAL NO-UNDO.
DEFINE VARIABLE lv_start_posn           AS INTEGER NO-UNDO.
DEFINE VARIABLE lv_end_posn             AS INTEGER NO-UNDO.
DEFINE VARIABLE lv_object_version       AS INTEGER NO-UNDO.
DEFINE VARIABLE lv_code                 AS CHARACTER NO-UNDO.

/* Ask for start directory to process */
UPDATE lv_directory lv_recurse WITH FRAME fr_dir WITH SIDE-LABELS.
IF lv_directory = "":U THEN RETURN.

/* Turn on egg-timer */
IF SESSION:SET-WAIT-STATE("GENERAL":U) THEN PROCESS EVENTS.

/* Get a list of structured includes, procedures, and windows to process */
RUN build-directory-list (INPUT lv_directory, INPUT lv_recurse, OUTPUT lv_file_list).

/* Work on each file */
DO lv_loop = 1 TO NUM-ENTRIES(lv_file_list):

    ASSIGN lv_filename = ENTRY(lv_loop,lv_file_list)
           lv_nopath_filename = LC(TRIM(REPLACE(lv_filename,"\":U,"/":U)))
           lv_nopath_filename = SUBSTRING(lv_nopath_filename,R-INDEX(lv_nopath_filename,"/":U) + 1)
           lv_template = NO.

    PAUSE 0.
    DISPLAY "Working on File: " + lv_filename FORMAT "X(75)":U
            WITH 15 DOWN RETAIN 14 FRAME fr_x.
    DOWN WITH FRAME fr_x.

    /* Get XFTR filename */
    RUN find-text-in-file ( INPUT   lv_filename,
                            INPUT   "&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS":U,
                            OUTPUT  lv_start_line_numbers,
                            OUTPUT  lv_start_line_texts).
    ASSIGN lv_string = LC(TRIM(ENTRY(1,lv_start_line_texts,"|":U)))
           lv_start_posn = R-INDEX(lv_string," ":U) + 1
           lv_xftr_filename = SUBSTRING(lv_string,lv_start_posn).

    /* See if it is a template */
    RUN find-text-in-file ( INPUT   lv_filename,
                            INPUT   "&ANALYZE-SUSPEND _PROCEDURE-SETTINGS":U,
                            OUTPUT  lv_start_line_numbers,
                            OUTPUT  lv_start_line_texts).
    RUN find-text-in-file ( INPUT   lv_filename,
                            INPUT   "&ANALYZE-RESUME _END-PROCEDURE-SETTINGS":U,
                            OUTPUT  lv_end_line_numbers,
                            OUTPUT  lv_end_line_texts).
    IF NUM-ENTRIES(lv_start_line_numbers) > 0 THEN
      DO:
        INPUT STREAM ls_file FROM VALUE(lv_filename) NO-ECHO.
        FILE-LINE:
        DO lv_loop2 = 1 TO INTEGER(ENTRY(1,lv_end_line_numbers)):
            IMPORT STREAM ls_file UNFORMATTED lv_line.
            IF lv_loop2 < INTEGER(ENTRY(1,lv_start_line_numbers))
                THEN NEXT FILE-LINE.           
            IF INDEX(TRIM(lv_line),"Type:":U) <> 0 AND
               INDEX(TRIM(lv_line),"Template":U) <> 0 THEN
              DO:
                ASSIGN lv_template = YES.
                LEAVE FILE-LINE.
              END.
        END.
        INPUT STREAM ls_file CLOSE.
      END.

    /* Read object version from Roundtable if possible */
    /* Find current version of object in the workspace */
    FIND FIRST rtb_object WHERE   rtb_object.obj-type = "PCODE":U
                            AND   rtb_object.object = lv_nopath_filename
                          NO-LOCK NO-ERROR.

    IF AVAILABLE rtb_object THEN
        ASSIGN lv_object_version = rtb_object.version.
    ELSE

    ASSIGN lv_object_version = 0.

    /* All information gathered - Add XFTR's */

    /* If the object does not already contain an XFTR to update the comment
       part of the definition section called af/cod/aftemwizpw.w,
       then add it */
    RUN find-text-in-file ( INPUT   lv_filename,
                            INPUT   "af/cod/aftemwizpw.w":U,
                            OUTPUT  lv_start_line_numbers,
                            OUTPUT  lv_start_line_texts).
    IF NUM-ENTRIES(lv_start_line_numbers) = 0 THEN
      DO:
        /* Add template XFTR just after "&Scoped-define WINDOW-NAME" */
        RUN find-text-in-file ( INPUT   lv_filename,
                                INPUT   "&Scoped-define WINDOW-NAME":U,
                                OUTPUT  lv_start_line_numbers,
                                OUTPUT  lv_start_line_texts).
        IF INTEGER(ENTRY(1,lv_start_line_numbers)) = 0 THEN
          DO:
            RUN find-text-in-file ( INPUT   lv_filename,
                                    INPUT   "&ANALYZE-RESUME":U,
                                    OUTPUT  lv_start_line_numbers,
                                    OUTPUT  lv_start_line_texts).
          END.        

        /* Assign contents of include file to variable with CHR(10)'s in */
        ASSIGN lv_code = "":U.
        INPUT STREAM ls_file FROM VALUE(SEARCH("af/sup/aftemxftrp.i":U)) NO-ECHO.
        REPEAT:
            IMPORT STREAM ls_file UNFORMATTED lv_line.
            ASSIGN lv_code = lv_code + REPLACE(lv_line,"xftr-name":U,lv_xftr_filename) +
                             CHR(10).
        END.
        INPUT STREAM ls_file CLOSE.

        RUN add-code-section (  INPUT   lv_filename,
                                INPUT   lv_code,
                                INPUT   INTEGER(ENTRY(1,lv_start_line_numbers)),
                                INPUT   INTEGER(ENTRY(1,lv_start_line_numbers)) + 1).
      END.

    /* If it is a template and it does not already contain an XFTR with the 
       information wizard af/cod/aftemwiziw.w in it, then this must be
       added. Only creation wizards will have this information wizard in them and
       these creation wizards must only exist in templates */
    IF lv_template = YES THEN
      DO:
        RUN find-text-in-file ( INPUT   lv_filename,
                                INPUT   "af/cod/aftemwiziw.w":U,
                                OUTPUT  lv_start_line_numbers,
                                OUTPUT  lv_start_line_texts).
        IF NUM-ENTRIES(lv_start_line_numbers) = 0 THEN
          DO:
            /* Add template XFTR just after "&Scoped-define WINDOW-NAME" */
            RUN find-text-in-file ( INPUT   lv_filename,
                                    INPUT   "&Scoped-define WINDOW-NAME":U,
                                    OUTPUT  lv_start_line_numbers,
                                    OUTPUT  lv_start_line_texts).
            IF INTEGER(ENTRY(1,lv_start_line_numbers)) = 0 THEN
              DO:
                RUN find-text-in-file ( INPUT   lv_filename,
                                        INPUT   "&ANALYZE-RESUME":U,
                                        OUTPUT  lv_start_line_numbers,
                                        OUTPUT  lv_start_line_texts).
              END.        

            /* Assign contents of include file to variable with CHR(10)'s in */
            ASSIGN lv_code = "":U.
            INPUT STREAM ls_file FROM VALUE(SEARCH("af/sup/aftemxftrc.i":U)) NO-ECHO.
            REPEAT:
                IMPORT STREAM ls_file UNFORMATTED lv_line.
                ASSIGN lv_code = lv_code + REPLACE(lv_line,"xftr-name":U,lv_xftr_filename) +
                                 CHR(10).
            END.
            INPUT STREAM ls_file CLOSE.

            /* Add code section to file */
            RUN add-code-section (  INPUT   lv_filename,
                                    INPUT   lv_code,
                                    INPUT   INTEGER(ENTRY(1,lv_start_line_numbers)),
                                    INPUT   INTEGER(ENTRY(1,lv_start_line_numbers)) + 1).
          END.
      END.

    /* If the object does not already contain an XFTR to update the object
       version called af/sup/afverxftrp.p, then add it */
    RUN find-text-in-file ( INPUT   lv_filename,
                            INPUT   "af/sup/afverxftrp.p":U,
                            OUTPUT  lv_start_line_numbers,
                            OUTPUT  lv_start_line_texts).
    IF NUM-ENTRIES(lv_start_line_numbers) = 0 THEN
      DO:
        /* Add object version XFTR just after "&Scoped-define WINDOW-NAME" */
        RUN find-text-in-file ( INPUT   lv_filename,
                                INPUT   "&Scoped-define WINDOW-NAME":U,
                                OUTPUT  lv_start_line_numbers,
                                OUTPUT  lv_start_line_texts).
        IF INTEGER(ENTRY(1,lv_start_line_numbers)) = 0 THEN
          DO:
            RUN find-text-in-file ( INPUT   lv_filename,
                                    INPUT   "&ANALYZE-RESUME":U,
                                    OUTPUT  lv_start_line_numbers,
                                    OUTPUT  lv_start_line_texts).
          END.        

        /* Assign contents of include file to variable with CHR(10)'s in */
        ASSIGN lv_code = "":U.
        INPUT STREAM ls_file FROM VALUE(SEARCH("af/sup/aftemxftro.i":U)) NO-ECHO.
        REPEAT:
            IMPORT STREAM ls_file UNFORMATTED lv_line.
            ASSIGN lv_code = lv_code + REPLACE(lv_line,"xftr-name":U,lv_xftr_filename) +
                             CHR(10).
        END.
        INPUT STREAM ls_file CLOSE.

        /* Add code section to file */
        RUN add-code-section (  INPUT   lv_filename,
                                INPUT   lv_code,
                                INPUT   INTEGER(ENTRY(1,lv_start_line_numbers)),
                                INPUT   INTEGER(ENTRY(1,lv_start_line_numbers)) + 1).
      END.

    /* If the object does not already contain pre-processors for the object-name
       and object-version, then add them with the current RTB version number for
       the object if we can. The code to insert is in the file
       af/sup/aftemobjvn.i*/
    RUN find-text-in-file ( INPUT   lv_filename,
                            INPUT   "&scop object-name":U,
                            OUTPUT  lv_start_line_numbers,
                            OUTPUT  lv_start_line_texts).
    IF NUM-ENTRIES(lv_start_line_numbers) = 0 THEN
      DO:
        /* Add pre-processors just after "******************  Definitions" or
           This .W file was created with the Progress UIB. */
        RUN find-text-in-file ( INPUT   lv_filename,
                                INPUT   "******************  Definitions":U,
                                OUTPUT  lv_start_line_numbers,
                                OUTPUT  lv_start_line_texts).
        IF INTEGER(ENTRY(1,lv_start_line_numbers)) = 0 THEN
          DO:
            RUN find-text-in-file ( INPUT   lv_filename,
                                    INPUT   "This .W file was created with the Progress UIB.":U,
                                    OUTPUT  lv_start_line_numbers,
                                    OUTPUT  lv_start_line_texts).
            IF INTEGER(ENTRY(1,lv_start_line_numbers)) <> 0 THEN
              ASSIGN ENTRY(1,lv_start_line_numbers) = STRING(INTEGER(ENTRY(1,lv_start_line_numbers)) + 1).
          END.        
        IF INTEGER(ENTRY(1,lv_start_line_numbers)) <> 0 THEN
          DO:
            /* Assign contents of include file to variable with CHR(10)'s in */
            ASSIGN lv_code = "":U.
            INPUT STREAM ls_file FROM VALUE(SEARCH("af/sup/aftemobjvn.i":U)) NO-ECHO.
            REPEAT:
                IMPORT STREAM ls_file UNFORMATTED lv_line.
                IF INDEX(lv_line,"&scop object-name":U) > 0 THEN
                    ASSIGN lv_line = TRIM(lv_line) + "       ":U + lv_nopath_filename.
                IF INDEX(lv_line,"DEFINE VARIABLE lv_this_object_name AS CHARACTER INITIAL "{&object-name}":U NO-UNDO.
&scop object-version":U) > 0 THEN
                    ASSIGN lv_line = TRIM(lv_line) + "    ":U + STRING(lv_object_version,"999999":U).

                ASSIGN lv_code = lv_code + lv_line + CHR(10).
            END.
            INPUT STREAM ls_file CLOSE.

            /* Add code section to file */
            RUN add-code-section (  INPUT   lv_filename,
                                    INPUT   lv_code,
                                    INPUT   INTEGER(ENTRY(1,lv_start_line_numbers)),
                                    INPUT   INTEGER(ENTRY(1,lv_start_line_numbers)) + 1).
          END.
      END.

END.    /* DO lv_loop = 1 TO NUM-ENTRIES(lv_file_list): */

/* Turn off egg-timer */
IF SESSION:SET-WAIT-STATE("":U) THEN PROCESS EVENTS.

RETURN.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-code-section Procedure 
PROCEDURE add-code-section :
/*------------------------------------------------------------------------------
  Purpose:     To add a code section to a file
  Parameters:  INPUT    ip_filename
               INPUT    ip_new_code_section
               INPUT    ip_before_code_line_number
               INPUT    ip_after_code_line_number
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER  ip_filename                 AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  ip_new_code_section         AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  ip_before_code_line_number  AS INTEGER      NO-UNDO.
DEFINE INPUT PARAMETER  ip_after_code_line_number   AS INTEGER      NO-UNDO.

DEFINE VARIABLE         lv_loop                     AS INTEGER      NO-UNDO.
DEFINE VARIABLE         lv_posn                     AS INTEGER      NO-UNDO.
DEFINE VARIABLE         lv_output_filename          AS CHARACTER    NO-UNDO.
DEFINE VARIABLE         lv_line                     AS CHARACTER    NO-UNDO.

ASSIGN
    lv_output_filename = ip_filename + ".mip".

OUTPUT STREAM ls_outsrc TO VALUE(lv_output_filename).
INPUT STREAM ls_inpsrc FROM VALUE(ip_filename) NO-ECHO.

ASSIGN lv_loop = 0.
REPEAT:
    IMPORT STREAM ls_inpsrc UNFORMATTED lv_line.
    ASSIGN lv_loop = lv_loop + 1.
    IF lv_loop <= ip_before_code_line_number OR
       lv_loop > ip_after_code_line_number THEN
        DO:
            IF lv_line <> "" THEN
                PUT STREAM ls_outsrc UNFORMATTED lv_line SKIP.
            ELSE
                PUT STREAM ls_outsrc UNFORMATTED SKIP(1).
        END.
    ELSE
      DO:
        /* Add new code section here */
        PUT STREAM ls_outsrc UNFORMATTED ip_new_code_section SKIP.
        IF lv_line <> "" THEN
            PUT STREAM ls_outsrc UNFORMATTED lv_line SKIP.
        ELSE
            PUT STREAM ls_outsrc UNFORMATTED SKIP(1).
      END.
END.
INPUT STREAM ls_inpsrc CLOSE.
OUTPUT STREAM ls_outsrc CLOSE.

/* copy temp file over original file and then delete temp file */
OS-COPY VALUE(lv_output_filename) VALUE(ip_filename).
OS-DELETE VALUE(lv_output_filename).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE build-directory-list Procedure 
PROCEDURE build-directory-list :
/*------------------------------------------------------------------------------
  Purpose:     Output a list of Progress source files (*.w,*.i,*.p) for the
               passed in directory and all its sub-directories. Only returns
               files that are structured includes, procedures, or windows ! 
  Parameters:  INPUT    ip_directory
               OUTPUT   op_file_list
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER  ip_directory    AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  ip_recurse      AS LOGICAL      NO-UNDO.
DEFINE OUTPUT PARAMETER op_file_list    AS CHARACTER    NO-UNDO.

DEFINE VARIABLE         lv_batchfile    AS CHARACTER    NO-UNDO.
DEFINE VARIABLE         lv_outputfile   AS CHARACTER    NO-UNDO.
DEFINE VARIABLE         lv_filename     AS CHARACTER    NO-UNDO.
DEFINE VARIABLE         lv_line_numbers AS CHARACTER    NO-UNDO.
DEFINE VARIABLE         lv_line_texts   AS CHARACTER    NO-UNDO.
DEFINE VARIABLE         lv_recurse      AS CHARACTER    NO-UNDO.

DISPLAY "Building file list..." SKIP(1) WITH FRAME fr_dir .

/* Write batch file to do a directory listing of all *.p, *.w, *.i files in
   the directory tree specified */
ASSIGN
    lv_batchfile  = SESSION:TEMP-DIRECTORY + "dir.bat":U
    lv_outputfile = SESSION:TEMP-DIRECTORY + "dir.log":U
    ip_directory = LC(TRIM(REPLACE(ip_directory,"/":U,"\":U)))
    lv_recurse = (IF ip_recurse = YES THEN "/s ":U ELSE " ":U).

OUTPUT TO VALUE(lv_batchfile).
PUT UNFORMATTED "dir /b/l/on":U + lv_recurse + ip_directory + "\*.w > ":U + lv_outputfile SKIP.
PUT UNFORMATTED "dir /b/l/on":U + lv_recurse + ip_directory + "\*.p >> ":U + lv_outputfile SKIP.
PUT UNFORMATTED "dir /b/l/on":U + lv_recurse + ip_directory + "\*.i >> ":U + lv_outputfile SKIP.
OUTPUT CLOSE.

/* Execute batch file */
OS-COMMAND SILENT VALUE(lv_batchfile).

/* Check result */
IF SEARCH(lv_outputfile) <> ? THEN
  DO:
    INPUT STREAM ls_output FROM VALUE(lv_outputfile) NO-ECHO.
    REPEAT:
        IMPORT STREAM ls_output UNFORMATTED lv_filename.
        IF ip_recurse  = NO THEN ASSIGN lv_filename = ip_directory + "\":U + lv_filename.
        RUN find-text-in-file ( INPUT   lv_filename,
                                INPUT   "&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS":U,
                                OUTPUT  lv_line_numbers,
                                OUTPUT  lv_line_texts).
        IF NUM-ENTRIES(lv_line_numbers) > 0 THEN
          ASSIGN
            op_file_list =  op_file_list +
                            (IF NUM-ENTRIES(op_file_list) > 0 THEN ",":U ELSE "":U) +
                            LC(TRIM(lv_filename)).
    END.
    INPUT STREAM ls_output CLOSE.
  END.

/* Delete temp files */
OS-DELETE VALUE(lv_batchfile).
OS-DELETE VALUE(lv_outputfile). 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-text-in-file Procedure 
PROCEDURE find-text-in-file :
/*------------------------------------------------------------------------------
  Purpose:     To search the specified file for the specified text and return
               the line numbers of the found text in a comma seperated list,
               and the actual text lines in a | delimited list.
  Parameters:  INPUT    ip_filename
               INPUT    ip_text
               OUTPUT   op_line_numbers
               OUTPUT   op_line_texts
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER  ip_filename     AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER  ip_text         AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER op_line_numbers AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER op_line_texts   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lv_command              AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_findlog              AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_output               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lv_number               AS INTEGER NO-UNDO.
DEFINE VARIABLE lv_start_posn           AS INTEGER NO-UNDO.
DEFINE VARIABLE lv_end_posn             AS INTEGER NO-UNDO.

ASSIGN  lv_findlog = SESSION:TEMP-DIRECTORY + "findtext.log":U
        lv_command = "FIND /N /I ":U + '"' + ip_text + '"' + " ":U + ip_filename + " > ":U + lv_findlog.

OS-DELETE VALUE(lv_findlog).
OS-COMMAND SILENT VALUE(lv_command).        
ASSIGN op_line_numbers = "":U.

IF SEARCH(lv_findlog) <> ? THEN
  DO:
    INPUT STREAM ls_find FROM VALUE(lv_findlog) NO-ECHO.
    REPEAT:
        IMPORT STREAM ls_find UNFORMATTED lv_output.
        ASSIGN
            lv_start_posn = INDEX(lv_output,"[":U)
            lv_end_posn = INDEX(lv_output,"]":U).
        IF lv_start_posn = 0 OR lv_end_posn = 0 OR lv_end_posn <= lv_start_posn THEN NEXT.
        ASSIGN op_line_numbers =    op_line_numbers +
                                    (IF NUM-ENTRIES(op_line_numbers) > 0 THEN ",":U ELSE "":U) +
                                    SUBSTRING(lv_output,lv_start_posn + 1,lv_end_posn - lv_start_posn - 1).
               op_line_texts =      op_line_texts +
                                    (IF NUM-ENTRIES(op_line_texts,"|":U) > 0 THEN "|":U ELSE "":U) +
                                    TRIM(REPLACE(lv_output,"|":U," PIPE ":U)).
    END.
    INPUT STREAM ls_find CLOSE.
  END.

OS-DELETE VALUE(lv_findlog).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

