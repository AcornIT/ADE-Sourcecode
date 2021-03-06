/*********************************************************************
* Copyright (C) 2000 by Progress Software Corporation. All rights    *
* reserved. Prior versions of this work may contain portions         *
* contributed by participants of Possenet.                           *
*               PSC                                                  *
*                                                                    *
*********************************************************************/

TRIGGER PROCEDURE FOR CREATE OF gsm_menu_item .

/* Created automatically using ERwin ICF Trigger template db/af/erw/afercustrg.i
   Do not change manually. Customisations to triggers should be placed in separate
   include files pulled into the trigger. ICF auto generates write trigger custom
   include files. Delete or create customisation include files need to be created
   manually. Be sure to put the hook in ERwin directly so as not to have you changes
   overwritten.
   User defined Macro (UDP) Summary (case sensitive)
   gsm_menu_item           Expands to full table name, e.g. gsm_user
   %TableFLA            Expands to table unique code, e.g. gsmus
   %TableObj            If blank or not defined expands to table_obj with no prefix (framework standard)
                        If defined, uses this field as the object field
                        If set to "none" then indicates table does not have an object field
   XYZ                  Do not define so we can compare against an empty string

   See docs for explanation of replication macros 
*/   

&SCOPED-DEFINE TRIGGER_TABLE gsm_menu_item
&SCOPED-DEFINE TRIGGER_FLA gsmmi
&SCOPED-DEFINE TRIGGER_OBJ menu_item_obj


DEFINE BUFFER lb_table FOR gsm_menu_item.      /* Used for recursive relationships */
DEFINE BUFFER lb1_table FOR gsm_menu_item.     /* Used for lock upgrades */

DEFINE BUFFER o_gsm_menu_item FOR gsm_menu_item.

/* Standard top of CREATE trigger code */
{af/sup/aftrigtopc.i}

  



/* Generated by ICF ERwin Template */
/* gsc_language is the source language of gsm_menu_item ON CHILD INSERT RESTRICT */
IF 
    ( gsm_menu_item.source_language_obj <> 0 ) THEN
  DO:
    IF NOT(CAN-FIND(FIRST gsc_language WHERE
        gsm_menu_item.source_language_obj = gsc_language.language_obj)) THEN
        DO:
          /* Cannot create child because parent does not exist ! */
          ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 102 lv-include = "gsm_menu_item|gsc_language":U.
          RUN error-message (lv-errgrp, lv-errnum, lv-include).
        END.
    
    
  END.

/* Generated by ICF ERwin Template */
/* ryc_smartobject appears on gsm_menu_item ON CHILD INSERT SET NULL */
IF NOT(CAN-FIND(FIRST ryc_smartobject WHERE
    gsm_menu_item.object_obj = ryc_smartobject.smartobject_obj)) THEN
  DO:
    
    ASSIGN gsm_menu_item.object_obj = 0 .
  END.



/* Generated by ICF ERwin Template */
/* gsc_product_module has gsm_menu_item ON CHILD INSERT SET NULL */
IF NOT(CAN-FIND(FIRST gsc_product_module WHERE
    gsm_menu_item.product_module_obj = gsc_product_module.product_module_obj)) THEN
  DO:
    
    ASSIGN gsm_menu_item.product_module_obj = 0 .
  END.



/* Generated by ICF ERwin Template */
/* gsc_item_category has gsm_menu_item ON CHILD INSERT SET NULL */
IF NOT(CAN-FIND(FIRST gsc_item_category WHERE
    gsm_menu_item.item_category_obj = gsc_item_category.item_category_obj)) THEN
  DO:
    
    ASSIGN gsm_menu_item.item_category_obj = 0 .
  END.



/* Generated by ICF ERwin Template */
/* gsc_instance_attribute is posted by gsm_menu_item ON CHILD INSERT SET NULL */
IF NOT(CAN-FIND(FIRST gsc_instance_attribute WHERE
    gsm_menu_item.instance_attribute_obj = gsc_instance_attribute.instance_attribute_obj)) THEN
  DO:
    
    ASSIGN gsm_menu_item.instance_attribute_obj = 0 .
  END.








ASSIGN gsm_menu_item.{&TRIGGER_OBJ} = getNextObj() NO-ERROR.
IF ERROR-STATUS:ERROR THEN 
DO:
    ASSIGN lv-error = YES lv-errgrp = "AF ":U lv-errnum = 31 lv-include = "gsm_menu_item|the specified object number.  Please ensure your database sequences have been set correctly":U.
    RUN error-message (lv-errgrp, lv-errnum, lv-include).
END.







/* Update Audit Log */
IF CAN-FIND(FIRST gsc_entity_mnemonic
            WHERE gsc_entity_mnemonic.entity_mnemonic = 'gsmmi':U
              AND gsc_entity_mnemonic.auditing_enabled = YES) THEN
  RUN af/app/afauditlgp.p (INPUT "CREATE":U, INPUT "gsmmi":U, INPUT BUFFER gsm_menu_item:HANDLE, INPUT BUFFER o_gsm_menu_item:HANDLE).

/* Standard bottom of CREATE trigger code */
{af/sup/aftrigendc.i}


/* Place any specific CREATE trigger customisations here */
