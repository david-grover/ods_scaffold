
INSERT INTO
    bo.address (
        source_system_id,
        address_type_id,
        address_string,
        created_process
    )
SELECT
    DISTINCT (
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
(
        SELECT
            address_type_id
        FROM
            bo.address_type
        WHERE
            address_type = 'BlueCore email address'
    ),
    IFNULL(UPPER(email), '0'),
    'bluecore_load_bo_engagement_20201118'
FROM
    raw.bluecore_deliveries job
WHERE
    job.email IS NOT NULL
    AND NOT EXISTS (
        SELECT
            address_string
        FROM
            bo.address
            INNER JOIN bo.address_type ON bo.address.address_type_id = bo.address_type.address_type_id
            AND bo.address_type.address_type = 'BlueCore email address'
        WHERE
            UPPER(address_string) = IFNULL(UPPER(job.email), '0')
            AND bo.address.SOURCE_SYSTEM_ID = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
    );
    

INSERT INTO
    bo.address (
        source_system_id,
        address_type_id,
        address_string,
        created_process
    )
SELECT
    DISTINCT (
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
(
        SELECT
            address_type_id
        FROM
            bo.address_type
        WHERE
            address_type = 'BlueCore email address'
    ),
    IFNULL(UPPER(job.email), '0'),
    'bluecore_load_bo_engagement_20201118'
FROM
    raw.bluecore_events job
WHERE
    job.email IS NOT NULL
    AND NOT EXISTS (
        SELECT
            address_string
        FROM
            bo.address
            INNER JOIN bo.address_type ON bo.address.address_type_id = bo.address_type.address_type_id
            AND bo.address_type.address_type = 'BlueCore email address'
        WHERE
            UPPER(address_string) = IFNULL(UPPER(job.email), '0')
            AND bo.address.SOURCE_SYSTEM_ID = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
    );

--seeded party with some brand names.  we can drop these later if we want or de-activate or reinsert with new names, whatever.

INSERT INTO
    bo.party (
        party_string,
        party_identifier,
        party_identifier_type,
        party_name,
        source_system_id,
      created_process
    )
SELECT
    DISTINCT IFNULL(UPPER(job.namespace), '0'),
    'namespace',
    'Bluecore namespace',
    UPPER(job.namespace),
    (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE'),
    'bluecore_load_bo_engagement_20201118'
FROM
    raw.bluecore_deliveries job
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT party_string
        FROM
            bo.party
        WHERE
            UPPER(party_string) = IFNULL(UPPER(job.namespace), '0')
            AND party_identifier_type = 'Bluecore namespace'
            AND source_system_id =     (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
    );