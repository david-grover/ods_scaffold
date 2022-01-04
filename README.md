# ods_scaffold

ODS scaffold contains SQL scripts to support the load of an Operational Data Store or Business-focused semantic layer.  There are three primary folders:

1. table:  This folder contains table-creation scripts for domains.  Current domains covered include:
    1. SALES_ORDER_X for orders of various kinds.
    2. TRANSACTION for transactions of various kinds, including orders.
    3. PRODUCT for storing, versioning and analyzing product catalogs of various kinds.
    4. PARTY for storing agents, their attributes and relationships.
    5. ENGAGEMENT for managing inbound and outbound communications with customers and prospects.
    6. DATASET to facilitate record versioning.
2. merge:  This folder contains MERGE statements of various quality for several brands of source data, into various domains.  
  These MERGE statements are not warranted.  They assume a fixed source schema, usually in RAW, and will need to be adapted to local circumstances.
3. function:  This folder contains functions that may be of use in one or more layers.
