&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI ADM2
&ANALYZE-RESUME
/* Connected Databases 
          temp-db          PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
{adecomm/appserv.i}
DEFINE VARIABLE h_Astra                    AS HANDLE          NO-UNDO.
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Update-Object-Version" dTables _INLINE
/* Actions: ? ? ? ? af/sup/afverxftrp.p */
/* This has to go above the definitions sections, as that is what it modifies.
   If its not, then the definitions section will have been saved before the
   XFTR code kicks in and changes it */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Definition Comments Wizard" dTables _INLINE
/* Actions: ? af/cod/aftemwizcw.w ? ? ? */
/* Program Definition Comment Block Wizard
Welcome to the Program Definition Comment Block Wizard. Press Next to proceed.
af/cod/aftemwizpw.w
*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "SmartDataObjectWizard" dTables _INLINE
/* Actions: ? af/cod/aftemwizcw.w ? ? ? */
/* SmartDataObject Wizard
Welcome to the SmartDataObject Wizard! During the next few steps, the wizard will lead you through creating a SmartDataObject. You will define the query that you will use to retrieve data from your database(s) and define a set of field values to make available to visualization objects. Press Next to proceed.
adm2/support/_wizqry.w,adm2/support/_wizfld.w 
*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* Temp-Table and Buffer definitions                                    */
{destdefi.i}


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS dTables 
/*---------------------------------------------------------------------------------
  File: ryclslinko.w

  Description:  Class Supported Link SDO

  Purpose:

  Parameters:   <none>

  History:
  --------
  (v:010000)    Task:           0   UserRef:    
                Date:   05/14/2004  Author:     pjudge

  Update Notes: Created from Template rysttasdoo.w

---------------------------------------------------------------------------------*/
/*                   This .W file was created with the Progress UIB.             */
/*-------------------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* MIP-GET-OBJECT-VERSION pre-processors
   The following pre-processors are maintained automatically when the object is
   saved. They pull the object and version from Roundtable if possible so that it
   can be displayed in the about window of the container */

&scop object-name       ryclslinko.w
DEFINE VARIABLE lv_this_object_name AS CHARACTER INITIAL "{&object-name}":U NO-UNDO.
&scop object-version    000000

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

/* Object identifying preprocessor */
&glob   astra2-staticSmartDataObject yes

{src/adm2/globals.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Global-define DATA-LOGIC-PROCEDURE ry/obj/ryclslinkologcp.p

&Scoped-define PROCEDURE-TYPE SmartDataObject
&Scoped-define DB-AWARE yes

&Scoped-define ADM-SUPPORTED-LINKS Data-Source,Data-Target,Navigation-Target,Update-Target,Commit-Target,Filter-Target


/* Db-Required definitions. */
&IF DEFINED(DB-REQUIRED) = 0 &THEN
    &GLOBAL-DEFINE DB-REQUIRED TRUE
&ENDIF
&GLOBAL-DEFINE DB-REQUIRED-START   &IF {&DB-REQUIRED} &THEN
&GLOBAL-DEFINE DB-REQUIRED-END     &ENDIF


&Scoped-define QUERY-NAME Query-Main

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttSupportedLink

/* Definitions for QUERY Query-Main                                     */
&Scoped-Define ENABLED-FIELDS  ClassName IsLinkSource IsLinkTarget LinkName DeactivateOnHide WhereStored
&Scoped-define ENABLED-FIELDS-IN-ttSupportedLink ClassName IsLinkSource ~
IsLinkTarget LinkName DeactivateOnHide WhereStored 
&Scoped-Define DATA-FIELDS  ClassName IsLinkSource IsLinkTarget LinkName DeactivateOnHide WhereStored
&Scoped-define DATA-FIELDS-IN-ttSupportedLink ClassName IsLinkSource ~
IsLinkTarget LinkName DeactivateOnHide WhereStored 
&Scoped-Define MANDATORY-FIELDS 
&Scoped-Define APPLICATION-SERVICE 
&Scoped-Define ASSIGN-LIST 
&Scoped-Define DATA-FIELD-DEFS "ry/obj/ryclslinko.i"
&Scoped-Define DATA-TABLE-NO-UNDO NO-UNDO
&Scoped-define QUERY-STRING-Query-Main FOR EACH ttSupportedLink NO-LOCK INDEXED-REPOSITION
{&DB-REQUIRED-START}
&Scoped-define OPEN-QUERY-Query-Main OPEN QUERY Query-Main FOR EACH ttSupportedLink NO-LOCK INDEXED-REPOSITION.
{&DB-REQUIRED-END}
&Scoped-define TABLES-IN-QUERY-Query-Main ttSupportedLink
&Scoped-define FIRST-TABLE-IN-QUERY-Query-Main ttSupportedLink


/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getTempTableBuffer dTables 
FUNCTION getTempTableBuffer RETURNS HANDLE
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

{&DB-REQUIRED-START}

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Query-Main FOR 
      ttSupportedLink SCROLLING.
&ANALYZE-RESUME
{&DB-REQUIRED-END}


/* ************************  Frame Definitions  *********************** */


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDataObject
   Allow: Query
   Frames: 0
   Add Fields to: Neither
   Other Settings: PERSISTENT-ONLY COMPILE APPSERVER DB-AWARE
   Temp-Tables and Buffers:
      TABLE: ttSupportedLink T "?" NO-UNDO temp-db ttSupportedLink
   END-TABLES.
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW dTables ASSIGN
         HEIGHT             = 1.62
         WIDTH              = 57.8.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB dTables 
/* ************************* Included-Libraries *********************** */

{src/adm2/data.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW dTables
  VISIBLE,,RUN-PERSISTENT                                               */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK QUERY Query-Main
/* Query rebuild information for SmartDataObject Query-Main
     _TblList          = "Temp-Tables.ttSupportedLink"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.ttSupportedLink.ClassName
"ClassName" "ClassName" ? "x(30)" "character" ? ? ? ? ? ? yes ? no 30 no
     _FldNameList[2]   > Temp-Tables.ttSupportedLink.IsLinkSource
"IsLinkSource" "IsLinkSource" ? ? "logical" ? ? ? ? ? ? yes ? no 12.4 no
     _FldNameList[3]   > Temp-Tables.ttSupportedLink.IsLinkTarget
"IsLinkTarget" "IsLinkTarget" ? ? "logical" ? ? ? ? ? ? yes ? no 11.8 no
     _FldNameList[4]   > Temp-Tables.ttSupportedLink.LinkName
"LinkName" "LinkName" ? "x(30)" "character" ? ? ? ? ? ? yes ? no 30 no
     _FldNameList[5]   > Temp-Tables.ttSupportedLink.DeactivateOnHide
"DeactivateOnHide" "DeactivateOnHide" ? ? "logical" ? ? ? ? ? ? yes ? no 17.6 no
     _FldNameList[6]   > Temp-Tables.ttSupportedLink.WhereStored
"WhereStored" "WhereStored" "Where Stored" "x(30)" "character" ? ? ? ? ? ? yes ? no 30 no
     _Design-Parent    is WINDOW dTables @ ( 1.14 , 2.6 )
*/  /* QUERY Query-Main */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK dTables 


/* ***************************  Main Block  *************************** */

  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN          
    RUN initializeObject.
  &ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI dTables  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getTempTableBuffer dTables 
FUNCTION getTempTableBuffer RETURNS HANDLE
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
    RETURN BUFFER ttSupportedLink:HANDLE.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

