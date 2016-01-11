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

/* This program generates explicit WORKFILE definitions from file
definitions in the database.  These workfile definitions can then
be customized.

This is useful if you need a workfile to temporarily hold some,
but not all, of the fields in a database file. */
/*
HISTORY:
    mcmann      07/13/98    Added _Owner for _File finds
    tomn        12/05/95    Added spacing to frame "working" to fix 4041 
                            errors on intl windows platforms  
    hutegger    94/05/04    _decimals seems to be no longer = ? for 
                            non-decimal fields -> "decimals #" gets
                            printed only if _dtype = 5
*/
                            
{ prodict/dictvar.i }
{ prodict/user/uservar.i }

DEFINE VARIABLE lin AS CHARACTER NO-UNDO.
DEFINE STREAM code.

FORM
  SKIP(1)
  _Field._Field-name LABEL "Working on Field" AT 3
  SKIP(1)
  WITH FRAME working 
  WIDTH 58 SIDE-LABELS ROW 5 CENTERED &IF "{&WINDOW-SYSTEM}" <> "TTY"
  &THEN VIEW-AS DIALOG-BOX THREE-D &ENDIF
  TITLE "Generate DEFINE WORK-TABLE Statements".
  
COLOR DISPLAY MESSAGES _Field._Field-name WITH FRAME working.

SESSION:IMMEDIATE-DISPLAY = yes.

FIND _File WHERE _File._Db-recid = drec_db AND _File._File-name = user_filename
             AND (_File._Owner = "PUB" OR _File._Owner = "_FOREIGN").

PAUSE 0.
OUTPUT STREAM code TO VALUE(user_env[1]) NO-ECHO NO-MAP.
PUT STREAM code UNFORMATTED
  "/* " STRING(TODAY,"99/99/99") " workfile definition for table "
    _File._File-name " */" SKIP
  "/* ~{1~} = """", ""NEW"" or ""NEW SHARED"" */" SKIP
  "/* ~{2~} = """" or ""NO-UNDO"" */" SKIP(1)
  "DEFINE ~{1~} WORK-TABLE w" LC(_File._File-name)
    " ~{2~} /* LIKE " _File._File-name " */".

FOR EACH _Field OF _File:
  ACCUMULATE LENGTH(_Field._Field-name) (MAXIMUM).
END.

FOR EACH _Field OF _File:
  DISPLAY _Field._Field-name WITH FRAME working.
  lin = "  FIELD " + STRING(_Field-name,"x("
      + STRING(ACCUM MAXIMUM LENGTH(_Field._Field-name))
      + ")") + " AS " + STRING(CAPS(_Data-type),"x(9)").
  IF _Extent > 0 THEN
    lin = lin + " EXTENT " + STRING(_Extent).
  IF _dtype = 5 THEN
    lin = lin + " DECIMALS " + STRING(_Decimals).

  IF ENCODE(_Format) <> ENCODE(LC(_Format)) /* match u/l case */
    OR (_dtype = 1 AND _Format <> "x(8)")         /* character */
    OR (_dtype = 2 AND _Format <> "99/99/99")     /* date */
    OR (_dtype = 3 AND _Format <> "yes/no")       /* logical */
    OR (_dtype = 4 AND _Format <> "->,>>>,>>9")   /* integer */
    OR (_dtype = 5 AND _Format <> "->>,>>9.99")   /* decimal */
    OR (_dtype = 7 AND _Format <> ">>>>>>9") THEN /* recid */
    lin = lin + " FORMAT " + CHR(34) + _Format + CHR(34).

  IF (_dtype =  2 OR _dtype =  7) AND (_Initial = ? OR _Initial = "?") THEN .
  ELSE
  IF _dtype <> 2 AND _dtype <> 7 AND (_Initial = ? OR _Initial = "?") THEN
    lin = lin + " INITIAL ?".

  ELSE
  IF _dtype = 1 AND _Initial <> "" THEN /* character */
    lin = lin + " INITIAL " + CHR(34) + _Initial + CHR(34).

  ELSE
  IF (_dtype = 2 OR _dtype = 7) AND _Initial <> "" THEN /* date, recid */
    lin = lin + " INITIAL " + _Initial.

  ELSE /* logical */
  IF _dtype = 3 AND (_Initial <> "FALSE" AND _Initial <> "NO") THEN DO:
    IF _Initial = "TRUE" OR _Initial = "YES" THEN
      lin = lin + " INITIAL " + _Initial.
    ELSE IF INDEX(_Format,_Initial) < INDEX(_Format,"/") THEN
      lin = lin + " INITIAL TRUE".
  END.

  ELSE /* integer, decimal */
  IF (_dtype = 4 OR _dtype = 5) AND DECIMAL(_Initial) <> 0 THEN
    lin = lin + " INITIAL " + STRING(DECIMAL(_Initial)).

  IF _dtype = 1 AND _Fld-case THEN lin = lin + " CASE-SENSITIVE".

  IF _Label <> ? THEN lin = lin + " LABEL " + CHR(34) + _Label + CHR(34).
  IF _Col-label <> ? THEN
    lin = lin + " COLUMN-LABEL " + CHR(34) + _Col-label + CHR(34).

  DO WHILE ASC(SUBSTR(lin,LENGTH(lin),1)) = 32:
    lin = SUBSTR(lin,1,LENGTH(lin) - 1).
  END.
  PUT STREAM code UNFORMATTED SKIP lin.
END.
PUT STREAM code UNFORMATTED "." SKIP.
OUTPUT STREAM code CLOSE.

HIDE FRAME working NO-PAUSE.
SESSION:IMMEDIATE-DISPLAY = no.
MESSAGE "Output Completed" VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
RETURN.
