
--does address_type need a source_system_id?  
--  20201020    assuming no.  This is a semantic field that means what we say it means in the name.  This creates some problems but I think we can add source_system_id and overwrite or NULL out the foreign keys, 
--              or rewrite them with new types easily later.
INSERT INTO
    bo.address_type (
        address_type,
        created_timestamp,
        created_process
    )
SELECT
    'BlueCore email address',
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
WHERE
    NOT EXISTS (
        SELECT
            address_type_id
        FROM
            bo.address_type
        WHERE
            address_type = 'BlueCore email address'
    );
        -------------------------------------------
	   ----------  Email address -----------------
	   -------------------------------------------
	   
	   INSERT INTO 
	           bo.address_type
	       (
	           address_type
	           ,created_timestamp
	           ,created_process    
	       )        
	   SELECT
	           'NETSUITE_LOCATIONS.EMAIL_ADDRESS'
	           ,current_timestamp
	           ,'DG_20210316_NETSUITE_LOCATIONS'
	   WHERE
	       NOT EXISTS
	           (
	               SELECT
	                   address_type_id
	               FROM
	                   bo.address_type
	               WHERE   
	                   address_type    =   'NETSUITE_LOCATIONS.EMAIL_ADDRESS'  
        );

-------------------------------------------
------------------ Phone ------------------
-------------------------------------------

INSERT INTO 
        bo.address_type
    (
        address_type
        ,created_timestamp
        ,created_process    
    )        
SELECT
        'NETSUITE_LOCATIONS.PHONE'
        ,current_timestamp
        ,'DG_20210316_NETSUITE_LOCATIONS'
WHERE
    NOT EXISTS
        (
            SELECT
                address_type_id
            FROM
                bo.address_type
            WHERE   
                address_type    =   'NETSUITE_LOCATIONS.PHONE'  
        );
        
INSERT INTO 
        bo.address_type
    (
        address_type
        ,created_timestamp
        ,created_process    
    )        
SELECT
        'NETSUITE_LOCATIONS.STREET_ADDRESS'
        ,current_timestamp
        ,'DG_20210316_NETSUITE_LOCATIONS'
WHERE
    NOT EXISTS
        (
            SELECT
                address_type_id
            FROM
                bo.address_type
            WHERE   
                address_type    =   'NETSUITE_LOCATIONS.STREET_ADDRESS'  
        );
        
INSERT INTO
	bo.address_type (
		address_type,
		created_timestamp,
		created_process
	)
SELECT
	'SFDC_order.billing_',
	current_timestamp,
	'DG_20201105_SFDC_order_manual'
WHERE
	NOT EXISTS (
		SELECT
			address_type
		FROM
			bo.address_type
		WHERE
			address_type = 'SFDC_order.billing_'
	);

INSERT INTO
	bo.address_type (
		address_type,
		created_timestamp,
		created_process
	)
SELECT
	'SFDC_order.shipping_',
	current_timestamp,
	'DG_20201105_SFDC_order_manual'
WHERE
	NOT EXISTS (
		SELECT
			address_type
		FROM
			bo.address_type
		WHERE
			address_type = 'SFDC_order.shipping_'
	);

INSERT INTO
	bo.address_type (
		address_type,
		created_timestamp,
		created_process
	)
SELECT
	'SFDC_order.store',
	current_timestamp,
	'DG_20201105_SFDC_order_manual'
WHERE
	NOT EXISTS (
		SELECT
			address_type
		FROM
			bo.address_type
		WHERE
			address_type = 'SFDC_order.store'
	);

INSERT INTO
	bo.address_type (
		address_type,
		created_timestamp,
		created_process
	)
SELECT
	'SFDC_order.account_email',
	current_timestamp,
	'DG_20201105_SFDC_order_manual'
WHERE
	NOT EXISTS (
		SELECT
			address_type
		FROM
			bo.address_type
		WHERE
			address_type = 'SFDC_order.account_email'
	);
	
--does address_type need a source_system_id?  
--  20201020    assuming no.  This is a semantic field that means what we say it means in the name.  This creates some problems but I think we can add source_system_id and overwrite or NULL out the foreign keys, 
--              or rewrite them with new types easily later.
INSERT INTO
    bo.address_type (
        address_type,
        created_timestamp,
        created_process
    )
SELECT
    'SFMC From Email Address',
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
WHERE
    NOT EXISTS (
        SELECT
            address_type
        FROM
            bo.address_type
        WHERE
            address_type = 'SFMC From Email Address'
    );

INSERT INTO
    bo.address_type (
        address_type,
        created_timestamp,
        created_process
    )
SELECT
    'SFMC subscriberkey',
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
WHERE
    NOT EXISTS (
        SELECT
            address_type_id
        FROM
            bo.address_type
        WHERE
            address_type = 'SFMC subscriberkey'
    );	