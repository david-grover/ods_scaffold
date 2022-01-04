
-- ACCOUNT_EMAIL__C
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
			source_system_name = 'SFDC_order'
			AND source_system_status = 'ACTIVE'
	),
(
		SELECT
			address_type_id
		FROM
			bo.address_type
		WHERE
			address_type = 'SFDC_order.account_email'
	),
	IFNULL(UPPER(o.ACCOUNT_EMAIL__C), '0'),
	'DG_20201105_SFDC_order_manual'
FROM
	raw.sfdc_order o
WHERE
	NOT EXISTS (
		SELECT
			address_string
		FROM
			bo.address
			INNER JOIN bo.address_type ON bo.address.address_type_id = bo.address_type.address_type_id
			AND bo.address_type.address_type = 'SFDC_order.account_email'
		WHERE
			UPPER(address_string) = IFNULL(UPPER(o.ACCOUNT_EMAIL__C), '0')
            AND bo.address.source_system_id    =   (SELECT source_system_id	FROM bo.source_system WHERE	source_system_name = 'SFDC_order' AND source_system_status = 'ACTIVE')
	);

--  customer
INSERT INTO
	bo.party (
		PARTY_STRING,
		PARTY_IDENTIFIER,
		PARTY_IDENTIFIER_TYPE,
		PARTY_NAME,
		source_system_id,
		CREATED_TIMESTAMP,
		CREATED_PROCESS
	)
SELECT
	DISTINCT UPPER(o.contact_name__c),
	o.accountid,
	'ACCOUNTID',
	UPPER(o.contact_name__c),
(
		SELECT
			source_system_id
		FROM
			bo.source_system
		WHERE
			source_system_name = 'SFDC_order'
			AND source_system_status = 'ACTIVE'
	),
	current_timestamp,
	'DG_20201105_SFDC_order_manual'
FROM
	raw.sfdc_order o
WHERE
	o.accountid IS NOT NULL --  this is an easy case not to worry about right now, but soon (20201Q1?) we'll need to deal with records w/o accountids.  The cardinality of that might be small too, about 6k records it looks like.
	AND NOT EXISTS (
		SELECT
			party_identifier,
			party_string
		FROM
			bo.party
		WHERE
			o.accountid = party_identifier
			AND party_identifier_type = 'ACCOUNTID'
			AND source_system_id = (
				SELECT
					source_system_id
				FROM
					bo.source_system
				WHERE
					source_system_name = 'SFDC_order'
					AND source_system_status = 'ACTIVE'
			)
	);

INSERT INTO
	bo.ADDRESS_PARTY_XREF (
		ADDRESS_ID,
		PARTY_ID,
		XREF_STATUS,
		CREATED_TIMESTAMP,
		CREATED_PROCESS
	)
SELECT
	DISTINCT a.address_id,
	p.party_id,
	'ACTIVE',
	current_timestamp,
	'DG_20201105_SFDC_order_manual'
FROM
	RAW.SFDC_order o
	INNER JOIN bo.address a ON UPPER(o.contact_email__c) = UPPER(a.address_string)
	INNER JOIN bo.party p ON p.party_identifier = o.accountid
	AND p.party_identifier_type = 'ACCOUNTID'
	AND p.source_system_id = a.source_system_id
WHERE 	a.address_type_id = (SELECT	address_type_id	FROM	bo.address_type	WHERE address_type = 'SFDC_order.account_email')
    AND a.source_system_id  =   (SELECT source_system_id	FROM bo.source_system WHERE	source_system_name = 'SFDC_order' AND source_system_status = 'ACTIVE')
    AND NOT EXISTS (
		SELECT
			address_id,
			party_id,
			xref_status
		FROM
			bo.address_party_xref
		WHERE
			party_id = p.party_id
			AND a.address_id = address_id
			AND xref_status = 'ACTIVE'
	);