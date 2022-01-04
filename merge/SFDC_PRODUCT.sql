
SET source_system_id  = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'SFDC_PRODUCT' AND source_system_status = 'ACTIVE');
SET source_system_name  = (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'SFDC_PRODUCT' AND source_system_status = 'ACTIVE');

MERGE INTO bo.product_keyset as keyset using
(
    SELECT DISTINCT
		$source_system_id as source_system_id,
		$source_system_name as source_system_name, 
		bo.nonzero_field(oi.PRODUCT_NAME__C)  as PRODUCT_DISPLAY_NAME,
		bo.nonzero_field(oi.sku_code__c)  as KEYSET_FIELD1_NO,
		'SKU_CODE__C' as KEYSET_FIELD1_NAME,
		bo.nonzero_field(oi.ORDERITEMNUMBER)  AS KEYSET_FIELD2_NO,
		'ORDERITEMNUMBER'  AS KEYSET_FIELD2_NAME,
		bo.nonzero_field(oi.PRODUCT2ID)  as KEYSET_FIELD3_NO,
		'PRODUCT2ID' as KEYSET_FIELD3_NAME,
		bo.nonzero_field(oi.ITEM_TYPE__C)  as KEYSET_FIELD4_NO,
		'ITEM_TYPE__C' as KEYSET_FIELD4_NAME,
		bo.nonzero_field(oi.PRODUCT_DESCRIPTION__C)  as KEYSET_FIELD5_NO,
		'PRODUCT_DESCRIPTION__C' as KEYSET_FIELD5_NAME,
		bo.nonzero_field(oi.PRODUCT_VENDOR__C) as KEYSET_FIELD6_NO,
		'PRODUCT_VENDOR__C' as KEYSET_FIELD6_NAME,
		bo.nonzero_field(oi.PRODUCT_CODE__C)  as KEYSET_FIELD7_NO,
		'PRODUCT_CODE__C' as KEYSET_FIELD7_NAME,
		bo.nonzero_field(oi.PRODUCT_NSINT_SOURCE_ID__C) as KEYSET_FIELD8_NO,
		'PRODUCT_NSINT_SOURCE_ID__C' as KEYSET_FIELD8_NAME,
		bo.nonzero_field(oi.CUSTOM_TYPE__C) as KEYSET_FIELD9_NO,
		'CUSTOM_TYPE__C' as KEYSET_FIELD9_NAME,
		'1'   as        ACTIVE_RECORD   ,            
		CURRENT_TIMESTAMP as ACTIVE_START_TIMESTAMP ,  
		'NAC_product_load_bo_product_20210323' as CREATED_PROCESS ,
		CURRENT_TIMESTAMP as CREATED_TIMESTAMP          
    FROM		
		raw.sfdc_orderitem	oi 
) as stg_sfdc
ON  stg_sfdc.source_system_id = keyset.source_system_id
AND stg_sfdc.product_display_name   =   keyset.product_display_name
AND stg_sfdc.KEYSET_FIELD1_NO   =   keyset.KEYSET_FIELD1_NO 
AND	stg_sfdc.KEYSET_FIELD2_NO	=	keyset.KEYSET_FIELD2_NO 
AND	stg_sfdc.KEYSET_FIELD3_NO	=	keyset.KEYSET_FIELD3_NO 
AND	stg_sfdc.KEYSET_FIELD4_NO	=	keyset.KEYSET_FIELD4_NO 
AND	stg_sfdc.KEYSET_FIELD5_NO	=	keyset.KEYSET_FIELD5_NO 
AND	stg_sfdc.KEYSET_FIELD6_NO	=	keyset.KEYSET_FIELD6_NO 
AND	stg_sfdc.KEYSET_FIELD7_NO	=	keyset.KEYSET_FIELD7_NO 
AND	stg_sfdc.KEYSET_FIELD8_NO	=	keyset.KEYSET_FIELD8_NO 
AND	stg_sfdc.KEYSET_FIELD9_NO	=	keyset.KEYSET_FIELD9_NO 
AND stg_sfdc.ACTIVE_RECORD	=	keyset.ACTIVE_RECORD
WHEN NOT MATCHED THEN INSERT 
(
		source_system_id,
		source_system_name, 
		PRODUCT_DISPLAY_NAME,
		KEYSET_FIELD1_NO,
		KEYSET_FIELD1_NAME,
		KEYSET_FIELD2_NO,
		KEYSET_FIELD2_NAME,
		KEYSET_FIELD3_NO,
		KEYSET_FIELD3_NAME,
		KEYSET_FIELD4_NO,
		KEYSET_FIELD4_NAME,
		KEYSET_FIELD5_NO,
		KEYSET_FIELD5_NAME,
		KEYSET_FIELD6_NO,
		KEYSET_FIELD6_NAME,
		KEYSET_FIELD7_NO,
		KEYSET_FIELD7_NAME,
		KEYSET_FIELD8_NO,
		KEYSET_FIELD8_NAME,
		KEYSET_FIELD9_NO,
		KEYSET_FIELD9_NAME,
		ACTIVE_RECORD   ,            
		ACTIVE_START_TIMESTAMP ,  
		CREATED_PROCESS ,
		CREATED_TIMESTAMP   
  )
VALUES
(		
        stg_sfdc.source_system_id,
		stg_sfdc.source_system_name, 
		stg_sfdc.PRODUCT_DISPLAY_NAME,
		stg_sfdc.KEYSET_FIELD1_NO,
		stg_sfdc.KEYSET_FIELD1_NAME,
		stg_sfdc.KEYSET_FIELD2_NO,
		stg_sfdc.KEYSET_FIELD2_NAME,
		stg_sfdc.KEYSET_FIELD3_NO,
		stg_sfdc.KEYSET_FIELD3_NAME,
		stg_sfdc.KEYSET_FIELD4_NO,
		stg_sfdc.KEYSET_FIELD4_NAME,
		stg_sfdc.KEYSET_FIELD5_NO,
		stg_sfdc.KEYSET_FIELD5_NAME,
		stg_sfdc.KEYSET_FIELD6_NO,
		stg_sfdc.KEYSET_FIELD6_NAME,
		stg_sfdc.KEYSET_FIELD7_NO,
		stg_sfdc.KEYSET_FIELD7_NAME,
		stg_sfdc.KEYSET_FIELD8_NO,
		stg_sfdc.KEYSET_FIELD8_NAME,
		stg_sfdc.KEYSET_FIELD9_NO,
		stg_sfdc.KEYSET_FIELD9_NAME,
		stg_sfdc.ACTIVE_RECORD   ,            
		stg_sfdc.ACTIVE_START_TIMESTAMP ,  
		stg_sfdc.CREATED_PROCESS ,
		stg_sfdc.CREATED_TIMESTAMP   
) ; 
  