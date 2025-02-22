/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/

/*----------------------------------------------------------------------------

File: _gendefs.p

Description:
    Procedure called by _gen4gl.p and _writedf.p to generate the frame
    and widget definitions of  a web-objectfile.  
   
    When called from _writedf.p it is intended write code for checking
    QUERY syntax (from the query builder).  In that case we don't want
    put out the existing query definition, so we need to skip queries.

Preprocessor Parameters:

Input Parameters:
    p_proc-id    = Context id of the current procedure
    p_status     = used to check status of _U records
    skip_queries = IF DEFINED, don't write out queries.

Output Parameters:
   <None>

Author: Wm.T.Wood [from adeuib/_gendefs.p by D. Ross Hunter]
Created: 1/31/97
Updated: 2/13/98 adams Modified for Skywalker

---------------------------------------------------------------------------- */

DEFINE INPUT PARAMETER p_proc-id    AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p_status     AS CHAR    NO-UNDO.
DEFINE INPUT PARAMETER skip_queries AS LOGICAL NO-UNDO.

/* Include files */
{ adeweb/htmwidg.i }     /* HTML Field TEMP-TABLE definition               */
{ adeuib/sharvars.i }    /* Shared variables                               */
{ adeuib/uniwidg.i }     /* Universal Widget TEMP-TABLE definition         */
{ adeuib/triggers.i }
{ adeweb/genshar.i}      /* Shared variable definitions                    */
{ adeuib/layout.i }

DEFINE SHARED STREAM P_4GL.
 
/* Local Definitions --                                   */
DEFINE VARIABLE define_type    AS CHARACTER        NO-UNDO.
DEFINE VARIABLE frame_layer    AS RECID            NO-UNDO.
DEFINE VARIABLE ix             AS INTEGER          NO-UNDO.
DEFINE VARIABLE l_dummy        AS LOGICAL          NO-UNDO.
DEFINE VARIABLE l_scrap        AS LOGICAL          NO-UNDO.
DEFINE VARIABLE tmp_db         AS CHARACTER        NO-UNDO.
DEFINE VARIABLE tmp_name       AS CHARACTER        NO-UNDO.
DEFINE VARIABLE tmp_string     AS CHARACTER        NO-UNDO.
DEFINE VARIABLE tmp_tbl        AS CHARACTER        NO-UNDO.

DEFINE TEMP-TABLE acopy
  FIELD _u-recid AS RECID
  INDEX _u-recid IS PRIMARY UNIQUE _u-recid.

DEFINE TEMP-TABLE defined
  FIELD _name      AS CHAR
  FIELD _data-type AS CHAR
  FIELD _type      AS CHAR
  INDEX _name IS PRIMARY UNIQUE _name.

DEFINE BUFFER x_F  FOR _F.
DEFINE BUFFER x_Q  FOR _Q.
DEFINE BUFFER x_U  FOR _U.
DEFINE BUFFER xx_U FOR _U.

&SCOPED-DEFINE debug FALSE

/* Include 4GL utility functions to 4gl-encode a string. Use this 
   around any string we are planning on saving. */
{ adeweb/util4gl.i }

/* Find the current procedure that we are creating definitions for. */
FIND _P WHERE RECID(_P) eq p_proc-id.

/* If there are no widgets then we're finished generating definitions. */
IF NOT CAN-FIND(FIRST _U WHERE _U._WINDOW-HANDLE eq _P._WINDOW-HANDLE
                           AND _U._STATUS        eq u_status) THEN RETURN.

/* ************************************************************************* */
/*                                                                           */
/*                      DEFINITION OF THE FORM BUFFER                        */
/*                                                                           */
/* ************************************************************************* */

PUT STREAM P_4GL UNFORMATTED SKIP (1)
  "&ANALYZE-SUSPEND _FORM-BUFFER":U SKIP(1).

/* ************************************************************************** */
/*                                                                            */
/*                           WIDGET DEFINITIONS                               */
/*                                                                            */
/* ************************************************************************** */
IF CAN-FIND(FIRST _U WHERE _U._WINDOW-HANDLE eq _P._WINDOW-HANDLE) THEN
  PUT STREAM P_4GL UNFORMATTED SKIP (1)
    "/* Definitions of the field level widgets                               */":U
    SKIP.

/* Cycle through the frames for this procedure                               */
FOR EACH _U WHERE _U._WINDOW-HANDLE eq _P._WINDOW-HANDLE
  AND CAN-DO("FRAME,DIALOG-BOX",_U._TYPE) USE-INDEX _OUTPUT:

  /* Cycle through the field-level widgets for this frame to create the       */
  /* widget definitions, be carefull not to create definitions for text       */
  /* widgets as they are displayed as literals in the frame.                  */
  frame_layer = RECID (_U).
  DEFINE-BLK:
  FOR EACH x_U WHERE x_U._parent-recid eq frame_layer
                 AND x_U._STATUS       eq u_status
                 AND x_U._DEFINED-BY   eq "Tool":U
                 AND x_U._TABLE        eq ? USE-INDEX _OUTPUT,
      EACH _F WHERE RECID(_F) = x_U._x-recid:

    /* Lots of widgets are really defined as variables.  Only a few are a
       distinct widget type. (i.e. We can have a fill-in and a toggle with
       the same name, but not an image and a variable.) */
    define_type = (IF CAN-DO("BUTTON,RECTANGLE,IMAGE", x_U._TYPE)
                   THEN x_U._TYPE ELSE "VARIABLE":U).

    /* Make sure that this object hasn't already been defined.  A variable 
       is the only exception. It can be used in multiple windows (as long as
       the datatype does not conflict).  */
    FIND defined WHERE defined._name = x_U._NAME NO-ERROR.
    IF AVAILABLE defined THEN DO:
      IF (define_type NE "VARIABLE") OR
         (defined._type NE define_type) THEN DO:
        RUN adeweb/_bstname.p (x_U._NAME, ?,  p_proc-id, OUTPUT tmp_name).
        RUN adecomm/_s-alert.p (INPUT-OUTPUT l_scrap, "warning":U, "ok":U,
          SUBSTITUTE ("The name for &2 &1 has already been used." +
                      "Renaming &2 &1 to &3.",  x_U._NAME,  x_U._TYPE, tmp_name)).
        /*
        MESSAGE 
          x_U._TYPE x_U._NAME "name conflicts with the" SKIP
          "previously defined" defined._type defined._name + "." SKIP (1)
          "Renaming" x_U._TYPE x_U._NAME "to" tmp_name + "."
          VIEW-AS ALERT-BOX WARNING BUTTONS OK.
        */
        x_U._NAME = tmp_name.
      END.
      ELSE IF define_type = "VARIABLE":U AND 
        (defined._data-type NE _F._DATA-TYPE) THEN DO:
        RUN adeweb/_bstname.p (x_U._NAME, ?, p_proc-id, OUTPUT tmp_name).
        RUN adecomm/_s-alert.p (INPUT-OUTPUT l_scrap, "warning":U, "sok":U,
          SUBSTITUTE ("Variable &1 is defined in two frames with two different datatypes." +
                      "Renaming &2 &1 to &3.",  x_U._NAME,  x_U._TYPE, tmp_name)).
         x_U._NAME = tmp_name.
      END.
      ELSE DO:
        /* Note the copy */
        CREATE acopy.
        ASSIGN acopy._u-recid = RECID(x_U).
        NEXT DEFINE-BLK.
      END.
    END.
    CREATE defined.
    ASSIGN defined._name      = x_U._NAME
           defined._data-type = _F._DATA-TYPE
           defined._type      = define_type.

    /* Make sure that this object isn't an array that has already been been defined. */
    IF _F._SUBSCRIPT < 0 THEN NEXT DEFINE-BLK.

    /* DEPENDING on TYPE this section puts out one of the following:          */
    /* BUTTON         - DEFINE BUTTON   blah                                  */
    /* COMBO-BOX      - DEFINE VARIABLE blah AS data-typ 
                                          FORMAT fnt VIEW-AS COMBO-BOX        */
    /* EDITOR         - DEFINE VARIABLE blah AS CHAR VIEW-AS EDITOR           */
    /* FILL-IN        - DEFINE VARIABLE blah AS CHAR 
                                          FORMAT fnt VIEW-AS FILL-IN          */
    /* RADIO-SET      - DEFINE VARIABLE blah AS data-tp LABEL VIEW-AS
                                        RADIO-SET HORIZONTAL EXPAND buttons   */
    /* SELECTION-LIST - DEFINE VARIABLE blah AS CHAR VIEW-AS SELECTION-LIST   */
    /* SLIDER         - DEFINE VARIABLE blah AS INTEGER VIEW-AS SLIDER        */
    /* TOGGLE-BOX     - DEFINE VARIABLE blah AS LOGICAL VIEW-AS TOGGLE-BOX    */

    tmp_name = IF _F._SUBSCRIPT > 0 THEN
                 SUBSTRING(x_U._NAME,1,INDEX(x_U._NAME,"[") - 1,"CHARACTER":U)
               ELSE x_U._NAME.
               
    IF define_type NE "VARIABLE":U THEN
      PUT STREAM P_4GL UNFORMATTED "DEFINE ":U define_type " ":U tmp_name.
    ELSE DO:
      /* Error checking */
      IF _F._FORMAT-ATTR eq ? THEN _F._FORMAT-ATTR = ?.
      PUT STREAM P_4GL UNFORMATTED
        "DEFINE VARIABLE " tmp_name " AS " CAPS(_F._DATA-TYPE)
        IF CAN-DO("FILL-IN,COMBO-BOX", x_U._TYPE) AND _F._FORMAT ne ? THEN
          (" FORMAT ~"" + 4GL-encode (_F._FORMAT) + "~"" +
          (IF _F._FORMAT-ATTR NE "" THEN ":":U + _F._FORMAT-ATTR ELSE "") + " ":U)
        ELSE " ".
           
      IF _F._INITIAL-DATA NE "" THEN 
      INITIAL-VALUE-BLK:
      DO:
        IF x_U._TYPE = "RADIO-SET":U AND _F._INITIAL-DATA = ? THEN
          LEAVE INITIAL-VALUE-BLK.
        tmp_string = _F._INITIAL-DATA.
        /* For logical fill-ins, determine if initial value is yes or no based on format.
         * (i.e. for format "GUI/TTY" 'GUI' is not a legal initial value, 'yes' is. */          
        IF CAN-DO("FILL-IN,COMBO-BOX":U, x_U._TYPE) AND _F._DATA-TYPE = "Logical":U THEN DO:
          tmp_string = IF ENTRY (1, _F._FORMAT, "/") EQ _F._INITIAL-DATA THEN "YES":U
                       ELSE "NO":U.
        END.
        /* Quote this if an character. */
        IF _F._DATA-TYPE eq "Character":U THEN
          tmp_string = "~"" + 4GL-encode(tmp_string) +  "~"".
          
        /* Note that this TRIM won't remove leading (or trailing) spaces on
           character values because of the quotes added in the last line.
           It only trims non-character values for neatness. */
        PUT STREAM P_4GL UNFORMATTED "INITIAL ":U  TRIM(tmp_string) " ":U.
      END. /* IF...INITIAL-DATA... */
    END. /* IF..VARIABLE  */

    IF _F._SUBSCRIPT > 0 THEN DO:
      { adeweb/defextnt.i }
    END.

    /* Put the view-as phrase for variables - this also puts size */
    RUN put_view-as ("     ":U).
      
    /* Add NO-UNDO to Variables. */
    IF define_type eq "VARIABLE":U THEN
      PUT STREAM P_4GL UNFORMATTED " NO-UNDO":U.

    /* Close out the 4GL statement. */
    PUT STREAM P_4GL UNFORMATTED ".":U SKIP (1).
    
  END.  /* For each field level widget DEFINE-BLK */
END.  /* For each frame in the procedure */

/* Have the subscripts revert to positive numbers                            */
FOR EACH _F WHERE _F._SUBSCRIPT < 0:
  _F._SUBSCRIPT = -1 * _F._SUBSCRIPT.
END.

/* ************************************************************************* */
/*                                                                           */
/*                            QUERY DEFINITIONS                              */
/*                                                                           */
/* ************************************************************************* */

IF NOT skip_queries THEN DO:
  l_dummy = YES. /* Flag to set if this is the first valid query */
  FOR EACH _U WHERE _U._WINDOW-HANDLE eq _P._WINDOW-HANDLE
                AND _U._TYPE          eq "QUERY":U
                AND _U._STATUS        eq u_status USE-INDEX _OUTPUT,
      EACH _C WHERE RECID(_C)         eq _U._x-recid,
      EACH _Q WHERE RECID(_Q)         eq _C._q-recid:
  
    /* Note: we only make shared queries for browsers.  Shared frames do NOT
       have shared queries (This is an arbitrary limitation - wood 1/7/94) */
    IF _Q._TblList NE "" THEN DO:
      /* Put out a header line if this is the first one */
      IF l_dummy THEN DO:  /* we haven't done the first yet */
        PUT STREAM P_4GL UNFORMATTED 
          SKIP 
          "/* Query definitions                                                    */"
          SKIP.
      END.  /* If l_dummy */
  
      IF NOT l_dummy THEN PUT 
        STREAM P_4GL UNFORMATTED SKIP (1).
      l_dummy = NO. /* Don't do this again */
      
      PUT STREAM P_4GL UNFORMATTED SKIP "DEFINE QUERY " _U._NAME " FOR " SKIP.
      
      DO ix = 1 TO NUM-ENTRIES(_Q._TblList):
        tmp_string = ENTRY (1, TRIM (ENTRY (ix,_Q._TblList)), " ").
        IF NUM-ENTRIES(tmp_string,".":U) > 1 AND _suppress_dbname THEN
          tmp_string = ENTRY(2,tmp_string,".").
        IF _Q._TblOptList NE ""                        AND 
           INDEX(ENTRY(ix,_Q._TblOptList),"USED":U) > 0 THEN 
        DO: /* NOTE: A Field List is not written out for a Freeform Query */
          /* Make a Field List */
          ASSIGN tmp_db     = ENTRY(1, ENTRY(1, TRIM(ENTRY(ix,_Q._TblList)), " "), ".")
                 tmp_tbl    = ENTRY(2, ENTRY(1, TRIM(ENTRY(ix,_Q._TblList)), " "), ".")
                 tmp_string = tmp_string + CHR(10) + "    FIELDS(":U.
          ASSIGN tmp_string = TRIM(tmp_string) + ")":U.
        END.
        PUT STREAM P_4GL UNFORMATTED "      " tmp_string
            IF ix = NUM-ENTRIES(_Q._TblList) THEN " SCROLLING." ELSE ", " SKIP.
      END.                           
    END. /* Valid _TblList */
  END. /* FOR EACH query */  
END. /* IF NOT skip_queries... */


/* ************************************************************************* */
/*                                                                           */
/*                            FRAME DEFINITIONS                              */
/*                                                                           */
/* ************************************************************************* */
/* Define the frames for this window                                         */
PUT STREAM P_4GL UNFORMATTED SKIP (1)
   "/* ************************  Frame Definitions  *********************** */"
    SKIP (1).

/* Write out the DEFINE FRAME statements.  Note the special case of a DIALOG-BOX
   where we need to pass in the "dummy" design window parent. */
FOR EACH _U WHERE _U._WINDOW-HANDLE eq _P._WINDOW-HANDLE
              AND _U._TYPE          eq "FRAME":U:
  RUN put-frame-definitions-in (RECID(_U)).
  PUT STREAM P_4GL UNFORMATTED " ":U SKIP.
END.

/* Close the section. */
PUT STREAM P_4GL UNFORMATTED SKIP (1)
"&ANALYZE-RESUME" SKIP(1).

/* * * * * * * * * * * * * * Internal Procedures * * * * * * * * * * * * * * */

/* put-frame-definitions-in - Write out the frame definition for each of the
 *     frames that are children of the object. 
 */
PROCEDURE put-frame-definitions-in :
  DEFINE INPUT PARAMETER p_parent-recid AS RECID NO-UNDO.

  DEFINE VARIABLE empty_frame    AS LOGICAL       NO-UNDO.

  FIND _U WHERE RECID(_U) eq p_parent-recid NO-ERROR.
  IF AVAILABLE _U AND _U._TYPE eq "FRAME":U THEN DO:
      
    /* Limit the frame definition to 4K. */ 
    ASSIGN stmnt_strt   = SEEK(P_4GL)
           empty_frame  = yes.
    PUT STREAM P_4GL UNFORMATTED "DEFINE FRAME " _U._NAME SKIP.
    
    /* Look through the widgets that we are going to have to define in
        the frame itself. */
    WIDGET-LOOP:
    FOR EACH x_U WHERE x_U._parent-recid eq p_parent-recid
                    AND NOT CAN-DO("FRAME,QUERY":U, x_U._TYPE)
                    AND x_U._STATUS EQ u_status 
                 BY x_U._NAME BY x_U._TABLE BY x_U._DBNAME BY x_U._TYPE:
 
      FIND _F WHERE RECID(_F) eq x_U._x-recid.    
      
      /* The frame IS not empty, (so don't size to fit). */
      empty_frame = no.
      IF SEEK(P_4GL) - stmnt_strt > 3300 THEN DO:  /* DEF FRAME statement is  */
        stmnt_strt = SEEK(P_4GL).                  /* getting too long, break */
        PUT STREAM P_4GL UNFORMATTED ".":U SKIP
        "/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */":U
        SKIP.
        PUT STREAM P_4GL UNFORMATTED "DEFINE FRAME ":U _U._NAME SKIP. 
      END.
      /* Now display the variable. */
      PUT STREAM P_4GL UNFORMATTED
        "     ":U { adeweb/name_u.i &U_BUFFER = "x_U" } .
             
      RUN put_help_msg.
         
      /* Add label, format, view-as phrase and color to database fields to
         variables that are defined multiple times or are defined in the
         database. */
      FIND acopy WHERE acopy._u-recid = RECID(x_U) NO-ERROR.
      IF AVAILABLE acopy OR (x_U._TABLE <> ?) THEN DO:
        /* Special fill-in attributes                                      */
        IF CAN-DO("FILL-IN,COMBO-BOX":U ,x_U._TYPE) AND
          _F._FORMAT ne ? AND _F._FORMAT-SOURCE eq "E":U THEN
          PUT STREAM P_4GL UNFORMATTED 
            ' FORMAT "':U _F._FORMAT '"':U
            (IF _F._FORMAT-ATTR NE '' AND _F._FORMAT-ATTR NE ? THEN
               ':':U + _F._FORMAT-ATTR ELSE '').
        RUN put_view-as ("          ":U).
      END.
      PUT STREAM P_4GL UNFORMATTED " SKIP":U SKIP.

    END. /* WIDGET-LOOP: FOR... */
            
    /* Put with clause in                                                      */
    PUT STREAM P_4GL UNFORMATTED "    WITH NO-LABELS":U.
    PUT STREAM P_4GL UNFORMATTED ".":U SKIP (1).
  END.  /* If an active frame or dialog box */
  
  /* See if the Frame has any child frames. */
  IF CAN-FIND(FIRST x_U WHERE x_U._TYPE eq "FRAME":U AND
                x_U._parent-recid eq p_parent-recid AND
                x_U._STATUS NE "DELETED":U) THEN DO:
    /* This frame has child frames - drill down. */
    RUN put-frame-definitions-in (INPUT RECID(x_U)).
  END.
    
END PROCEDURE.

/* ************************************************************************* */
/*                                                                           */
/*                            INTERNAL PROCEDURES                            */
/*                                                                           */
/* ************************************************************************* */

/* This procedure puts out a HELP message if any                            */
PROCEDURE put_help_msg.
  IF x_U._HELP NE "" AND x_U._HELP NE ? THEN DO:
    PUT STREAM P_4GL UNFORMATTED " HELP" SKIP '          "' 4GL-encode (x_U._HELP) '"'.
  END.
END PROCEDURE.

/* This procedure is called when local variable has been defined with a DEFINE 
   VAR or when a database field is realized in a DEFINE FRAME. This sets the 
   VIEW-AS PHRASE.  It operates on the current x_U/_F records. INPUT indent = 
   the new line indenting (eg. "     ")  */
PROCEDURE put_view-as :
  /* This is the indent to use on a new line */
  DEFINE INPUT PARAMETER  indent  AS CHAR  NO-UNDO.
  DEFINE VARIABLE         tmp-str AS CHAR  NO-UNDO.

  /* Specify special combo-box attributes                                    */
  IF x_U._TYPE EQ "COMBO-BOX" THEN DO:
    PUT STREAM P_4GL UNFORMATTED 
      SKIP indent "VIEW-AS COMBO-BOX ":U.
    IF _F._SORT THEN 
      PUT STREAM P_4GL UNFORMATTED "SORT ":U.
    PUT STREAM P_4GL UNFORMATTED SKIP indent "LIST-ITEMS ":U.
    
    IF NUM-ENTRIES(_F._LIST-ITEMS) > 0 THEN DO:
      DO ix = 1 TO NUM-ENTRIES(_F._LIST-ITEMS,CHR(10)):
        PUT STREAM P_4GL UNFORMATTED 
          '"':U + ENTRY(ix,_F._LIST-ITEMS,CHR(10)) +
          (IF ix < NUM-ENTRIES(_F._LIST-ITEMS,CHR(10)) THEN '",':U ELSE '" ':U).
      END.  /* DO ix = 1 to Num-Entries */
    END.
    ELSE 
      PUT STREAM P_4GL UNFORMATTED  '" "'.
  END.

  /* Specify special editor attributes                                    */
  ELSE IF x_U._TYPE EQ "EDITOR" THEN
    PUT STREAM P_4GL UNFORMATTED SKIP indent
      "VIEW-AS EDITOR":U
	  (IF NOT _F._WORD-WRAP THEN " NO-WORD-WRAP":U ELSE "").
  
  /* Specify special fill-in attributes                                  */      
  ELSE IF x_U._TYPE EQ "FILL-IN":U THEN 
    PUT STREAM P_4GL UNFORMATTED SKIP indent
      "VIEW-AS FILL-IN":U.

  /* Specify special radio-set attributes                                  */
  ELSE IF x_U._TYPE EQ "RADIO-SET":U THEN
    PUT STREAM P_4GL UNFORMATTED SKIP indent
      "VIEW-AS RADIO-SET":U.

  /* Initialize a selection-list with its LIST-ITEMS                       */
  ELSE IF x_U._TYPE EQ "SELECTION-LIST":U THEN DO:
    PUT STREAM P_4GL UNFORMATTED SKIP indent
	  "VIEW-AS SELECTION-LIST ":U
      (IF _F._MULTIPLE THEN "MULTIPLE ":U ELSE "SINGLE ":U)
      (IF _F._SORT     THEN "SORT ":U     ELSE "").
      
    IF NUM-ENTRIES(_F._LIST-ITEMS) > 0 THEN DO:
      PUT STREAM P_4GL UNFORMATTED SKIP indent "LIST-ITEMS ":U.
      DO ix = 1 TO NUM-ENTRIES(_F._LIST-ITEMS,CHR(10)):
        PUT STREAM P_4GL UNFORMATTED 
          '"':U + ENTRY(ix,_F._LIST-ITEMS,CHR(10)) +
		  (IF ix < NUM-ENTRIES(_F._LIST-ITEMS,CHR(10)) THEN '",':U ELSE '" ':U).
      END.  /* DO ix = 1 to Num-Entries */
    END.
  END.

  /* Specify special toggle box                                          */
  ELSE IF x_U._TYPE EQ "TOGGLE-BOX":U THEN
    PUT STREAM P_4GL UNFORMATTED SKIP indent "VIEW-AS TOGGLE-BOX":U.

  /* Specify the special RADIO-SET stuff                                    */
  IF x_U._TYPE = "RADIO-SET":U THEN DO:
    tmp-str = REPLACE(TRIM(_F._LIST-ITEMS),
			 ",":U + /*&IF "{&WINDOW-SYSTEM}":U BEGINS "MS-WIN":U
			       &THEN CHR(13) + &ENDIF */ CHR(10),
			 ",":U + /*&IF "{&WINDOW-SYSTEM}":U BEGINS "MS-WIN":U
			       &THEN CHR(13) + &ENDIF */ CHR(10) + indent + indent).

    /* WTW - The buttons are an editted string (like trigger code). */
    PUT STREAM P_4GL UNFORMATTED 
      SKIP indent "RADIO-BUTTONS ":U SKIP indent indent tmp-str.  
  END.

  FIND _L WHERE RECID(_L) = x_U._lo-recid.
  IF _L._WIDTH ne ? AND _L._HEIGHT ne ? THEN
    RUN put_size (CHR(10) + indent, "DEF":U). 
     
END PROCEDURE.  
 
/* This sets the SIZE of a field level widget.  It operates on the current x_U
   records.  INPUT indent = the new line indenting (eg. "     ") */
PROCEDURE put_size :
  /* This is the indent to use on a new line */
  DEFINE INPUT PARAMETER indent AS CHAR.
  DEFINE INPUT PARAMETER usage  AS CHAR.  /* "DEF" or "R-T" of Run-Time adjust    */
  
  /* Don't allow unknown sizes.*/
  IF _L._HEIGHT = ? THEN _L._HEIGHT = 1.
  IF _L._WIDTH  = ? THEN _L._WIDTH  = 20.
  
  IF CAN-DO("RECTANGLE,BUTTON,COMBO-BOX,FILL-IN,TEXT",x_U._TYPE) THEN DO:
    IF _L._HEIGHT < 1 OR _L._WIDTH < 1 THEN  
      RUN adjust_size_x (1, 1).
  END.
  ELSE IF CAN-DO("RADIO-SET,SELECTION-LIST,EDITOR",x_U._TYPE) THEN DO:
    IF _L._HEIGHT < 3 OR _L._WIDTH < 3 THEN
      RUN adjust_size_x (3, 3).
  END.
  ELSE IF x_U._TYPE = "TOGGLE-BOX":u THEN DO:
    IF _L._HEIGHT < 1 OR _L._WIDTH < 3 THEN
      RUN adjust_size_x (1, 3).
  END.
 
  /* Put out the size. */
  PUT STREAM P_4GL UNFORMATTED indent
    "SIZE ":U INTEGER(_L._WIDTH) " BY ":U INTEGER(_L._HEIGHT). 
          
END PROCEDURE.

PROCEDURE adjust_size_x:
  DEFINE INPUT PARAMETER min-hgt  AS INTEGER   NO-UNDO.
  DEFINE INPUT PARAMETER min-wdth AS INTEGER   NO-UNDO.        
  
  ASSIGN _L._HEIGHT = MAXIMUM(_L._HEIGHT,min-hgt)
         _L._WIDTH  = MAXIMUM(_L._WIDTH,min-wdth).      
         
END.  /* Procedure adjust-size */

/* _gendefs.p - end of file */
