/***********************************************************************
* Copyright (C) 2000,2010 by Progress Software Corporation. All rights *
* reserved. Prior versions of this work may contain portions           *
* contributed by participants of Possenet.                             *
*                                                                      *
************************************************************************/

/*----------------------------------------------------------------------------

File: _mssschg.p

    Created from _usrschg.p


Input-Parameters:
    none
    
Output-Parameters:
    none
    
Used/Modified Shared Objects:
    in:  user_env[1] = "add" or "upd"
         user_env[3] = dbtype to add or "" for any
                       MS Sql Srver 7, ORACLE  OR
                       ODBC (Sybase, SQLServer, DB2, Informix, MS SQL 6.5)
    out: user_env[2] = new DICTDB._Db._Db-name
         no other environment variables changed

History:
    D. McMann 06/18/01  Based on _usrschg.p 20010615-001
    moloney   07/21/21  Unicode requirements for schema holder database - added to CR#OE00147991
    sgarg     07/12/10  Disallow ? as case-insesitive entry (OE00198732)
                        

----------------------------------------------------------------------------*/
/*h-*/

/*==========================  DEFINITIONS ===========================*/

{ prodict/dictvar.i }
{ prodict/user/uservar.i }
{ prodict/user/userhue.i }
{ prodict/user/userhdr.f }

DEFINE VARIABLE amode    AS LOGICAL            NO-UNDO. /*true=add,false=modify*/
DEFINE VARIABLE c        AS CHARACTER          NO-UNDO.
DEFINE VARIABLE codepage AS CHARACTER          NO-UNDO format "x(40)".
DEFINE VARIABLE collname AS CHARACTER          NO-UNDO FORMAT "x(40)".
DEFINE VARIABLE dblst    AS CHARACTER          NO-UNDO.
DEFINE VARIABLE f_addr   AS CHARACTER          NO-UNDO.
DEFINE VARIABLE f_comm   AS CHARACTER          NO-UNDO.
DEFINE VARIABLE fmode    AS LOGICAL            NO-UNDO. /* part of gateway */
DEFINE VARIABLE i        AS INTEGER  INITIAL 0 NO-UNDO.
DEFINE VARIABLE j        AS INTEGER            NO-UNDO.
DEFINE VARIABLE okay     AS LOGICAL            NO-UNDO.
DEFINE VARIABLE ronly    AS LOGICAL            NO-UNDO. /* read only */
DEFINE VARIABLE x-l      AS LOGICAL            NO-UNDO. /* allow set ldb name */
DEFINE VARIABLE x-p      AS LOGICAL            NO-UNDO. /* allow set pdb name */
DEFINE VARIABLE canned   AS LOGICAL  INIT TRUE NO-UNDO.
DEFINE VARIABLE dname    AS CHARACTER          NO-UNDO.
DEFINE VARIABLE dsource  AS CHARACTER          NO-UNDO.
DEFINE VARIABLE dstitle  AS CHARACTER FORMAT "x(26)"    NO-UNDO.
DEFINE VARIABLE casesen  AS LOGICAL            NO-UNDO.
DEFINE VARIABLE olddb    AS CHARACTER          NO-UNDO.
DEFINE VARIABLE olddbtyp AS CHARACTER          NO-UNDO.

/* LANGUAGE DEP  END.ENCIES START */ /*----------------------------------------*/
DEFINE VARIABLE new_lang AS CHARACTER EXTENT 14 NO-UNDO INITIAL [
  /* 1*/ "You have to select a non-PROGRESS database to use this option.",
  /* 2*/ "None of the above information may be changed for this database.",
  /* 3*/ "(Cannot change Logical Name while database is Connected.)",
  /* 4*/ "Supported ODBC Data Sources:  ",
  /* 5*/ "The dictionary is in read-only mode - alterations not allowed.",
  /* 6*/ "You do not have permission to create foreign database definitions.",
  /* 7*/ "You do not have permission to view foreign database definitions.",
  /* 8*/ "You do not have permission to alter foreign database definitions.",
  /* 9*/ "There is currently a database using this name as a dbname or alias",
  /*10*/ "Internal Dictionary Error: inconsistent dbtype encountered.",
  /*11*/ "Logical Database Name may not be left blank or unknown.",
  /*12*/ "Connect parameters are required.",
  /*13*/ "ODBC Data Source Name is required.",
  /*14*/ "Oracle version must be either 7 or 8."
].
FORM
  &IF "{&WINDOW-SYSTEM}" <> "TTY" &THEN    
    SKIP ({&TFM_WID}) 
  &ENDIF
    DICTDB._Db._Db-name  FORMAT "x(18)" COLON 23 LABEL "Logical Database Name" 
      {&STDPH_FILL}  SKIP ({&VM_WID})
   /* DICTDB._Db._Db-type  FORMAT "x(10)" COLON 23 LABEL "Server Type" 
      {&STDPH_FILL}  SKIP ({&VM_WID})
     */
    codepage                     COLON 23 LABEL "Code Page" 
      {&STDPH_FILL}  SKIP ({&VM_WID})
    collname                     COLON 23 LABEL "Collation" 
      {&STDPH_FILL}  SKIP ({&VM_WID})
    casesen                      COLON 23 LABEL "Case Insensitive"  SKIP ({&VM_WIDG})
    new_lang[3]   FORMAT "x(63)" AT 2 NO-LABEL VIEW-AS TEXT SKIP ({&VM_WIDG})
    
    "Connection Parameters:" AT 2 VIEW-AS TEXT SKIP({&VM_WID})
    f_comm                   AT 2 NO-LABEL {&STDPH_EDITOR}
      VIEW-AS EDITOR 
      &IF "{&WINDOW-SYSTEM}" = "TTY" &THEN
               SIZE 65 BY 4
      &ELSE 
               SIZE 65 BY 3 SCROLLBAR-VERTICAL
      &ENDIF
    SKIP({&VM_WIDG})

    dstitle NO-LABEL VIEW-AS TEXT AT 2 SKIP ({&VM_WID})
    f_addr AT 2 FORMAT "x(256)" NO-LABEL VIEW-AS FILL-IN SIZE 65 BY 1
      {&STDPH_FILL} 

    {prodict/user/userbtns.i}
    WITH FRAME userschg ROW 1 CENTERED SIDE-LABELS
      DEFAULT-BUTTON btn_OK CANCEL-BUTTON btn_Cancel
      VIEW-AS DIALOG-BOX 
      TITLE "Create/Modify Database Record for MSS Schema".


/* LANGUAGE DEP  END.ENCIES   END. */ /*------------------------------------------*/

/*================================Triggers=================================*/
ON ANY-PRINTABLE OF casesen IN FRAME userschg 
DO:
    /* Disallow ? KEY EVENT in case-insensitive entry box during PULL */
    IF LAST-EVENT:LABEL = "?" THEN
    DO: 
        BELL. 
        RETURN NO-APPLY.  
    END.
END.

/*----- LEAVE of LOGICAL NAME -----*/
ON LEAVE OF DICTDB._Db._Db-name IN FRAME userschg DO:

    Define variable btn_ok   as logical initial true.
  
    /* If logical name was edited and name is in use: */
    dname = TRIM(INPUT FRAME userschg DICTDB._Db._Db-name).
    IF DICTDB._Db._Db-name ENTERED 
      THEN DO:  /* DICTDB._Db._Db-name ENTERED */
        IF LDBNAME(dname) <> ?
          THEN DO:
            MESSAGE new_lang[9] VIEW-AS ALERT-BOX ERROR BUTTONS OK.
            RETURN NO-APPLY.
            END.
        ELSE IF user_env[1] = "chg"
          THEN DO:
            message "Changing the logical database name causes"  skip
                    "the Data Administration tool to close."     skip
                    "You can then continue working with the "    skip
                    "tool by restarting it."                     skip(1)
                    "Do you want to make the change?"
                    view-as alert-box QUESTION buttons yes-no 
                    update btn_ok.
            if btn_ok 
              THEN ASSIGN user_path = "*E".
              ELSE DO:
                DISPLAY dname @ DICTDB._Db._Db-name WITH FRAME userschg.
                RETURN NO-APPLY.
                END.
            END.
        END.    /* DICTDB._Db._Db-name ENTERED */
    END.

/*----- LEAVE of code-page -----*/
{prodict/gate/gat_cpvl.i
  &frame    = "userschg"
  &variable = "codepage"
  &adbtype  = "user_env[3]" 
  }  /* checks if codepage contains convertable code-page */
 

/*----- GO or OK -----*/
ON GO OF FRAME userschg DO:
  dname = TRIM(INPUT FRAME userschg DICTDB._Db._Db-name).
  IF dname = "" OR dname = ? THEN DO:
     MESSAGE new_lang[11] VIEW-AS ALERT-BOX ERROR BUTTONS OK.
     APPLY "ENTRY" TO DICTDB._Db._Db-name IN FRAME userschg.
     RETURN NO-APPLY.
  END.
  IF x-p AND (INPUT FRAME userschg f_addr = "" or 
              INPUT FRAME userschg f_addr = ?) THEN DO:
       MESSAGE new_lang[13] VIEW-AS ALERT-BOX ERROR BUTTONS OK.
       APPLY "ENTRY" TO f_addr IN FRAME userschg.
       RETURN NO-APPLY.      
  END.      
END.

/*-----WINDOW-CLOSE-----*/
ON WINDOW-CLOSE OF FRAME userschg
    APPLY "END-ERROR" TO FRAME userschg.


/*----- HELP -----*/
&IF "{&WINDOW-SYSTEM}" <> "TTY" &THEN 
ON HELP OF FRAME userschg OR CHOOSE of btn_Help IN FRAME userschg DO:
    RUN "adecomm/_adehelp.p" (INPUT "admn", INPUT "CONTEXT", 
                              INPUT {&Create_DataServer_Schema_Dlg_Box},
      	       	     	      INPUT ?).
    END.
&ENDIF

    /* ----- Cancel ------ */
ON 'choose':U OF btn_cancel IN FRAME userschg DO:
    ASSIGN canned = TRUE
           user_dbname = olddb
           user_dbtype =  olddbtyp.
    RETURN.
END.

/*============================Mainline Code===============================*/

ASSIGN
  amode    = (user_env[1] = "add")
  fmode    = (user_env[3] <> "")
  olddb    = user_dbname
  olddbtyp = user_dbtype
  dblst    = (IF fmode THEN user_env[3] ELSE SUBSTRING(GATEWAYS,10)).
             /* 10 = LENGTH("PROGRESS") + 2 */

ASSIGN dstitle = "ODBC Data Source Name: ".

 
{ prodict/dictgate.i &action=query &dbtype=dblst &dbrec=? &output=c }

x-p = INDEX(ENTRY(5,c),"p") > 0.

IF NOT amode
  THEN DO:
    FIND DICTDB._Db WHERE RECID(DICTDB._Db) = drec_db NO-ERROR.
    IF NOT DICTDB._Db._Db-slave THEN i = 1. /* no DICTDB._Db rec */
    IF fmode AND dblst <> user_dbtype THEN i = 10. /* inconsistent dbtype */
    END.

if user_env[1] = "add" then do:
    { prodict/dictgate.i &action=query &dbtype=dblst &dbrec=? &output=codepage }
    assign codepage = ENTRY(11,codepage)
           collname = SESSION:CPCOLL
           casesen = TRUE.
END.
else  
  assign codepage = DICTDB._Db._Db-xl-name
         collname = (IF DICTDB._DB._Db-coll-name <> ? THEN DICTDB._DB._Db-coll-name
                             ELSE SESSION:CPCOLL)
         casesen = (IF DICTDB._Db._Db-misc1[1] = 1 THEN TRUE ELSE FALSE).



IF i > 0 THEN DO:
  MESSAGE new_lang[i] VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
  END.

ASSIGN
  f_addr = (IF AVAILABLE DICTDB._Db THEN DICTDB._Db._Db-addr ELSE "")
  f_comm = (IF AVAILABLE DICTDB._Db THEN DICTDB._Db._Db-comm ELSE "").
 

DO FOR DICTDB._File:
  FIND DICTDB._File "_Db" WHERE _File._Owner = "PUB" NO-LOCK.
  IF amode AND NOT CAN-DO(_Can-create,USERID("DICTDB")) THEN DO:
    MESSAGE new_lang[6] VIEW-AS ALERT-BOX ERROR BUTTONS OK.
    user_path = "".
    RETURN.
    END.
  IF NOT amode AND NOT CAN-DO(_Can-read,USERID("DICTDB")) THEN DO:
    MESSAGE new_lang[7] VIEW-AS ALERT-BOX ERROR BUTTONS OK.
    user_path = "".
    RETURN.
    END.
  ASSIGN
    x-l   = amode OR NOT CONNECTED(DICTDB._Db._Db-name) /* can set ldb name? */
    ronly = NOT CAN-DO(_Can-write,USERID("DICTDB")).
  END.

{adecomm/okrun.i  
  &FRAME  = "FRAME userschg" 
  &BOX    = "rect_Btns"
  &OK     = "btn_OK" 
  {&CAN_BTN}
  {&HLP_BTN}
}

ASSIGN f_comm:RETURN-INSERT in frame userschg = yes.

DISPLAY
  DICTDB._Db._Db-name WHEN AVAILABLE DICTDB._Db
  new_lang[3]  WHEN NOT x-l
  f_addr       WHEN x-p
  codepage
  collname
  dstitle
  casesen
  f_comm
  WITH FRAME userschg.

IF dict_rog OR ronly THEN DO:
    MESSAGE (IF dict_rog THEN new_lang[5] ELSE new_lang[8])
      VIEW-AS ALERT-BOX WARNING BUTTONS OK.
    ASSIGN  user_path = "".
    RETURN.      
END.  /* dict_rog OR ronly (we're in read-only mode - view only) */
      
  ELSE _trx: DO TRANSACTION WITH FRAME userschg:

    DO ON ERROR UNDO,RETRY ON ENDKEY UNDO,LEAVE:
     PROMPT-FOR
          DICTDB._Db._Db-name WHEN x-l   AND               NOT (dict_rog OR ronly)
          codepage            WHEN amode AND               NOT (dict_rog OR ronly)
          collname            WHEN amode AND               NOT (dict_rog OR ronly)
          casesen             WHEN amode  
          f_comm              WHEN                         NOT (dict_rog OR ronly)
          f_addr              WHEN x-p   AND               NOT (dict_rog OR ronly)
          btn_OK
          btn_Cancel
          {&HLP_BTN_NAME}.
     

      canned = false.
    END.

    IF canned THEN UNDO _trx, LEAVE _trx.

    IF amode
      THEN DO: /* create a new DICTDB._Db for a schema for a Non-PROGRESS db */
          
        CREATE DICTDB._Db.
        ASSIGN
          DICTDB._Db._Db-name    = INPUT DICTDB._Db._Db-name
          DICTDB._Db._Db-slave = TRUE
          DICTDB._Db._Db-type  = "MSS"
          DICTDB._Db._Db-addr  = ""
          DICTDB._Db._Db-comm  = ""
          DICTDB._Db._Db-misc1[1] = (IF INPUT casesen = TRUE THEN 1 
                                                ELSE 0)
          user_dbtype   = DICTDB._Db._Db-type.
        
        
        IF NOT fmode THEN 
          &IF "{&WINDOW-SYSTEM}" = "TTY"
            &THEN
                   user_path = "1=sys,_usrsget".
            &ELSE
                   user_path = "1=sys,_guisget".
            &ENDIF
        { prodict/dictgate.i &action=query &dbtype=DICTDB._Db._Db-type &dbrec=? &output=c }
        IF INDEX(ENTRY(1,c),"a") > 0
          THEN DO:
            { prodict/dictgate.i &action=add
              &dbtype=DICTDB._Db._Db-type &dbrec=RECID(DICTDB._Db) &output=c }
            END.
        END.   /* create a new DICTDB._Db for a schema for a Non-PROGRESS db */

    ASSIGN
      DICTDB._Db._Db-name    = INPUT DICTDB._Db._Db-name
      user_env[2]            = DICTDB._Db._Db-name
      DICTDB._Db._Db-addr    = (IF DICTDB._Db._Db-addr = ? THEN "" ELSE DICTDB._Db._Db-addr)
      DICTDB._Db._Db-comm    = TRIM(INPUT f_comm)
      /* Remove any line feeds (which we get on WINDOWS) */
      DICTDB._Db._Db-comm    = REPLACE(DICTDB._Db._Db-comm, CHR(13), "")
      user_dbname     = DICTDB._Db._Db-name
      .

   DICTDB._Db._Db-xl-name = if codepage = "<internal defaults apply>" 
                         then ? 
                         else codepage.
   DICTDB._Db._Db-coll-name = INPUT collname.

    IF x-p THEN DICTDB._Db._Db-addr = INPUT f_addr.

    { prodict/user/usercon.i }

 END.   /* _trx: do transaction */

RELEASE DICTDB._Db.   /* I'm not sure why we need this? (los) */

IF canned THEN user_path = "".
HIDE FRAME userschg NO-PAUSE.
RETURN.

/*====================================================================*/





