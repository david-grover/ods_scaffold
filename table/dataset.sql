CREATE OR REPLACE TABLE DATASET 0626
	(	
		DATASET_ID     NUMBER(38,0) IDENTITY
     	,DATASET_NAME     varchar(100) DEFAULT '0'
     	,DATASET_DESC     varchar(100) DEFAULT '0'
     	,DATASET_STATUS     varchar(100) DEFAULT '0'
     	,DATASET_BUSINESS_OWNER     varchar(100) DEFAULT '0'
     	,DATASET_OPERATOR     varchar(100) DEFAULT '0'
     	,CREATED_TIMESTAMP     timestamp_ntz  DEFAULT current_timestamp
     	,UPDATED_TIMESTAMP     timestamp_ntz  DEFAULT current_timestamp
     	,CREATED_PROCESS     varchar(100) DEFAULT '0'
     	,UPDATED_PROCESS     varchar(100) DEFAULT '0'     
     );
