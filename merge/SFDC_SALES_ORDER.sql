
INSERT INTO
	bo.sales_order_header (
		source_system_id,
		brand_party_id,
		customer_party_id,
		store_party_id,
		bill_to_party_id,
		ship_to_party_id,
		order_dealer_party_id,
		brand_no,
		brand_no_type,
		sales_order_no,
		sales_order_no_type,
		sales_order_reference_no,
		sfdc_order_no,
		sfdc_order_no_type,
		upstream_sales_order_no,
		upstream_sales_order_no_type,
		sfdc_table_no,
		sfcc_order_no,
		salesforce_order_no,
		purchase_order_no,
		netsuite_order_no,
		imarc_order_no,
		netsuite_salesorder_no,
		customer_no,
		customer_no_type,
		erp_customer_no --erp_customer_code__c
,
		erp_customer_no_type,
		bill_to_customer_no,
		bill_to_customer_no_type,
		ship_to_customer_no,
		ship_to_customer_no_type,
		netsuite_customer_no,
		order_dealer_account_no,
		sales_rep_no,
		sales_rep_no_type,
		store_location_no,
		store_location_no_type,
		netsuite_sales_location_no,
		order_dealer_no,
		quote_no,
		quote_no_type,
		quote_transaction_no,
		payment_terms_no,
		payment_terms_no_type,
		order_line_count,
		item_count,
		sale_status,
		sales_order_status,
		sfdc_status_code,
		netsuite_sales_order_status,
		netsuite_status,
		email_transaction_no,
		shipping_method_no,
		shipping_method_no_type,
		parcel_shipping_method_no,
		parcel_shipping_method_no_type,
		netsuite_shipping_method_no,
		shipping_zone_code,
		sales_channel,
		customer_source,
		applied_promotion_no,
		promotion_no,
		promotion_no_type,
		discount_percent,
		opportunity_project_name,
		netsuite_account_source_no,
		order_currency_code,
		after_discount_amount,
		custom_amount,
		custom_amount_name,
		discount_amount,
		IMARC_discount_amount,
		margin_amount,
		merchandise_amount,
		net_retail_amount,
		outstanding_payment_amount,
		payment_amount,
		retail_amount,
		sales_order_amount,
		tax_total_amount,
		valid_order_payment_amount,
		shipping_amount,
		tax_amount,
		bundled_est_ship_timestamp,
		est_delivery_max_timestamp,
		est_delivery_min_timestamp,
		est_ship_timestamp,
		payment_request_timestamp,
		sfdc_effective_timestamp,
		sfdc_activated_timestamp,
		sfdc_created_timestamp,
		sfdc_last_modified_timestamp,
		est_delivery_timestamp,
		salesorder_placed_timestamp,
		quote_expiration_timestamp,
		netsuite_error_code,
		resale_template_no,
		sales_order_blob1,
		sales_order_blob1_name,
		sales_order_blob2,
		sales_order_blob2_name,
		created_timestamp,
		updated_timestamp,
		created_process,
		updated_process
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
	) --source_system_id	
,
	0 --brand_party_id	
,
	p.party_id --customer_party_id	
,
	0 --store_party_id	
,
	0 --bill_to_party_id	
,
	0 --ship_to_party_id	
,
	0 --order_dealer_party_id	
,
	'0' --brand_no		
,
	'0' --brand_no_type		
,
	o.ordernumber --sales_order_no		
,
	'ordernumber' --sales_order_no_type		
,
	o.orderreferencenumber --sales_order_reference_no   		
,
	o.order_id__c --sfdc_order_no		
,
	'order_id__c' --sfdc_order_no_type		
,
	o.originalorderid --upstream_sales_order_no		
,
	'originalorderid' --upstream_sales_order_no_type		
,
	o.id --sfdc_table_no		
,
	o.ml_order__c --sfcc_order_no		
,
	o.SALESFORCE_ORDER_ID__C --sfdc_order_no		
,
	o.ponumber --purchase_order_no		
,
	0 --o.NSINT_order_number__C   --netsuite_order_no		
,
	o.imarc_ordercode__c --imarc_order_no
,
	o.NSINT_SALESORDER_ID__C --netsuite_salesorder_no	
,
	o.accountid --customer_no		
,
	'ACCOUNTID' --customer_no_type	
,
	o.erp_customer_code__c --erp_customer_no		--erp_customer_code__c
,
	'erp_customer_code__c' --erp_customer_no_type		
,
	o.BILLTOCONTACTID --bill_to_customer_no		
,
	'BILLTOCONTACTID' --bill_to_customer_no_type		
,
	o.SHIPTOCONTACTID --ship_to_customer_no		
,
	'SHIPTOCONTACTID' --ship_to_customer_no_type		
,
	o.nsint_customer_id__c --netsuite_customer_no		
,
	o.order_dealer_contact__c --order_dealer_account_no		
,
	o.sales_rep_email__c --sales_rep_no		
,
	'sales_rep_email__c' --sales_rep_no_type		
,
	o.sales_location__c --store_location_no		
,
	'sales_location__c' --store_location_no_type		
,
	'0' --netsuite_sales_location_no		
,
	o.order_dealer_number__c --order_dealer_no    
,
	o.quoteid --quote_no
,
	'quoteid',
	o.QUOTE_TRANSACTION_NUMBER__C --quote_transaction_no		
,
	o.pricebook2id --payment_terms_no		
,
	'pricebook2id' --payment_terms_no_type		
,
	o.number_of_order_lines__c --order_line_count		
,
	o.NUMBER_OF_ITEMS__C --item_count		
,
	o.status --sale_status		
,
	o.order_status__c --sales_order_status		
,
	o.statuscode --sfdc_status_code		
,
	o.nsint_salesorder_status__c --netsuite_sales_order_status		
,
	o.netsuite_status__c --netsuite_status		
,
	o.EMAIL_TRANSACTION_ID__C --email_transaction_no		
,
	o.shipping_method__c --shipping_method_no		
,
	'shipping_method__c' --shipping_method_no_type		
,
	o.parcel_shipping_method__c --parcel_shipping_method_no		
,
	'parcel_shipping_method__c' --parcel_shipping_method_no_type		
,
	'0' --netsuite_shipping_method_no		
,
	o.shipping_zone__c --shipping_zone_code		
,
	o.sales_channel__c --sales_channel		
,
	o.source__c --customer_source		
,
	o.promotion_applied__c --applied_promotion_no		
,
	o.promotion_code__c --promotion_no		
,
	o.promotion_name__c --promotion_no_type		
,
	o.discount_percent__c --discount_percent
,
	o.OPPORTUNITY_PROJECT_TYPE__C --opportunity_project_name		
,
	'0' --netsuite_account_source_no		
,
	o.currencyisocode --order_currency_code		
,
	o.total_after_discount__c --after_discount_amount	
,
	0 --custom_amount	
,
	'0' --custom_amount_name		
,
	o.discount_total__c --discount_amount	
,
	o.imarc_discount__c --IMARC_discount_amount	
,
	o.margin__c --margin_amount	
,
	o.merchandise_total__c --merchandise_amount	
,
	o.net_retail__c --net_retail_amount	
,
	o.payment_needed__c --outstanding_payment_amount	
,
	o.order_payment_total__c --payment_amount	
,
	o.retail_total__c --retail_amount	
,
	o.totalamount --sales_order_amount.  might also be order_total__c
,
	o.total_tax__c --tax_total_amount	
,
	o.VALID_ORDER_PAYMENT_TOTAL__C --valid_order_payment_amount	
,
	o.shipping_total__c --shipping_amount	
,
	o.total_tax__c --tax_amount	
,
	o.bundled_estimated_ship_date__c --bundled_est_ship_timestamp				
,
	o.ESTIMATED_DELIVERY_WINDOW_MAX__C --est_delivery_max_timestamp				
,
	o.ESTIMATED_DELIVERY_WINDOW_MIN__C --est_delivery_min_timestamp				
,
	o.estimated_ship_date__c --est_ship_timestamp				
,
	o.PAYMENT_EMAIL_SENT_DATE__C --payment_request_timestamp				
,
	o.effectivedate --sfdc_effective_timestamp				
,
	o.activateddate --sfdc_activated_timestamp				
,
	o.createddate --sfdc_created_timestamp				
,
	o.lastmodifieddate --sfdc_last_modified_timestamp				
,
	o.estimated_delivery_date__c --est_delivery_timestamp				
,
	o.PLACED_DATE__C --salesorder_placed_timestamp				
,
	o.quote_expiration_date__c --quote_expiration_timestamp				
,
	o.nsint_salesorder_error__c --netsuite_error_code	
,
	o.RESALE_TEMPLATE_TO_USE__C --resale_template_no		
,
	o.order_details__c --sales_order_blob1	
,
	'order_details__c' --sales_order_blob1_name	
,
	o.order_totals__c --sales_order_blob2	
,
	'order_totals__c' --sales_order_blob2_name	
,
	current_timestamp --created_timestamp		
,
	current_timestamp --updated_timestamp		
,
	'DG_20201105_SFDC_order_manual' --created_process	
,
	'0' --updated_process	
FROM
	raw.sfdc_order o
	INNER JOIN bo.party p ON o.accountid = p.party_identifier
	AND p.party_identifier_type = 'ACCOUNTID'
	AND p.source_system_id = (
		SELECT
			source_system_id
		FROM
			bo.source_system
		WHERE
			source_system_name = 'SFDC_order'
			AND source_system_status = 'ACTIVE'
	)
WHERE
	NOT EXISTS (
		SELECT
			sfdc_table_no
		FROM
			bo.sales_order_header
		WHERE
			o.id = sfdc_table_no
	);
