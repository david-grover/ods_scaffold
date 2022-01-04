
 


-- Seed the source_system_id
INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'Adwords',
    'Adwords as of 2020-12-29.' -- If you choose a name like SFMC_NEW it will show up in the reporting forever 
,
    'ACTIVE' -- defaults to active.
,
    'Unknown' -- DG 20201020: too lazy to create two additional fields here
,
    'Unknown' -- DG 20201020: too lazy to create two additional fields here
,
    current_timestamp,
    'Adwords_load_bo_engagement_2021230'
WHERE
    NOT EXISTS (
        SELECT
            source_system_name
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Adwords'
            AND source_system_status = 'ACTIVE'
    );

    
    
-- Seed the source_system_id
INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'BlueCore',
    'BlueCore as of 2020-11-18' -- If you choose a name like SFMC_NEW it will show up in the reporting forever 
,
    'ACTIVE' -- defaults to active.
,
    'Katherine Yellen kyellen@dwr.com' -- DG 20201020: too lazy to create two additional fields here
,
    'No operator, contact Katie.' -- DG 20201020: too lazy to create two additional fields here
,
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
WHERE
    NOT EXISTS (
        SELECT
            source_system_name
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    );
SET created_process = 'CJ_load_bo_engagement_20210407'; 

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'CJ',
    'Commission Junction - Publisher Metrics',
    'ACTIVE',
    'Michelle Feldman <mfeldman@dwr.com>',
    'Hassler Castro <hcchum@hermanmiller.com>',
    current_timestamp,
    $created_process
WHERE
    NOT EXISTS (
        SELECT
            source_system_name
        FROM
            bo.source_system
        WHERE
            source_system_name = 'CJ'
            AND source_system_status = 'ACTIVE'
    );
-------------------------------------------
--- Adding source system ------------------
-------------------------------------------
INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'Pinterest',
    'Pinterest metrics for each brand at the pin_promotion level (HMI/HAY/DWR)',
    'ACTIVE',
    'Chessia McBride <chessia_kelley@hermanmiller.com>',
    'Hassler Castro <hcchum@hermanmiller.com>',
    current_timestamp,
    'Pinterest_load_bo_engagement_20210304'
WHERE
    NOT EXISTS (
        SELECT
            source_system_name
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Pinterest'
            AND source_system_status = 'ACTIVE'
    );

SET created_process = 'Steelhouse_load_bo_engagement_20210331'; 

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'Steelhouse',
    'Steelhouse campaigns and metrics',
    'ACTIVE',
    'Michelle Feldman <mfeldman@dwr.com>',
    'Hassler Castro <hcchum@hermanmiller.com>',
    current_timestamp,
    $created_process
WHERE
    NOT EXISTS (
        SELECT
            source_system_name
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Steelhouse'
            AND source_system_status = 'ACTIVE'
    );

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'Salesforce Marketing Cloud',
    'SFMC as of 2020-10-20.' -- If you choose a name like SFMC_NEW it will show up in the reporting forever 
,
    'ACTIVE' -- defaults to active.
,
    'Katherine Yellen kyellen@dwr.com' -- DG 20201020: too lazy to create two additional fields here
,
    'Frank DeMaria fdemaria@dwr.com' -- DG 20201020: too lazy to create two additional fields here
,
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
WHERE
    NOT EXISTS (
        SELECT
            source_system_name
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    );

INSERT INTO
	bo.source_system (
		source_system_name,
		source_system_desc,
		source_system_status,
		source_system_business_owner,
		source_system_operator,
		created_timestamp,
		created_process
	)
SELECT
	DISTINCT 'SFDC_order',
	'Copy of SFDC tables.',
	'ACTIVE',
	'Frank DeMaria fdemaria@dwr.com',
	'Donny Gilmour',
	current_timestamp,
	'DG_20201105_SFDC_order_manual'
FROM
	bo.source_system ss
WHERE
	NOT EXISTS (SELECT source_system_id	FROM bo.source_system WHERE	source_system_name = 'SFDC_order' AND source_system_status = 'ACTIVE');
INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'Google Analytics',
    'GA session-level extract as of 2020-10-22.' -- If you choose a name like SFMC_NEW it will show up in the reporting forever 
,
    'ACTIVE' -- defaults to active.
,
    'Mark Gergess mark_gergess@hermanmiller.com' -- DG 20201020: too lazy to create two additional fields here
,
    'Joel Leo joel_leo@hermanmiller.com' -- DG 20201020: too lazy to create two additional fields here
,
    current_timestamp,
    'airflow_ga360_sessions_load_20210406'
WHERE
    NOT EXISTS (
        SELECT
            source_system_name
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Google Analytics'
            AND source_system_status = 'ACTIVE'
    );
	
	
INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'SFDC_PRODUCT',
    'SFDC OrderItem fields, best-guess as of 20210309.',
    'ACTIVE' ,
    'Unknown',
    'Frank DeMaria most likely' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'SFDC_PRODUCT' AND source_system_status = 'ACTIVE' );

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'NETSUITE_PRODUCT',
    'Netsuite ITEMS fields, best-guess as of 20210309.',
    'ACTIVE' ,
    'Unknown',
    'Frank DeMaria most likely' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'NETSUITE_PRODUCT' AND source_system_status = 'ACTIVE' );

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'NETSUITE_ITEM_COLLECTION_XREF',
    'Map of Zach''s categorization query as of 20210309.',
    'ACTIVE' ,
    'Unknown',
    'Frank DeMaria most likely' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'NETSUITE_ITEM_COLLECTION_XREF' AND source_system_status = 'ACTIVE' );

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'FO_PRODUCT',
    'Distinct set from FO_PRODUCT.',
    'ACTIVE' ,
    'Unknown',
    'Gary Gifford/Cindy Pizunski' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'FO_PRODUCT' AND source_system_status = 'ACTIVE' );

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'HYPERION_PRODUCT_CATEGORY',
    'Hyperion product hierarchy.',
    'ACTIVE' ,
    'Pat Hogan <Pat_Hogan@hermanmiller.com>',
    'Vicky Lindquist <Vicky_Lindquist@hermanmiller.com>' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'HYPERION_PRODUCT_CATEGORY' AND source_system_status = 'ACTIVE' );
    

--  Facebook
-- Seed the source_system_id
INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'PERF_FACEBOOK_1',
    'Rollup of Facebook action data to get metrics plus $s.' -- If you choose a name like SFMC_NEW it will show up in the reporting forever 
,
    'ACTIVE' -- defaults to active.
,
    'Chessia McBride <chessia_kelley@hermanmiller.com>' -- DG 20201020: too lazy to create two additional fields here
,
    'Who wants to play the exciting role of Facebook system operator?!?' -- DG 20201020: too lazy to create two additional fields here
,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
WHERE
    NOT EXISTS (
        SELECT
            source_system_name
        FROM
            bo.source_system
        WHERE
            source_system_name = 'PERF_FACEBOOK_1'
            AND source_system_status = 'ACTIVE'
    );    
    
INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'SFDC_PRODUCT',
    'SFDC OrderItem fields, best-guess as of 20210309.',
    'ACTIVE' ,
    'Unknown',
    'Frank DeMaria most likely' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'SFDC_PRODUCT' AND source_system_status = 'ACTIVE' );

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'NETSUITE_PRODUCT',
    'Netsuite ITEMS fields, best-guess as of 20210309.',
    'ACTIVE' ,
    'Unknown',
    'Frank DeMaria most likely' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'NETSUITE_PRODUCT' AND source_system_status = 'ACTIVE' );

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'NETSUITE_ITEM_COLLECTION_XREF',
    'Map of Zach''s categorization query as of 20210309.',
    'ACTIVE' ,
    'Unknown',
    'Frank DeMaria most likely' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'NETSUITE_ITEM_COLLECTION_XREF' AND source_system_status = 'ACTIVE' );

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'FO_PRODUCT',
    'Distinct set from FO_PRODUCT.',
    'ACTIVE' ,
    'Unknown',
    'Gary Gifford/Cindy Pizunski' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'FO_PRODUCT' AND source_system_status = 'ACTIVE' );

INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'HYPERION_PRODUCT_CATEGORY',
    'Hyperion product hierarchy.',
    'ACTIVE' ,
    'Pat Hogan <Pat_Hogan@hermanmiller.com>',
    'Vicky Lindquist <Vicky_Lindquist@hermanmiller.com>' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'HYPERION_PRODUCT_CATEGORY' AND source_system_status = 'ACTIVE' );


INSERT INTO
    bo.source_system (
        source_system_name,
        source_system_desc,
        source_system_status,
        source_system_business_owner,
        source_system_operator,
        created_timestamp,
        created_process
    )
SELECT
    'CSP_OFFERING',
    'Offering code to assign product_brand to CIW products.',
    'ACTIVE' ,
    'Unknown <unknown@hermanmiller.com>',
    'Unknown <unknown@hermanmiller.com>' ,
    current_timestamp,
    'NAC_product_load_bo_product_20210323'
WHERE
    NOT EXISTS (SELECT source_system_name FROM bo.source_system WHERE source_system_name = 'CSP_OFFERING' AND source_system_status = 'ACTIVE' );    