&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Check Version Notes Wizard" Procedure _INLINE
/* Actions: af/cod/aftemwizcw.w ? ? ? ? */
/* MIP Update Version Notes Wizard
Check object version notes.
af/cod/aftemwizpw.w
*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Update-Object-Version" Procedure _INLINE
/* Actions: ? ? ? ? af/sup/afverxftrp.p */
/* This has to go above the definitions sections, as that is what it modifies.
   If its not, then the definitions section will have been saved before the
   XFTR code kicks in and changes it */
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Definition Comments Wizard" Procedure _INLINE
/* Actions: ? af/cod/aftemwizcw.w ? ? ? */
/* Program Definition Comment Block Wizard
Welcome to the Program Definition Comment Block Wizard. Press Next to proceed.
af/cod/aftemwizpw.w
*/
/* _UIB-CODE-BLOCK-END */
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
/*---------------------------------------------------------------------------------
  File: afcfgwritep.p

  Description:  Writes out the ICFCONFIG.XML file

  Purpose:      Writes out the ICFCONFIG.XML file

  Parameters:   <none>

  History:
  --------
  (v:010000)    Task:    90000132   UserRef:    
                Date:   14/05/2001  Author:     Bruce Gruenbaum

  Update Notes: Created from Template rytemplipp.p

  (v:010002)    Task:    90000135   UserRef:    
                Date:   15/05/2001  Author:     Bruce Gruenbaum

  Update Notes: Fix return status

  (v:010003)    Task:    90000137   UserRef:    
                Date:   16/05/2001  Author:     Bruce Gruenbaum

  Update Notes: Fix FIND FIRST bttManager bug

-------------------------------------------------------------------------------*/
/*                   This .W file was created with the Progress UIB.             */
/*-------------------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* MIP-GET-OBJECT-VERSION pre-processors
   The following pre-processors are maintained automatically when the object is
   saved. They pull the object and version from Roundtable if possible so that it
   can be displayed in the about window of the container */

&scop object-name       afcfgwritep.p
DEFINE VARIABLE lv_this_object_name AS CHARACTER INITIAL "{&object-name}":U NO-UNDO.
&scop object-version    000000

/* Astra object identifying preprocessor */
&glob   AstraPlip    yes

DEFINE VARIABLE cObjectName         AS CHARACTER NO-UNDO.
DEFINE VARIABLE ghXMLHlpr           AS HANDLE    NO-UNDO.

ASSIGN cObjectName = "{&object-name}":U.

&scop   mip-notify-user-on-plip-close   NO

{afglobals.i}
{afxmlcfgtt.i}
{afcheckerr.i &define-only = yes}

DEFINE TEMP-TABLE ttSession NO-UNDO
  FIELD cSessionType AS CHARACTER 
  INDEX pudx IS PRIMARY UNIQUE
    cSessionType
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-addManager) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD addManager Procedure 
FUNCTION addManager RETURNS LOGICAL
  ( INPUT phRequiredManager AS HANDLE,
    INPUT pcSessionType     AS CHARACTER,
    INPUT pcManagerName     AS CHARACTER,
    INPUT pdObjectObj       AS DECIMAL )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


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
         HEIGHT             = 16.33
         WIDTH              = 47.2.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB Procedure 
/* ************************* Included-Libraries *********************** */

{src/adm/method/attribut.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  ******************************* */

{ry/app/ryplipmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-buildTempTables) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE buildTempTables Procedure 
PROCEDURE buildTempTables :
/*------------------------------------------------------------------------------
  Purpose:     Build the temp-tables that contain the data that we need to
               build the XML file.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE INPUT  PARAMETER pcSessionTypes  AS CHARACTER  NO-UNDO.

  DEFINE VARIABLE cMessage    AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cText       AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE iOrder      AS INTEGER    NO-UNDO.
  DEFINE VARIABLE cDateFormat AS CHARACTER  NO-UNDO.

  DEFINE BUFFER b_ConMgr FOR gsc_manager_type.

  /* Find out which is the connection manager's obj.
     Without the connection manager, nothing else will work. 
     As we need this for all the session types, we'll read this buffer
     here and hold onto it.*/
  FIND FIRST b_ConMgr NO-LOCK
    WHERE b_ConMgr.manager_type_code = "ConnectionManager":U
    NO-ERROR.
  IF NOT AVAILABLE(b_ConMgr) THEN
  DO:
    cMessage = {aferrortxt.i 'AF' '124' '?' '?' "'ConnectionManager Manager Type not specified'"}.
    RETURN cMessage.
  END.

  /* First lets populate the temp-tables */
  FOR EACH gsm_session_type NO-LOCK
    WHERE CAN-DO(pcSessionTypes,gsm_session_type.session_type_code):

    CREATE ttSession.
    ASSIGN
      ttSession.cSessionType = gsm_session_type.session_type_code
      .

    /* Set the property for valid OS list */
    setProperty(gsm_session_type.session_type_code,
                "valid_os_list":U,
                gsm_session_type.valid_os_list).

    /* Set the property for physical session list */
    setProperty(gsm_session_type.session_type_code,
                "physical_session_list":U,
                gsm_session_type.physical_session_list).

    /* Now loop through the session property table */
    FOR EACH gsc_session_property NO-LOCK:

      /* Try and find a specific gsm_session_type property for this 
         session type */
      FIND FIRST gsm_session_type_property NO-LOCK
        WHERE gsm_session_type_property.session_property_obj = gsc_session_property.session_property_obj
          AND gsm_session_type_property.session_type_obj = gsm_session_type.session_type_obj
        NO-ERROR.

      /* If we find one, set that property */
      IF AVAILABLE(gsm_session_type_property) THEN
        setProperty(gsm_session_type.session_type_code,
                    gsc_session_property.session_property_name,
                    gsm_session_type_property.property_value).

      /* If we don't find a specific entry for this session type and
         the property is supposed to always be used, set the property
         to the default value. */
      ELSE IF gsc_session_property.always_used THEN
        setProperty(gsm_session_type.session_type_code,
                    gsc_session_property.session_property_name,
                    gsc_session_property.default_property_value).

    END. /* FOR EACH gsc_session_property */


    /* Now see if a session_date_format has been set. */
    cDateFormat = getProperty(gsm_session_type.session_type_code,
                              "session_date_format":U).
    IF cDateFormat = ? OR
       cDateFormat = "":U THEN
    DO:
      FIND FIRST gsc_global_control NO-LOCK
        NO-ERROR.
      IF AVAILABLE(gsc_global_control) AND
        gsc_global_control.date_format <> ? AND
        gsc_global_control.date_format <> "":U THEN
        setProperty(gsm_session_type.session_type_code,
                    "session_date_format":U,
                    gsc_global_control.date_format).

    END.
                    

    /* See if we can find the manager procedure for the connection manager */
    FIND FIRST gsm_required_manager NO-LOCK
      WHERE gsm_required_manager.manager_type_obj = b_ConMgr.manager_type_obj
        AND gsm_required_manager.session_type_obj = gsm_session_type.session_type_obj
      NO-ERROR.
    IF NOT AVAILABLE(gsm_required_manager) THEN
    DO:
      cText    = "ConnectionManager not specified for session type " + gsm_session_type.session_type_code.
      cMessage = {aferrortxt.i 'AF' '124' '?' '?' "cText" }.
      RETURN cMessage.
    END.

    /* Add the connection manager to the list of managers */
    addManager(INPUT BUFFER gsm_required_manager:HANDLE, "":U, "":U, 0.0).

    /* Create a record for each of the Service Types Connection Managers that have to be 
       started */
    FOR EACH gsm_session_service NO-LOCK
      WHERE gsm_session_service.session_type_obj = gsm_session_type.session_type_obj:

      /* Find the logical service */
      FIND FIRST gsc_logical_service NO-LOCK
        WHERE gsc_logical_service.logical_service_obj = gsm_session_service.logical_service_obj
        NO-ERROR.
      IF NOT AVAILABLE(gsc_logical_service) OR
         NOT gsc_logical_service.write_to_config THEN
        NEXT.

      /* Find the physical service */
      FIND FIRST gsm_physical_service NO-LOCK
        WHERE gsm_physical_service.physical_service_obj = gsm_session_service.physical_service_obj
        NO-ERROR.
      IF NOT AVAILABLE(gsm_physical_service) THEN
        NEXT.

      /* Now find the service type */
      FIND FIRST gsc_service_type NO-LOCK
        WHERE gsc_service_type.service_type_obj = gsc_logical_service.service_type_obj
        NO-ERROR.
      IF NOT AVAILABLE(gsc_service_type) THEN
        NEXT.

      /* Add the manager object to the manager list */
      addManager(?,
                 gsm_session_type.session_type_code,
                 gsc_service_type.service_type_code + "ConnectionManager":U,
                 gsc_service_type.management_object_obj).

      /* Set the property for this connection manager */
      setProperty(gsm_session_type.session_type_code,
                  "ICFCM_":U + gsc_service_type.service_type_code,
                  gsc_service_type.service_type_code + "ConnectionManager":U).

      iOrder = getNextOrderNum(INPUT BUFFER ttService:HANDLE,
                               gsm_session_type.session_type_code).
      CREATE ttService.
      ASSIGN
        ttService.cSessionType     = gsm_session_type.session_type_code
        ttService.iOrder           = iOrder
        ttService.cServiceType     = gsc_service_type.service_type_code
        ttService.cServiceName     = gsc_logical_service.logical_service_code
        ttService.cPhysicalService = gsm_physical_service.physical_service_code
        ttService.cConnectParams   = gsm_physical_service.connection_parameters
        ttService.lDefaultService  = gsc_logical_service.logical_service_obj = gsc_service_type.default_logical_service_obj
        ttService.lCanRunLocal     = gsc_logical_service.can_run_locally
        .

    END. /* FOR EACH gsm_session_service */


    /* We should always add the AppServer and Database connection managers */
    FOR EACH gsc_service_type NO-LOCK  
      WHERE gsc_service_type.service_type_code = "AppServer":U
         OR gsc_service_type.service_type_code = "Database":U:
  
      /* Add the manager object to the manager list */
      addManager(?,
                 gsm_session_type.session_type_code,
                 gsc_service_type.service_type_code + "ConnectionManager":U,
                 gsc_service_type.management_object_obj).
  
      /* Set the property for this connection manager */
      setProperty(gsm_session_type.session_type_code,
                  "ICFCM_":U + gsc_service_type.service_type_code,
                  gsc_service_type.service_type_code + "ConnectionManager":U).
    END.

    /* Now just add the managers that are left over */
    FOR EACH gsm_required_manager NO-LOCK
      WHERE gsm_required_manager.session_type_obj = gsm_session_type.session_type_obj
      BY gsm_required_manager.session_type_obj
      BY gsm_required_manager.startup_order:

      /* We've already set up the connection manager, so skip it */
      IF gsm_required_manager.manager_type_obj = b_ConMgr.manager_type_obj THEN
        NEXT.

      addManager(INPUT BUFFER gsm_required_manager:HANDLE, "":U, "":U, 0.0).

    END. /* FOR EACH gsm_required_manager */

  END. /* FOR EACH gsm_session_type */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createXMLDoc) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createXMLDoc Procedure 
PROCEDURE createXMLDoc :
/*------------------------------------------------------------------------------
  Purpose:     Reads the contents of the temp-tables and builds an XML document
               from them.
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEFINE INPUT PARAMETER phNode AS HANDLE NO-UNDO.

  DEFINE VARIABLE hSessionNode  AS HANDLE   NO-UNDO.
  DEFINE VARIABLE hServicesNode  AS HANDLE   NO-UNDO.
  DEFINE VARIABLE hPropertiesNode  AS HANDLE   NO-UNDO.
  DEFINE VARIABLE hServiceNode  AS HANDLE   NO-UNDO.
  DEFINE VARIABLE hManagersNode  AS HANDLE   NO-UNDO.
  DEFINE VARIABLE hManagerNode  AS HANDLE   NO-UNDO.

  /* Loop through all the session records. */
  FOR EACH ttSession
    BREAK BY ttSession.cSessionType:

    /* Create the Session node */
    hSessionNode = DYNAMIC-FUNCTION("createElementNode":U IN ghXMLHlpr,
                                    phNode, 
                                    "session":U).
    /* Make sure the session type is specified */
    hSessionNode:SET-ATTRIBUTE("SessionType":U,ttSession.cSessionType).

    /* Create the Session node */
    hPropertiesNode = DYNAMIC-FUNCTION("createElementNode":U IN ghXMLHlpr,
                                       hSessionNode, 
                                       "properties":U).

    /* Create an element for each property */
    FOR EACH ttProperty
      WHERE ttProperty.cSessionType = ttSession.cSessionType:

      DYNAMIC-FUNCTION("setNodeElementValue":U IN ghXMLHlpr,
                       hPropertiesNode, 
                       ttProperty.cProperty,
                       ttProperty.cValue).

    END.

    /* Delete the Properties node as we are done with it */
    IF VALID-HANDLE(hPropertiesNode) THEN
    DO:
      DELETE OBJECT hPropertiesNode.
      hPropertiesNode = ?.
    END.

    hServicesNode = ?.

    /* Create a service for each ttService */
    FOR EACH ttService 
      WHERE ttService.cSessionType = ttSession.cSessionType
      BREAK BY ttService.cSessionType
            BY ttService.iOrder:

      /* Create the services node */
      IF FIRST-OF(ttService.cSessionType) THEN
      DO:
        hServicesNode = DYNAMIC-FUNCTION("createElementNode":U IN ghXMLHlpr,
                                         hSessionNode, 
                                         "services":U).
      END.

      /* Create a node for this service */
      hServiceNode = DYNAMIC-FUNCTION("createElementNode":U IN ghXMLHlpr,
                                       hServicesNode, 
                                       "service":U).
      DYNAMIC-FUNCTION("buildElementsFromBuffer":U IN ghXMLHlpr,
                       hServiceNode, 
                       INPUT BUFFER ttService:HANDLE,
                       "!cSessionType,!iOrder,*":U).

      DELETE OBJECT hServiceNode.
      hServiceNode = ?.
    END. /* FOR EACH ttService */

    /* set the services node handle to ? and delete it */
    IF VALID-HANDLE(hServicesNode) THEN
    DO:
      DELETE OBJECT hServicesNode.
      hServicesNode = ?.
    END.

    hManagersNode = ?.
    /* Create a manager for each ttManager */
    FOR EACH ttManager 
      WHERE ttManager.cSessionType = ttSession.cSessionType
      BREAK BY ttManager.cSessionType
            BY ttManager.iOrder:

      /* Create the Managers node */
      IF FIRST-OF(ttManager.cSessionType) THEN
      DO:
        hManagersNode = DYNAMIC-FUNCTION("createElementNode":U IN ghXMLHlpr,
                                         hSessionNode, 
                                         "managers":U).
      END.

      /* Create a node for this Manager */
      hManagerNode = DYNAMIC-FUNCTION("createElementNode":U IN ghXMLHlpr,
                                       hManagersNode, 
                                       "manager":U).
      DYNAMIC-FUNCTION("buildElementsFromBuffer":U IN ghXMLHlpr,
                       hManagerNode, 
                       INPUT BUFFER ttManager:HANDLE,
                       "!cSessionType,!iOrder,!iUniqueID,!hHandle,*":U).

      DELETE OBJECT hManagerNode.
      hManagerNode = ?.
    END. /* FOR EACH ttManager */

    /* set the Managers node handle to ? and delete it */
    IF VALID-HANDLE(hManagersNode) THEN
    DO:
      DELETE OBJECT hManagersNode.
      hManagersNode = ?.
    END.

    DELETE OBJECT hSessionNode.
    hSessionNode = ?.

  END.  /* FOR EACH ttSession */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-killPlip) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE killPlip Procedure 
PROCEDURE killPlip :
/*------------------------------------------------------------------------------
  Purpose:     entry point to instantly kill the plip if it should get lost in memory
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

{ry/app/ryplipkill.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-objectDescription) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE objectDescription Procedure 
PROCEDURE objectDescription :
/*------------------------------------------------------------------------------
  Purpose:     Pass out a description of the PLIP, used in Plip temp-table
  Parameters:  <none>
  Notes:       This should be changed manually for each plip
------------------------------------------------------------------------------*/

DEFINE OUTPUT PARAMETER cDescription AS CHARACTER NO-UNDO.

ASSIGN cDescription = "Dynamics XML Config PLIP".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-plipSetup) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE plipSetup Procedure 
PROCEDURE plipSetup :
/*------------------------------------------------------------------------------
  Purpose:    Run by main-block of PLIP at startup of PLIP
  Parameters: <none>
  Notes:       
------------------------------------------------------------------------------*/

{ry/app/ryplipsetu.i}


{aflaunch.i &PLIP = 'af/app/afxmlhlprp.p'
            &IProc = ''
            &OnApp = 'NO'}

ghXMLHlpr = hPlip.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-plipShutdown) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE plipShutdown Procedure 
PROCEDURE plipShutdown :
/*------------------------------------------------------------------------------
  Purpose:     This procedure will be run just before the calling program 
               terminates
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

  IF VALID-HANDLE(ghXMLHlpr) THEN
    RUN killPlip IN ghXMLHlpr.

  {ry/app/ryplipshut.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-writeConfigXML) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE writeConfigXML Procedure 
PROCEDURE writeConfigXML :
/*------------------------------------------------------------------------------
  Purpose:     This procedure prepares an XML document containing the data to 
               be written to the file system as the ICFCONFIG.XML file.
               The XML document is then either written to a file as specified
               in the pcFileName parameter or it is written to the MEMPTR
               and returned as a MEMPTR to the client who is then responsible
               for writing out the document to a file.
  Parameters:
    pcSessionTypes - Contains a comma separated list of session types to 
                     write out in CAN-DO format.
    pcFileName     - The name of the file to write the XML document to. If
                     <MEMPTR>, the contents are returned in pmXMLDoc.
    pmXMLDoc       - A MEMPTR parameter to contain the document to be returned.

  Notes:
    This procedure can only be run from inside the framework. It is thus 
    assumed that the framework is running when this file is generated.
------------------------------------------------------------------------------*/
  DEFINE INPUT  PARAMETER pcSessionTypes  AS CHARACTER  NO-UNDO.
  DEFINE INPUT  PARAMETER pcFileName      AS CHARACTER  NO-UNDO.
  DEFINE OUTPUT PARAMETER pmXMLDoc        AS MEMPTR     NO-UNDO.

  DEFINE VARIABLE hXMLDoc     AS HANDLE   NO-UNDO.
  DEFINE VARIABLE hRootNode   AS HANDLE   NO-UNDO.
  DEFINE VARIABLE cRetMessage AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cMessage    AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE lAns        AS LOGICAL    NO-UNDO.

  EMPTY TEMP-TABLE ttProperty.
  EMPTY TEMP-TABLE ttService.
  EMPTY TEMP-TABLE ttManager.
  EMPTY TEMP-TABLE ttSession.

  RUN buildTempTables (pcSessionTypes).
  {afcheckerr.i &return-only = yes}

  CREATE X-DOCUMENT hXMLDoc.

  hXMLDoc:ENCODING = SESSION:CPSTREAM.

  /* Create a root node */
  hRootNode = DYNAMIC-FUNCTION("createElementNode":U IN ghXMLHlpr,
                               hXMLDoc, 
                               "sessions":U).

  RUN createXMLDoc (hRootNode).
  {afcheckerr.i &no-return = YES}

  IF cMessageList <> "":U THEN
    cRetMessage = cRetMessage + CHR(3) + cMessageList.


  /* Now save away the XML document. If the value of pcFileName is 
     <MEMPTR>, save the XML document to a memptr, otherwise save
     it to the filename specified. */

  ERROR-STATUS:ERROR = NO.
  IF cRetMessage = "":U THEN
  DO:
    IF pcFileName = "<MEMPTR>":U THEN
    DO:
      SET-SIZE(pmXMLDoc) = 0. 
      lAns =  hXMLDoc:SAVE("MEMPTR":U,pmXMLDoc) NO-ERROR.
      cMessage = "to memory pointer":U.
    END.
    ELSE
    DO:
      lAns = hXMLDoc:SAVE("FILE",pcFileName) NO-ERROR.
      cMessage = pcFileName.
    END.
    {af/sup2/afcheckerr.i
      &errors-not-zero = YES
      &no-return = YES}
    IF cMessageList <> "":U OR 
       NOT lAns THEN
      cRetMessage = cRetMessage + CHR(3) + 
                    {af/sup2/aferrortxt.i 'AF' '117' '?' '?' 'save' cMessage cMessageList}.
  END.

  DELETE OBJECT hRootNode.
  DELETE OBJECT hXMLDoc.

  IF cRetMessage <> "":U THEN
    RETURN cRetMessage.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-addManager) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION addManager Procedure 
FUNCTION addManager RETURNS LOGICAL
  ( INPUT phRequiredManager AS HANDLE,
    INPUT pcSessionType     AS CHARACTER,
    INPUT pcManagerName     AS CHARACTER,
    INPUT pdObjectObj       AS DECIMAL ) :
/*------------------------------------------------------------------------------
  Purpose:     Adds a manager to the Managers table
    Notes:  
------------------------------------------------------------------------------*/

  DEFINE BUFFER bttManager FOR ttManager.
  DEFINE BUFFER bgsc_Object FOR gsc_object.
  DEFINE BUFFER bgsc_Manager FOR gsc_manager_type.
  DEFINE BUFFER bgsm_Session FOR gsm_session_type.

  DEFINE VARIABLE hSessionObj AS HANDLE   NO-UNDO.
  DEFINE VARIABLE hObjectObj  AS HANDLE   NO-UNDO.
  DEFINE VARIABLE hManagerObj AS HANDLE   NO-UNDO.

  DEFINE VARIABLE cFileName     AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cSessionType  AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cManagerName  AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cHandleName   AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE dObjectObj    AS DECIMAL DECIMALS 9   NO-UNDO.


  DEFINE VARIABLE iOrder    AS INTEGER    NO-UNDO.

  /* If the buffer handle was specified, read the data from the database. */
  IF VALID-HANDLE(phRequiredManager) THEN
  DO:
        /* Get the obj fields for the related tables */
    hSessionObj = phRequiredManager:BUFFER-FIELD("session_type_obj":U).
    hObjectObj = phRequiredManager:BUFFER-FIELD("object_obj":U).
    hManagerObj = phRequiredManager:BUFFER-FIELD("manager_type_obj":U).


    /* Get the session type record */
    FIND FIRST bgsm_Session NO-LOCK
      WHERE bgsm_Session.session_type_obj = hSessionObj:BUFFER-VALUE
      NO-ERROR.
    IF NOT AVAILABLE(bgsm_Session) THEN
      RETURN FALSE.

    /* Get the manager type record */
    FIND FIRST bgsc_Manager NO-LOCK
      WHERE bgsc_Manager.manager_type_obj = hManagerObj:BUFFER-VALUE
      NO-ERROR.
    IF NOT AVAILABLE(bgsc_Manager) THEN
      RETURN FALSE.

    ASSIGN
      cSessionType = bgsm_Session.session_type_code
      cManagerName = bgsc_Manager.manager_type_code
      cHandleName  = bgsc_Manager.static_handle
      dObjectObj   = hObjectObj:BUFFER-VALUE
      .
  END.
  /* Otherwise read the data from the input parameters */
  ELSE
  DO:
    ASSIGN
      cSessionType = pcSessionType
      cManagerName = pcManagerName
      cHandleName  = "":U
      dObjectObj   = pdObjectObj
      .
  END.

  /* Get the gsc_object record to base this on */
  FIND FIRST bgsc_Object NO-LOCK
    WHERE bgsc_Object.object_obj = dObjectObj
    NO-ERROR.
  IF NOT AVAILABLE(bgsc_Object) THEN
    RETURN FALSE.

  /* Build up the filename */
  cFileName = bgsc_object.object_path 
            + (IF bgsc_object.object_path <> "":U THEN "/":U ELSE "":U)
            + bgsc_object.object_filename
            + (IF bgsc_object.object_extension <> "":U THEN "." + bgsc_object.object_extension ELSE "":U).

  /* Add this manager to the table */                                                                
  FIND FIRST bttManager 
    WHERE bttManager.cSessionType = cSessionType 
      AND bttManager.cManagerName = cManagerName
    NO-ERROR.

  IF NOT AVAILABLE(bttManager) THEN
  DO TRANSACTION:
    iOrder = getNextOrderNum(INPUT BUFFER bttManager:HANDLE,cSessionType).
    CREATE bttManager.
    ASSIGN
      bttManager.cSessionType = cSessionType
      bttManager.cManagerName = cManagerName
      bttManager.cHandleName  = cHandleName
      bttManager.cFileName    = cFileName
      bttManager.iOrder       = iOrder
    .
  END.

  ERROR-STATUS:ERROR = NO.
  RETURN TRUE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF
