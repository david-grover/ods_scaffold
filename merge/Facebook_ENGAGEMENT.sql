

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

    MERGE INTO bo.stimulus st 
    USING (
        WITH campaign_window AS
                    (
                      SELECT 
                          campaign_id
                          ,MAX(date_start) as vendor_updated_timestamp
                          ,MIN(date_start) as stimulus_start_timestamp
                      FROM   
                          raw.facebook_actions
                      GROUP BY   
                          campaign_id
                    )
	    SELECT DISTINCT
		   p.party_id AS stimulus_owner_party_id,
		   p.party_identifier AS stimulus_owner_party_no,
		   p.party_name AS stimulus_owner,
		   campaign.campaign_id AS vendor_package_no,
		   SUBSTR(UPPER(campaign.campaign_name),1,100) AS stimulus_name,
		   --,campaign.cpc
		   campaign_window.stimulus_start_timestamp AS stimulus_start_timestamp,
		   CASE
			  WHEN    campaign_window.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    campaign_window.vendor_updated_timestamp
			  ELSE    NULL
		   END AS stimulus_end_timestamp,
		   campaign_window.vendor_updated_timestamp AS vendor_updated_timestamp,  
		   $source_system_id AS source_system_id,
		   current_timestamp AS created_timestamp,
		   'Facebook_load_bo_engagement_20210407' AS created_process
	    FROM
		   raw.facebook_action_values campaign
        INNER JOIN 
                bo.party p 
            ON 
                campaign.account_id = p.party_identifier    
        INNER JOIN  
        		campaign_window
            ON  
                campaign_window.campaign_id   =   campaign.campaign_id
            AND campaign_window.vendor_updated_timestamp    =   campaign.date_start       
            
            
            
            
            
            
	)   campaign_out
    ON  st.vendor_package_no    =   campaign_out.vendor_package_no
        AND st.source_system_id =   $source_system_id
    WHEN MATCHED THEN
        UPDATE
            SET st.stimulus_name  =   campaign_out.stimulus_name
                ,st.vendor_updated_timestamp    =   campaign_out.vendor_updated_timestamp
                ,st.stimulus_end_timestamp  =   
                CASE
                  WHEN    campaign_out.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    campaign_out.vendor_updated_timestamp
                  ELSE    NULL
                END                         
                ,st.updated_timestamp = current_timestamp
                ,st.updated_process = 'Facebook_load_bo_engagement_20210407'
	WHEN NOT MATCHED THEN INSERT (
	            stimulus_owner_party_id ,
	            stimulus_owner_party_no,
	            stimulus_owner,
	            vendor_package_no, --campaign_id
	            stimulus_name, --campaign_name
	            stimulus_start_timestamp,
	            stimulus_end_timestamp,
	            vendor_updated_timestamp,
	            source_system_id,
	            created_timestamp,
	            created_process
	        )
	VALUES (
	            campaign_out.stimulus_owner_party_id,
	            campaign_out.stimulus_owner_party_no,
	            campaign_out.stimulus_owner,
	            campaign_out.vendor_package_no, --campaign_id
	            campaign_out.stimulus_name, --campaign_name
	            campaign_out.stimulus_start_timestamp,
	            campaign_out.stimulus_end_timestamp,
	            campaign_out.vendor_updated_timestamp,
	            campaign_out.source_system_id,
	            campaign_out.created_timestamp,
	            campaign_out.created_process
	);



    MERGE INTO bo.stimulus st 
    USING (
        WITH campaign_window AS
                    (
                      SELECT 
                          campaign_id
                          ,MAX(date_start) as vendor_updated_timestamp
                          ,MIN(date_start) as stimulus_start_timestamp
                      FROM   
                          raw.facebook_actions
                      GROUP BY   
                          campaign_id
                    )
	    SELECT DISTINCT
		   p.party_id AS stimulus_owner_party_id,
		   p.party_identifier AS stimulus_owner_party_no,
		   p.party_name AS stimulus_owner,
		   campaign.campaign_id AS vendor_package_no,
		   SUBSTR(UPPER(campaign.campaign_name),1,100) AS stimulus_name,
		   --,campaign.cpc
		   campaign_window.stimulus_start_timestamp AS stimulus_start_timestamp,
		   CASE
			  WHEN    campaign_window.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    campaign_window.vendor_updated_timestamp
			  ELSE    NULL
		   END AS stimulus_end_timestamp,
		   campaign_window.vendor_updated_timestamp AS vendor_updated_timestamp,  
		   $source_system_id AS source_system_id,
		   current_timestamp AS created_timestamp,
		   'Facebook_load_bo_engagement_20210407' AS created_process
	    FROM
		   raw.facebook_actions campaign
        INNER JOIN 
                bo.party p 
            ON 
                campaign.account_id = p.party_identifier    
        INNER JOIN  
        		campaign_window
            ON  
                campaign_window.campaign_id   =   campaign.campaign_id
            AND campaign_window.vendor_updated_timestamp    =   campaign.date_start                     
	)   campaign_out
    ON  st.vendor_package_no    =   campaign_out.vendor_package_no
        AND st.source_system_id =   $source_system_id
    WHEN MATCHED THEN
        UPDATE
            SET st.stimulus_name  =   campaign_out.stimulus_name
                ,st.vendor_updated_timestamp    =   campaign_out.vendor_updated_timestamp
                ,st.stimulus_end_timestamp  =   
                CASE
                  WHEN    campaign_out.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    campaign_out.vendor_updated_timestamp
                  ELSE    NULL
                END                         
                ,st.updated_timestamp = current_timestamp
                ,st.updated_process = 'Facebook_load_bo_engagement_20210407'
	WHEN NOT MATCHED THEN INSERT (
	            stimulus_owner_party_id ,
	            stimulus_owner_party_no,
	            stimulus_owner,
	            vendor_package_no, --campaign_id
	            stimulus_name, --campaign_name
	            stimulus_start_timestamp,
	            stimulus_end_timestamp,
	            vendor_updated_timestamp,
	            source_system_id,
	            created_timestamp,
	            created_process
	        )
	VALUES (
	            campaign_out.stimulus_owner_party_id,
	            campaign_out.stimulus_owner_party_no,
	            campaign_out.stimulus_owner,
	            campaign_out.vendor_package_no, --campaign_id
	            campaign_out.stimulus_name, --campaign_name
	            campaign_out.stimulus_start_timestamp,
	            campaign_out.stimulus_end_timestamp,
	            campaign_out.vendor_updated_timestamp,
	            campaign_out.source_system_id,
	            campaign_out.created_timestamp,
	            campaign_out.created_process
	);





/*

    Under the CAMPAIGN is the ADSET, which we store in STIMULUS_ENVELOPE.  There is no need (at this point) for more than a 1-level parent-child relationship between adsets and campaigns.

    This INSERT assumes the adset_id is a solid key.  If its not, then we'll need more machinery here to manage deduping.

*/

  INSERT INTO 
          bo.envelope_type
      (
          envelope_type
          ,envelope_desc
          ,created_process
      )
  SELECT
          'socialmedia'
          ,'Social media marketing.'
          ,'DG manual'
  WHERE   NOT EXISTS
      (
          SELECT  
                  envelope_type
          FROM    
                  bo.envelope_type
          WHERE   
                  envelope_type   =   'socialmedia'
      );

SET envelope_type_id = (SELECT envelope_type_id FROM bo.envelope_type   WHERE envelope_type = 'socialmedia' );
SET envelope_type = (SELECT envelope_type FROM bo.envelope_type   WHERE envelope_type = 'socialmedia' );



    MERGE INTO bo.stimulus_envelope STE 
    USING (
   	WITH adset_window AS
			(
			  SELECT 
				 campaign_id
				 ,adset_id
				 ,MAX(date_start) as vendor_updated_timestamp
				 ,MIN(date_start) as stimulus_start_timestamp
			  FROM   
				 raw.facebook_actions
			  GROUP BY   
				 campaign_id
				 ,adset_id
			)	                   
    SELECT DISTINCT
        st.stimulus_id,
        st.stimulus_owner_party_id,
        st.stimulus_owner_party_no,
        st.stimulus_owner,
        st.vendor_package_no ,
        $envelope_type_id 	as envelope_type_id,
        $envelope_type AS envelope_type ,
        UPPER(adset.adset_id) AS vendor_envelope_no,
        'ADSET' AS vendor_envelope_type,
        SUBSTR(UPPER(adset.adset_name),1,100) AS ENVELOPE_NAME,
        adset_window.vendor_updated_timestamp,
        adset_window.envelope_start_timestamp,
        CASE
           WHEN    adset_window.vendor_updated_timestamp   <   DATEADD('day',-7,current_timestamp) THEN    adset_window.vendor_updated_timestamp
            ELSE    NULL
        END AS envelope_end_timestamp            ,
        $source_system_id AS source_system_id,
        current_timestamp AS created_timestamp,
        'Facebook_load_bo_engagement_20210407' AS created_process
    FROM
        raw.facebook_action_VALUES    adset
        INNER JOIN bo.stimulus st ON adset.campaign_id = st.vendor_package_no
        INNER JOIN  
                    (
                      SELECT 
                          adset_id
                          ,campaign_id
                          ,MAX(date_start) as vendor_updated_timestamp
                          ,MIN(date_start) as envelope_start_timestamp
                      FROM   
                          raw.facebook_actions
                      GROUP BY   
                          adset_id
                          ,campaign_id
                    ) as adset_window
            ON  
                adset_window.adset_id   =   adset.adset_id              
            AND adset_window.campaign_id   =   adset.campaign_id
            AND adset_window.vendor_updated_timestamp    =   adset.date_start
    WHERE st.source_system_id = $source_system_id              
	)   adset_out
    ON  STE.vendor_package_no    =   adset_out.vendor_package_no
    		AND	STE.VENDOR_ENVELOPE_NO	=	ADSET_OUT.VENDOR_ENVELOPE_NO
        AND STE.source_system_id =   $source_system_id
    WHEN MATCHED THEN
        UPDATE
            SET 
                ste.envelope_name  =   
                CASE
                  WHEN    ste.vendor_updated_timestamp  <   adset_out.vendor_updated_timestamp THEN   adset_out.envelope_name
                END,
                ste.vendor_updated_timestamp    =
                CASE
                  WHEN    ste.vendor_updated_timestamp  <   adset_out.vendor_updated_timestamp THEN   adset_out.vendor_updated_timestamp
                END,
                ste.envelope_end_timestamp  =   
                CASE
                  WHEN    adset_out.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    adset_out.vendor_updated_timestamp
                END ,                        
                STE.UPDATED_TIMESTAMP    =   
                CASE
                  WHEN    ste.vendor_updated_timestamp  <   adset_out.vendor_updated_timestamp THEN    CURRENT_TIMESTAMP
                END,
                ste.updated_process = 
                CASE
                  WHEN    ste.vendor_updated_timestamp  <   adset_out.vendor_updated_timestamp THEN    'Facebook_load_bo_engagement_20210407'
                END

	WHEN NOT MATCHED THEN INSERT (
            stimulus_id,
            stimulus_owner_party_id,
            stimulus_owner_party_no,
            stimulus_owner,
            vendor_package_no,
            envelope_type_id,
            envelope_type, --'socialmedia'
            vendor_envelope_no, --adset_id
            vendor_envelope_type, --'ADSET'
            envelope_name, --campaign_name
            vendor_updated_timestamp, 
            envelope_start_timestamp,
            envelope_end_timestamp,
            source_system_id,
            created_timestamp,
            created_process
	        )
	VALUES (
            adset_out.stimulus_id,
            adset_out.stimulus_owner_party_id,
            adset_out.stimulus_owner_party_no,
            adset_out.stimulus_owner,
            adset_out.vendor_package_no,
            adset_out.envelope_type_id,
            adset_out.envelope_type, --'socialmedia'
            adset_out.vendor_envelope_no, --adset_id
            adset_out.vendor_envelope_type, --'ADSET'
            adset_out.envelope_name, --campaign_name
            adset_out.vendor_updated_timestamp, 
            adset_out.envelope_start_timestamp,
            adset_out.envelope_end_timestamp,
            adset_out.source_system_id,
            adset_out.created_timestamp,
            adset_out.created_process
            );


   
    MERGE INTO bo.stimulus_envelope STE 
    USING (
   	WITH adset_window AS
			(
			  SELECT 
				 campaign_id
				 ,adset_id
				 ,MAX(date_start) as vendor_updated_timestamp
				 ,MIN(date_start) as stimulus_start_timestamp
			  FROM   
				 raw.facebook_actions
			  GROUP BY   
				 campaign_id
				 ,adset_id
			)	                   
    SELECT DISTINCT
        st.stimulus_id,
        st.stimulus_owner_party_id,
        st.stimulus_owner_party_no,
        st.stimulus_owner,
        st.vendor_package_no ,
        $envelope_type_id 	as envelope_type_id,
        $envelope_type AS envelope_type ,
        UPPER(adset.adset_id) AS vendor_envelope_no,
        'ADSET' AS vendor_envelope_type,
        SUBSTR(UPPER(adset.adset_name),1,100) AS ENVELOPE_NAME,
        adset_window.vendor_updated_timestamp,
        adset_window.envelope_start_timestamp,
        CASE
           WHEN    adset_window.vendor_updated_timestamp   <   DATEADD('day',-7,current_timestamp) THEN    adset_window.vendor_updated_timestamp
            ELSE    NULL
        END AS envelope_end_timestamp            ,
        $source_system_id AS source_system_id,
        current_timestamp AS created_timestamp,
        'Facebook_load_bo_engagement_20210407' AS created_process
    FROM
        raw.facebook_actions    adset
        INNER JOIN bo.stimulus st ON adset.campaign_id = st.vendor_package_no
        INNER JOIN  
                    (
                      SELECT 
                          adset_id
                          ,campaign_id
                          ,MAX(date_start) as vendor_updated_timestamp
                          ,MIN(date_start) as envelope_start_timestamp
                      FROM   
                          raw.facebook_actions
                      GROUP BY   
                          adset_id
                          ,campaign_id
                    ) as adset_window
            ON  
                adset_window.adset_id   =   adset.adset_id              
            AND adset_window.campaign_id   =   adset.campaign_id
            AND adset_window.vendor_updated_timestamp    =   adset.date_start
    WHERE st.source_system_id = $source_system_id              
	)   adset_out
    ON  STE.vendor_package_no    =   adset_out.vendor_package_no
    		AND	STE.VENDOR_ENVELOPE_NO	=	ADSET_OUT.VENDOR_ENVELOPE_NO
        AND STE.source_system_id =   $source_system_id
    WHEN MATCHED THEN
        UPDATE
            SET 
                ste.envelope_name  =   
                CASE
                  WHEN    ste.vendor_updated_timestamp  <   adset_out.vendor_updated_timestamp THEN   adset_out.envelope_name
                END,
                ste.vendor_updated_timestamp    =
                CASE
                  WHEN    ste.vendor_updated_timestamp  <   adset_out.vendor_updated_timestamp THEN   adset_out.vendor_updated_timestamp
                END,
                ste.envelope_end_timestamp  =   
                CASE
                  WHEN    adset_out.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    adset_out.vendor_updated_timestamp
                END ,                        
                STE.UPDATED_TIMESTAMP    =   
                CASE
                  WHEN    ste.vendor_updated_timestamp  <   adset_out.vendor_updated_timestamp THEN    CURRENT_TIMESTAMP
                END,
                ste.updated_process = 
                CASE
                  WHEN    ste.vendor_updated_timestamp  <   adset_out.vendor_updated_timestamp THEN    'Facebook_load_bo_engagement_20210407'
                END

	WHEN NOT MATCHED THEN INSERT (
            stimulus_id,
            stimulus_owner_party_id,
            stimulus_owner_party_no,
            stimulus_owner,
            vendor_package_no,
            envelope_type_id,
            envelope_type, --'socialmedia'
            vendor_envelope_no, --adset_id
            vendor_envelope_type, --'ADSET'
            envelope_name, --campaign_name
            vendor_updated_timestamp, 
            envelope_start_timestamp,
            envelope_end_timestamp,
            source_system_id,
            created_timestamp,
            created_process
	        )
	VALUES (
            adset_out.stimulus_id,
            adset_out.stimulus_owner_party_id,
            adset_out.stimulus_owner_party_no,
            adset_out.stimulus_owner,
            adset_out.vendor_package_no,
            adset_out.envelope_type_id,
            adset_out.envelope_type, --'socialmedia'
            adset_out.vendor_envelope_no, --adset_id
            adset_out.vendor_envelope_type, --'ADSET'
            adset_out.envelope_name, --campaign_name
            adset_out.vendor_updated_timestamp, 
            adset_out.envelope_start_timestamp,
            adset_out.envelope_end_timestamp,
            adset_out.source_system_id,
            adset_out.created_timestamp,
            adset_out.created_process
	);


/*

    Under the ADSET is the AD, which is VALUE in the Engagement model.

    This INSERT assumes {adset_id, campaign_id, ad_id}  is a solid key.  If its not, then we'll need more machinery here to manage deduping.



*/



    MERGE INTO bo.stimulus_value sv 
    USING (
   	WITH ad_window AS
                    (
                      SELECT 
                          adset_id
                            ,campaign_id
                            ,ad_id
                          ,MAX(date_start) as vendor_updated_timestamp
                          ,MIN(date_start) as value_start_timestamp
                      FROM   
                          raw.facebook_action_values
                      GROUP BY   
                          adset_id
                            ,campaign_id
                            ,ad_id
                    ) 
	SELECT DISTINCT
              ste.envelope_id
              ,ste.stimulus_id
              ,SUBSTR(UPPER(ad.ad_name),1,100) as value_name
              ,ad.campaign_id as vendor_package_no
              ,ad.adset_id as vendor_envelope_no
              ,ad.ad_id as vendor_value_no
              ,ad_window.vendor_updated_timestamp
              ,ad_window.value_start_timestamp
              ,CASE
                WHEN    ad_window.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    ad_window.vendor_updated_timestamp
                ELSE    NULL
              END as value_end_timestamp
              ,$source_system_id as source_system_id
              ,current_timestamp as created_timestamp
              ,'Facebook_load_bo_engagement_20210407' as created_process
      FROM        
          raw.facebook_action_values ad
      INNER JOIN bo.stimulus_envelope ste 
        ON      ad.campaign_id  = ste.vendor_package_no 
            AND ad.adset_id     = ste.vendor_envelope_no 
        INNER JOIN  ad_window
            ON  
                ad_window.adset_id   =   ad.adset_id              
            AND ad_window.campaign_id   =   ad.campaign_id
            AND ad_window.ad_id =   ad.ad_id
            AND ad_window.vendor_updated_timestamp    =   ad.date_start
    WHERE ste.source_system_id = $source_system_id
	)   ad_out
    ON  sv.vendor_package_no    =   ad_out.vendor_package_no
    		AND	sv.VENDOR_ENVELOPE_NO	=	ad_out.VENDOR_ENVELOPE_NO
    		AND	sv.VENDOR_value_NO	=	ad_out.VENDOR_value_NO
        AND sv.source_system_id =   $source_system_id
    WHEN MATCHED THEN UPDATE
            SET 
                sv.value_name  =   
                CASE
                  WHEN    sv.vendor_updated_timestamp  <   ad_out.vendor_updated_timestamp THEN   ad_out.value_name
                END,
                sv.vendor_updated_timestamp    =
                CASE
                  WHEN    sv.vendor_updated_timestamp  <   ad_out.vendor_updated_timestamp THEN   ad_out.vendor_updated_timestamp
                END,
                sv.value_end_timestamp  =   
                CASE
                  WHEN    ad_out.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    ad_out.vendor_updated_timestamp
                END ,                        
                sv.UPDATED_TIMESTAMP    =   
                CASE
                  WHEN    sv.vendor_updated_timestamp  <   ad_out.vendor_updated_timestamp THEN    CURRENT_TIMESTAMP
                END,
                sv.updated_process = 
                CASE
                  WHEN    sv.vendor_updated_timestamp  <   ad_out.vendor_updated_timestamp THEN    'Facebook_load_bo_engagement_20210407'
                END

	WHEN NOT MATCHED THEN INSERT (
			envelope_id,
			stimulus_id,
			value_name,
			vendor_package_no,
			vendor_envelope_no,
			vendor_value_no ,
			vendor_updated_timestamp,   
			value_start_timestamp,
			value_end_timestamp   ,         
			source_system_id,
			created_timestamp,
			created_process
	        )
	VALUES (
			ad_out.envelope_id,
			ad_out.stimulus_id,
			ad_out.value_name,
			ad_out.vendor_package_no,
			ad_out.vendor_envelope_no,
			ad_out.vendor_value_no ,
			ad_out.vendor_updated_timestamp   ,
			ad_out.value_start_timestamp,
			ad_out.value_end_timestamp   ,         
			ad_out.source_system_id,
			ad_out.created_timestamp,
			ad_out.created_process
	);



    MERGE INTO bo.stimulus_value sv 
    USING (
   	WITH ad_window AS
                    (
                      SELECT 
                          adset_id
                            ,campaign_id
                            ,ad_id
                          ,MAX(date_start) as vendor_updated_timestamp
                          ,MIN(date_start) as value_start_timestamp
                      FROM   
                          raw.facebook_action_values
                      GROUP BY   
                          adset_id
                            ,campaign_id
                            ,ad_id
                    ) 
	SELECT DISTINCT
              ste.envelope_id
              ,ste.stimulus_id
              ,SUBSTR(UPPER(ad.ad_name),1,100) as value_name
              ,ad.campaign_id as vendor_package_no
              ,ad.adset_id as vendor_envelope_no
              ,ad.ad_id as vendor_value_no
              ,ad_window.vendor_updated_timestamp
              ,ad_window.value_start_timestamp
              ,CASE
                WHEN    ad_window.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    ad_window.vendor_updated_timestamp
                ELSE    NULL
              END as value_end_timestamp
              ,$source_system_id as source_system_id
              ,current_timestamp as created_timestamp
              ,'Facebook_load_bo_engagement_20210407' as created_process
      FROM        
          raw.facebook_actions ad
      INNER JOIN bo.stimulus_envelope ste 
        ON      ad.campaign_id  = ste.vendor_package_no 
            AND ad.adset_id     = ste.vendor_envelope_no 
        INNER JOIN  ad_window
            ON  
                ad_window.adset_id   =   ad.adset_id              
            AND ad_window.campaign_id   =   ad.campaign_id
            AND ad_window.ad_id =   ad.ad_id
            AND ad_window.vendor_updated_timestamp    =   ad.date_start
    WHERE ste.source_system_id = $source_system_id
	)   ad_out
    ON  sv.vendor_package_no    =   ad_out.vendor_package_no
    		AND	sv.VENDOR_ENVELOPE_NO	=	ad_out.VENDOR_ENVELOPE_NO
    		AND	sv.VENDOR_value_NO	=	ad_out.VENDOR_value_NO
        AND sv.source_system_id =   $source_system_id
    WHEN MATCHED THEN UPDATE
            SET 
                sv.value_name  =   
                CASE
                  WHEN    sv.vendor_updated_timestamp  <   ad_out.vendor_updated_timestamp THEN   ad_out.value_name
                END,
                sv.vendor_updated_timestamp    =
                CASE
                  WHEN    sv.vendor_updated_timestamp  <   ad_out.vendor_updated_timestamp THEN   ad_out.vendor_updated_timestamp
                END,
                sv.value_end_timestamp  =   
                CASE
                  WHEN    ad_out.vendor_updated_timestamp <   DATEADD('day',-7,current_timestamp) THEN    ad_out.vendor_updated_timestamp
                END ,                        
                sv.UPDATED_TIMESTAMP    =   
                CASE
                  WHEN    sv.vendor_updated_timestamp  <   ad_out.vendor_updated_timestamp THEN    CURRENT_TIMESTAMP
                END,
                sv.updated_process = 
                CASE
                  WHEN    sv.vendor_updated_timestamp  <   ad_out.vendor_updated_timestamp THEN    'Facebook_load_bo_engagement_20210407'
                END

	WHEN NOT MATCHED THEN INSERT (
			envelope_id,
			stimulus_id,
			value_name,
			vendor_package_no,
			vendor_envelope_no,
			vendor_value_no ,
			vendor_updated_timestamp,   
			value_start_timestamp,
			value_end_timestamp   ,         
			source_system_id,
			created_timestamp,
			created_process
	        )
	VALUES (
			ad_out.envelope_id,
			ad_out.stimulus_id,
			ad_out.value_name,
			ad_out.vendor_package_no,
			ad_out.vendor_envelope_no,
			ad_out.vendor_value_no ,
			ad_out.vendor_updated_timestamp   ,
			ad_out.value_start_timestamp,
			ad_out.value_end_timestamp   ,         
			ad_out.source_system_id,
			ad_out.created_timestamp,
			ad_out.created_process
	);






  INSERT INTO bo.event_type
      (
          event_type
          ,vendor_event_type
          ,vendor_field_name
          ,event_category
          ,created_process
          ,source_system_id
      ) 
  SELECT DISTINCT
          'FACEBOOK_ROLLUP'  
          ,'ACTIONS'  
          ,'FACEBOOK_ACTIONS'
          ,'PERFORMANCE_MARKETING_ROLLUP'
          ,'Facebook_load_bo_engagement_20210407'
          ,$source_system_id
  FROM    raw.facebook_action_values  actions        
  WHERE NOT EXISTS (
          SELECT 
                  event_type 
          FROM 
                  bo.event_type 
          WHERE 
                  UPPER(event_type) =    'FACEBOOK_ROLLUP'  
              AND UPPER(vendor_field_name)   =   'FACEBOOK_ACTIONS'
                AND UPPER(event_category)   =   'PERFORMANCE_MARKETING_ROLLUP'
              AND source_system_id = $source_system_id                  
          );            
          
/*

    The main event, which is really pretty easy.  Each day that Courtney gives us is a rollup of that day's events, by action and ad_id.  We store exactly that in the RESPONSE_EVENT table, as long
    as we can also store a count of events.  
    
    Alternatively, I could do a loop here inserting a single record until the count adds up to the number for that day/event/campaign in Facebook.  But nobody wants that.
    
    
    */
SET event_type_id = (SELECT event_type_id FROM bo.event_type WHERE UPPER(event_type) = 'FACEBOOK_ROLLUP' AND UPPER(vendor_field_name)   =   'FACEBOOK_ACTIONS' AND UPPER(event_category)   =   'PERFORMANCE_MARKETING_ROLLUP' AND source_system_id = $source_system_id);   
SET event_type    = (SELECT event_type    FROM bo.event_type WHERE UPPER(event_type) = 'FACEBOOK_ROLLUP' AND UPPER(vendor_field_name)   =   'FACEBOOK_ACTIONS' AND UPPER(event_category)   =   'PERFORMANCE_MARKETING_ROLLUP' AND source_system_id = $source_system_id);
SET vendor_event_type    = (SELECT vendor_event_type    FROM bo.event_type WHERE UPPER(event_type) = 'FACEBOOK_ROLLUP' AND UPPER(vendor_field_name)   =   'FACEBOOK_ACTIONS' AND UPPER(event_category)   =   'PERFORMANCE_MARKETING_ROLLUP' AND source_system_id = $source_system_id);



MERGE INTO
      bo.response_event AS RE
USING (
  SELECT DISTINCT
          sv.value_id AS stimulus_value_id,
          $vendor_event_type AS vendor_event_type,
          $event_type_id AS event_type_id ,
          $event_type AS event_type ,
          response.date_start,
          CONVERT_TIMEZONE('America/Los_Angeles','UTC',response.date_start) AS event_timestamp_utc,
          CONVERT_TIMEZONE('America/Los_Angeles','America/Detroit',response.date_start) AS event_timestamp_ET,
          $source_system_id AS source_system_id,
          current_timestamp AS created_timestamp,
          'Facebook_load_bo_engagement_20210407' AS created_process
  FROM
          raw.facebook_action_values  response
  INNER JOIN  
          bo.stimulus_value   sv
      ON  
          sv.vendor_package_no    =   response.campaign_id
      AND sv.vendor_envelope_no   =   response.adset_id
      AND sv.vendor_value_no  =   response.ad_id 
  WHERE   sv.source_system_id =   $source_system_id
    AND   UPPER(response.action_type)    IN  ('OMNI_PURCHASE','OFFLINE_CONVERSION.PURCHASE')
) AS facebook
ON
	facebook.event_type_id   =   re.event_type_id 
	AND facebook.event_timestamp =   re.event_timestamp 
	AND facebook.stimulus_value_id = re.stimulus_value_id 
	AND facebook.source_system_id    =  re.source_system_id
WHEN NOT MATCHED THEN INSERT (
		stimulus_value_id,
		vendor_event_type,
		event_type_id,
		event_type,
		event_timestamp,
		event_timestamp_utc,
		event_timestamp_et,
		source_system_id,
		created_timestamp,
		created_process
      )     
VALUES (
		facebook.stimulus_value_id,
		facebook.vendor_event_type,
		facebook.event_type_id,
		facebook.event_type,
		facebook.event_timestamp,
		facebook.event_timestamp_utc,
		facebook.event_timestamp_et,
		facebook.source_system_id,
		facebook.created_timestamp,
		facebook.created_process
      )     ;




MERGE INTO
      bo.response_event AS RE
USING (
  SELECT DISTINCT
          sv.value_id AS stimulus_value_id,
          $vendor_event_type AS vendor_event_type,
          $event_type_id AS event_type_id ,
          $event_type AS event_type ,
          response.date_start,
          CONVERT_TIMEZONE('America/Los_Angeles','UTC',response.date_start) AS event_timestamp_utc,
          CONVERT_TIMEZONE('America/Los_Angeles','America/Detroit',response.date_start) AS event_timestamp_ET,
          $source_system_id AS source_system_id,
          current_timestamp AS created_timestamp,
          'Facebook_load_bo_engagement_20210407' AS created_process
  FROM
          raw.facebook_actions  response
  INNER JOIN  
          bo.stimulus_value   sv
      ON  
          sv.vendor_package_no    =   response.campaign_id
      AND sv.vendor_envelope_no   =   response.adset_id
      AND sv.vendor_value_no  =   response.ad_id 
  WHERE   sv.source_system_id =   $source_system_id
    AND   UPPER(response.action_type)    IN  ('OMNI_PURCHASE','OFFLINE_CONVERSION.PURCHASE')
) AS facebook
ON
	facebook.event_type_id   =   re.event_type_id 
	AND facebook.event_timestamp =   re.event_timestamp 
	AND facebook.stimulus_value_id = re.stimulus_value_id 
	AND facebook.source_system_id    =  re.source_system_id
WHEN NOT MATCHED THEN INSERT (
		stimulus_value_id,
		vendor_event_type,
		event_type_id,
		event_type,
		event_timestamp,
		event_timestamp_utc,
		event_timestamp_et,
		source_system_id,
		created_timestamp,
		created_process
      )     
VALUES (
		facebook.stimulus_value_id,
		facebook.vendor_event_type,
		facebook.event_type_id,
		facebook.event_type,
		facebook.event_timestamp,
		facebook.event_timestamp_utc,
		facebook.event_timestamp_et,
		facebook.source_system_id,
		facebook.created_timestamp,
		facebook.created_process
      )     ;





   
/*

Updated:
20210203    DG  We xref a given piece of content (e.g. CPC=3.08) with both the _IMPRESSION and _CLICK events.  This is just to be safe; it may be we don't need to do this. 

*/
   
--CPC


INSERT INTO bo.content_type(content_type,vendor_field_name,created_process,source_system_id) 
SELECT 'CPC','CPC','DG manual 20210201',$source_system_id 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE vendor_field_name = 'CPC' AND source_system_id = $source_system_id 
                 ); 

SET	content_type_id = (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'CPC' AND source_system_id = $source_system_id);    

MERGE INTO
    bo.content AS C
    USING (
   	WITH ad_window AS
                    (
                      SELECT 
                          adset_id
                            ,campaign_id
                            ,ad_id
                          ,MAX(date_start) as vendor_updated_timestamp
                          ,MIN(date_start) as value_start_timestamp
                      FROM   
                          raw.facebook_action_values
                      GROUP BY   
                          adset_id
                            ,campaign_id
                            ,ad_id
                    ) 
	SELECT DISTINCT 
        $content_type_id AS content_type_id,
        CAST(IFNULL(UPPER(actions.CPC), '0') as varchar) AS content_value,
        'CPC' AS vendor_field_name,
        $source_system_id AS source_system_id,
        current_timestamp AS created_timestamp,
        'Facebook_load_bo_engagement_20210407' AS created_process
	FROM
	    raw.facebook_action_values  actions

) AS facebook
ON
	UPPER(FACEBOOK.content_value) = C.CONTENT_VALUE
	AND FACEBOOK.content_type_id = $content_type_id
    )
WHEN NOT MATCHED THEN INSERT (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
VALUES (
        FACEBOOK.content_type_id,
        FACEBOOK.content_value,
        FACEBOOK.vendor_field_name,
        FACEBOOK.source_system_id,
        FACEBOOK.created_timestamp,
        FACEBOOK.created_process
);




MERGE INTO
    bo.content_response_xref AS CRX 
    USING (
	WITH ad_window AS
		(
		  SELECT 
			 adset_id
			   ,campaign_id
			   ,ad_id
			 ,MAX(date_start) as vendor_updated_timestamp
			 ,MIN(date_start) as value_start_timestamp
		  FROM   
			 raw.facebook_action_values
		  GROUP BY   
			 adset_id
			   ,campaign_id
			   ,ad_id
		) 
	SELECT
	    DISTINCT c.content_id,
	    r.response_event_id,
	    $source_system_id AS source_system_id,
	    current_timestamp,
	    'Facebook_load_bo_engagement_20210407'
	 FROM
	    bo.content c
	    INNER JOIN raw.facebook_action_values  actions 
	    ON UPPER(c.content_value) = UPPER(actions.CPC)
	    AND c.content_type_id      = $content_type_id 
	    INNER JOIN  bo.stimulus_value   sv
		   ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
		   AND sv.vendor_value_no  =   actions.ad_id
	    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id 
	    AND r.event_timestamp =   actions.date_start
	    AND sv.value_id =   r.stimulus_value_id
		INNER JOIN
			AD_WINDOW
		ON	ACTIONS.DATE_START	=	AD_WINDOW.VENDOR_UPDATED_TIMESTAMP
		AND	ACTIONS.AD_ID	=	AD_WINDOW.AD_ID
		AND	ACTIONS.ADSET_ID	=	AD_WINDOW.ADSET_ID
		AND	ACTIONS.CAMPAIGN_ID	=	AD_WINDOW.CAMPAIGN_ID
	    WHERE r.source_system_id =  $source_system_id 
	    AND r.source_system_id  =   sv.source_system_id
	    AND r.source_system_id  =   c.source_system_id
	) AS FACEBOOK
	ON 
		response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
		AND source_system_id    =   r.source_system_id

WHEN MATCHED THEN UPDATE 
	SET	
		crx.content_id	=
		CASE
			WHEN	CRX.CONTENT_ID <> facebook.content_id	THEN	facebook.content_id
		END
		,CRX.UPDATED_TIMESTAMP	=	
		CASE
			WHEN	CRX.CONTENT_ID <> facebook.content_id	THEN	CURRENT_TIMESTAMP
		END
		,CRX.UPDATED_PROCESS	=	
		CASE
			WHEN	CRX.CONTENT_ID <> facebook.content_id	THEN	'FB_CONTENT_UPDATE'
		END

WHEN NOT MATCHED THEN INSERT (
	   content_id,
	   response_event_id,
	   source_system_id,
	   created_timestamp,
	   created_process
    )
VALUES (
	   FACEBOOK.content_id,
	   FACEBOOK.response_event_id,
	   FACEBOOK.source_system_id,
	   FACEBOOK.created_timestamp,
	   FACEBOOK.created_process
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_actions  actions 
    ON UPPER(c.content_value) = UPPER(actions.CPC)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id 
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id 
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
    );              
  
--SOCIAL_SPEND
INSERT INTO bo.content_type(content_type,vendor_field_name,created_process,source_system_id) 
SELECT 'SOCIAL_SPEND','SOCIAL_SPEND','DG manual 20210201',$source_system_id 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE vendor_field_name = 'SOCIAL_SPEND' AND source_system_id = $source_system_id 
                 ); 

SET content_type_id = (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'SOCIAL_SPEND' AND source_system_id = $source_system_id)    ;


INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.SOCIAL_SPEND), '0')
        ,'SOCIAL_SPEND'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_action_values  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.SOCIAL_SPEND), '0') as varchar)
            AND content_type_id = $content_type_id 
    );

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.SOCIAL_SPEND), '0')
        ,'SOCIAL_SPEND'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_actions  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.SOCIAL_SPEND), '0') as varchar)
            AND content_type_id = $content_type_id 
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_action_values  actions 
    ON UPPER(c.content_value) = UPPER(actions.SOCIAL_SPEND)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_actions  actions 
    ON UPPER(c.content_value) = UPPER(actions.SOCIAL_SPEND)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
    );                  
    
--CPM
INSERT INTO bo.content_type(content_type,vendor_field_name,created_process,source_system_id) 
SELECT 'CPM','CPM','DG manual 20210201',$source_system_id 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE vendor_field_name = 'CPM' AND source_system_id = $source_system_id 
                 ); 

SET content_type_id = (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'CPM' AND source_system_id = $source_system_id);    

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.CPM), '0')
        ,'CPM'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_action_values  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.CPM), '0') as varchar)
            AND content_type_id = $content_type_id 
    );

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.CPM), '0')
        ,'CPM'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_actions  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.CPM), '0') as varchar)
            AND content_type_id = $content_type_id 
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_action_values  actions 
    ON UPPER(c.content_value) = UPPER(actions.CPM)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_actions  actions 
    ON UPPER(c.content_value) = UPPER(actions.CPM)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
    );    
    
--CLICKS
INSERT INTO bo.content_type(content_type,vendor_field_name,created_process,source_system_id) 
SELECT 'CLICKS','CLICKS','DG manual 20210201',$source_system_id 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE vendor_field_name = 'CLICKS' AND source_system_id = $source_system_id 
                 ); 

SET content_type_id = (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'CLICKS' AND source_system_id = $source_system_id)    ;

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.CLICKS), '0')
        ,'CLICKS'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_action_values  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.CLICKS), '0') as varchar)
            AND content_type_id = $content_type_id 
    );

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.CLICKS), '0')
        ,'CLICKS'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_actions  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.CLICKS), '0') as varchar)
            AND content_type_id = $content_type_id 
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_action_values  actions 
    ON UPPER(c.content_value) = UPPER(actions.CLICKS)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_actions  actions 
    ON UPPER(c.content_value) = UPPER(actions.CLICKS)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
    );        
    
--IMPRESSIONS
INSERT INTO bo.content_type(content_type,vendor_field_name,created_process,source_system_id) 
SELECT 'IMPRESSIONS','IMPRESSIONS','DG manual 20210201',$source_system_id 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE vendor_field_name = 'IMPRESSIONS' AND source_system_id = $source_system_id 
                 ); 

SET content_type_id = (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'IMPRESSIONS' AND source_system_id = $source_system_id)    ;

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.IMPRESSIONS), '0')
        ,'IMPRESSIONS'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_action_values  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.IMPRESSIONS), '0') as varchar)
            AND content_type_id = $content_type_id 
    );

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.IMPRESSIONS), '0')
        ,'IMPRESSIONS'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_actions  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.IMPRESSIONS), '0') as varchar)
            AND content_type_id = $content_type_id 
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_action_values  actions 
    ON UPPER(c.content_value) = UPPER(actions.IMPRESSIONS)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_actions  actions 
    ON UPPER(c.content_value) = UPPER(actions.IMPRESSIONS)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
    );            

--CTR
INSERT INTO bo.content_type(content_type,vendor_field_name,created_process,source_system_id) 
SELECT 'CTR','CTR','DG manual 20210201',$source_system_id 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE vendor_field_name = 'CTR' AND source_system_id = $source_system_id 
                 ); 

SET content_type_id = (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'CTR' AND source_system_id = $source_system_id)    ;

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.CTR), '0')
        ,'CTR'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_action_values  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.CTR), '0') as varchar)
            AND content_type_id = $content_type_id 
    );

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.CTR), '0')
        ,'CTR'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_actions  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.CTR), '0') as varchar)
            AND content_type_id = $content_type_id 
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_action_values  actions 
    ON UPPER(c.content_value) = UPPER(actions.CTR)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_actions  actions 
    ON UPPER(c.content_value) = UPPER(actions.CTR)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
    );            
    
--SPEND
INSERT INTO bo.content_type(content_type,vendor_field_name,created_process,source_system_id) 
SELECT 'SPEND','SPEND','DG manual 20210201',$source_system_id 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE vendor_field_name = 'SPEND' AND source_system_id = $source_system_id 
                 ); 

SET content_type_id = (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'SPEND' AND source_system_id = $source_system_id)   ; 

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.SPEND), '0')
        ,'SPEND'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_action_values  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.SPEND), '0') as varchar)
            AND content_type_id = $content_type_id 
    );

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.SPEND), '0')
        ,'SPEND'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_actions  actions
WHERE
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.SPEND), '0') as varchar)
            AND content_type_id = $content_type_id 
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_action_values  actions 
    ON UPPER(c.content_value) = UPPER(actions.SPEND)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_actions  actions 
    ON UPPER(c.content_value) = UPPER(actions.SPEND)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
    );            
        
--VENDOR_REVENUE
INSERT INTO bo.content_type(content_type,vendor_field_name,created_process,source_system_id) 
SELECT 'VENDOR_REVENUE','ACTION_VALUE','DG manual 20210201',$source_system_id 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE vendor_field_name = 'ACTION_VALUE' AND source_system_id = $source_system_id 
                 ); 

SET content_type_id = (SELECT content_type_id FROM bo.content_type WHERE vendor_field_name = 'ACTION_VALUE' AND content_type = 'VENDOR_REVENUE' AND source_system_id = $source_system_id)   ; 

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.ACTION_VALUE), '0')
        ,'ACTION_VALUE'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'
FROM
    raw.facebook_action_values  actions
WHERE
    UPPER(actions.action_type)    IN  ('OMNI_PURCHASE') --,'OFFLINE_CONVERSION.PURCHASE')
AND
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.ACTION_VALUE), '0') as varchar)
            AND content_type_id = $content_type_id 
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_action_values  actions 
    ON UPPER(c.content_value) = UPPER(actions.ACTION_VALUE)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND UPPER(actions.action_type)    IN  ('OMNI_PURCHASE')
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
    );              


--TRANSACTION_COUNT
INSERT INTO bo.content_type(content_type,vendor_field_name,created_process,source_system_id) 
SELECT 'TRANSACTION_COUNT','ACTION_VALUE','DG manual 20210201',$source_system_id 
WHERE NOT EXISTS (
    SELECT content_type FROM bo.content_type WHERE content_type = 'TRANSACTION_COUNT' AND source_system_id = $source_system_id 
                 ); 

SET content_type_id = (SELECT content_type_id FROM bo.content_type WHERE content_type = 'TRANSACTION_COUNT' AND source_system_id = $source_system_id)   ; 

INSERT INTO
    bo.content (
        content_type_id,
        content_value,
        vendor_field_name,
        source_system_id,
        created_timestamp,
        created_process
    )
SELECT DISTINCT 
        $content_type_id 
        ,IFNULL(UPPER(actions.ACTIONS_VALUE), '0')
        ,'ACTION_VALUE'
        ,$source_system_id
        ,current_timestamp
        ,'Facebook_load_bo_engagement_20210407'   
FROM
    raw.facebook_actions  actions 
WHERE
    UPPER(actions.actions_action_type)    IN  ('OMNI_PURCHASE')--,'OFFLINE_CONVERSION.PURCHASE')
AND
    NOT EXISTS (
        SELECT
            DISTINCT content_type_id,
            content_value
        FROM
            bo.content
        WHERE
            UPPER(content_value) = CAST(IFNULL(UPPER(actions.ACTIONS_VALUE), '0') as varchar)
            AND content_type_id = $content_type_id 
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
    $source_system_id,
    current_timestamp,
    'Facebook_load_bo_engagement_20210407'
 FROM
    bo.content c
    INNER JOIN raw.facebook_actions  actions 
    ON UPPER(c.content_value) = UPPER(actions.actions_action_type)
    AND c.content_type_id      = $content_type_id 
    INNER JOIN  bo.stimulus_value   sv
        ON  UPPER(sv.value_name)   =   UPPER(actions.ad_name)
        AND sv.vendor_value_no  =   actions.ad_id
    INNER JOIN bo.response_event r ON r.event_type_id = $event_type_id
    AND r.event_timestamp =   actions.date_start
    AND sv.value_id =   r.stimulus_value_id
    WHERE r.source_system_id =  $source_system_id
    AND UPPER(actions.actions_action_type)    IN  ('OMNI_PURCHASE')
    AND r.source_system_id  =   sv.source_system_id
    AND r.source_system_id  =   c.source_system_id
    AND NOT EXISTS (
        SELECT
            content_id,
            response_event_id
        FROM
            bo.content_response_xref
        WHERE
            content_id = c.content_id
            AND response_event_id = r.response_event_id --AND click.eventdate =   r.event_timestamp
            AND source_system_id    =   r.source_system_id
    );              
