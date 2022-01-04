

/*
 Top down, the campaign management structure looks like this:
 
 STIMULUS (any effort to make some extra money)
 ENVELOPE1 (any package of offer, effort and content that makes up the stimulus)
 ENVELOPE2 (could be a sub-package, or could be a parallel envelope.  up to you.)
 VALUE (The payload.  Where all the content really is.)
 
 ENGAGE_EVENT (the delivery of the value out there in the world, i.e. the SEND or the IMPRESSION.)
 
 RESPONSE_EVENT (Some of these are organic.  Someone just showed up out of the blue.  We want to know which ones were not organic.)
 
 The model lets you make mistakes and often salvage some of your data.  If you don't give yourself enough levels when you're mapping someone's 
 campaign management system into place, you can continue reporting with the old structure while mapping the restricted source into a new source_system_id.
 
 That means its best to restrict what you want to store at first.  Don't store every possible event  in this system.  Its designed to discover areas of 
 coordination and misalignments in campaign management language and process.  It very quickly highlights areas of coordination. 
 You can very quickly determine who owns a particular implentation.
 
 
 */
-- delete from bo.stimulus where source_system_id = 1;
 
INSERT INTO
    bo.stimulus (
        stimulus_owner_party_id,
        stimulus_owner_party_no,
        stimulus_owner,
        vendor_status,
        vendor_package_no,
        stimulus_trigger_no,
        stimulus_scheme_no,
        scheduled_timestamp,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    p.party_id
    ,p.party_string
    ,p.party_name
    ,job.jobstatus
    ,job.sendid
    ,REPLACE('0',IFNULL(job.triggeredsendexternalkey,'0'))
    ,REPLACE('0',IFNULL(job.senddefinitionexternalkey,'0'))
    ,MIN(job.schedtime)
    ,(SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    ,current_timestamp
    ,'sfmc_load_bo_engagement_20201113'
FROM
    raw.sfmc_sendjobs job
    INNER JOIN bo.party p ON IFNULL(job.CLIENTID, '0') = p.party_string    
WHERE   p.party_identifier = 'CLIENTID'
    AND p.party_identifier_type = 'SFMC account'
    AND NOT EXISTS ( SELECT DISTINCT vendor_package_no
                FROM bo.stimulus
                WHERE   vendor_package_no = job.sendid
                    AND source_system_id =     (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
        )
GROUP BY        p.party_id
    ,p.party_string
    ,p.party_name
    ,job.jobstatus
    ,job.sendid
    ,REPLACE('0',IFNULL(job.triggeredsendexternalkey,'0'))
    ,REPLACE('0',IFNULL(job.senddefinitionexternalkey,'0'))
    ,(SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
        ;




INSERT INTO
    bo.stimulus_envelope (
        stimulus_id,
        stimulus_owner_party_id,
        stimulus_owner_party_no,
        stimulus_owner,
        envelope_type_id,
        envelope_type,
        vendor_envelope_no --sendid
,
        vendor_envelope_type --email
,
        envelope_name,
        envelope_desc,
        envelope_trigger_no --triggeredsendexternalkey
,
        envelope_scheme_no --senddefinitionexternalkey
,
    --    scheduled_status,
        scheduled_timestamp,
        sent_timestamp,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    st.stimulus_id,
    st.stimulus_owner_party_id,
    st.stimulus_owner_party_no,
    st.stimulus_owner,
    (SELECT envelope_type_id FROM bo.envelope_type   WHERE envelope_type = 'email' ),
    (SELECT envelope_type FROM bo.envelope_type WHERE envelope_type = 'email' ),
    UPPER(st.vendor_package_no),
    'email',
    UPPER(job.emailname),
    NULL,
    REPLACE('0',IFNULL(UPPER(job.triggeredsendexternalkey),'0')),
    REPLACE('0',IFNULL(UPPER(job.senddefinitionexternalkey),'0')),
    -- UPPER(job.jobstatus), taking this out b/c if this changes (as it will, depending on snapshots from SFMC) the risk is we get dupes or bad statuses or something.
    MIN(job.schedtime),
    MIN(job.senttime),
    (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE'),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    raw.sfmc_sendjobs job
    INNER JOIN bo.stimulus st ON CAST(job.sendid as varchar) = st.vendor_package_no 
        AND st.stimulus_trigger_no  =   CAST(REPLACE('0',IFNULL(job.triggeredsendexternalkey,'0')) as varchar)
        AND st.stimulus_scheme_no    =   CAST(REPLACE('0',IFNULL(job.senddefinitionexternalkey,'0')) as varchar)
WHERE st.source_system_id = (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND NOT EXISTS (
        SELECT
            DISTINCT vendor_envelope_no,
            scheduled_timestamp,
            sent_timestamp
        FROM
            bo.stimulus_envelope
        WHERE
            vendor_envelope_no = CAST(job.sendid as varchar)
            AND envelope_trigger_no  =   CAST(REPLACE('0',IFNULL(job.triggeredsendexternalkey,'0')) as varchar)
            AND envelope_scheme_no    =   CAST(REPLACE('0',IFNULL(job.senddefinitionexternalkey,'0')) as varchar)
    ) 
GROUP BY    st.stimulus_id,
    st.stimulus_owner_party_id,
    st.stimulus_owner_party_no,
    st.stimulus_owner,
    (SELECT envelope_type_id FROM bo.envelope_type   WHERE envelope_type = 'email' ),
    (SELECT envelope_type FROM bo.envelope_type WHERE envelope_type = 'email' ),
    UPPER(st.vendor_package_no),
    UPPER(job.emailname),
    REPLACE('0',IFNULL(UPPER(job.triggeredsendexternalkey),'0')),
    REPLACE('0',IFNULL(UPPER(job.senddefinitionexternalkey),'0'))
    --job.jobstatus
        ;

UPDATE
    bo.stimulus_envelope se
SET
    envelope_category = UPPER(ec.email_category)
FROM
    bo.email_category ec
WHERE
    UPPER(se.envelope_name) = UPPER(ec.email_name);


-- subject line                    
INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT (
        SELECT
            content_type_id
        FROM
            bo.content_type
        WHERE
            vendor_field_name = 'SUBJECT'
            AND source_system_id = (
                SELECT
                    source_system_id
                FROM
                    bo.source_system
                WHERE
                    source_system_name = 'Salesforce Marketing Cloud'
                    AND source_system_status = 'ACTIVE'
            )
    ),
    IFNULL(UPPER(job.subject), '0'),
    'SUBJECT',
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.stimulus_envelope ste
    INNER JOIN raw.sfmc_sendjobs job ON ste.vendor_envelope_no = job.sendid
    --AND ste.sent_timestamp = job.senttime
WHERE ste.source_system_id = (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = IFNULL(UPPER(job.subject), '0')
            AND content_type_id = (
                SELECT
                    content_type_id
                FROM
                    bo.content_type
                WHERE
                    vendor_field_name = 'SUBJECT'
                    AND source_system_id = (
                        SELECT
                            source_system_id
                        FROM
                            bo.source_system
                        WHERE
                            source_system_name = 'Salesforce Marketing Cloud'
                            AND source_system_status = 'ACTIVE'
                    )
            )
            AND source_system_id = (
                SELECT
                    source_system_id
                FROM
                    bo.source_system
                WHERE
                    source_system_name = 'Salesforce Marketing Cloud'
                    AND source_system_status = 'ACTIVE'
            )
    );


INSERT INTO
    bo.content_envelope_xref (
        content_id,
        envelope_id,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT c.content_id,
    ste.envelope_id,
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.content c
    INNER JOIN raw.sfmc_sendjobs job ON UPPER(c.content_value) = IFNULL(UPPER(job.subject), '0')
    INNER JOIN bo.stimulus_envelope ste ON job.sendid = ste.vendor_envelope_no
    AND c.source_system_id   = ste.source_system_id
WHERE ste.source_system_id = (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND
    NOT EXISTS (
        SELECT
            content_id,
            envelope_id
        FROM
            bo.content_envelope_xref
        WHERE
            content_id = c.content_id
            AND envelope_id = ste.envelope_id
     order by envelope_id);

INSERT INTO
    bo.stimulus_value (
        envelope_id,
        stimulus_id,
        value_name -- emailname
,
        from_persona_address_id,
        vendor_envelope_no,
        value_trigger_no --triggeredsendexternalkey
,
        value_scheme_no --senddefinitionexternalkey
,
        scheduled_status,
        scheduled_timestamp,
        sent_timestamp,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT
    ste.envelope_id,
    ste.stimulus_id,
    UPPER(job.emailname),
    ad.address_id,
    UPPER(job.sendid),
     REPLACE('0',IFNULL(UPPER(job.triggeredsendexternalkey),'0')),
     REPLACE('0',IFNULL(UPPER(job.senddefinitionexternalkey),'0')),
    NULL,   --job.jobstatus,
    ste.scheduled_timestamp,
    ste.sent_timestamp,
    (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE'),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    raw.sfmc_sendjobs job
    INNER JOIN bo.stimulus_envelope ste ON job.sendid = ste.vendor_envelope_no
        AND UPPER(job.emailname) = UPPER(ste.envelope_name)        
        AND UPPER(ste.envelope_trigger_no)  =   REPLACE('0',IFNULL(UPPER(job.triggeredsendexternalkey),'0'))
        AND UPPER(ste.envelope_scheme_no)    =   REPLACE('0',IFNULL(UPPER(job.senddefinitionexternalkey),'0'))
INNER JOIN bo.address ad ON UPPER(ad.address_string) = IFNULL(UPPER(job.fromemail), '0') 
        AND ad.source_system_id =   ste.source_system_id 
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
WHERE ste.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND adt.address_type = 'SFMC From Email Address'
    AND NOT EXISTS (
        SELECT
            envelope_id,
            value_id,
            from_persona_address_id,
            sent_timestamp
        FROM
            bo.stimulus_value
        WHERE
            ste.envelope_id = envelope_id
            AND job.senttime = sent_timestamp
            AND ad.address_id = from_persona_address_id
            AND ste.envelope_id = envelope_id
            AND ste.source_system_id    =   source_system_id
    ) 
;



INSERT INTO
    bo.engagement_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        event_list_no,
        event_batch_no,
        event_type_id,
        event_type,
        event_trigger_no,
        event_timestamp,
        vendor_event_type,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT
    sv.value_id,
    ad.address_id,
    UPPER(ad.address_string),
    sent.subscriberid,
    sent.listid,
    sent.batchid,
    et.event_type_id,
    UPPER(et.event_type),
    REPLACE('0',IFNULL(UPPER(sent.triggeredsendexternalkey),'0')),
    sent.eventdate,
    UPPER(sent.eventtype),
    ( SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE'),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'

FROM
    bo.stimulus_value sv
    INNER JOIN raw.sfmc_sent sent 
        ON      sent.sendid = sv.vendor_envelope_no
            AND REPLACE('0',IFNULL(sent.triggeredsendexternalkey,'0'))  =   sv.value_trigger_no
    INNER JOIN bo.address ad 
        ON      UPPER(ad.address_string) = UPPER(sent.emailaddress) 
            AND IFNULL(ad.address_no,'0') = IFNULL(sent.subscriberid,'0')
            AND ad.source_system_id =   sv.source_system_id
    INNER JOIN bo.address_type adt 
        ON      ad.address_type_id = adt.address_type_id
    INNER JOIN bo.event_type et 
        ON      et.event_type = sent.eventtype
            AND et.source_system_id = ( SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
WHERE   sv.source_system_id =   ( SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND adt.address_type = 'SFMC subscriberkey'
    AND NOT EXISTS (
        SELECT
            stimulus_value_id,
            address_id,
            event_type_id,
            event_timestamp
        FROM
            bo.engagement_event
        WHERE
            address_id = ad.address_id
            AND stimulus_value_id = sv.value_id
            AND event_timestamp = sent.eventdate
            AND source_system_id = sv.source_system_id
    );




  
--Opens
INSERT INTO
    bo.response_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        vendor_list_no,
        vendor_batch_no,
        vendor_envelope_no,
        event_type_id,
        event_type,
        vendor_trigger_no,
        event_timestamp,
        vendor_event_type,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT sv.value_id,
    ad.address_id,
    UPPER(ad.address_string),
    opens.subscriberid,
    opens.listid,
    opens.batchid,
    sv.vendor_envelope_no,
    et.event_type_id,
    UPPER(et.event_type),
    opens.triggeredsendexternalkey,
    opens.eventdate,
    UPPER(opens.eventtype),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.stimulus_value sv
INNER JOIN raw.sfmc_opens opens ON opens.sendid = sv.vendor_envelope_no
            AND REPLACE('0',IFNULL(opens.triggeredsendexternalkey,'0'))  =   sv.value_trigger_no
    INNER JOIN bo.address ad 
        ON      UPPER(ad.address_string) = UPPER(opens.emailaddress) 
            AND ad.address_no   =   opens.subscriberid 
            AND sv.source_system_id =   ad.source_system_id
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
    INNER JOIN bo.event_type et ON et.event_type = opens.eventtype
    AND et.source_system_id = sv.source_system_id
WHERE   sv.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND adt.address_type = 'SFMC subscriberkey'
    AND NOT EXISTS (
        SELECT
            stimulus_value_id,
            address_id,
            event_type_id,
            event_timestamp
        FROM
            bo.response_event
        WHERE
            address_id = ad.address_id
            AND stimulus_value_id = sv.value_id
            AND event_timestamp = opens.eventdate
            AND source_system_id    =   sv.source_system_id
            AND vendor_envelope_no  =   sv.vendor_envelope_no
    );
    



--Clicks
INSERT INTO
    bo.response_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        vendor_list_no,
        vendor_batch_no,
        vendor_envelope_no,
        event_type_id,
        event_type,
        vendor_trigger_no,
        event_timestamp,
        vendor_event_type,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    sv.value_id,
    ad.address_id,
    UPPER(ad.address_string),
    click.subscriberid,
    click.listid,
    click.batchid,
    sv.vendor_envelope_no,
    et.event_type_id,
    UPPER(et.event_type),
    click.triggeredsendexternalkey,
    click.eventdate,
    UPPER(click.eventtype),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.stimulus_value sv
    INNER JOIN raw.sfmc_clicks click ON click.sendid = sv.vendor_envelope_no
            AND REPLACE('0',IFNULL(click.triggeredsendexternalkey,'0'))  =   sv.value_trigger_no
    INNER JOIN bo.address ad ON UPPER(ad.address_string) = UPPER(click.emailaddress)
        AND ad.address_no   =   click.subscriberid
        AND sv.source_system_id =   ad.source_system_id
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
    INNER JOIN bo.event_type et ON et.event_type = click.eventtype
    AND et.source_system_id = sv.source_system_id
WHERE sv.source_system_id = ( SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND adt.address_type = 'SFMC subscriberkey'
    AND NOT EXISTS (
        SELECT
            stimulus_value_id,
            address_id,
            event_type_id,
            event_timestamp
        FROM
            bo.response_event
        WHERE
            address_id = ad.address_id
            AND stimulus_value_id = sv.value_id
            AND event_timestamp = click.eventdate
            AND source_system_id = sv.source_system_id
            AND vendor_envelope_no  =   sv.vendor_envelope_no
    );

-- URL                    
INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        vendor_content_no,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT (
        SELECT
            content_type_id
        FROM
            bo.content_type
        WHERE
            vendor_field_name = 'URL'
            AND content_type = 'URL'
            AND source_system_id = (
                SELECT
                    source_system_id
                FROM
                    bo.source_system
                WHERE
                    source_system_name = 'Salesforce Marketing Cloud'
                    AND source_system_status = 'ACTIVE'
            )
    ),
    IFNULL(UPPER(click.URL), '0'),
    'URL',
    IFNULL(UPPER(click.sendurlid), '0'),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    raw.sfmc_clicks click
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = IFNULL(UPPER(click.URL), '0')
            AND UPPER(vendor_content_no) = IFNULL(UPPER(click.sendurlid), '0')
            AND content_type_id = (
                SELECT
                    content_type_id
                FROM
                    bo.content_type
                WHERE
                    vendor_field_name = 'URL'
                    AND content_type = 'URL'
                    AND source_system_id = (
                        SELECT
                            source_system_id
                        FROM
                            bo.source_system
                        WHERE
                            source_system_name = 'Salesforce Marketing Cloud'
                            AND source_system_status = 'ACTIVE'
                    )
            )
    );

INSERT INTO
    bo.content_response_xref (
        content_id,
        response_event_id,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT c.content_id,
    r.response_event_id,
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.content c
    INNER JOIN raw.sfmc_clicks click ON UPPER(c.content_value) = IFNULL(click.url, '0')
    AND IFNULL(click.sendurlid, '0') = CAST(c.vendor_content_no as varchar)
    INNER JOIN bo.response_event r ON CAST(click.subscriberid as varchar) = r.vendor_address_no
    AND r.vendor_batch_no = CAST(click.batchid  as varchar)
    AND click.eventdate = r.event_timestamp
    AND r.vendor_list_no = CAST(click.listid as varchar)
    AND r.vendor_envelope_no    =   CAST(click.sendid as varchar)
    AND c.source_system_id    =   r.source_system_id
WHERE
    r.source_system_id = (
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    )
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id
            AND source_system_id = r.source_system_id --AND click.eventdate =   r.event_timestamp
    );

-- utm_term                    
INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        vendor_content_no,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT (
        SELECT
            content_type_id
        FROM
            bo.content_type
        WHERE
            content_type = 'utm_term'
            AND vendor_field_name = 'URL'
            AND source_system_id = (
                SELECT
                    source_system_id
                FROM
                    bo.source_system
                WHERE
                    source_system_name = 'Salesforce Marketing Cloud'
                    AND source_system_status = 'ACTIVE'
            )
    ),
CASE
        WHEN UPPER(click.url) IS NOT NULL THEN SUBSTR(UPPER(click.url), CHARINDEX('UTM_TERM', UPPER(click.url), 1) + 9, 16)
        ELSE '0'
    END,
    'URL',
    IFNULL(UPPER(click.sendurlid), '0'),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    raw.sfmc_clicks click
WHERE
    CHARINDEX('UTM_TERM', UPPER(click.url), 1) > 0
    AND NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            content_value = SUBSTR(UPPER(click.url), CHARINDEX('UTM_TERM', UPPER(click.url), 1) + 9, 16)
            AND UPPER(vendor_content_no) = UPPER(click.sendurlid)
            AND content_type_id = (
                SELECT
                    content_type_id
                FROM
                    bo.content_type
                WHERE
                    content_type = 'utm_term'
                    AND vendor_field_name = 'URL'
                    AND source_system_id = (
                        SELECT
                            source_system_id
                        FROM
                            bo.source_system
                        WHERE
                            source_system_name = 'Salesforce Marketing Cloud'
                            AND source_system_status = 'ACTIVE'
                    )
            )
    );

INSERT INTO
    bo.content_response_xref (
        content_id,
        response_event_id,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT c.content_id,
    r.response_event_id,
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.content c
    INNER JOIN raw.sfmc_clicks click ON UPPER(c.content_value) = SUBSTR(UPPER(click.url), CHARINDEX('UTM_TERM', UPPER(click.url), 1) + 9, 16)
    AND IFNULL(UPPER(click.sendurlid), '0') = UPPER(c.vendor_content_no)
    AND CHARINDEX('UTM_TERM', UPPER(click.url), 1) > 0
    INNER JOIN bo.response_event r ON CAST(r.vendor_list_no as varchar) = CAST(click.listid as varchar)
    AND r.vendor_batch_no = CAST(click.batchid as varchar)
    AND CAST(click.subscriberid as varchar) = r.vendor_address_no
    AND click.eventdate = r.event_timestamp
    AND c.source_system_id =   r.source_system_id
    AND r.vendor_envelope_no    =   CAST(click.sendid as varchar)
WHERE     r.source_system_id = (
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    )
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id
            AND source_system_id = r.source_system_id --AND click.eventdate =   r.event_timestamp
    );

-- ALIAS                    
INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        vendor_content_no,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT (
        SELECT
            content_type_id
        FROM
            bo.content_type
        WHERE
            vendor_field_name = 'ALIAS'
            AND source_system_id = (
                SELECT
                    source_system_id
                FROM
                    bo.source_system
                WHERE
                    source_system_name = 'Salesforce Marketing Cloud'
                    AND source_system_status = 'ACTIVE'
            )
    ),
    IFNULL(UPPER(click.ALIAS), '0'),
    'ALIAS',
    IFNULL(click.urlid, '0'),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    raw.sfmc_clicks click
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = IFNULL(UPPER(click.ALIAS), '0')
            AND vendor_content_no = IFNULL(click.urlid, '0')
            AND content_type_id = (
                SELECT
                    content_type_id
                FROM
                    bo.content_type
                WHERE
                    vendor_field_name = 'ALIAS'
                    AND source_system_id = (
                        SELECT
                            source_system_id
                        FROM
                            bo.source_system
                        WHERE
                            source_system_name = 'Salesforce Marketing Cloud'
                            AND source_system_status = 'ACTIVE'
                    )
            )
    );

INSERT INTO
    bo.content_response_xref (
        content_id,
        response_event_id,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT c.content_id,
    r.response_event_id,
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.content c
    INNER JOIN raw.sfmc_clicks click ON UPPER(c.content_value) = IFNULL(UPPER(click.alias), '0')
    AND IFNULL(click.urlid, '0') = c.vendor_content_no
    INNER JOIN bo.response_event r ON r.vendor_list_no = CAST(click.listid as varchar)
    AND r.vendor_batch_no = CAST(click.batchid as varchar)
    AND CAST(click.subscriberid as varchar) = r.vendor_address_no
    AND click.eventdate = r.event_timestamp
    AND c.source_system_id  =   r.source_system_id
    AND CAST(click.sendid as varchar)    =   r.vendor_envelope_no
WHERE     r.source_system_id = (
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    )
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id
            AND source_system_id = r.source_system_id --AND click.eventdate =   r.event_timestamp
    );

--Unsubs
INSERT INTO
    bo.response_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        vendor_list_no,
        vendor_batch_no,
        vendor_envelope_no,
        event_type_id,
        event_type,
        vendor_trigger_no,
        event_timestamp,
        vendor_event_type,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    sv.value_id,
    ad.address_id,
    UPPER(ad.address_string),
    click.subscriberid,
    click.listid,
    click.batchid,
    sv.vendor_envelope_no,
    et.event_type_id,
    et.event_type,
    click.triggeredsendexternalkey,
    click.eventdate,
    click.eventtype,
	(SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE'),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.stimulus_value sv
    INNER JOIN raw.sfmc_unsubs click ON click.sendid = sv.vendor_envelope_no
            AND REPLACE('0',IFNULL(click.triggeredsendexternalkey,'0'))  =   sv.value_trigger_no
    INNER JOIN bo.address ad ON UPPER(ad.address_string) = UPPER(click.emailaddress)
        AND ad.address_no   =   click.subscriberid
        AND ad.source_system_id =   sv.source_system_id
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
    INNER JOIN bo.event_type et ON et.event_type = click.eventtype
    AND et.source_system_id = sv.source_system_id
WHERE sv.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND adt.address_type = 'SFMC subscriberkey'
    AND NOT EXISTS (
        SELECT
            stimulus_value_id,
            address_id,
            event_type_id,
            event_timestamp
        FROM
            bo.response_event
        WHERE
            address_id = ad.address_id
            AND stimulus_value_id = sv.value_id
            AND event_timestamp = click.eventdate
            AND source_system_id    =   sv.source_system_id
            AND vendor_envelope_no  =   sv.vendor_envelope_no
    );

--Bounces
INSERT INTO
    bo.response_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        vendor_list_no,
        vendor_batch_no,
        vendor_envelope_no,
        event_type_id,
        event_type,
        vendor_trigger_no,
        event_timestamp,
        vendor_event_type,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    sv.value_id,
    ad.address_id,
    UPPER(ad.address_string),
    bounce.subscriberid,
    bounce.listid,
    bounce.batchid,
    sv.vendor_envelope_no,
    et.event_type_id,
    UPPER(et.event_type),
    bounce.triggeredsendexternalkey,
    bounce.eventdate,
    UPPER(bounce.eventtype),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.stimulus_value sv
    INNER JOIN raw.sfmc_bounces bounce ON bounce.sendid = sv.vendor_envelope_no
        AND REPLACE('0',IFNULL(bounce.triggeredsendexternalkey,'0'))  =   sv.value_trigger_no
    INNER JOIN bo.address ad ON UPPER(ad.address_string) = UPPER(bounce.emailaddress)
        AND ad.address_no   =   bounce.subscriberid
        AND ad.source_system_id =   sv.source_system_id
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
    INNER JOIN bo.event_type et ON et.event_type = bounce.eventtype
    AND et.source_system_id = sv.source_system_id
WHERE sv.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND adt.address_type = 'SFMC subscriberkey'
    AND NOT EXISTS (
        SELECT
            stimulus_value_id,
            address_id,
            event_type_id,
            event_timestamp
        FROM
            bo.response_event
        WHERE
            address_id = ad.address_id
            AND stimulus_value_id = sv.value_id
            AND event_timestamp = bounce.eventdate
            AND source_system_id    =   sv.source_system_id
    );

-- BOUNCECATEGORY                    
INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT (
        SELECT
            content_type_id
        FROM
            bo.content_type
        WHERE
            vendor_field_name = 'BOUNCECATEGORY'
            AND source_system_id = (
                SELECT
                    source_system_id
                FROM
                    bo.source_system
                WHERE
                    source_system_name = 'Salesforce Marketing Cloud'
                    AND source_system_status = 'ACTIVE'
            )
    ),
    IFNULL(UPPER(bounce.BOUNCECATEGORY), '0'),
    'BOUNCECATEGORY',
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    raw.sfmc_bounces bounce
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = IFNULL(UPPER(bounce.BOUNCECATEGORY), '0')
            AND content_type_id = (
                SELECT
                    content_type_id
                FROM
                    bo.content_type
                WHERE
                    vendor_field_name = 'BOUNCECATEGORY'
                    AND source_system_id = (
                        SELECT
                            source_system_id
                        FROM
                            bo.source_system
                        WHERE
                            source_system_name = 'Salesforce Marketing Cloud'
                            AND source_system_status = 'ACTIVE'
                    )
            )
    );

INSERT INTO
    bo.content_response_xref (
        content_id,
        response_event_id,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT c.content_id,
    r.response_event_id,
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'Salesforce Marketing Cloud'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'sfmc_load_bo_engagement_20201113'
FROM
    bo.content c
    INNER JOIN raw.sfmc_bounces bounce ON UPPER(c.content_value) = IFNULL(UPPER(bounce.BOUNCECATEGORY), '0')
    INNER JOIN bo.response_event r ON r.vendor_list_no = CAST(bounce.listid as varchar)
    AND r.vendor_batch_no = CAST(bounce.batchid as varchar)
    AND CAST(bounce.subscriberid as varchar) = r.vendor_address_no
    AND bounce.eventdate = r.event_timestamp
    AND r.source_system_id  =   c.source_system_id
    AND r.vendor_envelope_no    =   CAST(bounce.sendid as varchar)
WHERE   r.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Salesforce Marketing Cloud' AND source_system_status = 'ACTIVE')
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id
            AND source_system_id = r.source_system_id --AND click.eventdate =   r.event_timestamp
    );
