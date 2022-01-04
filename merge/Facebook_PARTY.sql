--seeded party with some brand names.  we can drop these later if we want or de-activate or reinsert with new names, whatever.
INSERT INTO
    bo.party (
        party_string,
        party_identifier,
        party_identifier_type,
        party_name,
        created_process
    )
SELECT DISTINCT 
    IFNULL(act.account_name, '0'),
    act.account_id,
    'Facebook account_id',
     IFNULL(act.account_name, '0'),
    'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_actions    act
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT party_identifier
        FROM
            bo.party
        WHERE
            party_identifier = act.account_id
            AND party_identifier_type = 'Facebook account_id'
        
    );
    