

INSERT INTO
    bo.address (
        source_system_id,
        address_type_id,
        address_string,
        address_no,
        created_process
    )
SELECT
    DISTINCT (
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
(
        SELECT
            address_type_id
        FROM
            bo.address_type
        WHERE
            address_type = 'SFMC subscriberkey'
    ),
    IFNULL(UPPER(sent.subscriberkey), '0'),
    IFNULL(UPPER(sent.subscriberid),'0'),
    'sfmc_load_bo_engagement_20201113'
FROM
    raw.sfmc_sent sent
WHERE
    NOT EXISTS (
        SELECT
            address_string
        FROM
            bo.address
            INNER JOIN bo.address_type ON bo.address.address_type_id = bo.address_type.address_type_id
            AND bo.address_type.address_type = 'SFMC subscriberkey'
        WHERE
            UPPER(address_string) = IFNULL(UPPER(sent.subscriberkey), '0')
            AND address_no  =   IFNULL(sent.subscriberid,'0')
            AND bo.address.source_system_id = (
                SELECT
                    source_system_id
                FROM
                    bo.source_system
                WHERE
                    source_system_name = 'Salesforce Marketing Cloud'
                    AND source_system_status = 'ACTIVE'
            )
    );

--seeded party with some brand names.  we can drop these later if we want or de-activate or reinsert with new names, whatever.
INSERT INTO
    bo.party (
        party_string,
        party_identifier,
        party_identifier_type,
        party_name,
        created_process
    )
SELECT
    DISTINCT IFNULL(job.CLIENTID, '0'),
    'CLIENTID',
    'SFMC account',
CASE
        WHEN job.clientid = '10973668' THEN 'Herman Miller'
        WHEN job.clientid = '10979192' THEN 'DWR'
        WHEN job.clientid = '10982492' THEN 'Hay'
    END,
    'sfmc_load_bo_engagement_20201113'
FROM
    raw.sfmc_sendjobs job
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT party_string
        FROM
            bo.party
        WHERE
            party_string = CAST(IFNULL(job.CLIENTID, '0') as varchar)
            AND party_identifier_type = 'SFMC account'
        
    );