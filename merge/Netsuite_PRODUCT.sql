

SET source_system_id  = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'NETSUITE_PRODUCT' AND source_system_status = 'ACTIVE');
SET source_system_name  = (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'NETSUITE_PRODUCT' AND source_system_status = 'ACTIVE');

MERGE INTO bo.product_keyset as keyset using
(
  SELECT DISTINCT
          $source_system_id as source_system_id,
          $source_system_name as source_system_name, 
          bo.nonzero_field(ni.ITEM_ID) as NETSUITE_ITEM_ID,
          bo.nonzero_field(ni.UPC_CODE)  as UPC_CODE	,
          bo.nonzero_field(ni.DISPLAYNAME)  as PRODUCT_DISPLAY_NAME,
          bo.nonzero_field(ni.MPN)  as MANUFACTURER_PART_NO,
          bo.nonzero_field(ni.SFDC_INTEGRATION_ID)  as SFDC_INTEGRATION_ID,
          bo.nonzero_field(ni.NAME)  as KEYSET_FIELD1_NO,
          'NAME'as KEYSET_FIELD1_NAME,
          bo.nonzero_field(ni.TYPE_NAME)  as KEYSET_FIELD2_NO,
          'TYPE_NAME' as KEYSET_FIELD2_NAME,
          bo.nonzero_field(ni.ITEM_TYPE_ID)  as KEYSET_FIELD3_NO,
          'ITEM_TYPE_ID' as KEYSET_FIELD3_NAME,
          bo.nonzero_field(ni.VENDORNAME) as KEYSET_FIELD4_NO,
          'VENDORNAME' as KEYSET_FIELD4_NAME,
           bo.nonzero_field(ni.FULL_NAME) as KEYSET_FIELD5_NO,
          'FULL_NAME' as KEYSET_FIELD5_NAME,
          '1'   as active_record,    
          CURRENT_TIMESTAMP as ACTIVE_START_TIMESTAMP,  
          'NAC_product_load_bo_product_20210323' as CREATED_PROCESS,
          CURRENT_TIMESTAMP  as CREATED_TIMESTAMP     
  FROM 
      RAW.NETSUITE_5TRAN_ITEMS	ni
) as stg_ni
ON 
  stg_ni.NETSUITE_ITEM_ID	=	keyset.NETSUITE_ITEM_ID 	
  AND stg_ni.UPC_CODE	=	keyset.UPC_CODE	
  AND stg_ni.PRODUCT_DISPLAY_NAME	=	keyset.PRODUCT_DISPLAY_NAME
  AND stg_ni.MANUFACTURER_PART_NO	=	keyset.MANUFACTURER_PART_NO
  AND stg_ni.SFDC_INTEGRATION_ID	=	keyset.SFDC_INTEGRATION_ID 
  AND stg_ni.KEYSET_FIELD1_NO	=	keyset.KEYSET_FIELD1_NO
  AND stg_ni.KEYSET_FIELD2_NO	=	keyset.KEYSET_FIELD2_NO 
  AND stg_ni.KEYSET_FIELD3_NO	=	keyset.KEYSET_FIELD3_NO
  AND stg_ni.KEYSET_FIELD4_NO	=	keyset.KEYSET_FIELD4_NO
  AND stg_ni.KEYSET_FIELD5_NO	=	keyset.KEYSET_FIELD5_NO
  AND stg_ni.source_system_id	=	keyset.source_system_id
  AND stg_ni.ACTIVE_RECORD	=	keyset.active_record
WHEN NOT MATCHED THEN INSERT
(
    SOURCE_SYSTEM_ID  ,
    SOURCE_SYSTEM_NAME,
    NETSUITE_ITEM_ID 	,
    UPC_CODE	,
    PRODUCT_DISPLAY_NAME	,
    MANUFACTURER_PART_NO	,
    SFDC_INTEGRATION_ID	,
    KEYSET_FIELD1_NO , --NAME
    KEYSET_FIELD1_NAME,
    KEYSET_FIELD2_NO ,--TYPE_NAME 
    KEYSET_FIELD2_NAME,
    KEYSET_FIELD3_NO ,--ITEM_TYPE_ID
    KEYSET_FIELD3_NAME,
    KEYSET_FIELD4_NO ,--VENDORNAME
    KEYSET_FIELD4_NAME,
    KEYSET_FIELD5_NO ,--FULL_NAME
    KEYSET_FIELD5_NAME,
    ACTIVE_RECORD   ,    
    ACTIVE_START_TIMESTAMP  ,
    CREATED_PROCESS ,
    CREATED_TIMESTAMP       
) 
VALUES
(
    stg_ni.SOURCE_SYSTEM_ID  ,
    stg_ni.SOURCE_SYSTEM_NAME,
    stg_ni.NETSUITE_ITEM_ID 	,
    stg_ni.UPC_CODE	,
    stg_ni.PRODUCT_DISPLAY_NAME	,
    stg_ni.MANUFACTURER_PART_NO	,
    stg_ni.SFDC_INTEGRATION_ID	,
    stg_ni.KEYSET_FIELD1_NO , --NAME
    stg_ni.KEYSET_FIELD1_NAME,
    stg_ni.KEYSET_FIELD2_NO ,--TYPE_NAME 
    stg_ni.KEYSET_FIELD2_NAME,
    stg_ni.KEYSET_FIELD3_NO ,--ITEM_TYPE_ID
    stg_ni.KEYSET_FIELD3_NAME,
    stg_ni.KEYSET_FIELD4_NO ,--VENDORNAME
    stg_ni.KEYSET_FIELD4_NAME,
    stg_ni.KEYSET_FIELD5_NO ,--FULL_NAME
    stg_ni.KEYSET_FIELD5_NAME,
    stg_ni.ACTIVE_RECORD   ,    
    stg_ni.ACTIVE_START_TIMESTAMP  ,
    stg_ni.CREATED_PROCESS ,
    stg_ni.CREATED_TIMESTAMP       
)
;