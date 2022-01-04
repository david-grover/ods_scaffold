

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
            stimulus_owner_party_id
            ,stimulus_owner_party_no
            ,stimulus_owner
            ,vendor_status
            ,vendor_package_no
            ,stimulus_name
            ,stimulus_category
            ,stimulus_type  
            ,stimulus_subtype
            ,stimulus_budget_no
            ,stimulus_cost      
            ,scheduled_timestamp
            ,vendor_updated_timestamp
            ,stimulus_end_timestamp
            ,stimulus_scheme_no
            ,source_system_id
            ,created_timestamp
            ,created_process
        )
    SELECT DISTINCT
        p.party_id
        ,p.party_string
        ,p.party_name
        ,IFNULL(camp.campaignstatus,'0') -- or servingstatus?
        ,camp.campaignid
        ,IFNULL(camp.campaignname,'0')
        ,IFNULL(camp.BIDDINGSTRATEGYTYPE,'0') --category
        ,IFNULL(camp.advertisingchanneltype,'0') --type
        ,IFNULL(camp.campaigntrialtype,'0') --subtype
        ,IFNULL(camp.budgetid,'0') --stimulus_budget_no
        ,IFNULL(camp.amount,'0')    --stimulus_cost
        ,camp.startdate --scheduled_timestamp
        ,camp._latest_date  -- vendor_updated_timestamp
        ,camp.enddate   --stimulus_end_timestamp
        ,camp.labelids --stimulus_scheme_no   
        ,(SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
        ,current_timestamp
        ,'Adwords_load_bo_engagement_2021230'
    FROM
        raw.adwords_campaign camp
        INNER JOIN bo.party p ON IFNULL(camp.externalcustomerid, '0') = p.party_string    
        INNER JOIN  (
                      SELECT 
                          campaignid
                          ,MAX(_latest_date) as _latest_date
                          ,MAX(_data_date) as _data_date
                      FROM   
                          raw.adwords_campaign
                      GROUP BY   
                          campaignid
                    ) as latest
            ON  latest._data_date =   camp._data_date
            AND latest._latest_date =   camp._latest_date
            AND latest.campaignid   =   camp.campaignid
    WHERE   p.party_identifier = 'EXTERNALCUSTOMERID'
        AND p.party_identifier_type = 'Adwords account'
        AND NOT EXISTS ( SELECT DISTINCT vendor_package_no
                    FROM bo.stimulus
                    WHERE   vendor_package_no = camp.campaignid
                        AND source_system_id =     (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
            )

            ;

    MERGE INTO bo.stimulus st 
    USING (
        WITH max_camp AS (
            SELECT 
                  campaignid
                  ,MAX(_latest_date) as _latest_date
                  ,MAX(_data_date) as _data_date
          FROM   
                  raw.adwords_campaign
            GROUP BY   
                  campaignid
          )
    SELECT  
            camp.campaignid
            ,camp.amount    --stimulus_cost
            ,camp.startdate --scheduled_timestamp
            ,camp.enddate
            ,camp._latest_date  -- vendor_updated_timestamp
            ,camp.labelids --stimulus_scheme_no   
            ,UPPER(camp.servingstatus) as servingstatus -- or servingstatus?
    FROM    
            raw.adwords_campaign    camp
    INNER JOIN  
            max_camp
        ON  
            max_camp.campaignid =   camp.campaignid
        AND max_camp._latest_date   =   camp._latest_date
        AND max_camp._data_date   =   camp._data_date
    )   adwords
    ON  st.vendor_package_no    =   adwords.campaignid
        AND st.source_system_id =   (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
        --AND st.vendor_update_timestamp  <   camp._latest_date
    WHEN MATCHED THEN
        UPDATE
            SET st.stimulus_cost   =   adwords.amount
                ,st.scheduled_timestamp =   adwords.startdate
                ,st.vendor_updated_timestamp    =   adwords._latest_date
                ,st.stimulus_end_timestamp  =   adwords.enddate
                ,st.stimulus_scheme_no  =   adwords.labelids
                ,st.vendor_status    =   adwords.servingstatus
                ;

/*


20201230    DG

    ENVELOPE_TYPE is created at the top level of the hierarchy.  That's a choice I'm making to simplify the load.  
    It could also probably be added automatically if we added some metadata (e.g. source_system_id) to BO.ENVELOPE_TYPE 
    to use it to store any of these as envelope_type values too:

        ,camp.BIDDINGSTRATEGYTYPE --category
        ,camp.advertisingchanneltype --type
        ,camp.campaigntrialtype --subtype

    If you did that, you'd need to be able to subtype them appropriately in the envelope_type table and assign them correctly to the Adwords hierarchy, which has four levels
    in the Engagement model.  But you'd just do an insert into that table and correlate each envelope_type with its specific envelope.
    
    The limitation of this approach from the standpoint of feature discovery is that we have to choose what we want to store, so we can't store everything.
    The upside is that much of the data preparation is done, from a reliability standpoint, so you don't have to spend 80% of your time doing prep.  If you want to 
    add a new feature, add some content to the content_catalog and xref it with the right envelope, and you'll be able to analyze it in a cube.


*/

  INSERT INTO 
          bo.envelope_type
      (
          envelope_type
          ,envelope_desc
          ,created_process
      )
  SELECT
          'sem'
          ,'Search engine marketing.'
          ,'DG manual'
  WHERE   NOT EXISTS
      (
          SELECT  
                  envelope_type
          FROM    
                  bo.envelope_type
          WHERE   
                  envelope_type   =   'sem'
      );

/*

    Under the CAMPAIGN is the ADGROUP, which is ENVELOPE.  There is no need (at this point) for more than a 1-level parent-child relationship between adgroups and ads.

    This INSERT assumes the adgroupid is a solid key.  If its not, then we'll need more machinery here to manage deduping.

*/

--delete from bo.stimulus_envelope where source_system_id = (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE');

    INSERT INTO
        bo.stimulus_envelope (
            stimulus_id
            ,stimulus_owner_party_id
            ,stimulus_owner_party_no
            ,stimulus_owner
            ,vendor_package_no
            ,envelope_type_id
            ,envelope_type --'sem'
            ,vendor_envelope_no --adgroupid
            ,vendor_envelope_type --ADGROUPTYPE
            ,envelope_name --ADGROUPNAME
            ,envelope_desc --NULL
            ,envelope_budget_type -- CONTENTBIDCRITERIONTYPEGROUP
            ,envelope_scheme_no --labelids
            ,vendor_envelope_status --adgroupstatus
            ,vendor_updated_timestamp -- _latest_date
            ,source_system_id
            ,created_timestamp
            ,created_process
        )
    SELECT DISTINCT
        st.stimulus_id
        ,st.stimulus_owner_party_id
        ,st.stimulus_owner_party_no
        ,st.stimulus_owner
        ,st.vendor_package_no --campaignid
        ,(SELECT envelope_type_id FROM bo.envelope_type   WHERE envelope_type = 'sem' )
        ,(SELECT envelope_type FROM bo.envelope_type WHERE envelope_type = 'sem' )
        ,UPPER(adg.adgroupid) --vendor_envelope_no
        ,UPPER(IFNULL(adg.adgrouptype,'0')) --vendor_envelope_type
        ,UPPER(IFNULL(adg.adgroupname,'0')) --name
        ,NULL --desc
        ,UPPER(IFNULL(adg.contentbidcriteriontypegroup,'0'))
        ,UPPER(IFNULL(adg.labelids,'0'))
        ,UPPER(IFNULL(adg.adgroupstatus,'0'))
        ,adg._latest_date
        ,(   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
        ,current_timestamp
        ,'Adwords_load_bo_engagement_2021230'
    FROM
        raw.adwords_adgroup adg
        INNER JOIN bo.stimulus st ON adg.campaignid = st.vendor_package_no 
        INNER JOIN  (
                SELECT 
                      adgroupid
                      ,campaignid
                      ,MAX(_latest_date) as _latest_date
                      ,MAX(_data_date) as _data_date
              FROM   
                      raw.adwords_adgroup
                GROUP BY   
                      adgroupid
                    ,campaignid
              ) as max_adgroup
        ON  max_adgroup.adgroupid   =   adg.adgroupid
            AND max_adgroup.campaignid   =   adg.campaignid
            AND max_adgroup._latest_date    =   adg._latest_date
            AND max_adgroup._data_date  =   adg._data_date
    WHERE st.source_system_id = (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
    AND NOT EXISTS (
            SELECT
                DISTINCT vendor_envelope_no
            FROM
                bo.stimulus_envelope
            WHERE
                    vendor_envelope_no  =   adg.adgroupid
                AND vendor_package_no   =   adg.campaignid
                AND source_system_id    =   (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
        ) 
    ;

    MERGE INTO bo.stimulus_envelope ste 
    USING (
        WITH max_adg AS (
            SELECT 
                  campaignid
                  ,adgroupid
                  ,MAX(_latest_date) as _latest_date
                  ,MAX(_data_date) as _data_date
          FROM   
                  raw.adwords_adgroup
            GROUP BY   
                    campaignid
                    ,adgroupid
          )
    SELECT  
            adg.campaignid
            ,adg.adgroupid
            ,UPPER(adg.adgroupstatus) as adgroupstatus
            ,adg.labelids
            ,adg._latest_date
    FROM    
            raw.adwords_adgroup    adg
    INNER JOIN  
            max_adg
        ON  
            max_adg.campaignid =   adg.campaignid
        AND max_adg.adgroupid   =   adg.adgroupid
        AND max_adg._latest_date   =   adg._latest_date
        AND max_adg._data_date   =   adg._data_date
    )   adgroup
    ON  ste.vendor_package_no    =   adgroup.campaignid
        AND ste.vendor_envelope_no  =   adgroup.adgroupid
        AND ste.source_system_id =   (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
        --AND st.vendor_update_timestamp  <   camp._latest_date
    WHEN MATCHED THEN
        UPDATE
            SET ste.vendor_updated_timestamp    =   adgroup._latest_date
                ,ste.envelope_scheme_no  =   adgroup.labelids
                ,ste.vendor_envelope_status    =   adgroup.adgroupstatus
                ,ste.updated_timestamp  =   current_timestamp
                ,ste.updated_process    =   'Adwords_load_bo_engagement_2021230'
                ;
                
                
INSERT INTO bo.content_type(content_type,vendor_content_no,vendor_field_name,created_process,source_system_id) 
SELECT 'Adwords Criteria','CRITERIONID','ADWORDS_KEYWORD.CRITERIA','DG manual',(SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE') 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE content_type = 'Adwords Criteria' AND source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE') 
                 );                
                

INSERT INTO bo.content_type(content_type,vendor_content_no,vendor_field_name,created_process,source_system_id) 
SELECT 'Adwords FirstPageCPC','FIRSTPAGECPC','ADWORDS_KEYWORD.FIRSTPAGECPC','DG manual',(SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE') 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE content_type = 'Adwords FirstPageCPC' AND source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE') 
                 );                


    -- keyword                    
    INSERT INTO
            bo.content 
              (
                content_type_id
                ,content_value
                ,vendor_field_name
                ,vendor_content_no
                ,source_system_id
                ,created_timestamp
                ,created_process
              )
    SELECT DISTINCT
            (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'ADWORDS_KEYWORD.CRITERIA' AND source_system_id = ( SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE'))
            ,IFNULL(UPPER(keyword.criteria), '0')
            ,'ADWORDS_KEYWORD.CRITERIA'
            ,keyword.criterionid
            ,( SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')    
            ,current_timestamp
            ,'Adwords_load_bo_engagement_2021230'
    FROM
        bo.stimulus_envelope ste
        INNER JOIN raw.adwords_keyword keyword 
            ON ste.vendor_envelope_no = keyword.adgroupid
            AND ste.vendor_package_no   =   keyword.campaignid
    WHERE ste.source_system_id = (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
        AND
        NOT EXISTS (
            SELECT
                DISTINCT content_type_id,
                content_value
            FROM
                bo.content
            WHERE
                UPPER(content_value) = IFNULL(UPPER(keyword.criteria), '0')
                AND content_type_id = (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'ADWORDS_KEYWORD.CRITERIA' AND source_system_id = ( SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE'))
                AND source_system_id    =   (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
        );


    INSERT INTO
        bo.content_envelope_xref (
            content_id,
            envelope_id,
            source_system_id,
            created_timestamp,
            created_process
        )
    SELECT DISTINCT 
        c.content_id
        ,ste.envelope_id
        ,(SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')    
        ,current_timestamp
        ,'Adwords_load_bo_engagement_2021230'
    FROM
        bo.content c
        INNER JOIN raw.adwords_keyword keyword 
            ON  UPPER(c.content_value) = IFNULL(UPPER(keyword.criteria), '0')
        INNER JOIN bo.stimulus_envelope ste
            ON ste.vendor_envelope_no = keyword.adgroupid
            AND ste.vendor_package_no   =   keyword.campaignid
            AND c.source_system_id   = ste.source_system_id
    WHERE ste.source_system_id = (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
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
                AND source_system_id    =   ste.source_system_id
            );


/*

    Under the ADGROUP is the AD, which is VALUE in the Engagement model.

    This INSERT assumes {adgroupid, campaignid, creativeid}  is a solid key.  If its not, then we'll need more machinery here to manage deduping.

     --,from_persona   ---displayurl could be added here, but we'd need to create an ADDRESS record.


*/


      INSERT INTO
          bo.stimulus_value (
              envelope_id
              ,stimulus_id
              ,value_name -- headline
              ,value_desc --  description1 || ' ' description2
              ,vendor_envelope_no
              ,vendor_package_no
                ,vendor_value_no --creativeid
                ,value_scheme_no --labelids
              ,vendor_value_status --status     
              ,vendor_updated_timestamp   --_latest_date
              ,source_system_id
              ,created_timestamp
              ,created_process
          )
      SELECT DISTINCT
              ste.envelope_id
              ,ste.stimulus_id
              ,UPPER(IFNULL(ad.headline,'0'))
              ,UPPER(ad.description1) || ' ' || UPPER(ad.description2)
              ,ad.adgroupid
              ,ad.campaignid
              ,ad.creativeid
              ,SUBSTR(IFNULL(ad.labelids,'0'),1,100)
              ,IFNULL(ad.status,'0')
              ,ad._latest_date
              ,(SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
              ,current_timestamp
              ,'Adwords_load_bo_engagement_2021230'
      FROM        
          raw.adwords_ad ad
      INNER JOIN bo.stimulus_envelope ste 
        ON      ad.campaignid   = ste.vendor_package_no 
            AND ad.adgroupid    = ste.vendor_envelope_no 
      INNER JOIN  (
              SELECT 
                    adgroupid
                    ,campaignid
                    ,creativeid
                    ,MAX(_latest_date) as _latest_date
                    ,MAX(_data_date) as _data_date
            FROM   
                    raw.adwords_ad
              GROUP BY   
                    adgroupid
                    ,campaignid
                    ,creativeid
            ) as max_ad
      ON  max_ad.adgroupid   =   ad.adgroupid
          AND max_ad._latest_date    =   ad._latest_date
          AND max_ad._data_date  =   ad._data_date
    WHERE ste.source_system_id = (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')     
      AND NOT EXISTS (
              SELECT
                  DISTINCT vendor_value_no
              FROM
                  bo.stimulus_value
              WHERE
                      vendor_envelope_no  =   ad.adgroupid
                  AND vendor_package_no   =   ad.campaignid       
                  AND   vendor_value_no =   ad.creativeid
                    AND source_system_id    =   (   SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
          ) 
      ;

    MERGE INTO bo.stimulus_value stv
    USING (
        WITH max_ad AS (
            SELECT 
                  campaignid
                  ,adgroupid
                  ,creativeid
                  ,MAX(_latest_date) as _latest_date
                  ,MAX(_data_date) as _data_date
          FROM   
                  raw.adwords_ad
            GROUP BY   
                    campaignid
                    ,adgroupid
                    ,creativeid
          )
    SELECT  
            ad.campaignid
            ,ad.adgroupid
            ,ad.creativeid
            ,UPPER(ad.status) as vendor_value_status
            ,ad.labelids
            ,ad._latest_date
    FROM    
            raw.adwords_ad    ad
    INNER JOIN  
            max_ad
        ON  
            max_ad.campaignid =   ad.campaignid
        AND max_ad.adgroupid   =   ad.adgroupid
        AND max_ad.creativeid   =   ad.creativeid
        AND max_ad._latest_date   =   ad._latest_date
        AND max_ad._data_date   =   ad._data_date
    )   ad
    ON  stv.vendor_package_no    =   ad.campaignid
        AND stv.vendor_envelope_no  =   ad.adgroupid
        AND stv.vendor_value_no  =   ad.creativeid
        AND stv.source_system_id =   (SELECT source_system_id FROM bo.source_system WHERE source_system_name = 'Adwords' AND source_system_status = 'ACTIVE')
        AND stv.vendor_updated_timestamp  <   ad._latest_date
    WHEN MATCHED THEN
        UPDATE
            SET stv.vendor_updated_timestamp    =   ad._latest_date
                ,stv.value_scheme_no  =   SUBSTR(ad.labelids,1,100)
                ,stv.vendor_value_status    =   ad.vendor_value_status
                ,stv.updated_timestamp  =   current_timestamp
                ,stv.updated_process    =   'Adwords_load_bo_engagement_2021230'
                ;
