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

TRIGGER PROCEDURE FOR CREATE OF gsc_deploy_package .

/* generic trigger override include file to disable trigger if required */
{af/sup2/aftrigover.i &DB-NAME      = "ICFDB"
                      &TABLE-NAME   = "gsc_deploy_package"
                      &TRIGGER-TYPE = "CREATE"}

/* Created automatically using ERwin ICF Trigger template db/af/erw/afercustrg.i
   Do not change manually. Customisations to triggers should be placed in separate
   include files pulled into the trigger. ICF auto generates write trigger custom
   include files. Delete or create customisation include files need to be created
   manually. Be sure to put the hook in ERwin directly so as not to have you changes
   overwritten.
   User defined Macro (UDP) Summary (case sensitive)
   gsc_deploy_package           Expands to full table name, e.g. gsm_user
   %TableFLA            Expands to table unique code, e.g. gsmus
   %TableObj            If blank or not defined expands to table_obj with no prefix (framework standard)
                        If defined, uses this field as the object field
                        If set to "none" then indicates table does not have an object field
   XYZ                  Do not define so we can compare against an empty string

   See docs for explanation of replication macros 
*/   

&SCOPED-DEFINE TRIGGER_TABLE gsc_deploy_package
&SCOPED-DEFINE TRIGGER_FLA gscdp
&SCOPED-DEFINE TRIGGER_OBJ deploy_package_obj


DEFINE BUFFER lb_table FOR gsc_deploy_package.      /* Used for recursive relationships */
DEFINE BUFFER lb1_table FOR gsc_deploy_package.     /* Used for lock upgrades */

DEFINE BUFFER o_gsc_deploy_package FOR gsc_deploy_package.

/* Standard top of CREATE trigger code */
{af/sup/aftrigtopc.i}

  








ASSIGN gsc_deploy_package.{&TRIGGER_OBJ} = getNextObj().





/* Update Audit Log */
IF CAN-FIND(FIRST gsc_entity_mnemonic
            WHERE gsc_entity_mnemonic.entity_mnemonic = 'gscdp':U
              AND gsc_entity_mnemonic.auditing_enabled = YES) THEN
  RUN af/app/afauditlgp.p (INPUT "CREATE":U, INPUT "gscdp":U, INPUT BUFFER gsc_deploy_package:HANDLE, INPUT BUFFER o_gsc_deploy_package:HANDLE).

/* Standard bottom of CREATE trigger code */
{af/sup/aftrigendc.i}


/* Place any specific CREATE trigger customisations here */