

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
    DISTINCT IFNULL(cust.EXTERNALCUSTOMERID, '0'),
    'EXTERNALCUSTOMERID',
    'Adwords account',
    'Design Within Reach',
    'Adwords_load_bo_engagement_2021230'
FROM
    raw.adwords_customer    cust
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT party_string
        FROM
            bo.party
        WHERE
            party_string = CAST(IFNULL(cust.EXTERNALCUSTOMERID, '0') as varchar)
            AND party_identifier_type = 'Adwords account'
        
    );
