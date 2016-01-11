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
* Contributors: MIP Holdings (Pty) Ltd ("MIP")                       *
*               PSC                                                  *
*                                                                    *
*********************************************************************/

TRIGGER PROCEDURE FOR CREATE OF rvm_workspace_module .

/* generic trigger override include file to disable trigger if required */
{af/sup2/aftrigover.i &DB-NAME      = "RVDB"
                      &TABLE-NAME   = "rvm_workspace_module"
                      &TRIGGER-TYPE = "CREATE"}

/* Created automatically using ERwin ICF Trigger template db/af/erw/afercustrg.i
   Do not change manually. Customisations to triggers should be placed in separate
   include files pulled into the trigger. ICF auto generates write trigger custom
   include files. Delete or create customisation include files need to be created
   manually. Be sure to put the hook in ERwin directly so as not to have you changes
   overwritten.
   User defined Macro (UDP) Summary (case sensitive)
   rvm_workspace_module           Expands to full table name, e.g. gsm_user
   %TableFLA            Expands to table unique code, e.g. gsmus
   %TableObj            If blank or not defined expands to table_obj with no prefix (framework standard)
                        If defined, uses this field as the object field
                        If set to "none" then indicates table does not have an object field
   XYZ                  Do not define so we can compare against an empty string

   See docs for explanation of replication macros 
*/   

&SCOPED-DEFINE TRIGGER_TABLE rvm_workspace_module
&SCOPED-DEFINE TRIGGER_FLA rvmwm
&SCOPED-DEFINE TRIGGER_OBJ workspace_module_obj


DEFINE BUFFER lb_table FOR rvm_workspace_module.      /* Used for recursive relationships */
DEFINE BUFFER lb1_table FOR rvm_workspace_module.     /* Used for lock upgrades */

DEFINE BUFFER o_rvm_workspace_module FOR rvm_workspace_module.

/* Standard top of CREATE trigger code */
{af/sup/aftrigtopc.i}

  



/* Generated by ICF ERwin Template */
/* rvm_workspace is the source of rvm_workspace_module ON CHILD INSERT RESTRICT */
IF 
    ( rvm_workspace_module.source_workspace_obj <> 0 ) THEN
  DO:
    IF NOT(CAN-FIND(FIRST rvm_workspace WHERE
        rvm_workspace_module.source_workspace_obj = rvm_workspace.workspace_obj)) THEN
        DO:
          /* Cannot create child because parent does not exist ! */
          ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 102 lv-include = "rvm_workspace_module|rvm_workspace":U.
          RUN error-message (lv-errgrp, lv-errnum, lv-include).
        END.
    
    
  END.

/* Generated by ICF ERwin Template */
/* gsc_product_module is in rvm_workspace_module ON CHILD INSERT RESTRICT */
IF 
    ( rvm_workspace_module.product_module_obj <> 0 ) THEN
  DO:
    IF NOT(CAN-FIND(FIRST gsc_product_module WHERE
        rvm_workspace_module.product_module_obj = gsc_product_module.product_module_obj)) THEN
        DO:
          /* Cannot create child because parent does not exist ! */
          ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 102 lv-include = "rvm_workspace_module|gsc_product_module":U.
          RUN error-message (lv-errgrp, lv-errnum, lv-include).
        END.
    
    
  END.

/* Generated by ICF ERwin Template */
/* rvm_workspace has rvm_workspace_module ON CHILD INSERT RESTRICT */
IF 
    ( rvm_workspace_module.workspace_obj <> 0 ) THEN
  DO:
    IF NOT(CAN-FIND(FIRST rvm_workspace WHERE
        rvm_workspace_module.workspace_obj = rvm_workspace.workspace_obj)) THEN
        DO:
          /* Cannot create child because parent does not exist ! */
          ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 102 lv-include = "rvm_workspace_module|rvm_workspace":U.
          RUN error-message (lv-errgrp, lv-errnum, lv-include).
        END.
    
    
  END.






ASSIGN rvm_workspace_module.{&TRIGGER_OBJ} = getNextObj().





/* Update Audit Log */
IF CAN-FIND(FIRST gsc_entity_mnemonic
            WHERE gsc_entity_mnemonic.entity_mnemonic = 'rvmwm':U
              AND gsc_entity_mnemonic.auditing_enabled = YES) THEN
  RUN af/app/afauditlgp.p (INPUT "CREATE":U, INPUT "rvmwm":U, INPUT BUFFER rvm_workspace_module:HANDLE, INPUT BUFFER o_rvm_workspace_module:HANDLE).

/* Standard bottom of CREATE trigger code */
{af/sup/aftrigendc.i}


/* Place any specific CREATE trigger customisations here */