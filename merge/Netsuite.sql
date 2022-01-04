SET source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Netsuite prototype' AND source_system_status = 'ACTIVE');        

-------------------------------------------
--- Adding customer to party --------------
-------------------------------------------
MERGE INTO bo.party as so USING (
    SELECT
        IFNULL(c.full_name,'0') AS party_string,
        TO_VARCHAR(c.customer_id) AS party_identifier,
        'NETSUITE_CUSTOMER_ID' AS party_identifier_type,
        IFNULL(c.full_name, '0') AS party_name,
        IFNULL(c.firstname, '0') AS party_first_name,
        IFNULL(c.lastname, '0') AS party_last_name,
        IFNULL(c.companyname, '0') AS party_company_name,
        $source_system_id AS source_system_id,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as created_timestamp,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as updated_timestamp,
        'netsuite_load' AS created_process,
        'netsuite_load' AS updated_process,
        NULL as party_channel_identifier,
        NULL as party_channel_name
    FROM RAW.NETSUITE_5TRAN_CUSTOMERS c ) as p
ON  so.source_system_id = p.source_system_id
AND  so.party_identifier = p.party_identifier

WHEN MATCHED THEN UPDATE 
SET 
 so.party_string = p.party_string,
-- so.party_identifier,
 so.party_identifier_type = p.party_identifier_type,
 so.party_name = p.party_name,
 so.party_first_name = p.party_first_name,
 so.party_last_name = p.party_last_name,
 so.party_company_name = p.party_company_name,
-- so.source_system_id = p.source_system_id,
 so.updated_timestamp = p.updated_timestamp,
 so.updated_process = p.updated_process,
 so.party_channel_identifier = p.party_channel_identifier,
 so.party_channel_name = p.party_channel_name
WHEN NOT MATCHED THEN INSERT 
(
    party_string,
    party_identifier,
    party_identifier_type,
    party_name,
    party_first_name,
    party_last_name,
    party_company_name,
    source_system_id,
    created_timestamp,
    updated_timestamp,
    created_process,
    updated_process,
    party_channel_identifier,
    party_channel_name
    )
VALUES 
(
    p.party_string,
    p.party_identifier,
    p.party_identifier_type,
    p.party_name,
    p.party_first_name,
    p.party_last_name,
    p.party_company_name,
    p.source_system_id,
    p.created_timestamp,
    p.updated_timestamp,
    p.created_process,
    p.updated_process,
    p.party_channel_identifier,
    p.party_channel_name);

-------------------------------------------
--- Add Location Data to Party ------------
-------------------------------------------
MERGE INTO bo.party as so USING (
    SELECT
        IFNULL(l.full_name,'0') AS party_string,
        TO_VARCHAR(l.location_id) AS party_identifier,
        CASE WHEN c.channel_id is NULL THEN 'NETSUITE_CHANNEL_ID' ELSE 'NETSUITE_LOCATION_ID' END AS party_identifier_type,
        IFNULL(l.full_name, '0') AS party_name,
        IFNULL(le.list_item_name, '0') AS party_company_name,
        $source_system_id AS source_system_id,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as created_timestamp,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as updated_timestamp,
        'netsuite_load' AS created_process,
        'netsuite_load' AS updated_process,
        TO_VARCHAR(channel_id) as party_channel_identifier,
        channel_name as party_channel_name
    FROM RAW.NETSUITE_5TRAN_LOCATIONS l
    LEFT JOIN RAW.NETSUITE_5TRAN_LOCATION_ENTITY le ON l.location_entity_id = le.list_id
    LEFT JOIN
    (select location_id as channel_id, name as channel_name, address as channel_address 
    from RAW.NETSUITE_5TRAN_LOCATIONS
    where parent_id is null) c
    on l.parent_id = c.channel_id
) as p
ON  so.source_system_id = p.source_system_id
AND  so.party_identifier = p.party_identifier
WHEN MATCHED THEN UPDATE 
SET 
 so.party_string = p.party_string,
-- so.party_identifier,
 so.party_identifier_type = p.party_identifier_type,
 so.party_name = p.party_name,
 so.party_company_name = p.party_company_name,
-- so.source_system_id = p.source_system_id,
 so.updated_timestamp = p.updated_timestamp,
 so.updated_process = p.updated_process,
 so.party_channel_identifier = p.party_channel_identifier,
 so.party_channel_name = p.party_channel_name
WHEN NOT MATCHED THEN INSERT 
(
    party_string,
    party_identifier,
    party_identifier_type,
    party_name,
    party_company_name,
    source_system_id,
    created_timestamp,
    updated_timestamp,
    created_process,
    updated_process,
    party_channel_identifier,
    party_channel_name
    )
VALUES 
(
    p.party_string,
    p.party_identifier,
    p.party_identifier_type,
    p.party_name,
    p.party_company_name,
    p.source_system_id,
    p.created_timestamp,
    p.updated_timestamp,
    p.created_process,
    p.updated_process,
    p.party_channel_identifier,
    p.party_channel_name);


-------------------------------------------
---------  Street address -----------------
-------------------------------------------
 


        
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
        
SET address_type_id =           (SELECT address_type_id FROM bo.address_type WHERE address_type = 'NETSUITE_LOCATIONS.STREET_ADDRESS');
           

MERGE INTO bo.address as address USING (
SELECT DISTINCT
        $address_type_id AS address_type_id,
        l.location_id as address_no,
        IFNULL(l.address,'0') AS address_string, -- theoretically we should clean this field so its as close to a pristine natural key as we can get, using some prebuilt functions to remove spaces, special chars, etc.
        l.address_one AS address1,
        l.address_two AS address2,
        l.address_three AS address3,
        l.city as city,
        l.country as country,
        l.state as state_province,
        l.zipcode as postal_code,
        $source_system_id AS source_system_id,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as created_timestamp,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as updated_timestamp,
        'DG_20210316_NETSUITE_LOCATIONS' AS created_process,
        'DG_20210316_NETSUITE_LOCATIONS' AS updated_process
    FROM RAW.NETSUITE_5TRAN_LOCATIONS l
                                  ) as add_stg
ON  add_stg.source_system_id = address.source_system_id
AND add_stg.address_string = address.address_string
WHEN NOT MATCHED THEN INSERT 
(
        address_type_id,
        address_no,
        address_string,
        address1,
        address2,
        address3,
        city,
        country,
        state_province,
        postal_code,
        source_system_id,
        created_timestamp,
        updated_timestamp,
        created_process,
        updated_process
    )
VALUES 
(
        add_stg.address_type_id,
        add_stg.address_no,
        add_stg.address_string,
        add_stg.address1,
        add_stg.address2,
        add_stg.address3,
        add_stg.city,
        add_stg.country,
        add_stg.state_province,
        add_stg.postal_code,
        add_stg.source_system_id,
        add_stg.created_timestamp,
        add_stg.updated_timestamp,
        add_stg.created_process,
        add_stg.updated_process
);            


MERGE INTO bo.address_party_xref as apx USING (
SELECT DISTINCT
        a.address_id ,
        p.party_id,
        'ACTIVE' as XREF_STATUS ,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as created_timestamp,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as updated_timestamp,
        'DG_20210316_NETSUITE_LOCATIONS' AS created_process,
        'DG_20210316_NETSUITE_LOCATIONS' AS updated_process
    FROM 
        RAW.NETSUITE_5TRAN_LOCATIONS l
    INNER JOIN
        BO.ADDRESS  a
        ON  a.address_string  =   l.address
    INNER JOIN
        BO.PARTY    p
        ON l.full_name  =   p.party_string      
    WHERE
        a.source_system_id    =   $source_system_id
        AND p.source_system_id  =   a.source_system_id                                                                                                                                       
                                  ) as add_xref_stg
ON  add_xref_stg.party_id = apx.party_id
AND add_xref_stg.address_id =   apx.address_id
WHEN NOT MATCHED THEN INSERT 
(
        address_id ,
        party_id,
        XREF_STATUS ,
        created_timestamp,
        updated_timestamp,
        created_process,
        updated_process
    )
VALUES 
(
        add_xref_stg.address_id ,
        add_xref_stg.party_id,
        add_xref_stg.XREF_STATUS ,
        add_xref_stg.created_timestamp,
        add_xref_stg.updated_timestamp,
        add_xref_stg.created_process,
        add_xref_stg.updated_process
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

SET address_type_id = (SELECT address_type_id FROM bo.address_type WHERE address_type    =   'NETSUITE_LOCATIONS.PHONE');

MERGE INTO bo.address as address USING (
SELECT DISTINCT
        $address_type_id as address_type_id,
        l.location_id as address_no,
        IFNULL(l.phone,'0') AS address_string,  -- theoretically we should clean this field so its as close to a pristine natural key as we can get, using some prebuilt functions to remove spaces, special chars, etc.
        l.phone AS phone_number,
        'UNKNOWN' as phone_number_type,
        $source_system_id AS source_system_id,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as created_timestamp,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as updated_timestamp,
        'DG_20210316_NETSUITE_LOCATIONS' AS created_process,
        'DG_20210316_NETSUITE_LOCATIONS' AS updated_process
    FROM RAW.NETSUITE_5TRAN_LOCATIONS l
                                  ) as add_stg
ON  add_stg.source_system_id = address.source_system_id
AND add_stg.address_string = address.address_string
WHEN NOT MATCHED THEN INSERT 
(
        address_type_id,
        address_no,
        address_string,
        phone_number,
        phone_number_type,
        source_system_id,
        created_timestamp,
        updated_timestamp,
        created_process,
        updated_process
    )
VALUES 
(
        add_stg.address_type_id,
        add_stg.address_no,
        add_stg.address_string,
        add_stg.phone_number,
        add_stg.phone_number_type,
        add_stg.source_system_id,
        add_stg.created_timestamp,
        add_stg.updated_timestamp,
        add_stg.created_process,
        add_stg.updated_process
);            


MERGE INTO bo.address_party_xref as apx USING (
SELECT DISTINCT
        a.address_id ,
        p.party_id,
        'ACTIVE' as XREF_STATUS ,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as created_timestamp,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as updated_timestamp,
        'DG_20210316_NETSUITE_LOCATIONS' AS created_process,
        'DG_20210316_NETSUITE_LOCATIONS' AS updated_process
    FROM 
        RAW.NETSUITE_5TRAN_LOCATIONS l
    INNER JOIN
        BO.ADDRESS  a
        ON  a.address_string  =   l.phone
    INNER JOIN
        BO.PARTY    p
        ON l.full_name  =   p.party_string      
    WHERE
        a.source_system_id    =   $source_system_id
        AND p.source_system_id  =   a.source_system_id                                                                                                                                       
                                  ) as add_xref_stg
ON  add_xref_stg.party_id = apx.party_id
AND add_xref_stg.address_id =   apx.address_id
WHEN NOT MATCHED THEN INSERT 
(
        address_id ,
        party_id,
        XREF_STATUS ,
        created_timestamp,
        updated_timestamp,
        created_process,
        updated_process
    )
VALUES 
(
        add_xref_stg.address_id ,
        add_xref_stg.party_id,
        add_xref_stg.XREF_STATUS ,
        add_xref_stg.created_timestamp,
        add_xref_stg.updated_timestamp,
        add_xref_stg.created_process,
        add_xref_stg.updated_process
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

        
SET address_type_id = (SELECT address_type_id FROM bo.address_type WHERE address_type    =   'NETSUITE_LOCATIONS.EMAIL_ADDRESS');

MERGE INTO bo.address as address USING (
SELECT DISTINCT
        $ADDRESS_TYPE_ID  AS address_type_id,
        IFNULL(l.EMAIL_ADDRESS,'0') AS address_string,  -- theoretically we should clean this field so its as close to a pristine natural key as we can get, using some prebuilt functions to remove spaces, special chars, etc.
        l.location_id as address_no,
        l.EMAIL_ADDRESS AS EMAIL_ADDRESS,
        $source_system_id AS source_system_id,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as created_timestamp,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as updated_timestamp,
        'DG_20210316_NETSUITE_LOCATIONS' AS created_process,
        'DG_20210316_NETSUITE_LOCATIONS' AS updated_process
    FROM RAW.NETSUITE_5TRAN_LOCATIONS  l
                                  ) as add_stg
ON  add_stg.source_system_id = address.source_system_id
AND add_stg.address_string = address.address_string
WHEN NOT MATCHED THEN INSERT 
(
        address_type_id,
        address_no,
        address_string,
        email_address,
        source_system_id,
        created_timestamp,
        updated_timestamp,
        created_process,
        updated_process
    )
VALUES 
(
        add_stg.address_type_id,
        add_stg.address_no,
        add_stg.address_string,
        add_stg.email_address,
        add_stg.source_system_id,
        add_stg.created_timestamp,
        add_stg.updated_timestamp,
        add_stg.created_process,
        add_stg.updated_process
);            


MERGE INTO bo.address_party_xref as apx USING (
SELECT DISTINCT
        a.address_id ,
        p.party_id,
        'ACTIVE' as XREF_STATUS ,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as created_timestamp,
        TO_TIMESTAMP_NTZ(convert_timezone('America/Detroit', current_timestamp)) as updated_timestamp,
        'DG_20210316_NETSUITE_LOCATIONS' AS created_process,
        'DG_20210316_NETSUITE_LOCATIONS' AS updated_process
    FROM 
        RAW.NETSUITE_5TRAN_LOCATIONS l
    INNER JOIN
        BO.ADDRESS  a
        ON  a.address_string  =   l.email_address
    INNER JOIN
        BO.PARTY    p
        ON l.full_name  =   p.party_string      
    WHERE
        a.source_system_id    =   $source_system_id
        AND p.source_system_id  =   a.source_system_id                                                                                                                                       
                                  ) as add_xref_stg
ON  add_xref_stg.party_id = apx.party_id
AND add_xref_stg.address_id =   apx.address_id
WHEN NOT MATCHED THEN INSERT 
(
        address_id ,
        party_id,
        XREF_STATUS ,
        created_timestamp,
        updated_timestamp,
        created_process,
        updated_process
    )
VALUES 
(
        add_xref_stg.address_id ,
        add_xref_stg.party_id,
        add_xref_stg.XREF_STATUS ,
        add_xref_stg.created_timestamp,
        add_xref_stg.updated_timestamp,
        add_xref_stg.created_process,
        add_xref_stg.updated_process
);            