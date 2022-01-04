create or replace function nonzero_field(field_name varchar)
  returns varchar
  as
  $$
      CASE
        WHEN    LEN(field_name)   =   0   THEN    '0'
        ELSE    nonzero_field(field_name)
        END 
  $$
  ;
