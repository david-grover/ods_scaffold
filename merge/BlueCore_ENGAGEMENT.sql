
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


INSERT INTO
    bo.stimulus (
        stimulus_owner_party_id,
        stimulus_owner,
        vendor_package_no -- campaign_id
,
        stimulus_scheme_no -- audience_id, which we'll repeat in the envelope
,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT p.party_id,
    UPPER(p.party_name),
    IFNULL(UPPER(job.campaign_id), '0'),
    IFNULL(UPPER(job.audience_id), '0'),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    raw.bluecore_deliveries job
    INNER JOIN bo.party p ON IFNULL(UPPER(job.namespace), '0') = p.party_string
    AND UPPER(p.party_identifier) = 'NAMESPACE'
    AND p.party_identifier_type = 'Bluecore namespace'
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT vendor_package_no
        FROM
            bo.stimulus
        WHERE
            UPPER(vendor_package_no) = IFNULL(UPPER(job.campaign_id), '0')
            AND UPPER(stimulus_scheme_no) = IFNULL(UPPER(job.audience_id), '0')
            AND source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
    );

INSERT INTO
    bo.stimulus_envelope (
        stimulus_id,
        stimulus_owner_party_id,
        stimulus_owner_party_no,
        stimulus_owner,
        envelope_type_id,
        envelope_type,
        vendor_envelope_no --campaign_id
,
        vendor_envelope_type --email
,
        envelope_name,
        envelope_scheme_no --senddefinitionexternalkey
,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    DISTINCT st.stimulus_id,
    st.stimulus_owner_party_id,
    st.stimulus_owner_party_no,
    st.stimulus_owner,
(
        SELECT
            envelope_type_id
        FROM
            bo.envelope_type
        WHERE
            envelope_type = 'email'
    ),
(
        SELECT
            envelope_type
        FROM
            bo.envelope_type
        WHERE
            envelope_type = 'email'
    ),
    IFNULL(UPPER(st.vendor_package_no), '0'),
    'email',
    UPPER(job.campaign_name),
    IFNULL(job.audience_id, '0'),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    raw.bluecore_deliveries job
    INNER JOIN bo.stimulus st ON IFNULL(job.campaign_id, 0) = UPPER(st.vendor_package_no)
    AND IFNULL(job.audience_id, '0') = IFNULL(st.stimulus_scheme_no,'0')
WHERE
  st.source_system_id =   (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
  AND  NOT EXISTS (
        SELECT
            DISTINCT vendor_envelope_no,
            envelope_scheme_no
        FROM
            bo.stimulus_envelope
        WHERE
            UPPER(vendor_envelope_no) = IFNULL(job.campaign_id, 0)
            AND UPPER(envelope_scheme_no) = IFNULL(UPPER(job.audience_id), '0')
            AND source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
    );

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
            vendor_field_name = 'SUBJECT_LINE'
            AND source_system_id = (
                SELECT
                    source_system_id
                FROM
                    bo.source_system
                WHERE
                    source_system_name = 'BlueCore'
                    AND source_system_status = 'ACTIVE'
            )
    ),
    IFNULL(UPPER(job.SUBJECT_LINE), '0'),
    'SUBJECT_LINE',
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    bo.stimulus_envelope ste
    INNER JOIN raw.bluecore_deliveries job ON IFNULL(UPPER(ste.vendor_envelope_no),'0') = IFNULL(job.campaign_id, 0)
    AND IFNULL(UPPER(ste.envelope_scheme_no),'0') = IFNULL(UPPER(job.audience_id), '0')
WHERE
  ste.source_system_id =   (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
  AND  NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = IFNULL(UPPER(job.SUBJECT_LINE), '0')
            AND content_type_id = (
                SELECT
                    content_type_id
                FROM
                    bo.content_type
                WHERE
                    vendor_field_name = 'SUBJECT_LINE'
                    AND source_system_id = (
                        SELECT
                            source_system_id
                        FROM
                            bo.source_system
                        WHERE
                            source_system_name = 'BlueCore'
                            AND source_system_status = 'ACTIVE'
                    )
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
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    bo.content c
    INNER JOIN raw.bluecore_deliveries job ON UPPER(c.content_value) = IFNULL(UPPER(job.subject_line), '0')
    INNER JOIN bo.stimulus_envelope ste ON UPPER(ste.vendor_envelope_no) = IFNULL(job.campaign_id, 0)
    AND UPPER(ste.envelope_scheme_no) = IFNULL(UPPER(job.audience_id), '0')
WHERE ste.source_system_id =   (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
 AND NOT EXISTS (
        SELECT
            content_id,
            envelope_id
        FROM
            bo.content_envelope_xref
        WHERE
            content_id = c.content_id
            AND envelope_id = ste.envelope_id
            AND source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
    );

INSERT INTO
    bo.stimulus_value (
        envelope_id,
        stimulus_id,
        value_name -- emailname
,
        vendor_envelope_no,
        value_scheme_no --senddefinitionexternalkey
,
        sent_timestamp,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT
    ste.envelope_id,
    ste.stimulus_id,
    UPPER(job.campaign_name),
    IFNULL(job.campaign_id,'0'),
    IFNULL(UPPER(job.audience_id),'0'),
    MIN(job.event_time),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    raw.bluecore_deliveries job
    INNER JOIN bo.stimulus_envelope ste ON IFNULL(job.campaign_id,'0') = IFNULL(UPPER(ste.vendor_envelope_no),'0')
    AND IFNULL(UPPER(job.audience_id),'0') = IFNULL(UPPER(ste.envelope_scheme_no),'0')
WHERE ste.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
    AND NOT EXISTS (
        SELECT
            envelope_id,
            value_id
        FROM
            bo.stimulus_value
        WHERE
            ste.envelope_id = envelope_id
            AND IFNULL(UPPER(ste.envelope_scheme_no),'0') = IFNULL(UPPER(value_scheme_no),'0')
            AND ste.source_system_id = source_system_id
    )
GROUP BY
    ste.envelope_id,
    ste.stimulus_id,
    job.campaign_name,
    job.campaign_id,
    job.audience_id;

INSERT INTO
    bo.engagement_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        event_type_id,
        event_type,
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
    UPPER(sent.nqe),
    et.event_type_id,
    UPPER(et.event_type),
    sent.event_time,
    UPPER(sent.event),
    (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE'),
    current_timestamp,
    'bluecore_load_bo_engagement_20201213'
FROM bo.stimulus_value sv
INNER JOIN   raw.bluecore_deliveries sent ON IFNULL(sent.campaign_id, 0) = IFNULL(UPPER(sv.vendor_envelope_no),'0')
        AND IFNULL(UPPER(sent.audience_id), '0') = IFNULL(UPPER(sv.value_scheme_no),'0')
    INNER JOIN bo.address ad ON UPPER(ad.address_string) = UPPER(sent.email)
      AND ad.source_system_id =  sv.source_system_id
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
        AND adt.address_type = 'BlueCore email address'
    INNER JOIN bo.event_type et ON UPPER(et.event_type) = UPPER(sent.event)
WHERE et.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
       AND  sv.source_system_id =  (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE') 
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
            AND event_timestamp = sent.event_time
           AND source_system_id = sv.source_system_id
    );



--33915558
--33915558

--Opens
INSERT INTO
    bo.response_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        event_type_id,
        event_type,
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
    UPPER(opens.nqe),
    et.event_type_id,
    UPPER(et.event_type),
    opens.event_time,
    UPPER(opens.event),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    bo.stimulus_value sv
    INNER JOIN raw.bluecore_opens opens ON IFNULL(opens.campaign_id, 0) = UPPER(sv.vendor_envelope_no)
        AND IFNULL(UPPER(opens.audience_id), '0') = UPPER(sv.value_scheme_no)
    INNER JOIN bo.address ad ON UPPER(ad.address_string) = UPPER(opens.email)
        AND ad.source_system_id = sv.source_system_id
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
     AND adt.address_type = 'BlueCore email address'
    INNER JOIN bo.event_type et ON UPPER(et.event_type) = UPPER(opens.event)
    AND et.source_system_id = sv.source_system_id
WHERE sv.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
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
            AND event_timestamp = opens.event_time
            AND source_system_id = ad.source_system_id
    );

--Clicks
INSERT INTO
    bo.response_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        event_type_id,
        event_type,
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
    UPPER(click.nqe),
    et.event_type_id,
    UPPER(et.event_type),
    click.event_time,
    UPPER(click.event),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    bo.stimulus_value sv
    INNER JOIN raw.bluecore_clicks click ON IFNULL(click.CAMPAIGN_ID, 0) = sv.vendor_envelope_no
        AND IFNULL(UPPER(click.audience_id), '0') = UPPER(sv.value_scheme_no)
    INNER JOIN bo.address ad ON UPPER(ad.address_string) = UPPER(click.email)
        AND ad.source_system_id = sv.source_system_id
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
    AND adt.address_type = 'BlueCore email address'
    INNER JOIN bo.event_type et ON UPPER(et.event_type) = UPPER(click.event)
    AND et.source_system_id = sv.source_system_id
WHERE sv.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
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
            AND event_timestamp = click.event_time
            AND source_system_id = sv.source_system_id
    );


-- URL                    
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
            vendor_field_name = 'URL'
            AND content_type = 'URL'
            AND source_system_id = (
                SELECT
                    source_system_id
                FROM
                    bo.source_system
                WHERE
                    source_system_name = 'BlueCore'
                    AND source_system_status = 'ACTIVE'
            )
    ),
    IFNULL(UPPER(click.url), '0'),
    'URL',
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    raw.bluecore_clicks click
WHERE
    click.url IS NOT NULL
    AND NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            UPPER(content_value)
        FROM
            bo.content
        WHERE
            UPPER(content_value) = IFNULL(UPPER(click.URL), '0')
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
                            source_system_name = 'BlueCore'
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
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    bo.content c
    INNER JOIN raw.bluecore_clicks click ON UPPER(c.content_value) = IFNULL(UPPER(click.url), '0') 
    INNER JOIN bo.response_event r ON IFNULL(UPPER(click.nqe), '0') = UPPER(r.vendor_address_no)
     AND click.event_time = r.event_timestamp
     AND  r.source_system_id = c.source_system_id
    INNER JOIN bo.event_type et ON r.event_type_id = et.event_type_id
     AND  r.source_system_id = et.source_system_id
WHERE UPPER(et.event_type) = 'CLICK'
     AND c.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
 AND  NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.event_time =   r.event_timestamp
            AND source_system_id    =   r.source_system_id--AND click.event_time =   r.event_timestamp
    );

-- utm_campaign
/*
 
 INSERT INTO content_type(content_type,vendor_field_name,created_process,source_system_id) VALUES('utm_campaign','URL','bluecore_load_bo_engagement_20201118',13);
 
 
 */
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
    DISTINCT (SELECT content_type_id FROM bo.content_type WHERE content_type = 'utm_campaign' AND vendor_field_name = 'URL' AND source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE'))
    ,CASE
        WHEN click.url IS NOT NULL THEN SUBSTR(UPPER(click.url),charindex('UTM_CAMPAIGN', UPPER(click.url), 1) + 13,(charindex('&OBEM',UPPER(click.url),charindex('UTM_CAMPAIGN', UPPER(click.url), 1) + 13) - (charindex('UTM_CAMPAIGN', UPPER(click.url), 1) + 13)))
        ELSE '0'
    END
    ,'URL'
    ,(SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
    ,current_timestamp
    ,'bluecore_load_bo_engagement_20201118'
FROM
    raw.bluecore_clicks click
WHERE
    CHARINDEX('UTM_CAMPAIGN', UPPER(click.url), 1) > 0
    AND NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            content_type_id = (
                SELECT
                    content_type_id
                FROM
                    bo.content_type
                WHERE
                    UPPER(content_type) = 'UTM_CAMPAIGN'
                    AND vendor_field_name = 'URL'
                    AND source_system_id = (
                        SELECT
                            source_system_id
                        FROM
                            bo.source_system
                        WHERE
                            source_system_name = 'BlueCore'
                            AND source_system_status = 'ACTIVE'
                    )
            )
            AND content_value = SUBSTR(
                UPPER(click.url),
                charindex('UTM_CAMPAIGN', UPPER(click.url), 1) + 13,
(
                    charindex(
                        '&OBEM',
                        UPPER(click.url),
                        charindex('UTM_CAMPAIGN', UPPER(click.url), 1) + 13
                    ) - (charindex('UTM_CAMPAIGN', UPPER(click.url), 1) + 13)
                )
            ) --AND vendor_content_no   =   click.sendurlid 
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
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    bo.content c
    INNER JOIN raw.bluecore_clicks click ON UPPER(c.content_value) = SUBSTR(UPPER(click.url),charindex('UTM_CAMPAIGN', UPPER(click.url), 1) + 13,(charindex('&OBEM',UPPER(click.url),charindex('UTM_CAMPAIGN', UPPER(click.url), 1) + 13) - (charindex('UTM_CAMPAIGN', UPPER(click.url), 1) + 13)))
  INNER JOIN bo.response_event r ON IFNULL(UPPER(click.nqe), '0') = UPPER(r.vendor_address_no)
    AND click.event_time = r.event_timestamp
    AND r.source_system_id = c.source_system_id
 INNER JOIN bo.event_type et ON r.event_type_id = et.event_type_id
    AND r.source_system_id = et.source_system_id
WHERE 
     UPPER(et.event_type) = 'CLICK'
 AND c.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')    
 AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id 
            AND source_system_id    =   r.source_system_id--AND click.event_time =   r.event_timestamp
    );


--Bounces
INSERT INTO
    bo.response_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        event_type_id,
        event_type,
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
    UPPER(bounce.nqe),
    et.event_type_id,
    UPPER(et.event_type),
    bounce.event_time,
    UPPER(bounce.event_type),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    bo.stimulus_value sv
    INNER JOIN raw.bluecore_events bounce ON IFNULL(bounce.CAMPAIGN_ID, 0) = sv.vendor_envelope_no
    INNER JOIN bo.address ad ON UPPER(ad.address_string) = UPPER(bounce.email)
      AND sv.source_system_id = ad.source_system_id
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
     AND adt.address_type = 'BlueCore email address'
    INNER JOIN bo.event_type et ON et.event_type = bounce.event_type
     AND et.source_system_id = sv.source_system_id
WHERE
    UPPER(bounce.event_type) = 'BOUNCE'
     AND sv.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
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
            AND event_timestamp = bounce.event_time
            AND source_system_id = sv.source_system_id
    );

--Spam Reports
INSERT INTO
    bo.response_event (
        stimulus_value_id,
        address_id,
        address_value,
        vendor_address_no,
        event_type_id,
        event_type,
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
    UPPER(bounce.nqe),
    et.event_type_id,
    UPPER(et.event_type),
    bounce.event_time,
    UPPER(bounce.event_type),
(
        SELECT
            source_system_id
        FROM
            bo.source_system
        WHERE
            source_system_name = 'BlueCore'
            AND source_system_status = 'ACTIVE'
    ),
    current_timestamp,
    'bluecore_load_bo_engagement_20201118'
FROM
    bo.stimulus_value sv
    INNER JOIN raw.bluecore_events bounce ON IFNULL(bounce.CAMPAIGN_ID, 0) = UPPER(sv.vendor_envelope_no)
    INNER JOIN bo.address ad ON UPPER(ad.address_string) = UPPER(bounce.email)
     AND ad.source_system_id = sv.source_system_id
    INNER JOIN bo.address_type adt ON ad.address_type_id = adt.address_type_id
    AND adt.address_type = 'BlueCore email address'
    INNER JOIN bo.event_type et ON et.event_type = bounce.event_type
    AND et.source_system_id = sv.source_system_id
WHERE
    UPPER(bounce.event_type) = 'SPAMREPORT'
     AND sv.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'BlueCore' AND source_system_status = 'ACTIVE')
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
            AND event_timestamp = bounce.event_time
            AND source_system_id = sv.source_system_id
    );