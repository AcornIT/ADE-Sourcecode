/*********************************************************************
* Copyright (C) 2005 by Progress Software Corporation. All rights    *
* reserved.  Prior versions of this work may contain portions        *
* contributed by participants of Possenet.                           *
*                                                                    *
*********************************************************************/

TRIGGER PROCEDURE FOR DELETE OF gsm_category .

/* Created automatically using ERwin ICF Trigger template db/af/erw/afercustrg.i
   Do not change manually. Customisations to triggers should be placed in separate
   include files pulled into the trigger. ICF auto generates write trigger custom
   include files. Delete or create customisation include files need to be created
   manually. Be sure to put the hook in ERwin directly so as not to have you changes
   overwritten.
   User defined Macro (UDP) Summary (case sensitive)
   gsm_category           Expands to full table name, e.g. gsm_user
   %TableFLA            Expands to table unique code, e.g. gsmus
   %TableObj            If blank or not defined expands to table_obj with no prefix (framework standard)
                        If defined, uses this field as the object field
                        If set to "none" then indicates table does not have an object field
   XYZ                  Do not define so we can compare against an empty string

   See docs for explanation of replication macros 
*/   

&SCOPED-DEFINE TRIGGER_TABLE gsm_category
&SCOPED-DEFINE TRIGGER_FLA gsmca
&SCOPED-DEFINE TRIGGER_OBJ category_obj


DEFINE BUFFER lb_table FOR gsm_category.      /* Used for recursive relationships */
DEFINE BUFFER lb1_table FOR gsm_category.     /* Used for lock upgrades */

DEFINE BUFFER o_gsm_category FOR gsm_category.

/* Standard top of DELETE trigger code */
{af/sup/aftrigtopd.i}

  




/* Generated by ICF ERwin Template */
/* gsm_category of gsm_control_code ON PARENT DELETE RESTRICT */
IF CAN-FIND(FIRST gsm_control_code WHERE
    gsm_control_code.category_obj = gsm_category.category_obj) THEN
    DO:
      /* Cannot delete parent because child exists! */
      ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 101 lv-include = "gsm_category|gsm_control_code":U.
      RUN error-message (lv-errgrp, lv-errnum, lv-include).
    END.



/* Generated by ICF ERwin Template */
/* gsm_category of gsc_custom_procedure ON PARENT DELETE RESTRICT */
IF CAN-FIND(FIRST gsc_custom_procedure WHERE
    gsc_custom_procedure.category_obj = gsm_category.category_obj) THEN
    DO:
      /* Cannot delete parent because child exists! */
      ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 101 lv-include = "gsm_category|gsc_custom_procedure":U.
      RUN error-message (lv-errgrp, lv-errnum, lv-include).
    END.



/* Generated by ICF ERwin Template */
/* gsm_category of gsc_language_text ON PARENT DELETE RESTRICT */
IF CAN-FIND(FIRST gsc_language_text WHERE
    gsc_language_text.category_obj = gsm_category.category_obj) THEN
    DO:
      /* Cannot delete parent because child exists! */
      ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 101 lv-include = "gsm_category|gsc_language_text":U.
      RUN error-message (lv-errgrp, lv-errnum, lv-include).
    END.



/* Generated by ICF ERwin Template */
/* gsm_category of gsm_status ON PARENT DELETE RESTRICT */
IF CAN-FIND(FIRST gsm_status WHERE
    gsm_status.category_obj = gsm_category.category_obj) THEN
    DO:
      /* Cannot delete parent because child exists! */
      ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 101 lv-include = "gsm_category|gsm_status":U.
      RUN error-message (lv-errgrp, lv-errnum, lv-include).
    END.



/* Generated by ICF ERwin Template */
/* gsm_category of gsm_multi_media ON PARENT DELETE RESTRICT */
IF CAN-FIND(FIRST gsm_multi_media WHERE
    gsm_multi_media.category_obj = gsm_category.category_obj) THEN
    DO:
      /* Cannot delete parent because child exists! */
      ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 101 lv-include = "gsm_category|gsm_multi_media":U.
      RUN error-message (lv-errgrp, lv-errnum, lv-include).
    END.



/* Generated by ICF ERwin Template */
/* gsm_category of gsm_comment ON PARENT DELETE RESTRICT */
IF CAN-FIND(FIRST gsm_comment WHERE
    gsm_comment.category_obj = gsm_category.category_obj) THEN
    DO:
      /* Cannot delete parent because child exists! */
      ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 101 lv-include = "gsm_category|gsm_comment":U.
      RUN error-message (lv-errgrp, lv-errnum, lv-include).
    END.












/* Update Audit Log */
IF CAN-FIND(FIRST gsc_entity_mnemonic
            WHERE gsc_entity_mnemonic.entity_mnemonic = 'gsmca':U
              AND gsc_entity_mnemonic.auditing_enabled = YES) THEN
  RUN af/app/afauditlgp.p (INPUT "DELETE":U, INPUT "gsmca":U, INPUT BUFFER gsm_category:HANDLE, INPUT BUFFER o_gsm_category:HANDLE).

/* Standard bottom of DELETE trigger code */
{af/sup/aftrigendd.i}


/* Place any specific DELETE trigger customisations here */