

SET source_system_id  = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'NETSUITE_ITEM_COLLECTION_XREF' AND source_system_status = 'ACTIVE');
SET source_system_name  = (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'NETSUITE_ITEM_COLLECTION_XREF' AND source_system_status = 'ACTIVE');

MERGE INTO bo.product_keyset as keyset using
(
SELECT DISTINCT
        $SOURCE_SYSTEM_ID as SOURCE_SYSTEM_ID  ,
        $SOURCE_SYSTEM_NAME as SOURCE_SYSTEM_NAME,
        bo.nonzero_field(i.item_id) as NETSUITE_ITEM_ID,
        bo.nonzero_field(i.DisplayName) as PRODUCT_DISPLAY_NAME, 
        bo.nonzero_field(s.DWR_Style_ID) as DWR_STYLE_ID,
        bo.nonzero_field(s.DWR_Style_Name) as DWR_STYLE_NAME,
        bo.nonzero_field(hmc.List_Item_Name) as  NETSUITE_HM_CATEGORY,
        bo.nonzero_field(hmsc.List_Item_Name) as NETSUITE_HM_SUBCATEGORY,
        bo.nonzero_field(c.List_Item_Name)  as NETSUITE_COLLECTION_NAME,
        bo.nonzero_field(i.Full_Name) as KEYSET_FIELD1_NO ,
        'Netsuite_Items.Full_Name as Sku_Code' as KEYSET_FIELD1_NAME,
        bo.nonzero_field(c.List_ID) as KEYSET_FIELD2_NO,
        'Netsuite_Collection.List_ID' as KEYSET_FIELD2_NAME,
        bo.nonzero_field(hmc.List_ID) as KEYSET_FIELD3_NO,
        'Netsuite_HM_Categories.List_ID' as KEYSET_FIELD3_NAME,
              CASE
        WHEN    LEN(hmsc.List_ID)   =   0   THEN    '0'
        ELSE    bo.nonzero_field(hmsc.List_ID)
        END as KEYSET_FIELD4_NO ,
        'Netsuite_HM_Subcategory.List_ID' as KEYSET_FIELD4_NAME,
        '1' as ACTIVE_RECORD,    
        CURRENT_TIMESTAMP as ACTIVE_START_TIMESTAMP,  
		'NAC_product_load_bo_product_20210323' as CREATED_PROCESS,
        CURRENT_TIMESTAMP as CREATED_TIMESTAMP
FROM 
    RAW.NETSUITE_5TRAN_ITEMS i
INNER JOIN
    RAW.Netsuite_5TRAN_DWR_Style s on i.Style_ID = s.DWR_Style_ID
INNER JOIN
    RAW.Netsuite_5TRAN_Collection c on s.Collection_ID = c.List_ID
LEFT JOIN
    RAW.Netsuite_5TRAN_HM_Categories hmc on s.HM_Category_ID = hmc.List_ID
LEFT JOIN
    RAW.Netsuite_5TRAN_HM_Subcategory hmsc on s.HM_Subcategory_ID = hmsc.List_ID
) as netsuite_category
ON  
    netsuite_category.SOURCE_SYSTEM_ID  =   keyset.SOURCE_SYSTEM_ID  
    AND netsuite_category.NETSUITE_ITEM_ID  =   keyset.NETSUITE_ITEM_ID 	
    AND netsuite_category.PRODUCT_DISPLAY_NAME  =   keyset.PRODUCT_DISPLAY_NAME
    AND netsuite_category.DWR_STYLE_ID  =   keyset.DWR_STYLE_ID	
    AND netsuite_category.DWR_STYLE_NAME    =   keyset.DWR_STYLE_NAME	
    AND netsuite_category.NETSUITE_HM_CATEGORY  =   keyset.NETSUITE_HM_CATEGORY	
    AND netsuite_category.NETSUITE_HM_SUBCATEGORY   =   keyset.NETSUITE_HM_SUBCATEGORY	
    AND netsuite_category.NETSUITE_COLLECTION_NAME  =   keyset.NETSUITE_COLLECTION_NAME	
    AND netsuite_category.KEYSET_FIELD1_NO  =   keyset.KEYSET_FIELD1_NO  
    AND netsuite_category.KEYSET_FIELD1_NAME    =   keyset.KEYSET_FIELD1_NAME
    AND netsuite_category.KEYSET_FIELD2_NO  =   keyset.KEYSET_FIELD2_NO 
    AND netsuite_category.KEYSET_FIELD2_NAME    =   keyset.KEYSET_FIELD2_NAME
    AND netsuite_category.KEYSET_FIELD3_NO  =   keyset.KEYSET_FIELD3_NO 
    AND netsuite_category.KEYSET_FIELD3_NAME    =   keyset.KEYSET_FIELD3_NAME
    AND netsuite_category.KEYSET_FIELD4_NO  =   keyset.KEYSET_FIELD4_NO 
    AND netsuite_category.KEYSET_FIELD4_NAME    =   keyset.KEYSET_FIELD4_NAME
    AND netsuite_category.ACTIVE_RECORD =   keyset.ACTIVE_RECORD      
WHEN NOT MATCHED THEN INSERT
(
    SOURCE_SYSTEM_ID  ,
    SOURCE_SYSTEM_NAME,
    NETSUITE_ITEM_ID 	,
    PRODUCT_DISPLAY_NAME	,
    DWR_STYLE_ID	,
    DWR_STYLE_NAME	,
    NETSUITE_HM_CATEGORY	,
    NETSUITE_HM_SUBCATEGORY	,
    NETSUITE_COLLECTION_NAME	,
    KEYSET_FIELD1_NO , --i.Full_Name
    KEYSET_FIELD1_NAME,
    KEYSET_FIELD2_NO , --c.List_ID
    KEYSET_FIELD2_NAME,
    KEYSET_FIELD3_NO ,--hmc.List_ID
    KEYSET_FIELD3_NAME,
    KEYSET_FIELD4_NO ,--hmsc.List_ID
    KEYSET_FIELD4_NAME,
    ACTIVE_RECORD   ,    
    ACTIVE_START_TIMESTAMP  ,
    CREATED_PROCESS ,
    CREATED_TIMESTAMP       
)
VALUES
(  
    netsuite_category.SOURCE_SYSTEM_ID  ,
    netsuite_category.SOURCE_SYSTEM_NAME,
    netsuite_category.NETSUITE_ITEM_ID 	,
    netsuite_category.PRODUCT_DISPLAY_NAME	,
    netsuite_category.DWR_STYLE_ID	,
    netsuite_category.DWR_STYLE_NAME	,
    netsuite_category.NETSUITE_HM_CATEGORY	,
    netsuite_category.NETSUITE_HM_SUBCATEGORY	,
    netsuite_category.NETSUITE_COLLECTION_NAME	,
    netsuite_category.KEYSET_FIELD1_NO , --i.Full_Name
    netsuite_category.KEYSET_FIELD1_NAME,
    netsuite_category.KEYSET_FIELD2_NO , --c.List_ID
    netsuite_category.KEYSET_FIELD2_NAME,
    netsuite_category.KEYSET_FIELD3_NO ,--hmc.List_ID
    netsuite_category.KEYSET_FIELD3_NAME,
    netsuite_category.KEYSET_FIELD4_NO ,--hmsc.List_ID
    netsuite_category.KEYSET_FIELD4_NAME,
    netsuite_category.ACTIVE_RECORD   ,    
    netsuite_category.ACTIVE_START_TIMESTAMP  ,
    netsuite_category.CREATED_PROCESS ,
    netsuite_category.CREATED_TIMESTAMP       
)
  ; 