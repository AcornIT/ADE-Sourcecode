&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          sports2000       PROGRESS
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
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

  File: fulloobjcw.w

  Description: SDO Quick Create

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: Johan Meyer, MIP Holdings (Pty) Ltd

  Created: 2001

  (v:010000)    Task:    10100047   UserRef:    POSSE
                Date:   26/09/2001  Author:     Johan Meyer

  Update Notes: Fixed screen-value updates throughout all the internal procedures
                Fixed references to database records where buffer records are used in a query

  (v:010002)    Task:               UserRef:    
                Date:   04/02/2002  Author:     Mark Davies (MIP)

  Update Notes: Fixed issue #3609 - Object generator does not show errors from RTB

  (v:010003)    Task:               UserRef:    
                Date:   02/27/2002  Author:     Mark Davies (MIP)

  Update Notes: Fixed issue #4009 - wrong percentage of completion given 
                in Object Generator
  (v:010004)    Task:               UserRef:    
                Date:   02/28/2002  Author:     Mark Davies (MIP)

  Update Notes: Fixed issue #4055 - Does not generate Dyn Browsers or Viewers 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

{adeuib/uibhlp.i}          /* Help File Preprocessor Directives         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{afglobals.i NEW GLOBAL}

/* Define required RTB global shared variables - used for RTB integration hooks (if installed) */
DEFINE NEW GLOBAL SHARED VARIABLE grtb-wsroot       AS CHARACTER    NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE grtb-task-num     AS INTEGER      NO-UNDO.
DEFINE NEW GLOBAL SHARED VARIABLE grtb-wspace-id    AS CHARACTER    NO-UNDO.

DEFINE STREAM sDir.
DEFINE STREAM LogFile.

DEFINE VARIABLE hHandle  AS HANDLE     NO-UNDO.
DEFINE VARIABLE hScmTool AS HANDLE     NO-UNDO.

DEFINE VARIABLE fiLogicGroup    AS CHARACTER NO-UNDO.
DEFINE VARIABLE clogFile        AS CHARACTER NO-UNDO INITIAL ?.
DEFINE VARIABLE fiLogicSubtype  AS CHARACTER NO-UNDO.
DEFINE VARIABLE cLogicSuffix    AS CHARACTER NO-UNDO INITIAL "logcp.p":U.
DEFINE VARIABLE cLogicTemplate  AS CHARACTER NO-UNDO INITIAL "ry/obj/rytemlogic.p":U.
DEFINE VARIABLE fiSDOGroup      AS CHARACTER NO-UNDO.
DEFINE VARIABLE fiSDOSubtype    AS CHARACTER NO-UNDO.
DEFINE VARIABLE cSuffix         AS CHARACTER NO-UNDO INITIAL "fullo.w":U.
DEFINE VARIABLE fiWspace        AS CHARACTER NO-UNDO.
DEFINE VARIABLE cTemplate       AS CHARACTER NO-UNDO INITIAL "ry/obj/rysttasdoo.w":U.

DEFINE VARIABLE TableCount      AS INTEGER    NO-UNDO.
DEFINE VARIABLE fiTask          AS INTEGER NO-UNDO INITIAL 0.

DEFINE VARIABLE toCreate                    AS LOGICAL      INITIAL YES             NO-UNDO.
DEFINE VARIABLE toLogicOverWrite            AS LOGICAL      INITIAL NO              NO-UNDO.
DEFINE VARIABLE toSDOOverWrite              AS LOGICAL      INITIAL YES             NO-UNDO.
DEFINE VARIABLE done                        AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE cmaxnumflds                 AS INTEGER      INITIAL 48              NO-UNDO. 
DEFINE VARIABLE cnamesuffix                 AS CHARACTER    INITIAL "fullb"         NO-UNDO.
DEFINE VARIABLE cvmaxnumflds                AS INTEGER      INITIAL 48              NO-UNDO. 
DEFINE VARIABLE cvnamesuffix                AS CHARACTER    INITIAL "viewv"         NO-UNDO.
DEFINE VARIABLE cvmaxfldspercolumn          AS INTEGER      INITIAL 24              NO-UNDO.
DEFINE VARIABLE cSDOViewerFields            AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE cSDOBrowseFields            AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE hObjApi                     AS HANDLE                               NO-UNDO.
DEFINE VARIABLE dSmobj                      AS DECIMAL                              NO-UNDO.
DEFINE VARIABLE shdl                        AS HANDLE                               NO-UNDO.
DEFINE VARIABLE gcOldPropath                AS CHAR                                 NO-UNDO.
DEFINE VARIABLE glAppendToLogFile           AS LOGICAL      INITIAL NO              NO-UNDO.
DEFINE VARIABLE glDisplayRepository         AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE glDeleteBrowseOnGeneration  AS LOGICAL                              NO-UNDO.  
DEFINE VARIABLE glDeleteViewerOnGeneration  AS LOGICAL                              NO-UNDO.  
DEFINE VARIABLE cLinks                      AS CHARACTER                            NO-UNDO.

DEFINE VARIABLE giCount AS INTEGER    NO-UNDO.
DEFINE VARIABLE giTotal AS INTEGER    NO-UNDO.

DEFINE TEMP-TABLE ttfiletable                   NO-UNDO
    FIELD tt_db     AS CHARACTER format "X(20)"
    FIELD tt_type   AS CHARACTER format "X(20)"
    FIELD tt_tag    AS CHARACTER format "X(20)"
    FIELD tt_data   AS CHARACTER EXTENT 4 FORMAT "X(40)" LABEL "Filename"
    INDEX tt_main tt_db tt_type tt_tag .

DEFINE TEMP-TABLE ttsdotable                    NO-UNDO
    FIELD tt_product_module_code    AS CHARACTER format "X(20)"
    FIELD tt_object_filename        AS CHARACTER format "X(20)"
    FIELD tt_object_description     AS CHARACTER format "X(20)"
    FIELD tt_object_path            AS CHARACTER FORMAT "X(20)"
    INDEX tt_key  tt_object_filename.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME BrBrowse

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttFileTable ttsdotable

/* Definitions for BROWSE BrBrowse                                      */
&Scoped-define FIELDS-IN-QUERY-BrBrowse tt_data[2] tt_data[3]   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BrBrowse   
&Scoped-define SELF-NAME BrBrowse
&Scoped-define QUERY-STRING-BrBrowse FOR EACH ttFileTable WHERE ttFileTable.tt_tag = "T" BY tt_data[2]
&Scoped-define OPEN-QUERY-BrBrowse OPEN QUERY {&SELF-NAME} FOR EACH ttFileTable WHERE ttFileTable.tt_tag = "T" BY tt_data[2].
&Scoped-define TABLES-IN-QUERY-BrBrowse ttFileTable
&Scoped-define FIRST-TABLE-IN-QUERY-BrBrowse ttFileTable


/* Definitions for BROWSE Brbrowse2                                     */
&Scoped-define FIELDS-IN-QUERY-Brbrowse2 tt_product_module_code tt_OBJECT_filename tt_OBJECT_description tt_object_path   
&Scoped-define ENABLED-FIELDS-IN-QUERY-Brbrowse2   
&Scoped-define SELF-NAME Brbrowse2
&Scoped-define QUERY-STRING-Brbrowse2 FOR EACH ttsdotable NO-LOCK
&Scoped-define OPEN-QUERY-Brbrowse2 OPEN QUERY {&SELF-NAME} FOR EACH ttsdotable NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Brbrowse2 ttsdotable
&Scoped-define FIRST-TABLE-IN-QUERY-Brbrowse2 ttsdotable


/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME ~
    ~{&OPEN-QUERY-BrBrowse}~
    ~{&OPEN-QUERY-Brbrowse2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS coDatabase coModule buAdvanced ~
fiRootDirectory buRootDirectory fiSDODirectory gendataflds rsdo ~
RAFieldSequence toGenBrowser toGenViewer buBrowserSettings geninstance ~
buViewerSettings toSuppressAll tofollow BrBrowse buSelectAll buDeSelect ~
Brbrowse2 buGenerate buStop buExit buHelp prcnt RECT-1 RECT-2 RECT-3 RECT-4 ~
RECT-6 RECT-7 RECT-8 RECT-9 
&Scoped-Define DISPLAYED-OBJECTS coDatabase coModule fiRootDirectory ~
fiSDODirectory gendataflds rsdo RAFieldSequence toGenBrowser toGenViewer ~
geninstance toSuppressAll tofollow fiProcessingTable fprocessing 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD timeCheck C-Win 
FUNCTION timeCheck RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON buAdvanced 
     LABEL "&Advanced..." 
     SIZE 19 BY 1.14 TOOLTIP "Advanced  Settings for  SDO Generation".

DEFINE BUTTON buBrowserSettings 
     LABEL " &Browser Settings..." 
     SIZE 19 BY 1.14 TOOLTIP "Change browser generation default settings".

DEFINE BUTTON buDeSelect 
     LABEL "D&eselect All" 
     SIZE 19 BY 1.14 TOOLTIP "Select All Tables".

DEFINE BUTTON buExit AUTO-END-KEY 
     LABEL "E&xit" 
     SIZE 19 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON buGenerate 
     LABEL "&Start" 
     SIZE 19 BY 1.14 TOOLTIP "Generate sdo's for selected tables"
     BGCOLOR 8 .

DEFINE BUTTON buHelp 
     LABEL "&Help" 
     SIZE 19 BY 1.14 TOOLTIP "Advanced  Settings for  SDO Generation".

DEFINE BUTTON buRootDirectory 
     LABEL "..." 
     SIZE 3.4 BY 1 TOOLTIP "Directory lookup"
     BGCOLOR 8 .

DEFINE BUTTON buSDODirectory-2 
     LABEL "..." 
     SIZE 3.4 BY .81 TOOLTIP "Directory lookup"
     BGCOLOR 8 .

DEFINE BUTTON buSelectAll 
     LABEL "&Select All" 
     SIZE 19 BY 1.14 TOOLTIP "Select All Tables".

DEFINE BUTTON buStop 
     LABEL "&Cancel" 
     SIZE 19 BY 1.14.

DEFINE BUTTON buViewerSettings 
     LABEL "V&iewer Settings..." 
     SIZE 19 BY 1.14 TOOLTIP "Change viewer generation default settings".

DEFINE VARIABLE coDatabase AS CHARACTER FORMAT "X(256)":U INITIAL "0" 
     LABEL "Da&tabase" 
     VIEW-AS COMBO-BOX SORT INNER-LINES 5
     LIST-ITEMS "0" 
     DROP-DOWN-LIST
     SIZE 36.4 BY 1 TOOLTIP "Create SDOs for this database" NO-UNDO.

DEFINE VARIABLE coModule AS CHARACTER FORMAT "X(256)":U 
     LABEL "M&odule" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 36.2 BY 1 TOOLTIP "Product module associated with SDOs" NO-UNDO.

DEFINE VARIABLE fiProcessingTable AS CHARACTER FORMAT "X(256)":U 
     LABEL "Processing Table" 
     VIEW-AS FILL-IN 
     SIZE 46 BY 1 TOOLTIP "Generating SDO for this table now" NO-UNDO.

DEFINE VARIABLE fiRootDirectory AS CHARACTER FORMAT "X(256)":U 
     LABEL "&Root Directory" 
     VIEW-AS FILL-IN 
     SIZE 74.6 BY 1 TOOLTIP "Specify the Root Directory for generating SDOs" NO-UNDO.

DEFINE VARIABLE fiSDODirectory AS CHARACTER FORMAT "X(256)":U 
     LABEL "S&DO Directory" 
     VIEW-AS FILL-IN 
     SIZE 74.6 BY 1 TOOLTIP "The relative path into which SDO and Logic will be created" NO-UNDO.

DEFINE VARIABLE fprocessing AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE prcnt AS INTEGER FORMAT "ZZ9 %":U INITIAL 0 
      VIEW-AS TEXT 
     SIZE 10 BY 1 TOOLTIP "Percentage of SDOs generated so far"
     FGCOLOR 4 FONT 6 NO-UNDO.

DEFINE VARIABLE RAFieldSequence AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "By &Order", 1,
"By &Field Name", 2
     SIZE 18 BY 1.57 TOOLTIP "Specifies the field order in the SDO" NO-UNDO.

DEFINE VARIABLE rsdo AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Create New SDOs", 1,
"Use Existing SDOs to Generate Browsers/Viewers", 2
     SIZE 50.8 BY 1.57 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 143 BY 2.38.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 143 BY 1.91.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 143 BY 4.52.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 143 BY 12.38.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 71 BY 3.57.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 24 BY 3.57.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 23 BY 3.57.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL 
     SIZE 25 BY 3.57.

DEFINE VARIABLE gendataflds AS LOGICAL INITIAL yes 
     LABEL "Generate DataFields" 
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .81 TOOLTIP "Generate Datafields for Table or SDO" NO-UNDO.

DEFINE VARIABLE geninstance AS LOGICAL INITIAL yes 
     LABEL "Generate Instances" 
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .81 TOOLTIP "Generate DataField Instances for SDO" NO-UNDO.

DEFINE VARIABLE tofollow AS LOGICAL INITIAL yes 
     LABEL "&Follow Joins" 
     VIEW-AS TOGGLE-BOX
     SIZE 16.4 BY .81 NO-UNDO.

DEFINE VARIABLE toGenBrowser AS LOGICAL INITIAL no 
     LABEL "Generate Browsers" 
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .81 TOOLTIP "Check to Generate Browsers for Selected Tables" NO-UNDO.

DEFINE VARIABLE toGenViewer AS LOGICAL INITIAL no 
     LABEL "Generate Viewers" 
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .81 TOOLTIP "Check to generate Viewers for select tables" NO-UNDO.

DEFINE VARIABLE toSuppressAll AS LOGICAL INITIAL yes 
     LABEL "Suppress All &Validation" 
     VIEW-AS TOGGLE-BOX
     SIZE 25.4 BY .81 TOOLTIP "Check to suppress all validation in the SDO" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BrBrowse FOR 
      ttFileTable SCROLLING.

DEFINE QUERY Brbrowse2 FOR 
      ttsdotable SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BrBrowse
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BrBrowse C-Win _FREEFORM
  QUERY BrBrowse DISPLAY
      tt_data[2] LABEL "Table Name"  FORMAT "X(70)":U
      tt_data[3] LABEL "Dump Name" FORMAT "X(10)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 115 BY 5.52 ROW-HEIGHT-CHARS .62 EXPANDABLE TOOLTIP "Select the tables to create SDOs".

DEFINE BROWSE Brbrowse2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS Brbrowse2 C-Win _FREEFORM
  QUERY Brbrowse2 DISPLAY
      tt_product_module_code LABEL "Product Module" FORMAT "X(10)"
      tt_OBJECT_filename LABEL "SDO Name" FORMAT "X(20)"
      tt_OBJECT_description LABEL "Description"  FORMAT "X(50)"
      tt_object_path LABEL "Sub Directory" FORMAT "X(20)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS MULTIPLE SIZE 115 BY 5.52 ROW-HEIGHT-CHARS .62 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     coDatabase AT ROW 1.48 COL 19 COLON-ALIGNED
     coModule AT ROW 2.43 COL 19 COLON-ALIGNED
     buAdvanced AT ROW 2.43 COL 120.6
     fiRootDirectory AT ROW 3.38 COL 19 COLON-ALIGNED
     buRootDirectory AT ROW 3.38 COL 92
     fiSDODirectory AT ROW 4.33 COL 19 COLON-ALIGNED
     buSDODirectory-2 AT ROW 4.43 COL 92
     gendataflds AT ROW 6.48 COL 121
     rsdo AT ROW 6.91 COL 2.6 NO-LABEL
     RAFieldSequence AT ROW 6.91 COL 54.2 NO-LABEL
     toGenBrowser AT ROW 6.91 COL 74
     toGenViewer AT ROW 6.91 COL 98.4
     buBrowserSettings AT ROW 8.05 COL 75.8
     geninstance AT ROW 8.05 COL 121.2
     buViewerSettings AT ROW 8.14 COL 99.4
     toSuppressAll AT ROW 8.62 COL 2.8
     tofollow AT ROW 8.62 COL 54.6
     BrBrowse AT ROW 10.52 COL 4
     buSelectAll AT ROW 10.76 COL 120.6
     buDeSelect AT ROW 12.43 COL 120.6
     Brbrowse2 AT ROW 16.24 COL 4
     fiProcessingTable AT ROW 22.57 COL 29.2 COLON-ALIGNED
     fprocessing AT ROW 22.67 COL 96 COLON-ALIGNED NO-LABEL
     buGenerate AT ROW 25.52 COL 5
     buStop AT ROW 25.52 COL 26
     buExit AT ROW 25.52 COL 100
     buHelp AT ROW 25.52 COL 120.6
     prcnt AT ROW 22.57 COL 78.2 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 22.43 COL 2
     RECT-2 AT ROW 25.05 COL 2
     RECT-3 AT ROW 1.24 COL 2.2
     RECT-4 AT ROW 9.81 COL 2
     RECT-6 AT ROW 6 COL 2
     RECT-7 AT ROW 6 COL 73
     RECT-8 AT ROW 6 COL 97
     RECT-9 AT ROW 6 COL 120
     "Field Sequence:" VIEW-AS TEXT
          SIZE 18 BY .62 AT ROW 6.19 COL 54.2
     "SmartDataObjects (SDOs)" VIEW-AS TEXT
          SIZE 25.8 BY .62 AT ROW 5.76 COL 3.2
     "Dynamic Viewers" VIEW-AS TEXT
          SIZE 18 BY .62 AT ROW 5.76 COL 98.4
     "Dynamic Browsers" VIEW-AS TEXT
          SIZE 18 BY .62 AT ROW 5.76 COL 74
     "DataFields" VIEW-AS TEXT
          SIZE 12 BY .62 AT ROW 5.76 COL 121
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 151.4 BY 26.19
         DEFAULT-BUTTON buGenerate CANCEL-BUTTON buExit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Generate Objects"
         HEIGHT             = 26.05
         WIDTH              = 144.8
         MAX-HEIGHT         = 45.38
         MAX-WIDTH          = 256
         VIRTUAL-HEIGHT     = 45.38
         VIRTUAL-WIDTH      = 256
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
                                                                        */
/* BROWSE-TAB BrBrowse tofollow DEFAULT-FRAME */
/* BROWSE-TAB Brbrowse2 buDeSelect DEFAULT-FRAME */
/* SETTINGS FOR BUTTON buSDODirectory-2 IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
ASSIGN 
       buSDODirectory-2:HIDDEN IN FRAME DEFAULT-FRAME           = TRUE.

/* SETTINGS FOR FILL-IN fiProcessingTable IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fprocessing IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN prcnt IN FRAME DEFAULT-FRAME
   NO-DISPLAY                                                           */
ASSIGN 
       prcnt:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BrBrowse
/* Query rebuild information for BROWSE BrBrowse
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttFileTable WHERE ttFileTable.tt_tag = "T" BY tt_data[2].
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BrBrowse */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE Brbrowse2
/* Query rebuild information for BROWSE Brbrowse2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttsdotable NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE Brbrowse2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Generate Objects */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Generate Objects */
DO:
    /* This event will close the window and terminate the procedure.  */
    IF VALID-HANDLE(hHandle) THEN RUN killPlip IN hHandle.
    IF VALID-HANDLE(hScmTool) THEN RUN killPlip IN hScmTool.
    APPLY "CLOSE":U TO THIS-PROCEDURE.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buAdvanced
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buAdvanced C-Win
ON CHOOSE OF buAdvanced IN FRAME DEFAULT-FRAME /* Advanced... */
DO:    
    IF clogfile = ? THEN
        ASSIGN cLogFile = coDatabase:SCREEN-VALUE IN FRAME {&FRAME-NAME} + ".log":U.
    
    RUN af/cod2/fulloadvanced.w ( INPUT-OUTPUT cTemplate, 
                                  INPUT-OUTPUT cSuffix, 
                                  INPUT-OUTPUT cLogicTemplate, 
                                  INPUT-OUTPUT cLogicSuffix, 
                                  INPUT-OUTPUT cLogFile ,
                                  INPUT-OUTPUT fiWspace,         /* rtb */
                                  INPUT-OUTPUT fiSDOGroup,       /* rtb */
                                  INPUT-OUTPUT fiLogicGroup,     /* rtb */
                                  INPUT-OUTPUT fiSDOSubType,     /* rtb */
                                  INPUT-OUTPUT fiTask,           /* rtb */
                                  INPUT-OUTPUT fiLogicSubType,   /* rtb */
                                  INPUT-OUTPUT toLogicOverWrite, /* rtb */
                                  INPUT-OUTPUT toSDOOverwrite,   /* rtb */
                                  INPUT-OUTPUT glAppendToLogFile           ).  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buBrowserSettings
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buBrowserSettings C-Win
ON CHOOSE OF buBrowserSettings IN FRAME DEFAULT-FRAME /*  Browser Settings... */
DO:
    RUN af/cod2/gbrowsettings.w ( INPUT-OUTPUT cmaxnumflds,
                                  INPUT-OUTPUT cnamesuffix,
                                  INPUT-OUTPUT cSDOBrowseFields,
                                  INPUT-OUTPUT glDeleteBrowseOnGeneration   ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buDeSelect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buDeSelect C-Win
ON CHOOSE OF buDeSelect IN FRAME DEFAULT-FRAME /* Deselect All */
DO:
  IF BROWSE brbrowse2:VISIBLE = TRUE AND BROWSE brbrowse2:NUM-ITERATIONS > 0  THEN
  brBrowse2:DESELECT-ROWS().
  ELSE IF brbrowse:VISIBLE = TRUE AND BROWSE brbrowse:NUM-ITERATIONS > 0 THEN
  brBrowse:DESELECT-ROWS().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buExit C-Win
ON CHOOSE OF buExit IN FRAME DEFAULT-FRAME /* Exit */
DO:

  APPLY "window-close":U TO {&WINDOW-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buGenerate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buGenerate C-Win
ON CHOOSE OF buGenerate IN FRAME DEFAULT-FRAME /* Start */
DO:

    DEFINE VARIABLE cDirectory AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE lContinue  AS LOGICAL INITIAL YES   NO-UNDO.
    DEFINE VARIABLE iStat      AS INTEGER               NO-UNDO.
    
    IF SEARCH(cTemplate) = ? THEN
    DO:
       MESSAGE 
           "Template file not found. Template file must exist in a directory in the propath.".
       LEAVE.
    END.

    IF coDatabase:SCREEN-VALUE = ? THEN
    DO:
        MESSAGE 
            "A valid database must be selected".
        LEAVE.
    END.
    
    IF coModule:SCREEN-VALUE = "<None>":U THEN
    DO:
        MESSAGE 
            "A valid product module must be specified".
        LEAVE.
    END.

    IF fiRootDirectory:SCREEN-VALUE = "":U THEN
    DO:
        MESSAGE 
            "A root directory must be specified".
        LEAVE.
    END.
    IF fiSDODirectory:SCREEN-VALUE = "":U THEN
    DO:
        MESSAGE 
            "An SDO directory must be specified".
        LEAVE.
    END.

    IF {&BROWSE-NAME}:NUM-SELECTED-ROWS = 0  AND rsdo:SCREEN-VALUE = "1" THEN
    DO:
        MESSAGE 
            "Select a table to create a smartobject".
        LEAVE.
    END.
    IF brbrowse2:NUM-SELECTED-ROWS = 0  AND rsdo:SCREEN-VALUE = "2" THEN
    DO:
        MESSAGE 
            "Select an SDO to create a viewer or browser".
        LEAVE.
    END.

    IF coModule:SCREEN-VALUE = "":U THEN DO:
        MESSAGE "The product module must be specified.".
        LEAVE.
    END.

    IF cSuffix = cLogicSuffix THEN DO:
        MESSAGE "The Suffix for the SDO and Logical Object can not be the same.".
        LEAVE.
    END.
    
    IF cNameSuffix = cVnameSuffix THEN DO:
        MESSAGE "The Suffix for the Browser and Viewer can not be the same.".
        LEAVE.
    END.
    
    ASSIGN
      fiRootDirectory:SCREEN-VALUE = LC(TRIM(REPLACE(fiRootDirectory:SCREEN-VALUE,"\":U,"/":U),"/":U))
      fiSDODirectory:SCREEN-VALUE = LC(TRIM(REPLACE(fiSDODirectory:SCREEN-VALUE,"\":U,"/":U),"/":U))
      cDirectory = fiRootDirectory:SCREEN-VALUE + "/":U + fiSDODirectory:SCREEN-VALUE + "/":U
      .    
    IF clogfile = ? THEN
        ASSIGN cLogFile = coDatabase:SCREEN-VALUE IN FRAME {&FRAME-NAME} + ".log":U.

    IF clogfile = ? THEN
        ASSIGN cLogFile = "ExistSDO.log":U.

    FILE-INFO:FILE-NAME = cDirectory.
    IF FILE-INFO:FILE-TYPE <> "DRW"   /* if not a directory or not found */
    THEN DO:                          /* show error message and prompt to create it */
        MESSAGE "File" RIGHT-TRIM(cDirectory,"/":U) "does not exist." SKIP
                 "Do you want to create it?" 
                 VIEW-AS ALERT-BOX QUESTION
                 BUTTONS YES-NO
                 UPDATE lAnswer AS LOGICAL.
        IF NOT lAnswer THEN LEAVE.    /* if they say no then cancel generation */
        ELSE DO: /* if they say yes then create dir and continue generation */
            /*OS-CREATE does not create multi-level directories*/
            /* OS-CREATE-DIR VALUE(cDirectory). */
            OS-COMMAND SILENT VALUE('mkdir "' + cDirectory + '"').
            iStat = OS-ERROR.
                IF iStat NE 0 THEN DO:
                
                MESSAGE RIGHT-TRIM(cDirectory,"/":U) " not created. System Error #." istat
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
                LEAVE.
                END.
                
        END.
            
    END.

      /* we have what we need from the user so now we can attempt to do
       * the sdo generation. Make sure the buttons are in the right state 
       */
      prcnt = 0.
      DISPLAY prcnt WITH FRAME {&FRAME-NAME}.
      RUN setButtons.
      fprocessing:SCREEN-VALUE = "Processing please wait....".

      IF rSdo:INPUT-VALUE EQ 1 THEN
          RUN CreateNewSdo.
      ELSE
          RUN UseExistingSdo.

    /* Write the log footer and close the stream. */
    RUN LogFooter NO-ERROR.
   
      RUN setButtons.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buHelp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buHelp C-Win
ON CHOOSE OF buHelp IN FRAME DEFAULT-FRAME /* Help */
OR HELP OF FRAME {&FRAME-NAME}
DO: 
  /* Help for this Frame */
  RUN adecomm/_adehelp.p
                ("ICAB", "CONTEXT", {&Generate_Objects_Dlg_Box}  , "").

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buRootDirectory
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buRootDirectory C-Win
ON CHOOSE OF buRootDirectory IN FRAME DEFAULT-FRAME /* ... */
DO:
    DEF VAR tmpfirootdirectory AS CHAR NO-UNDO.
    RUN mipGetFolder("Directory", OUTPUT tmpfiRootDirectory).
    IF tmpfiRootDirectory <> ? AND tmpfirootdirectory <> "" THEN
       ASSIGN fiRootDirectory:SCREEN-VALUE = tmpfiRootDirectory.

    APPLY "entry":U TO fiRootDirectory.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buSDODirectory-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buSDODirectory-2 C-Win
ON CHOOSE OF buSDODirectory-2 IN FRAME DEFAULT-FRAME /* ... */
DO:
    RUN mipGetFolder("Directory", OUTPUT fiSDODirectory).

    IF fiSdoDirectory EQ ? THEN
        ASSIGN fiSdoDirectory = fiSdoDirectory:SCREEN-VALUE.
    ELSE
        ASSIGN fiSDODirectory:SCREEN-VALUE = REPLACE(fiSDODirectory,fiRootDirectory + "/":U,"":U).
    APPLY "entry":U TO fiSDODirectory.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buSelectAll
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buSelectAll C-Win
ON CHOOSE OF buSelectAll IN FRAME DEFAULT-FRAME /* Select All */
DO:
   
  IF BROWSE brbrowse2:VISIBLE = TRUE AND BROWSE brbrowse2:NUM-ITERATIONS > 0 THEN
  brBrowse2:SELECT-ALL().
  ELSE IF BROWSE brbrowse:VISIBLE = TRUE AND BROWSE brbrowse:NUM-ITERATIONS > 0 THEN 
  brBrowse:SELECT-ALL().

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buStop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buStop C-Win
ON CHOOSE OF buStop IN FRAME DEFAULT-FRAME /* Cancel */
DO:
  ASSIGN done = TRUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME buViewerSettings
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL buViewerSettings C-Win
ON CHOOSE OF buViewerSettings IN FRAME DEFAULT-FRAME /* Viewer Settings... */
DO:
    RUN af/cod2/gviewsettings.w ( INPUT-OUTPUT cvmaxnumflds,
                                  INPUT-OUTPUT cvnamesuffix,
                                  INPUT-OUTPUT cvmaxfldspercolumn,
                                  INPUT-OUTPUT cSDOViewerFields,
                                  INPUT-OUTPUT glDeleteViewerOnGeneration ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME coDatabase
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL coDatabase C-Win
ON VALUE-CHANGED OF coDatabase IN FRAME DEFAULT-FRAME /* Database */
DO:
    RUN populateTable.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME coModule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL coModule C-Win
ON VALUE-CHANGED OF coModule IN FRAME DEFAULT-FRAME /* Module */
DO:    

    DEFINE VARIABLE cDirectory AS CHARACTER NO-UNDO.

    IF coModule:SCREEN-VALUE <> "<None>":U THEN
    DO:

     /****/ IF CONNECTED("RTB":U) THEN
      DO:
        IF NOT VALID-HANDLE(hScmTool) THEN
            RUN rtb/prc/afrtbprocp.p PERSISTENT SET hScmTool.
        RUN scmGetModuleDir IN hScmTool (INPUT coModule:SCREEN-VALUE,
                                         OUTPUT cDirectory).       
      END.
      ELSE
      
      DO:
      /****/
        FIND FIRST gsc_product_module NO-LOCK
             WHERE gsc_product_module.product_module_code = coModule:SCREEN-VALUE
             NO-ERROR.      
        IF AVAILABLE gsc_product_module THEN
          ASSIGN cDirectory = TRIM(LC(REPLACE(gsc_product_module.relative_path,"\":U,"/":U)),"/":U)     
            .
      END.
      fiSDODirectory:SCREEN-VALUE = cDirectory.

   END.
   ELSE fiSDODirectory:SCREEN-VALUE = "":U.

   RUN populateSDOtable IN THIS-PROCEDURE (INPUT comodule:SCREEN-VALUE).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fiRootDirectory
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fiRootDirectory C-Win
ON LEAVE OF fiRootDirectory IN FRAME DEFAULT-FRAME /* Root Directory */
DO:
  ASSIGN
    SELF:SCREEN-VALUE = LC(TRIM(REPLACE(SELF:SCREEN-VALUE,"\":U,"/":U),"/":U))
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fiSDODirectory
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fiSDODirectory C-Win
ON LEAVE OF fiSDODirectory IN FRAME DEFAULT-FRAME /* SDO Directory */
DO:
  ASSIGN
    SELF:SCREEN-VALUE = LC(TRIM(REPLACE(SELF:SCREEN-VALUE,"\":U,"/":U),"/":U))
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME prcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL prcnt C-Win
ON VALUE-CHANGED OF prcnt IN FRAME DEFAULT-FRAME
DO:
  IF integer(SELF:SCREEN-VALUE) > 100 THEN DO:
    prcnt = 100.
    DISPLAY prcnt WITH FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RAFieldSequence
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RAFieldSequence C-Win
ON VALUE-CHANGED OF RAFieldSequence IN FRAME DEFAULT-FRAME
DO:
  ASSIGN RAFieldSequence.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsdo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsdo C-Win
ON VALUE-CHANGED OF rsdo IN FRAME DEFAULT-FRAME
DO:
    IF rsdo:SCREEN-VALUE = "2" THEN
    DO:
        ASSIGN BROWSE brbrowse:VISIBLE   = FALSE
               BROWSE brbrowse2:VISIBLE  = TRUE
               RAFieldsequence:SENSITIVE = FALSE
               tosuppressall:SENSITIVE   = FALSE
               toFollow:SENSITIVE        = FALSE
               .    
        /*repopulate tmptable to include newly created sdos*/
        RUN populateSDOtable IN THIS-PROCEDURE (INPUT coModule:SCREEN-VALUE).
    END.    /* screen-value */
    ELSE
    IF rsdo:SCREEN-VALUE = "1" THEN
        ASSIGN BROWSE brbrowse:VISIBLE   = TRUE
               BROWSE brbrowse2:VISIBLE  = FALSE
               RAFieldsequence:SENSITIVE = TRUE
               tosuppressall:SENSITIVE   = TRUE
               toFollow:SENSITIVE        = TRUE
               .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME toGenBrowser
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL toGenBrowser C-Win
ON VALUE-CHANGED OF toGenBrowser IN FRAME DEFAULT-FRAME /* Generate Browsers */
DO:  
    IF SELF:CHECKED THEN
        ASSIGN genDataFlds:CHECKED = YES
               genInstance:CHECKED = YES
               genDataFlds:SENSITIVE = FALSE
               .
    ELSE 
    IF NOT toGenBrowser:CHECKED AND 
       NOT toGenViewer:CHECKED 
       THEN genDataFlds:SENSITIVE = TRUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME toGenViewer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL toGenViewer C-Win
ON VALUE-CHANGED OF toGenViewer IN FRAME DEFAULT-FRAME /* Generate Viewers */
DO:
    IF SELF:CHECKED THEN
        ASSIGN genDataFlds:CHECKED = YES
               genInstance:CHECKED = YES
               genDataFlds:SENSITIVE = FALSE
               .
    IF NOT toGenBrowser:CHECKED AND 
       NOT toGenViewer:CHECKED 
       THEN genDataFlds:SENSITIVE = TRUE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BrBrowse
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE DO:
    /*rest the propath if req'd*/
    IF gcOldPropath <> "" AND gcOldPropath <> PROPATH THEN
    ASSIGN
      PROPATH = gcOldPropath.
   IF VALID-HANDLE(hObjApi) THEN RUN killplip IN hObjApi.
   RUN disable_UI.

   OUTPUT STREAM logfile CLOSE. 
END.
/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

RUN ry/app/ryreposobp.p PERSISTENT SET hObjApi.

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  
  RUN initValues IN THIS-PROCEDURE.       /*set some initial values */
  RUN populateScreen IN THIS-PROCEDURE.     /*put up the screen */
  
  IF RETURN-VALUE NE "":U THEN
  DO:
      MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX.
      APPLY "CLOSE":U TO THIS-PROCEDURE.
      RETURN.
  END.

  RUN populateDatabase IN THIS-PROCEDURE.
  RUN populateSDOtable IN THIS-PROCEDURE (INPUT comodule:SCREEN-VALUE).
  RUN populateTable    IN THIS-PROCEDURE.
 

  APPLY "VALUE-CHANGED":U TO coModule.
  APPLY "VALUE-CHANGED":U TO toGenBrowser.
  APPLY "entry":U TO coDatabase.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE FOCUS coDatabase.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createNewSDO C-Win 
PROCEDURE createNewSDO :
/*------------------------------------------------------------------------------
  Purpose:     Creates a new SDO
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE VARIABLE iLoop                 AS INT   NO-UNDO.
DEFINE VARIABLE cFollow               AS CHAR  NO-UNDO.
DEFINE VARIABLE cFilename             AS CHAR  NO-UNDO.
DEFINE VARIABLE cLogicFileName        AS CHAR  NO-UNDO.
DEFINE VARIABLE lExistsInRtb1         AS LOG   NO-UNDO.
DEFINE VARIABLE lExistsInWorkspace1   AS LOG   NO-UNDO.
DEFINE VARIABLE iWorkspaceVersion1    AS INT   NO-UNDO.
DEFINE VARIABLE lWorkspaceCheckedOut1 AS LOG   NO-UNDO.
DEFINE VARIABLE iVersionTaskNumber1   AS INT   NO-UNDO.
DEFINE VARIABLE iLatestVersion1       AS INT   NO-UNDO.
DEFINE VARIABLE cObjectModule1        AS CHAR  NO-UNDO.
DEFINE VARIABLE cModulePath1          AS CHAR  NO-UNDO.
DEFINE VARIABLE lExistsInRtb2         AS LOG   NO-UNDO.
DEFINE VARIABLE lExistsInWorkspace2   AS LOG   NO-UNDO.
DEFINE VARIABLE iWorkspaceVersion2    AS INT   NO-UNDO.
DEFINE VARIABLE lWorkspaceCheckedOut2 AS LOG   NO-UNDO.
DEFINE VARIABLE iVersionTaskNumber2   AS INT   NO-UNDO.
DEFINE VARIABLE iLatestVersion2       AS INT   NO-UNDO.
DEFINE VARIABLE cObjectModule2        AS CHAR  NO-UNDO.
DEFINE VARIABLE cModulePath2          AS CHAR  NO-UNDO.
DEFINE VARIABLE iRecid                AS RECID NO-UNDO.
DEFINE VARIABLE cError                AS CHAR  NO-UNDO.
DEFINE VARIABLE lSCMOk                AS LOG   NO-UNDO.
DEFINE VARIABLE prnt                  AS LOG   NO-UNDO.
DEFINE VARIABLE newobjectpath         AS CHAR  NO-UNDO.
DEFINE VARIABLE cattrnames            AS CHAR  NO-UNDO.
DEFINE VARIABLE cattrvalues           AS CHAR  NO-UNDO.
DEFINE VARIABLE tdatacolumns          AS CHAR  NO-UNDO.
DEFINE VARIABLE dfldname              AS CHAR  NO-UNDO.
DEFINE VARIABLE ttablename            AS CHAR  NO-UNDO. 
DEFINE VARIABLE tmpsdoname            AS CHAR  NO-UNDO.
DEFINE VARIABLE tmplogname            AS CHAR  NO-UNDO.
DEFINE VARIABLE tmplogclname          AS CHAR  NO-UNDO.
DEFINE VARIABLE tmpdumpname           AS CHAR  NO-UNDO.
DEFINE VARIABLE sdodir                AS CHAR  NO-UNDO.

DO WITH FRAME {&FRAME-NAME}:       
  ASSIGN coDatabase
         coModule
         fiRootDirectory
         fiSDODirectory.        
  IF LOOKUP(fiRootDirectory:SCREEN-VALUE,PROPATH) = 0 THEN
    ASSIGN gcOldPropath = PROPATH
           PROPATH      = PROPATH + "," + fiRootDirectory:SCREEN-VALUE.
  IF ToFollow:CHECKED THEN
    ASSIGN cFollow = "FOLLOW":U.
  ELSE
    ASSIGN cFollow = "NORMAL":U.

  IF QUERY brBrowse:IS-OPEN THEN
    GET LAST brBrowse NO-LOCK.

  ASSIGN 
    TableCount = brBrowse:NUM-SELECTED-ROWS
    giTotal    = brBrowse:NUM-SELECTED-ROWS * (7 + (IF toGenBrowser:CHECKED THEN 1 ELSE 0) + (IF toGenViewer:CHECKED THEN 1 ELSE 0) + (IF gendataflds:CHECKED THEN 1 ELSE 0) + (IF geninstance:CHECKED THEN 1 ELSE 0)) + 1.
  RUN logHeader.
END.    /* with frame ... */

ROW-BLOCK:
DO iLoop = 1 TO brBrowse:NUM-SELECTED-ROWS:
  brBrowse:FETCH-SELECTED-ROW(iLoop).

  ASSIGN cFilename      = ttFileTable.tt_data[3] + cSuffix
         cLogicFileName = ttFileTable.tt_data[3] + cLogicSuffix
         lSCMOk         = YES
         cError         = "":U
         fprocessing:SCREEN-VALUE = "Checking SCM Tool ...".
         .
  DISPLAY ttFileTable.tt_data[2] @ fiProcessingTable WITH FRAME {&FRAME-NAME}.

  IF CONNECTED("RTB":U)
  THEN
  rtbBlock:
  DO:

    IF NOT VALID-HANDLE(hScmTool)
    THEN DO:
      IF SEARCH("rtb/prc/afrtbprocp.p":U) <> ?
      OR SEARCH("rtb/prc/afrtbprocp.r":U) <> ?
      THEN
        RUN rtb/prc/afrtbprocp.p PERSISTENT SET hScmTool.
    END.

    IF NOT VALID-HANDLE(hScmTool)
    THEN LEAVE rtbBlock.

    RUN scmObjectExists IN hScmTool 
      ( INPUT cFileName,
        INPUT fiWspace,
        OUTPUT lExistsInRtb1,
        OUTPUT lExistsInWorkspace1,
        OUTPUT iWorkspaceVersion1,
        OUTPUT lWorkspaceCheckedOut1,
        OUTPUT iVersionTaskNumber1,
        OUTPUT iLatestVersion1 ).
    IF lExistsinRtb1 THEN 
      RUN scmGetObjectModule IN hScmTool 
                            (INPUT  fiWspace
                            ,INPUT  cFileName
                            ,INPUT  fiSDOSubType
                            ,OUTPUT cObjectModule1
                            ,OUTPUT cModulePath1
                            ).
    RUN scmObjectExists IN hScmTool 
      ( INPUT cLogicFileName,
        INPUT fiWspace,
        OUTPUT lExistsInRtb2,
        OUTPUT lExistsInWorkspace2,
        OUTPUT iWorkspaceVersion2,
        OUTPUT lWorkspaceCheckedOut2,
        OUTPUT iVersionTaskNumber2,
        OUTPUT iLatestVersion2).

    IF lExistsinRtb2 THEN 
      RUN scmGetObjectModule IN hScmTool 
                            (INPUT  fiWspace
                            ,INPUT  cLogicFileName
                            ,INPUT  fiLogicSubtype
                            ,OUTPUT cObjectModule2
                            ,OUTPUT cModulePath2
                            ).

    IF NOT lExistsInWorkspace1 AND lExistsinRtb1 THEN DO:
      RUN LogMessage(""," Object " + cFilename + " exists in SCM Tool, but not in the selected workspace",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.    /* errors */

    IF lExistsInWorkspace1
    AND cObjectModule1 <> coModule:SCREEN-VALUE THEN DO:
      RUN LogMessage(""," Object " + cFilename + " already exist in a different module than selected",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.

    IF lExistsInWorkspace1
    AND cModulePath1 <> fiSDODirectory THEN DO:
      RUN LogMessage(""," Object " + cFilename + " already exist in a different directory than selected",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.

    IF lExistsInWorkspace1 AND lWorkspaceCheckedOut1 AND
       fiTask = iVersionTaskNumber1 AND NOT toSDOOverwrite THEN DO:
      RUN LogMessage(""," Object " + cFilename + " is checked out already and SDO overwrite flag is set to NO",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.

    IF lExistsInWorkspace1 AND
       lWorkspaceCheckedOut1 AND
       fiTask <> iVersionTaskNumber1 THEN DO:
      RUN LogMessage(""," Object " + cFilename + " is checked out already in a different task",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.

    IF NOT lExistsInWorkspace2 AND lExistsinRtb2 THEN DO:
      RUN LogMessage(""," Logical Object " + cLogicFilename + " exists in SCM Tool, but not in the selected workspace",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.
    
    IF lExistsInWorkspace2
    AND cObjectModule2 <> coModule:SCREEN-VALUE THEN DO:
      RUN LogMessage(""," Logical Object " + cLogicFilename + " already exist in a different module than selected",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.

    IF lExistsInWorkspace2
    AND cModulePath2 <> fiSDODirectory
    THEN DO:
      RUN LogMessage(""," Logical Object " + cLogicFilename + " already exist in a different directory than selected",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.

    IF lExistsInWorkspace2 AND lWorkspaceCheckedOut2 AND
      fiTask EQ iVersionTaskNumber2 AND NOT toLogicOverwrite THEN
    DO:
      RUN LogMessage("", " Logical Object " + cLogicFilename + " is checked out already and Logic overwrite flag is set to NO",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.

    IF lExistsInWorkspace2 AND lWorkspaceCheckedOut2 AND fiTask NE iVersionTaskNumber2 THEN DO:
      RUN LogMessage("", " Logical Object " + cLogicFilename + " is checked out already in a different task",YES).
      ASSIGN lSCMOk = NO.
      IF RETURN-VALUE = "ABORT":U THEN
        LEAVE ROW-BLOCK.
    END.

    IF NOT lSCMOk THEN NEXT ROW-BLOCK.

  END. /* RTB connected */

  ASSIGN cError = "":U.
  RUN ShowMessage("Generating Datafields....").

  IF lscmok = YES AND (GenDataFlds:CHECKED OR toGenviewer:CHECKED) THEN
  DO:
    IF VALID-HANDLE(hObjApi)
    THEN DO:
      RUN storeTableFields IN hObjApi ( INPUT coDatabase:SCREEN-VALUE,
                                      INPUT ttFileTable.tt_data[2],
                                      INPUT coModule:SCREEN-VALUE   ).
      IF RETURN-VALUE NE "":U THEN
        ASSIGN lSCMOk = NO
               cError = "Error from StoreTableFields ":U + RETURN-VALUE
                 .
      ELSE
        ASSIGN cError = "Datafield Generation Successful".
    END.
    ELSE
      ASSIGN cError = "Error with Datafield Generation".

    RUN LogMessage(ttFileTable.tt_data[2],cError,NO).
  END.

  ETIME(YES).
  ASSIGN cError = "":U.
  RUN ShowMessage("Generating SDO ....").

  IF lSCMOk = YES
  THEN
    RUN af/app/fullocreat.p 
      ( INPUT "FOR EACH " + coDatabase:SCREEN-VALUE + "." + ttFileTable.tt_data[2] + " NO-LOCK",
        INPUT cTemplate,
        INPUT fiRootDirectory:SCREEN-VALUE + "/":U +  fiSDODirectory:SCREEN-VALUE + "/":U + cFileName,
        INPUT cFollow,
        INPUT cLogicTemplate,
        INPUT fiRootDirectory:SCREEN-VALUE + "/":U + fiSDODirectory:SCREEN-VALUE + "/":U + cLogicFileName,
        INPUT fiRootDirectory:SCREEN-VALUE,
        INPUT RAFieldSequence,
        INPUT toSuppressAll:CHECKED,
        OUTPUT cError,
        OUTPUT cLinks).

  IF toFollow:CHECKED THEN DO:
    ASSIGN cLinks = REPLACE(cLinks,"|",",").
    RUN LogMessage('Joins Followed':U,cLinks,NO).
  END.

  IF cError <> "":U THEN
    ASSIGN lSCMOk = NO.
  ELSE
    ASSIGN cError = " SDO Generation Successful. ":U.

  RUN LogMessage(ttFileTable.tt_data[2],cError,NO).

  ASSIGN
    cError      = "":U
    cAttrNames  = "ObjectPath,StaticObject":U
    cAttrValues = fiSDODirectory:SCREEN-VALUE + CHR(3) + "yes":U + CHR(3)
    .

  RUN ShowMessage("Generating SDO in Repository ....").

  IF toCreate AND lSCMOk = YES THEN        
    RUN storeObject IN hObjApi 
      (  INPUT  "SDO":U,
         INPUT  coModule:SCREEN-VALUE,
         INPUT  cFileName,
         INPUT  "SDO for " + ttFileTable.tt_data[2], /* desc*/
         INPUT  cAttrNames,
         INPUT  cAttrValues,
         OUTPUT dSmobj).        
  
  IF RETURN-VALUE <> "":U THEN DO:
    RUN LogMessage(ttFileTable.tt_data[2],RETURN-VALUE,YES).
    ASSIGN lSCMOk = NO.
    IF RETURN-VALUE = "ABORT":U THEN
      LEAVE ROW-BLOCK.
  END.

  RUN ShowMessage("Compiling Static SDO ....").
  RUN adecomm/_osfmush.p (INPUT fiSDODirectory:SCREEN-VALUE, INPUT cFileName, OUTPUT tmpsdoName).
  IF SEARCH(tmpsdoname) <> ?
  THEN
    RUN af/cod2/fullocompile.p (tmpsdoname).

  RUN ShowMessage("Generating Logic Procedure in Repository ....").

  IF toCreate AND lSCMOk = YES THEN
  DO:
      ASSIGN cAttrNames  = "StaticObject":U
             cAttrValues = "YES":U
             .
      RUN storeObject IN hObjApi (  INPUT  "DLProc":U,
                                    INPUT  coModule:SCREEN-VALUE,
                                    INPUT  cLogicFileName,
                                    INPUT  "Logic Procedure for " + ttFileTable.tt_data[2], /* desc*/
                                    INPUT  cAttrNames,
                                    INPUT  cAttrValues,
                                    OUTPUT dSmobj).
      IF RETURN-VALUE <> "":U THEN 
      DO:
          RUN LogMessage(ttFileTable.tt_data[2],RETURN-VALUE,YES).
          ASSIGN lSCMOk = NO.
          IF RETURN-VALUE = "ABORT":U THEN
              LEAVE ROW-BLOCK.
      END.

      RUN ShowMessage("Compiling Static SDO Logic....").
      RUN adecomm/_osfmush.p (INPUT fiSDODirectory:SCREEN-VALUE, INPUT cLogicFileName, OUTPUT tmplogName).
      IF SEARCH(tmplogname) <> ? THEN
          COMPILE VALUE(tmplogname) SAVE.

      RUN ShowMessage("Compiling Static SDO Logic _cl....").
      ASSIGN tmplogclname = SUBSTRING(tmplogname,1,LENGTH(tmplogname) - 2) + "_cl.p":U.

      IF SEARCH(tmplogclname) <> ? THEN
          COMPILE VALUE(tmplogclname) SAVE. 
  END.  /* Create SDO Logic procedure. */

  PROCESS EVENTS. 
  
  ASSIGN cError = "":U.
  IF toGenBrowser:CHECKED THEN
  DO:
    RUN ShowMessage("Generating Dynamic Browser ....").
    RUN adecomm/_osfmush.p (INPUT fiRootDirectory:SCREEN-VALUE, fiSDODirectory:SCREEN-VALUE, OUTPUT sdodir).
    ASSIGN
      sdodir = REPLACE(sdodir,"\":U,"/":U).
    RUN rygenbrowse IN THIS-PROCEDURE ( INPUT cFileName,
                                        INPUT ttFileTable.tt_data[2], 
                                        INPUT coModule:SCREEN-VALUE,
                                        INPUT sdodir,
                                        INPUT cmaxnumflds,
                                        INPUT cnamesuffix,
                                        INPUT ttFileTable.tt_data[3],
                                        INPUT cSDOBrowseFields).
    IF RETURN-VALUE <> "":U THEN
      ASSIGN lSCMOk = NO
             cError = "Error from ryGenBrowse: " + RETURN-VALUE.
    ELSE
      ASSIGN cError = "Dynamic Browse Generation Successful. ":U.

    RUN LogMessage(ttFileTable.tt_data[2],cError,NO).
  END. /*if togenbrowser*/
  
  PROCESS EVENTS. 

  ASSIGN cError = "":U.
  IF toGenviewer:CHECKED THEN
  DO:
    RUN ShowMessage("Generating Dynamic Viewer ....").
    RUN af/cod2/afgenview.p ( INPUT codatabase:SCREEN-VALUE,
                              INPUT cfilename, 
                              INPUT ttFileTable.tt_data[2], 
                              INPUT comodule:SCREEN-VALUE,
                              INPUT firootdirectory:SCREEN-VALUE + "/":U + fiSDODirectory:SCREEN-VALUE ,
                              INPUT cvmaxnumflds, 
                              INPUT ttfiletable.tt_data[3],
                              INPUT cvnamesuffix,
                              INPUT cvmaxfldspercolumn,
                              INPUT cSDOViewerFields,
                              INPUT glDeleteViewerOnGeneration ).
    IF RETURN-VALUE <> "":U THEN
      ASSIGN lSCMOk = NO
             cError = "Error from afGenView: " + RETURN-VALUE.
    ELSE
      ASSIGN cError = "Dynamic Viewer Generation Successful. ":U.

    RUN LogMessage(ttFileTable.tt_data[2], cError,NO).
  END. /*if togenviewer*/

  IF lSCMOk
  THEN
    ASSIGN
      cError = "Create Repository records was Successful.":U.

  RUN LogMessage("", cError,NO).
  ASSIGN cError = "":U.

  PROCESS EVENTS. 

  IF SEARCH(tmpsdoname) <> ?
  THEN
    RUN VALUE(tmpsdoname) PERSISTENT SET sHdl.

  IF VALID-HANDLE(sHdl)
  THEN DO:

    RUN "initializeobject" IN sHdl NO-ERROR.

    IF geninstance:CHECKED AND lscmok THEN
    DO:
      RUN ShowMessage("Generating Instances ....").

      RUN storeinstance IN THIS-PROCEDURE(INPUT  fiSDODirectory:SCREEN-VALUE + "/":U + cfilename).

      IF RETURN-VALUE <> "":U THEN
        ASSIGN lSCMOk = NO
               cError = "Error from storeInstance: " + RETURN-VALUE.
      ELSE
        ASSIGN cError = "DataField Instance Generation Successful ":U.

      RUN LogMessage(ttFileTable.tt_data[2],cError,NO).
    END.    /* geninstance */

    RUN "destroyobject" IN sHdl.
    ASSIGN
      sHdl = ?.

  END.
  ELSE DO:
    ASSIGN
      lSCMOk = NO
      cError = "Error Generating Instances. SDO (" + tmpsdoname + ") not available ".
    RUN LogMessage("", cError,NO).
  END.

  RUN ShowMessage("Done ....").

  PROCESS EVENTS.  /* Check to see if user is trying to bailout  */

  IF done
  THEN LEAVE ROW-BLOCK.

END. /* ROW-BLOCK */
  
  RUN ShowMessage("Complete ....").
  
  ASSIGN
    giCount = 0
    giTotal = 0.
  RETURN.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE displayHelp C-Win 
PROCEDURE displayHelp :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

  MESSAGE 
"
Database: Select a currently connected database.
Tables  : Multi select browser of all tables in the selected database
"
    VIEW-AS ALERT-BOX INFO BUTTONS OK.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY coDatabase coModule fiRootDirectory fiSDODirectory gendataflds rsdo 
          RAFieldSequence toGenBrowser toGenViewer geninstance toSuppressAll 
          tofollow fiProcessingTable fprocessing 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE coDatabase coModule buAdvanced fiRootDirectory buRootDirectory 
         fiSDODirectory gendataflds rsdo RAFieldSequence toGenBrowser 
         toGenViewer buBrowserSettings geninstance buViewerSettings 
         toSuppressAll tofollow BrBrowse buSelectAll buDeSelect Brbrowse2 
         buGenerate buStop buExit buHelp prcnt RECT-1 RECT-2 RECT-3 RECT-4 
         RECT-6 RECT-7 RECT-8 RECT-9 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initValues C-Win 
PROCEDURE initValues :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE rRowid              AS ROWID                        NO-UNDO.
    DEFINE VARIABLE cProfileData        AS CHARACTER                    NO-UNDO.

    /* set Root Directory to the current working directory */
    /* A future algorithm may be to try to get root dir in the following order
     * 1) get root dir from RTB
     * 2) if not from RTB, then from config file manager's getSessionParam()
     * 3) do what we are doing here whioh is to use working dir
     * May want to do #3 in af/sup2/afstartup.p by setting grtb-wsroot to the working
     * dir as shown below. That might be a good place to do it in case someone changes
     * the working dir during open or something. I haven't seen this change but some
     * say it might                                                                  */
    IF CONNECTED("RTB":U) THEN
        ASSIGN FILE-INFO:FILE-NAME = Grtb-wsroot.
    ELSE
        ASSIGN FILE-INFO:FILE-NAME = ".":U.

    ASSIGN fiRootDirectory          = REPLACE(FILE-INFO:FULL-PATHNAME,"\":U,"/":U)
           BROWSE brbrowse2:ROW     = 10.52
           BROWSE brbrowse2:HEIGHT  = 11
           BROWSE brbrowse2:VISIBLE = FALSE
           BROWSE brbrowse:HEIGHT   = BROWSE brbrowse2:HEIGHT
           .

    /* Display Repository?  */
    ASSIGN rRowid = ?.
    RUN getProfileData IN gshProfileManager ( INPUT        "General":U,
                                              INPUT        "DispRepos":U,
                                              INPUT        "DispRepos":U,
                                              INPUT        NO,
                                              INPUT-OUTPUT rRowid,
                                                    OUTPUT cProfileData).
    ASSIGN glDisplayRepository = (cProfileData EQ "YES":U).

    RETURN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LogFooter C-Win 
PROCEDURE LogFooter :
/*------------------------------------------------------------------------------
  Purpose:     Write a log footer, and close the stream.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/ 
    /* Output Option Information */
    DISPLAY STREAM LogFile
        SKIP(2)
        ("Object Generation Completed at " + STRING(TIME, "HH:MM:SS":U)  )  FORMAT "x(110)":U AT 3 SKIP
        FILL("=":U, 110)                                                    FORMAT "x(110)":U AT 3
        SKIP(2)
        WITH
            DOWN
            FRAME frmFooter            
            NO-BOX
            STREAM-IO
            SIDE-LABELS
            WIDTH 118.

    OUTPUT STREAM LogFile CLOSE.
    RETURN. 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE logHeader C-Win 
PROCEDURE logHeader :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    /* Put Header on the Log file */
    OUTPUT STREAM Logfile CLOSE.                    
    IF glAppendToLogFile THEN
        OUTPUT STREAM Logfile TO VALUE(cLogFile) PAGE-SIZE 83 UNBUFFERED APPEND.
    ELSE
        OUTPUT STREAM Logfile TO VALUE(cLogFile) PAGE-SIZE 83 UNBUFFERED.


  FORM HEADER TODAY FORMAT "99/99/9999" 
              STRING(TIME,"HH:MM:SS") FORMAT "X(11)"
              "Generating SDOs for " + LDBNAME(1) FORMAT "X(35)" AT 50
              "PAGE" AT 100 PAGE-NUMBER(LogFile) FORMAT "zz9" SKIP (2)
        WITH FRAME hdr PAGE-TOP NO-BOX STREAM-IO WIDTH 118.
  VIEW STREAM LogFile FRAME hdr.

  /* Output Option Information */
  DISPLAY STREAM LogFile
      "OPTIONS:" AT 3
      "--------" AT 3 SKIP (1)
      coDatabase:SCREEN-VALUE IN FRAME {&frame-name} AT 3  FORMAT "X(19)" LABEL "Database"
      "Number of Tables selected:" AT 55 TableCount FORMAT "zz9" NO-LABEL SKIP
      cTemplate AT 3 FORMAT "X(40)" LABEL "SDO Template"
      cLogicTemplate AT 3 FORMAT "X(40)" LABEL "Logic Template"
      fiRootDirectory:screen-value IN FRAME {&frame-name} AT 3 FORMAT "X(50)" LABEL "Root Directory"
      fiSDODirectory:SCREEN-VALUE AT 3 FORMAT "x(50)" LABEL "SDO Directory"
      SKIP(2)
      WITH FRAME Opt1 NO-BOX STREAM-IO SIDE-LABELS WIDTH 118.
  IF ToGenBrowser:CHECKED THEN
    DISPLAY STREAM LogFile
      'Generate Browsers' AT 6
      WITH FRAME Opt3 NO-BOX STREAM-IO WIDTH 118.
  IF ToGenViewer:CHECKED THEN
    DISPLAY STREAM LogFile
      'Generate Viewers' AT 6
      WITH FRAME Opt3 NO-BOX STREAM-IO WIDTH 118.
  IF ToFollow:CHECKED THEN
    DISPLAY STREAM LogFile
      'Follow Joins' AT 6
      WITH FRAME Opt3 NO-BOX STREAM-IO WIDTH 118.
   
  IF ToSuppressAll:CHECKED THEN
      DISPLAY STREAM LogFile
      'Suppress all field validations.' AT 6
      WITH FRAME Opt3 NO-BOX STREAM-IO WIDTH 118.

  ELSE DISPLAY STREAM LogFile
      'Inherit all field validations.' AT 6
      WITH FRAME Opt3 NO-BOX STREAM-IO WIDTH 118.

  DISPLAY STREAM LogFile
      'Fields are sequenced ' + (IF raFieldSequence EQ 1 THEN 'by order.'
                                    ELSE 'alphabetically.') AT 6 FORMAT "X(60)"
      
      WITH FRAME Opt6 NO-BOX STREAM-IO WIDTH 118.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE logMessage C-Win 
PROCEDURE logMessage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pcTable       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pcMessage     AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER plShowMessage AS LOGICAL   NO-UNDO.

    DEFINE VARIABLE cButton AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cAnswer AS CHARACTER  NO-UNDO.

    IF pcTable = "Joins Followed":U 
    THEN PUT STREAM LogFile UNFORMATTED
           "   " pcTable.
    ELSE IF pcTable <> "":U THEN
            PUT STREAM LogFile UNFORMATTED 
                "   Table: "  pcTable.

    IF pcMessage <> "":U THEN
        PUT STREAM LogFile UNFORMATTED 
            ' - ' pcMessage SKIP.
    IF plShowMessage THEN DO:
      RUN askQuestion IN gshSessionManager (INPUT pcMessage + "~nDo you wish to continue?",      /* messages */
                                            INPUT "&Yes,&No":U,     /* button list */
                                            INPUT "&No":U,          /* default */
                                            INPUT "&No":U,          /* cancel */
                                            INPUT "Do you wish to continue?":U,     /* title */
                                            INPUT "":U,             /* datatype */
                                            INPUT "":U,             /* format */
                                            INPUT-OUTPUT cAnswer,   /* answer */
                                            OUTPUT cButton          /* button pressed */
                                            ).
      IF cButton <> "&Yes":U THEN
        RETURN "ABORT":U.
    END.
    RETURN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mipGetFolder C-Win 
PROCEDURE mipGetFolder :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

DEFINE INPUT  PARAMETER ipTitle AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER opPath  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lhServer AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE lhFolder AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE lhParent AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE lvFolder AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lvCount  AS INTEGER    NO-UNDO.
DEFINE VARIABLE cButtonPressed          AS CHARACTER                NO-UNDO.
DEFINE VARIABLE cErrorText              AS CHARACTER                NO-UNDO.

CREATE 'Shell.Application' lhServer NO-ERROR.

    IF ERROR-STATUS:ERROR THEN
    DO WITH FRAME {&FRAME-NAME}:
        /* Disable folder lookup buttons. */
        ASSIGN buSdoDirectory-2:SENSITIVE = NO
               buRootDirectory:SENSITIVE  = NO
               .
        /* Inform user. */
        DO lvCount = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN cErrorText = cErrorText + (IF NUM-ENTRIES(cErrorText, "~n":U) EQ 0 THEN "":U ELSE "~n":U)
                              + ERROR-STATUS:GET-MESSAGE(lvCount).
        END.    /* count error messages */
        RUN showMessages IN gshSessionManager (INPUT  {aferrortxt.i 'AF' '40' '?' '?' "cErrorText" },
                                               INPUT  "ERR",                                /* error type */
                                               INPUT  "&OK",                                /* button list */
                                               INPUT  "&OK",                                /* default button */ 
                                               INPUT  "&OK",                                /* cancel button */
                                               INPUT  "Error Creating Automation Server",   /* error window title */
                                               INPUT  YES,                                  /* display if empty */ 
                                               INPUT  ?,                                    /* container handle */ 
                                               OUTPUT cButtonPressed            ).          /* button pressed */                                          
        ASSIGN opPath = ?.
        RETURN.
    END.    /* Error. */

ASSIGN
    lhFolder = lhServer:BrowseForFolder(c-win:HWND,ipTitle,0).

IF VALID-HANDLE(lhFolder) = True 
THEN DO:
    ASSIGN 
        lvFolder = lhFolder:Title
        lhParent = lhFolder:ParentFolder
        lvCount  = 0.
    REPEAT:
        IF lvCount >= lhParent:Items:Count THEN
            DO:
                ASSIGN
                    opPath = "":U.
                LEAVE.
            END.
        ELSE
            IF lhParent:Items:Item(lvCount):Name = lvFolder THEN
                DO:
                    ASSIGN
                        opPath = lhParent:Items:Item(lvCount):Path.
                    LEAVE.
                END.
        ASSIGN lvCount = lvCount + 1.
    END.
END.
ELSE
    ASSIGN
        opPath = "":U.

RELEASE OBJECT lhParent NO-ERROR.
RELEASE OBJECT lhFolder NO-ERROR.
RELEASE OBJECT lhServer NO-ERROR.

ASSIGN
  lhParent = ?
  lhFolder = ?
  lhServer = ?
  .

ASSIGN opPath = TRIM(REPLACE(LC(opPath),"\":U,"/":U),"/":U).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateDatabase C-Win 
PROCEDURE populateDatabase :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE lv_loop         AS INTEGER INITIAL 1                NO-UNDO.
    DEFINE VARIABLE lExists         AS LOGICAL                          NO-UNDO.

    DO WITH FRAME {&FRAME-NAME}:
        ASSIGN coDatabase:LIST-ITEMS = "":U
               coModule:LIST-ITEMS   = "":U
               lv_loop               = 1
               .
        DO lv_loop = 1 TO NUM-DBS:
            /* then any db is fine */
            IF glDisplayRepository THEN
                coDatabase:ADD-LAST(LDBNAME(lv_loop)).
            ELSE
            /* show only non-repos */
            IF LOOKUP(LDBNAME(lv_loop), "ICFDB,RVDB,RTB,TEMP-DB":U) EQ 0 THEN
                coDatabase:ADD-LAST(LDBNAME(lv_loop)).
        END. /* end loop through DBs */

        IF coDatabase:LIST-ITEMS <> "":U AND coDatabase:LIST-ITEMS <> ? THEN
            /* for now set to first one -- til we track sessiond db in ab */
            /* ASSIGN coDatabase:SCREEN-VALUE = sessionDbName. */
            ASSIGN coDatabase:SCREEN-VALUE = coDatabase:ENTRY(1). 

        coModule:ADD-LAST("<None>":U).

        FOR EACH gsc_product_module
                 NO-LOCK
                 BY gsc_product_module.product_module_code:
            /* Display Repository-owned product modules only if the relevant flag is set.
             * Checking for these based on the code is a temporary measure.              */
            IF NOT glDisplayRepository AND
               ( gsc_product_module.product_module_code BEGINS "RY":U  OR
                 gsc_product_module.product_module_code BEGINS "RV":U  OR
                 gsc_product_module.product_module_code BEGINS "ICF":U OR
                 gsc_product_module.product_module_code BEGINS "AF":U  OR
                 gsc_product_module.product_module_code BEGINS "GS":U  OR
                 gsc_product_module.product_module_code BEGINS "AS":U  OR
                 gsc_product_module.product_module_code BEGINS "RTB":U   ) THEN
                NEXT.

            /*****/
            IF CONNECTED("RTB":U) THEN
            DO:
                IF NOT VALID-HANDLE(hScmTool) THEN
                    RUN rtb/prc/afrtbprocp.p PERSISTENT SET hScmTool.

                RUN scmModuleInWorkspace IN hScmTool ( INPUT  gsc_product_module.product_module_code,
                                                       INPUT  grtb-wspace-id,
                                                       OUTPUT lExists).
                IF lExists THEN
                    coModule:ADD-LAST(gsc_product_module.product_module_code).
            END.
            ELSE
                /*****/
                coModule:ADD-LAST(gsc_product_module.product_module_code).
        END.    /* each product module. */

        IF coModule:LIST-ITEMS <> "":U AND coModule:LIST-ITEMS <> ? THEN
            /* later we need to init to sessionModule */
            ASSIGN coModule:SCREEN-VALUE = ENTRY(1,coModule:LIST-ITEMS).        
    END.    /* with frame ... */

    RETURN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateScreen C-Win 
PROCEDURE populateScreen :
/*------------------------------------------------------------------------------
  Purpose:    Assign all the values and display the Screen. 
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    DEFINE VARIABLE lExists                   AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE cShareStatus              AS CHARACTER  NO-UNDO.

    DO WITH FRAME {&FRAME-NAME}:
/*****/      IF CONNECTED("RTB":U) THEN
      DO:
        IF NOT VALID-HANDLE(hScmTool) THEN
            RUN rtb/prc/afrtbprocp.p PERSISTENT SET hScmTool.
        RUN scmGetTaskShareStatus IN hScmTool (INPUT grtb-task-num,
                                               OUTPUT lExists,
                                               OUTPUT cShareStatus).       
        IF lExists = NO THEN
        DO:
          RETURN "Select a valid task in SCM Tool to continue".        
        END.
        IF cShareStatus <> "CENTRAL":U THEN
        DO:
          RETURN "SCM Tool task share status must be Central to continue".
        END.
      END.
/****/
      ASSIGN
        fiTask    = grtb-task-num
        fiWspace  = grtb-wspace-id
        coModule  = ""
        fiSDOGroup   = "SDO"
        fiSDOSubtype = "SDO"
        fiLogicGroup   = "DLProc"
        fiLogicSubtype = "DLProc"
        fiSDODirectory = "":U
        toLogicOverwrite = NO
        toSDOOverwrite = YES
        toCreate = YES
       raFieldSequence = 1
        toSuppressAll = YES 
        toGenBrowser = FALSE
        toGenViewer = FALSE
        /*fiRootDirectory =  (IF grtb-wsroot <> "":U THEN TRIM(REPLACE(LC(grtb-wsroot),"\":U,"/":U),"/":U) ELSE 
                           TRIM(REPLACE(LC(SESSION:TEMP-DIR),"\":U,"/":U),"/":U))
        */
        fiSDODirectory = "":U
        buStop:SENSITIVE = NO
        .      

      DISPLAY
       coModule
       fiRootDirectory
       fiSDODirectory
       raFieldSequence 
       toSuppressAll 
       /*toSuppressCanFind*/
          .
        

    END.

ERROR-STATUS:ERROR = NO.
RETURN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateSDOtable C-Win 
PROCEDURE populateSDOtable :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAM pproduct_module_code LIKE gsc_product_module.product_module_code NO-UNDO.
DEFINE BUFFER bgsc_object_type FOR gsc_object_type.
DEFINE BUFFER bryc_smartobject FOR ryc_smartobject.
DEFINE BUFFER bgsc_object FOR gsc_object.
DEFINE BUFFER bgsc_product_module FOR gsc_product_module.

    CLOSE QUERY BrBrowse2.
    EMPTY TEMP-TABLE ttsdoTable.
    
    FOR EACH bgsc_object_type NO-LOCK
    WHERE bgsc_object_type.object_type_code = "SDO",
    EACH bryc_smartobject NO-LOCK
    WHERE bryc_smartobject.OBJECT_type_obj = bgsc_object_type.OBJECT_type_obj,
    FIRST bgsc_object NO-LOCK
    WHERE bgsc_object.OBJECT_obj = bryc_smartobject.OBJECT_obj,
    FIRST bgsc_product_module  NO-LOCK
    WHERE bgsc_product_module.product_module_obj = bryc_smartobject.product_module_obj AND
         bgsc_product_module.product_module_code = pproduct_module_code
    BY bryc_smartobject.object_filename:
         
         CREATE ttsdotable.

         ASSIGN
           tt_product_module_code = bgsc_product_module.product_module_code     
           tt_object_filename = bryc_smartobject.object_filename         
           tt_object_description = bgsc_object.object_description      
           tt_object_path = bgsc_object.object_path.
           
    END. /*for each bgsc_object*/

    OPEN QUERY BrBrowse2 FOR EACH ttsdoTable NO-LOCK.
    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE populateTable C-Win 
PROCEDURE populateTable :
/*------------------------------------------------------------------------------
  Purpose: populate the list of tables to select. This changes if the dbname 
           changes.    
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE cSchemaName             AS CHARACTER                NO-UNDO.
    DEFINE VARIABLE cWhere                  AS CHARACTER                NO-UNDO.
    DEFINE VARIABLE cTableName              AS CHARACTER                NO-UNDO.
    DEFINE VARIABLE cFileName               AS CHARACTER                NO-UNDO.
    DEFINE VARIABLE hDbBuffer               AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE hFileBuffer             AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE hFieldTableType         AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE hFieldFileName          AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE hFieldDUmpName          AS HANDLE                   NO-UNDO.
    DEFINE VARIABLE hQuery                  AS HANDLE                   NO-UNDO.
    
    DO WITH FRAME {&FRAME-NAME}:
        CLOSE QUERY BrBrowse.
        EMPTY TEMP-TABLE ttFileTable.

        /* Don't attempt to populate the table without a db */
        IF coDatabase:INPUT-VALUE EQ "":U THEN
            RETURN.

        /* If the logical object name and the schema name differ, then we assume that we are working with 
         * a DataServer. If the schema and logical names are the same, we are dealing with a native 
         * Progress DB.
         *
         * We also only want to display non-SQL files and files which are not hidden.               */
        ASSIGN cSchemaName = SDBNAME(coDatabase:INPUT-VALUE).

        IF cSchemaName EQ coDatabase:INPUT-VALUE THEN
            ASSIGN cTableName = coDatabase:INPUT-VALUE + "._Db":U
                   cFileName  = coDatabase:INPUT-VALUE + "._File":U
                   cWhere     = "FOR EACH ":U + cTableName + " NO-LOCK, ":U
                              + " EACH " + cFileName + " WHERE ":U
                              +  cFileName + "._Db-recid = RECID(_Db) AND ":U
                              +  cFileName + "._Owner    = 'Pub'      AND ":U
                              +  cFileName + "._Hidden   = FALSE ":U
                              + " NO-LOCK ":U.
        ELSE
            ASSIGN cTableName = cSchemaName + "._Db":U                                      
                   cFileName  = cSchemaName + "._File":U                   
                   cWhere     = " FOR EACH ":U + cTableName + " WHERE ":U
                              +   cTableName + "._Db-Name = '" + coDatabase:INPUT-VALUE + "' ":U
                              + " NO-LOCK, ":U
                              + " EACH " + cFileName + " WHERE ":U
                              +  cFileName + "._Db-recid = RECID(_Db) AND ":U
                              +  cFileName + "._Owner    = '_Foreign' AND ":U
                              +  cFileName + "._Hidden   = FALSE ":U
                              + " NO-LOCK ":U.

        CREATE BUFFER hDbBuffer         FOR TABLE cTableName.
        CREATE BUFFER hFileBuffer       FOR TABLE cFileName.
        CREATE QUERY hQuery.

        ASSIGN hFieldTableType = hFileBuffer:BUFFER-FIELD("_Tbl-type":U)
               hFieldFileName  = hFileBuffer:BUFFER-FIELD("_File-name":U)
               hFieldDumpName  = hFileBuffer:BUFFER-FIELD("_Dump-name":U)
               .
        hQuery:SET-BUFFERS(hDbBuffer, hFileBuffer).
        hQuery:QUERY-PREPARE(cWhere).
        hQuery:QUERY-OPEN().

        hQuery:GET-FIRST(NO-LOCK).

        DO WHILE hDbBuffer:AVAILABLE:
            CREATE ttfiletable.
            ASSIGN ttfiletable.tt_tag     = TRIM(hFieldTableType:STRING-VALUE)
                   ttfiletable.tt_data[1] = TRIM(hFieldTableType:STRING-VALUE)
                   ttfiletable.tt_data[2] = TRIM(hFieldFileName:STRING-VALUE)
                   ttfiletable.tt_data[3] = TRIM(hFieldDumpName:STRING-VALUE)
                   ttfiletable.tt_db      = coDatabase:INPUT-VALUE      /* use the combo name incase of data server. */
                   ttfiletable.tt_type    = hFileBuffer:TABLE
                   ttfiletable.tt_data[4] = STRING(hFileBuffer:RECID)
                   .
            hQuery:GET-NEXT(NO-LOCK).
        END.    /* avail db buffer */

        hQuery:QUERY-CLOSE().

        DELETE OBJECT hQuery NO-ERROR.
        ASSIGN hQuery = ?.

        DELETE OBJECT hDbBuffer NO-ERROR.
        ASSIGN hDbBuffer = ?.

        DELETE OBJECT hFileBuffer NO-ERROR.
        ASSIGN hFileBuffer = ?.

        DELETE OBJECT hFieldTableType NO-ERROR.
        ASSIGN hFieldTableType = ?.

        DELETE OBJECT hFieldFileName NO-ERROR.
        ASSIGN hFieldFileName = ?.

        DELETE OBJECT hFieldDumpName NO-ERROR.
        ASSIGN hFieldDumpName = ?.
        
        OPEN QUERY BrBrowse FOR EACH ttFileTable WHERE ttFileTable.tt_tag = "T" BY tt_data[2].
    END.    /* with frame ... */

    RETURN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rygenbrowse C-Win 
PROCEDURE rygenbrowse :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/*Input parameters*/
DEFINE INPUT PARAMETER csdoname                      AS CHAR       NO-UNDO.
DEFINE INPUT PARAMETER tablename                     AS CHAR       NO-UNDO.
DEFINE INPUT PARAMETER productmodule                 AS CHAR       NO-UNDO.
DEFINE INPUT PARAMETER relativepath                  AS CHAR       NO-UNDO.
DEFINE INPUT PARAMETER maxflds                       AS INT        NO-UNDO.
DEFINE INPUT PARAMETER objectnamesuffix              AS CHAR       NO-UNDO.
DEFINE INPUT PARAMETER dumpname                      AS CHAR       NO-UNDO.
DEFINE INPUT PARAMETER lSDOBrowseFields              AS LOGICAL    NO-UNDO.

/*local variables*/
DEFINE VARIABLE maxfields                     AS CHAR       NO-UNDO.
DEFINE VARIABLE fieldnames                    AS CHAR       NO-UNDO.
DEFINE VARIABLE fieldvalues                   AS CHAR       NO-UNDO.
DEFINE VARIABLE cprocname                     AS CHAR       NO-UNDO.
DEFINE VARIABLE etest                         AS CHAR       NO-UNDO.
DEFINE VARIABLE selectedfields                AS CHAR       NO-UNDO.
DEFINE VARIABLE iLoop                         AS INTEGER    NO-UNDO.
DEFINE VARIABLE cEntry                        AS CHARACTER  NO-UNDO.
DEFINE VARIABLE cField                        AS CHARACTER  NO-UNDO.
DEFINE VARIABLE lEnabled                      AS LOGICAL    NO-UNDO.
DEFINE VARIABLE cSdoInclude                   AS CHAR       NO-UNDO.
DEFINE VARIABLE iPosn1                        AS INTEGER    NO-UNDO.
DEFINE VARIABLE iPosn2                        AS INTEGER    NO-UNDO.
DEFINE VARIABLE cLine                         AS CHAR       NO-UNDO.
DEFINE VARIABLE objectname                    AS CHAR       NO-UNDO.
DEFINE VARIABLE cmes                          AS CHAR       NO-UNDO.
DEFINE VARIABLE psdo                          AS CHAR       NO-UNDO.
DEFINE VARIABLE cSchemaName                     AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE hDbBuffer                       AS HANDLE                       NO-UNDO.
DEFINE VARIABLE hFileBuffer                     AS HANDLE                       NO-UNDO.
DEFINE VARIABLE hFieldBuffer                    AS HANDLE                       NO-UNDO.
DEFINE VARIABLE hQuery                          AS HANDLE                       NO-UNDO. 
DEFINE VARIABLE hFieldNameField                 AS HANDLE                       NO-UNDO.
DEFINE VARIABLE cWhere                          AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE cDbBufferName                   AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE cFileBufferName                 AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE cFieldBufferName                AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE cLogicalDbName                  AS CHARACTER                    NO-UNDO.

/*sample input*/
/* ASSIGN                       */
/* csdoname = "customerfullo.w" */
/* tablename = "customer"       */
/* productmodule = "module"   */
/* maxflds = 2                  */
/* relativepath = "sdo"         */
/* objectnamesuffix = "test5".  */

IF objectnamesuffix = "" THEN objectnamesuffix = "fullb" .
REPLACE(relativepath,"\","/").
IF SUBSTRING(relativepath,LENGTH(relativepath),1) <> "/"
    THEN relativepath = relativepath + "/".
psdo = csdoname.
csdoname = relativepath  + csdoname.

/* use fields in SDO*/
IF lSDOBrowseFields 
THEN DO:
    IF NUM-ENTRIES(cSdoName,".":U) < 2 THEN
      cSdoInclude = SEARCH(cSdoName + ".i").
    ELSE
      cSdoInclude = SEARCH(REPLACE(cSdoName, ".w":U,".i":U)).

    IF cSdoInclude <> ? THEN DO:
      ASSIGN iLoop = 0.
      INPUT FROM VALUE(cSdoInclude) NO-ECHO.
      import-loop:
      REPEAT:
          IMPORT UNFORMATTED cLine.
          ASSIGN
              iPosn1 = INDEX(cLine, 'FIELD ')
              iPosn2 = INDEX(cLine,' ', iPosn1 + 6)
            .
          IF iPosn1 > 1 AND iPosn2 > iPosn1 THEN
              ASSIGN cField = TRIM(SUBSTRING(cLine, (iPosn1 + 6), iPosn2 - (iPosn1 + 6))).      
          ELSE
              ASSIGN cField = "":U.

          IF cField <> "":U THEN DO:

              ASSIGN iLoop = iLoop + 1.

              ASSIGN  selectedfields =  selectedfields +  CHR(3) +
                    STRING(iLoop) + CHR(4) +
                    STRING(cField) + CHR(4) +
                    STRING(NO).
                   IF iloop = maxflds THEN LEAVE import-loop.
          END.
      END. /*repeat import-loop*/
      INPUT CLOSE.
    END.
END.

ELSE DO:
  /*use entiity mnemonic to get fieldnames if avail*/
  FIND FIRST gsc_entity_mnemonic WHERE  gsc_entity_mnemonic.entity_mnemonic_description =
      tablename NO-LOCK NO-ERROR.
  
  IF AVAIL gsc_entity_mnemonic THEN DO:
      iLoop = 0.
       FOR EACH gsc_entity_display_field WHERE gsc_entity_display_field.entity_mnemonic =
           gsc_entity_mnemonic.entity_mnemonic NO-LOCK BY gsc_entity_display_field.display_field_order:
  
           /* Don't add any ObjectId field (*_OBJ) to a browse. */
           IF NOT gsc_entity_display_field.display_field_name MATCHES "*_obj":U THEN
               ASSIGN iLoop = iLoop + 1
                      selectedfields = selectedfields + CHR(3)
                                     + STRING(iLoop) + CHR(4)
                                     + STRING(gsc_entity_display_field.display_field_name) + CHR(4)
                                     + STRING(NO).
       END.
  END.
END.  

/* If there are no selected fields here, get the fields off the metaschema. */
IF SelectedFields EQ "":U THEN
DO:
    /* If the logical object name and the schema name differ, then we assume that we are working with 
     * a DataServer. If the schema and logical names are the same, we are dealing with a native 
     * Progress DB.                                                                                   */
    ASSIGN cLogicalDbName = coDatabase:INPUT-VALUE IN FRAME {&FRAME-NAME}
           cSchemaName    = SDBNAME(cLogicalDbName)
           .
    IF cSchemaName EQ cLogicalDbName THEN
        ASSIGN cDbBufferName    = cLogicalDbName + "._Db":U
               cFileBufferName  = cLogicalDbName + "._File":U
               cFieldBufferName = cLogicalDbName + "._Field":U
               cWhere           = "FOR EACH ":U + cDbBufferName + " NO-LOCK, ":U
                                + " EACH " + cFileBufferName + " WHERE ":U
                                +   cFileBufferName + "._Db-recid  = RECID(":U + cDbBufferName + ") AND ":U
                                +   cFileBufferName + "._File-name = '":U + TableName + "' AND ":U
                                +   cFileBufferName + "._Owner     = 'PUB':U ":U
                                + " NO-LOCK, ":U
                                + " EACH ":U + cFieldBufferName + " WHERE ":U
                                +   cFieldBufferName + "._File-recid = RECID(":U + cFileBufferName + ") ":U
                                + " NO-LOCK ":U
                                + " BY ":U + cFieldBufferName + "._Order":U.
    ELSE
        ASSIGN cDbBufferName    = cSchemaName + "._Db":U
               cFileBufferName  = cSchemaName + "._File":U
               cFieldBufferName = cSchemaName + "._Field":U
               cWhere           = " FOR EACH ":U + cDbBufferName + " WHERE ":U
                                +   cDbBufferName + "._Db-Name = '" + cLogicalDbName + "' ":U
                                + " NO-LOCK, ":U
                                + " EACH " + cFileBufferName + " WHERE ":U
                                +   cFileBufferName + "._Db-recid  = RECID(":U + cDbBufferName + ") AND ":U
                                +   cFileBufferName + "._File-name = '":U + TableName + "' AND ":U
                                +   cFileBufferName + "._Owner     = '_Foreign':U ":U
                                + " NO-LOCK, ":U
                                + " EACH ":U + cFieldBufferName + " WHERE ":U
                                +   cFieldBufferName + "._File-recid = RECID(":U + cFileBufferName + ") ":U
                                + " NO-LOCK ":U
                                + " BY ":U + cFieldBufferName + "._Order":U.

    CREATE BUFFER hDbBuffer     FOR TABLE cDbBufferName     NO-ERROR.   {afcheckerr.i}
    CREATE BUFFER hFileBuffer   FOR TABLE cFileBufferName   NO-ERROR.   {afcheckerr.i}
    CREATE BUFFER hFieldBuffer  FOR TABLE cFieldBufferName  NO-ERROR.   {afcheckerr.i}

    CREATE QUERY hQuery NO-ERROR.
        {afcheckerr.i}

    hQuery:SET-BUFFERS(hDbBuffer, hFileBuffer, hFieldBuffer) NO-ERROR.
        {afcheckerr.i}

    hQuery:QUERY-PREPARE(cWhere) NO-ERROR.
        {afcheckerr.i}

    hQuery:QUERY-OPEN() NO-ERROR.
        {afcheckerr.i}

    hQuery:GET-FIRST(NO-LOCK) NO-ERROR.
        {afcheckerr.i}

    ASSIGN iLoop = 0.
    
    DO WHILE hFieldBuffer:AVAILABLE AND iLoop <= maxflds:
        ASSIGN hFieldNameField = hFieldBuffer:BUFFER-FIELD("_Field-Name":U).

        /* Don't add any ObjectId field (*_OBJ) to a browse. */
        IF NOT hFieldNameField:BUFFER-VALUE MATCHES "*_obj":U THEN
            ASSIGN iLoop          = iLoop + 1
                   selectedfields = selectedfields + CHR(3)
                                  + STRING(iLoop) + CHR(4)
                                  + STRING(hFieldNameField:BUFFER-VALUE) + CHR(4)
                                  + STRING(NO)
                   .
        hQuery:GET-NEXT(NO-LOCK).
    END.    /* lop through fields. */

    hQuery:QUERY-CLOSE().

    DELETE OBJECT hQuery.
    ASSIGN hQuery = ?.

    DELETE OBJECT hFieldNameField NO-ERROR.
    ASSIGN hFieldNameField = ?.

    DELETE OBJECT hFieldBuffer NO-ERROR.
    ASSIGN hFieldBuffer = ?.

    DELETE OBJECT hFileBuffer NO-ERROR.
    ASSIGN hFileBuffer = ?.

    DELETE OBJECT hDbBuffer NO-ERROR.
    ASSIGN hDbBuffer = ?.

END.    /* no selected fields */
  
  ASSIGN objectname =  dumpname + objectnamesuffix
         fieldnames =  "customsuperprocedure" + CHR(2) +
                       "launchcontainer" + CHR(2) +
                       "objectdescription" + CHR(2 )+
                       "objectname" + CHR(2) +
                       "productmodulecode" + CHR(2) +
                       "sdoname" + CHR(2) +
                       "selectedfields" 
         fieldvalues = "" + CHR(2) +
                       "" + CHR(2) +
                       tablename + "Dynamic Browser"  + CHR(2) +
                       objectname + CHR(2) +
                       productmodule + CHR(2) +
                       psdo  + CHR(2) +
                       selectedfields
         cProcName   = "storebrowser".

/* Delete the browse */
IF glDeleteBrowseOnGeneration THEN
DO:
    { launch.i
        &PLIP     = 'ry/app/ryreposobp.p'
        &IProc    = 'DeleteObject'
        &PList    = "(INPUT ObjectName, OUTPUT eTest)"
        &AutoKill = NO
    }
    IF eTest EQ "" THEN
        ASSIGN cMes = " Browser Deletion Successful.":U.
    ELSE
        ASSIGN cMes = " Browser Deletion NOT Successful." + "chr(10)" + eTest.
END.    /* delete browse */

{afrun2.i &PLIP = 'ry/app/ryreposobp.p'
                  &IProc = cProcName
                  &PList = "(INPUT objectname , INPUT fieldnames, INPUT fieldvalues, OUTPUT etest)"
                  &OnApp = 'no'}

              IF etest = "" THEN
              ASSIGN cmes = " Browser Generation Successful. ":U.
              ELSE cmes = " Browser Generation NOT Successful." + "chr(10)" + etest.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setButtons C-Win 
PROCEDURE setButtons :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

/* change the start and stop buttons' sensitivity  to the opposite of
 * what they are now 
 */
 DO WITH FRAME {&FRAME-NAME}:

 ASSIGN 
     codatabase:SENSITIVE        = NOT codatabase:SENSITIVE
     comodule:SENSITIVE          = NOT comodule:SENSITIVE
     firootdirectory:SENSITIVE   = NOT firootdirectory:SENSITIVE
     fiSDOdirectory:SENSITIVE    = NOT  fiSDOdirectory:SENSITIVE
     buAdvanced:SENSITIVE        = NOT buAdvanced:SENSITIVE 
     rsdo:SENSITIVE              = NOT rsdo:SENSITIVE
     tosuppressall:SENSITIVE     = NOT  tosuppressall:SENSITIVE
     RAFieldSequence:SENSITIVE   = NOT  RAFieldSequence:SENSITIVE
     toGenBrowser:SENSITIVE      = NOT  toGenBrowser:SENSITIVE 
     buBrowserSettings:SENSITIVE = NOT  buBrowserSettings:SENSITIVE
     togenviewer:SENSITIVE       = NOT   togenviewer:SENSITIVE
     buviewersettings:SENSITIVE  = NOT buviewersettings:SENSITIVE 
     gendataflds:SENSITIVE       = IF toGenBrowser:CHECKED OR 
                                      toGenViewer:CHECKED 
                                   THEN gendataflds:SENSITIVE
                                   ELSE NOT gendataflds:SENSITIVE
     geninstance:SENSITIVE       = NOT geninstance:SENSITIVE 
     buselectall:SENSITIVE       = NOT buselectall:SENSITIVE
     budeselect:SENSITIVE        = NOT budeselect:SENSITIVE  
     brbrowse:SENSITIVE          = NOT brbrowse:SENSITIVE   
     brbrowse2:SENSITIVE         = NOT brbrowse2:SENSITIVE 
     buhelp:SENSITIVE            = NOT buhelp:SENSITIVE 
     tofollow:SENSITIVE          = NOT tofollow:SENSITIVE
     buGenerate:SENSITIVE        = NOT buGenerate:SENSITIVE   
     buStop:SENSITIVE            = NOT buGenerate:SENSITIVE
     buExit:SENSITIVE            = buGenerate:SENSITIVE.
     
 END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE showMessage C-Win 
PROCEDURE showMessage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT  PARAMETER pcMessage AS CHARACTER  NO-UNDO.

DO WITH FRAME {&FRAME-NAME}:
  ASSIGN
    fprocessing:SCREEN-VALUE = pcMessage
    giCount = giCount + 1
    prcnt   = giCount / giTotal * 100.

  DISPLAY 
    prcnt 
    WITH FRAME {&FRAME-NAME}.

  PROCESS EVENTS.

END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE storeinstance C-Win 
PROCEDURE storeinstance :
/*------------------------------------------------------------------------------
  Purpose:     Store data field info in repos
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAM cfilename        AS CHARACTER                    NO-UNDO.

    DEFINE VARIABLE tmpenabled              AS CHAR             NO-UNDO.
    DEFINE VARIABLE tdatacolumns            AS CHAR             NO-UNDO.
    DEFINE VARIABLE fieldcnt                AS INTEGER          NO-UNDO.
    DEFINE VARIABLE pcfieldsmartObject      AS DECIMAL          NO-UNDO.
    DEFINE VARIABLE ttablename              AS CHAR             NO-UNDO.
    DEFINE VARIABLE dfldname                AS CHAR             NO-UNDO.
    DEFINE VARIABLE dfinstance              AS DECIMAL          NO-UNDO.
    DEFINE VARIABLE cattrnames              AS CHAR             NO-UNDO.
    DEFINE VARIABLE cattrvalues             AS CHAR             NO-UNDO.
    DEFINE VARIABLE tmplabel                AS CHAR             NO-UNDO.
    DEFINE VARIABLE tmpextent               AS CHAR             NO-UNDO.
    DEFINE VARIABLE tmphelp                 AS CHAR             NO-UNDO.
    DEFINE VARIABLE tmpformat               AS CHAR             NO-UNDO.
    DEFINE VARIABLE iExtent                 AS INTEGER    NO-UNDO.

    DO WITH FRAME {&FRAME-NAME}:
        /*get all fields from SDO*/
        ASSIGN tdatacolumns = DYNAMIC-FUNCTION("getdatacolumns" IN shdl)
               ttablename   = DYNAMIC-FUNCTION("columntable" IN shdl, ENTRY(1, tdatacolumns))
               dfldname     = ttablename + "." + ENTRY(1, tdatacolumns)
               .

        IF DYNAMIC-FUNCTION("smartobjectobj" IN hobjapi, dFldName) = ? THEN
            RETURN "DataFields must be generated before DataField instances can be created.".
        ELSE
        DO fieldcnt = 1 TO NUM-ENTRIES(tdatacolumns):
            ASSIGN tmpenabled = DYNAMIC-FUNCTION("columnreadonly" IN shdl, ENTRY(fieldcnt, tdatacolumns))
                   tmplabel   = DYNAMIC-FUNCTION("columnlabel" IN shdl, ENTRY(fieldcnt, tdatacolumns))
                   tmphelp    = DYNAMIC-FUNCTION("columnhelp" IN shdl, ENTRY(fieldcnt, tdatacolumns))
                   tmpformat  = DYNAMIC-FUNCTION("columnformat" IN shdl, ENTRY(fieldcnt, tdatacolumns))
                   tmpextent  = DYNAMIC-FUNCTION("columnextent" IN shdl, ENTRY(fieldcnt, tdatacolumns))
                   ttablename = DYNAMIC-FUNCTION("columntable" IN shdl,ENTRY(fieldcnt, tdatacolumns)).

            IF tmpextent = "0" THEN DO:
              ASSIGN
                dfldname   = ttablename + "." + ENTRY(fieldcnt, tdatacolumns).

              RUN storeObjectInstance IN hobjapi ( INPUT  dSmobj,
                                                   INPUT  dFldName,
                                                   INPUT  "":U, 
                                                   OUTPUT pcfieldsmartObject,
                                                   OUTPUT dfinstance ).
  
              ASSIGN cattrnames  = "FieldName,TableName,DatabaseName,Label,Format,Help,Enabled":U
                     cattrvalues = dfldname                   + CHR(3)
                                 + ttablename                 + CHR(3)
                                 + codatabase:SCREEN-VALUE    + CHR(3)
                                 + tmplabel                   + CHR(3)
                                 + tmpformat                  + CHR(3)
                                 + tmphelp                    + CHR(3) 
                                 + tmpenabled
                     .
              RUN storeAttributeValues IN hobjapi ( INPUT 0, 
                                                    INPUT pcfieldsmartObject,
                                                    INPUT dSmobj,
                                                    INPUT dfinstance,
                                                    INPUT cattrnames,
                                                    INPUT cattrvalues).
            END.
            ELSE DO iExtent = 1 TO INTEGER(tmpExtent):
              ASSIGN
                dfldname   = ttablename + "." + ENTRY(fieldcnt, tdatacolumns) + "[" + STRING(iExtent) + "]".

              RUN storeObjectInstance IN hobjapi ( INPUT  dSmobj,
                                                   INPUT  dFldName,
                                                   INPUT  "":U, 
                                                   OUTPUT pcfieldsmartObject,
                                                   OUTPUT dfinstance ).
  
              ASSIGN cattrnames  = "FieldName,TableName,DatabaseName,Label,Format,Help,Enabled":U
                     cattrvalues = dfldname                   + CHR(3)
                                 + ttablename                 + CHR(3)
                                 + codatabase:SCREEN-VALUE    + CHR(3)
                                 + tmplabel                   + CHR(3)
                                 + tmpformat                  + CHR(3)
                                 + tmphelp                    + CHR(3) 
                                 + tmpenabled
                     .
              RUN storeAttributeValues IN hobjapi ( INPUT 0, 
                                                    INPUT pcfieldsmartObject,
                                                    INPUT dSmobj,
                                                    INPUT dfinstance,
                                                    INPUT cattrnames,
                                                    INPUT cattrvalues).
            END.

       END. /* fieldcnt = 1 TO NUM-ENTRIEs...*/
    END.    /* with frame */

    RETURN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE useExistingSDO C-Win 
PROCEDURE useExistingSDO :
/*------------------------------------------------------------------------------
  Purpose:     Generates objects based on an existing SDO.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iLoop                   AS INTEGER                      NO-UNDO.
    DEFINE VARIABLE cFilename               AS CHARACTER                    NO-UNDO.
    DEFINE VARIABLE cLogicFileName          AS CHARACTER                    NO-UNDO.
    DEFINE VARIABLE cError                  AS CHARACTER                    NO-UNDO.    
    DEFINE VARIABLE lSCMOk                  AS LOGICAL                      NO-UNDO.
    DEFINE VARIABLE prnt                    AS LOGICAL                      NO-UNDO.
    DEFINE VARIABLE newobjectpath           AS CHAR                         NO-UNDO.
    DEFINE VARIABLE cattrnames              AS CHAR                         NO-UNDO.
    DEFINE VARIABLE cattrvalues             AS CHAR                         NO-UNDO.
    DEFINE VARIABLE tdatacolumns            AS CHAR                         NO-UNDO.
    DEFINE VARIABLE dfldname                AS CHAR                         NO-UNDO.
    DEFINE VARIABLE ttablename              AS CHAR                         NO-UNDO. 
    DEFINE VARIABLE tmpsdoname              AS CHAR                         NO-UNDO.
    DEFINE VARIABLE tmplogname              AS CHAR                         NO-UNDO.
    DEFINE VARIABLE tmplogclname            AS CHAR                         NO-UNDO.
    DEFINE VARIABLE tmpdumpname             AS CHAR                         NO-UNDO.
    DEFINE VARIABLE sdodir                  AS CHAR                         NO-UNDO.

    DO WITH FRAME {&FRAME-NAME}:       
        ASSIGN Done       = FALSE /* re-set this in case user wants to try generating again */
               fiRootDirectory
               .
        ETIME(YES).

        IF LOOKUP(fiRootDirectory:SCREEN-VALUE,PROPATH) = 0 THEN
            ASSIGN gcOldPropath = PROPATH
                   PROPATH      = PROPATH + ",":U + fiRootDirectory:SCREEN-VALUE
                   .
        IF QUERY brBrowse2:IS-OPEN THEN
            GET LAST brBrowse2 NO-LOCK.
    
        ASSIGN 
          TableCount = brBrowse2:NUM-SELECTED-ROWS
          giTotal    = brBrowse2:NUM-SELECTED-ROWS * (1 + (IF toGenBrowser:CHECKED THEN 1 ELSE 0) + (IF toGenViewer:CHECKED THEN 1 ELSE 0) + (IF gendataflds:CHECKED THEN 1 ELSE 0) + (IF geninstance:CHECKED THEN 1 ELSE 0)) + 1.
        RUN logHeader.
               .
    END.    /* with frame ... */

    sdoloop:
    DO iLoop = 1 TO brbrowse2:NUM-SELECTED-ROWS:
        brbrowse2:FETCH-SELECTED-ROW(iLoop).

        ASSIGN lSCMOk               = YES
               .
        RUN adecomm/_osfmush.p ( INPUT ttsdotable.tt_object_path,
                                 INPUT tt_object_filename, 
                                 OUTPUT newobjectpath)              newobjectpath = FILE-INFO:FILE-NAME = newobjectpath.
        ASSIGN newobjectpath = REPLACE(newobjectpath,"\":U,"/":U).

        IF SEARCH(newobjectpath) = ? AND
           NUM-ENTRIES(newobjectpath,".":U) < 2 THEN
          newobjectpath = newobjectpath + ".w":U.
        
        RUN VALUE(newobjectpath) PERSISTENT SET shdl.
        RUN "initializeobject" IN shdl NO-ERROR.

        ASSIGN tdatacolumns = DYNAMIC-FUNCTION("getdatacolumns" IN shdl)
               ttablename   = DYNAMIC-FUNCTION("columntable" IN shdl, ENTRY(1,tdatacolumns))
               dfldname     = ttablename + "." + ENTRY(1,tdatacolumns)
               .
        DISPLAY ttablename @ fiProcessingTable WITH FRAME {&FRAME-NAME}.

        RUN ShowMessage("Generating Instances....").

        IF (GenDataFlds:CHECKED OR toGenviewer:CHECKED) THEN
        DO:
            RUN storeTableFields IN hObjApi ( INPUT coDatabase:SCREEN-VALUE,
                                              INPUT ttablename,
                                              INPUT coModule:SCREEN-VALUE).
            IF RETURN-VALUE NE "":U THEN
                ASSIGN lSCMOk = NO
                       cError = "Error from storeTableFields ":U + RETURN-VALUE
                       .
            ELSE
                ASSIGN cError = "Datafield Generation Successful".

            RUN LogMessage(tTableName,cError,NO).
        END. /* gendataflds */

        /* Determine the dump name of the table.
         * getDumpName will use the correct DB name, even if using a DataServer */
        RUN getDumpName IN gshGenManager ( INPUT  coDatabase:INPUT-VALUE + "|":U + tTableName,
                                           OUTPUT tmpDumpName ) NO-ERROR.
        IF tmpDumpName EQ "":U OR tmpDumpName EQ ? THEN
            ASSIGN tmpDumpName = SUBSTRING(ttablename, 1, 8).

        IF toGenBrowser:CHECKED THEN
        DO:
            RUN ShowMessage("Generating Dynamic Browser ....").

            RUN rygenbrowse IN THIS-PROCEDURE ( INPUT tt_object_filename, 
                                                INPUT ttablename, 
                                                INPUT tt_product_module_code,
                                                INPUT FILE-INFO:FULL-PATHNAME,
                                                INPUT cmaxnumflds,  
                                                INPUT cnamesuffix,
                                                INPUT tmpdumpname,
                                                INPUT cSDOBrowseFields).
            IF RETURN-VALUE NE "":U THEN
                ASSIGN lSCMOk = NO
                       cError = "Error from rygenbrowse ":U + RETURN-VALUE
                       .
            ELSE
                ASSIGN cError = "Dynamic Browse Generation Successful".

            RUN LogMessage(tTableName,cError,NO).
        END.    /* toGenBrowser */

        IF toGenviewer:CHECKED THEN
        DO:
            RUN ShowMessage("Generating Dynamic Viewer ....").

            RUN af/cod2/afgenview.p ( INPUT codatabase:SCREEN-VALUE,
                                      INPUT tt_object_filename,
                                      INPUT ttablename,
                                      INPUT tt_product_module_code,
                                      INPUT FILE-INFO:FULL-PATHNAME,
                                      INPUT cvmaxnumflds,
                                      INPUT tmpdumpname,
                                      INPUT cvnamesuffix,
                                      INPUT cvmaxfldspercolumn,
                                      INPUT cSDOViewerFields,
                                      INPUT glDeleteViewerOnGeneration ).
            IF RETURN-VALUE NE "":U THEN
                ASSIGN lSCMOk = NO
                       cError = "Error from afGenView.p: " + RETURN-VALUE.
            ELSE
                ASSIGN cError = "Dynamic Viewer Generation Successful. ":U.

            RUN LogMessage(tTableName,cError,NO).
        END.    /* toGenViewer */

        IF geninstance:CHECKED AND lSCMok THEN
        DO:            
          RUN ShowMessage("Generating DataFields ....").

            RUN storeinstance IN THIS-PROCEDURE(INPUT newobjectpath + tt_object_filename).

            IF RETURN-VALUE <> "":U THEN
                ASSIGN lSCMOk = NO
                       cError = "Error from StoreInstance: " + RETURN-VALUE.
            ELSE
                ASSIGN cError = "DataField Instance Generation Successful. ":U.

            RUN LogMessage(tTableName, cError,NO).
        END.    /* GenInstance:checked */

        IF VALID-HANDLE(shdl) THEN
        DO:
            RUN "destroyobject" IN shdl.
            ASSIGN sHdl = ?.
        END.

        RUN ShowMessage("Done ....").
    END.    /* SDO-LOOP: */
    
    RUN ShowMessage("Complete ....").
    ASSIGN
      giCount = 0
      giTotal = 0.

    RETURN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION timeCheck C-Win 
FUNCTION timeCheck RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    DEFINE VARIABLE iEtime          AS INTEGER                          NO-UNDO.
    ASSIGN iEtime = ETIME.
    ETIME(YES).

    RETURN SUBSTITUTE(" - &1 Seconds", ROUND(IEtime / 1000,2)).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
