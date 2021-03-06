---jsonb_build_object. jsonb_agg use case demo.
/*
jsonb_build_object ( VARIADIC "any" ) → jsonb
Builds a JSON object out of a variadic argument list.
By convention, the argument list consists of alternating keys and values.
Key arguments are coerced to text; value arguments are converted as per to_json or to_jsonb.
*/
---set up the tbl4 table.
begin;
create temp table tbl4(tbl4_id int GENERATED by default AS IDENTITY, col_a text, col_b text, col_c text);
insert into tbl4(col_a, col_b, col_c) values('a', 'string1','stringa');
insert into tbl4(col_a, col_b, col_c) values('b', 'string2','stringa2');
insert into tbl4(col_a, col_b, col_c) values('a', 'string3','stringa3');
insert into tbl4(col_a, col_b, col_c) values('b', 'string4','stringa4');
insert into tbl4(col_a, col_b, col_c) values('a', 'string5','stringa5');
commit;
----------------------------------------------
--jsonb_agg: PCollects all the input values, including nulls, into a JSONB array.
    --Values are converted to JSON as per to_json or to_jsonb.
SELECT col_a, jsonb_agg(
    jsonb_build_object('col_b', col_b
                   , 'col_c' , col_c) ) AS jsonbagg
FROM   tbl4
GROUP  BY col_a;
---------------------------------------------
--sort objects in an array inside a jsonb value by a property of the object.
with s1 as(
SELECT jsonb_agg(
    jsonb_build_object('col_b', col_b
                   , 'col_c' , col_c) ) AS jsonbagg1
FROM   tbl4 group by col_a), s2 as (select jsonb_array_elements(s1.jsonbagg1) as elem from s1)
SELECT jsonb_agg(s2.elem ORDER BY (s2.elem->>'col_c')::text) from s2;