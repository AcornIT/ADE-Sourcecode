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

TRIGGER PROCEDURE FOR WRITE OF gsc_dataset_entity OLD BUFFER o_gsc_dataset_entity.

/* generic trigger override include file to disable trigger if required */
{af/sup2/aftrigover.i &DB-NAME      = "ICFDB"
                      &TABLE-NAME   = "gsc_dataset_entity"
                      &TRIGGER-TYPE = "WRITE"}

/* Created automatically using ERwin ICF Trigger template db/af/erw/afercustrg.i
   Do not change manually. Customisations to triggers should be placed in separate
   include files pulled into the trigger. ICF auto generates write trigger custom
   include files. Delete or create customisation include files need to be created
   manually. Be sure to put the hook in ERwin directly so as not to have you changes
   overwritten.
   User defined Macro (UDP) Summary (case sensitive)
   gsc_dataset_entity           Expands to full table name, e.g. gsm_user
   %TableFLA            Expands to table unique code, e.g. gsmus
   %TableObj            If blank or not defined expands to table_obj with no prefix (framework standard)
                        If defined, uses this field as the object field
                        If set to "none" then indicates table does not have an object field
   XYZ                  Do not define so we can compare against an empty string

   See docs for explanation of replication macros 
*/   

&SCOPED-DEFINE TRIGGER_TABLE gsc_dataset_entity
&SCOPED-DEFINE TRIGGER_FLA gscde
&SCOPED-DEFINE TRIGGER_OBJ dataset_entity_obj


DEFINE BUFFER lb_table FOR gsc_dataset_entity.      /* Used for recursive relationships */
DEFINE BUFFER lb1_table FOR gsc_dataset_entity.     /* Used for lock upgrades */



/* Standard top of WRITE trigger code */
{af/sup/aftrigtopw.i}

/* properform fields if enabled for table */
IF CAN-FIND(FIRST gsc_entity_mnemonic
            WHERE gsc_entity_mnemonic.entity_mnemonic = 'gscde':U
              AND gsc_entity_mnemonic.auto_properform_strings = YES) THEN
  RUN af/app/afpropfrmp.p (INPUT BUFFER gsc_dataset_entity:HANDLE).
  



/* Generated by ICF ERwin Template */
/* gsc_entity_mnemonic is the join partner for gsc_dataset_entity ON CHILD UPDATE SET NULL */
IF NEW gsc_dataset_entity OR  gsc_dataset_entity.join_entity_mnemonic <> o_gsc_dataset_entity.join_entity_mnemonic  THEN
  DO:
    IF NOT(CAN-FIND(FIRST gsc_entity_mnemonic WHERE
        gsc_dataset_entity.join_entity_mnemonic = gsc_entity_mnemonic.entity_mnemonic)) THEN DO:
        
        ASSIGN gsc_dataset_entity.join_entity_mnemonic = "":U .
    END.
    
    
  END.

/* Generated by ICF ERwin Template */
/* gsc_entity_mnemonic is included in gsc_dataset_entity ON CHILD UPDATE RESTRICT */
IF NEW gsc_dataset_entity OR  gsc_dataset_entity.entity_mnemonic <> o_gsc_dataset_entity.entity_mnemonic  THEN
  DO:
    IF NOT(CAN-FIND(FIRST gsc_entity_mnemonic WHERE
        gsc_dataset_entity.entity_mnemonic = gsc_entity_mnemonic.entity_mnemonic)) THEN
              DO:
                /* Cannot update child because parent does not exist ! */
                ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 103 lv-include = "gsc_dataset_entity|gsc_entity_mnemonic":U.
                RUN error-message (lv-errgrp, lv-errnum, lv-include).
              END.
    
    
  END.

/* Generated by ICF ERwin Template */
/* gsc_deploy_dataset includes gsc_dataset_entity ON CHILD UPDATE RESTRICT */
IF NEW gsc_dataset_entity OR  gsc_dataset_entity.deploy_dataset_obj <> o_gsc_dataset_entity.deploy_dataset_obj  THEN
  DO:
    IF NOT(CAN-FIND(FIRST gsc_deploy_dataset WHERE
        gsc_dataset_entity.deploy_dataset_obj = gsc_deploy_dataset.deploy_dataset_obj)) THEN
              DO:
                /* Cannot update child because parent does not exist ! */
                ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 103 lv-include = "gsc_dataset_entity|gsc_deploy_dataset":U.
                RUN error-message (lv-errgrp, lv-errnum, lv-include).
              END.
    
    
  END.








IF NOT NEW gsc_dataset_entity AND gsc_dataset_entity.{&TRIGGER_OBJ} <> o_gsc_dataset_entity.{&TRIGGER_OBJ} THEN
    DO:
        ASSIGN lv-error = YES lv-errgrp = "AF":U lv-errnum = 13 lv-include = "table object number":U.
        RUN error-message (lv-errgrp,lv-errnum,lv-include).
    END.

/* Customisations to WRITE trigger */
{icf/trg/gscdetrigw.i}

/* Update Audit Log */
IF CAN-FIND(FIRST gsc_entity_mnemonic
            WHERE gsc_entity_mnemonic.entity_mnemonic = 'gscde':U
              AND gsc_entity_mnemonic.auditing_enabled = YES) THEN
  RUN af/app/afauditlgp.p (INPUT "WRITE":U, INPUT "gscde":U, INPUT BUFFER gsc_dataset_entity:HANDLE, INPUT BUFFER o_gsc_dataset_entity:HANDLE).

/* Standard bottom of WRITE trigger code */
{af/sup/aftrigendw.i}


