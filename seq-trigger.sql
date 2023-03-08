set serveroutput on
declare 
 max_num_pk number(10);
  sql_stmt       varchar2 ( 1000 ) := null;
  seq_name varchar2(100) := null;
  sql_trig_stmt varchar2(1000) :=null;
  trig_name varchar2(100) :=null;
cursor seq_cursor is 
         select sequence_name from user_sequences;
cursor pk_cursor is 
        SELECT distinct CONS.TABLE_NAME, cols.column_name
        FROM user_constraints cons ,user_cons_columns cols,  user_tab_columns
        WHERE cons.constraint_type = 'P'
        AND cons.constraint_name = cols.constraint_name
        and  cols.column_name = user_tab_columns.column_name
        and  user_tab_columns.data_type = 'NUMBER'
        and cons.table_name in(select OBJECT_NAME from user_objects where OBJECT_TYPE = 'TABLE');
cursor trig_table is 
      select TRIGGER_NAME,TABLE_NAME  from user_triggers
      where BASE_OBJECT_TYPE ='TABLE'
      and TRIGGERING_EVENT = 'INSERT';

begin


for rec_seq in pk_cursor loop

for drop_seq in seq_cursor loop
  if drop_seq.sequence_name LIKE rec_seq.table_name||'%'  then 
  execute immediate 'DROP SEQUENCE '||drop_seq.sequence_name;
   end if;
end loop ;
-------------------------------------------------------------------------------------------------

sql_stmt := 'SELECT  max(nvl('||rec_seq.column_name||',0)) +1 FROM ' ||  rec_seq.table_name  ;
execute immediate sql_stmt into max_num_pk;
seq_name :=rec_seq.table_name||'_SEQ';

execute immediate '
CREATE SEQUENCE '||seq_name||'
START WITH '|| max_num_pk||'
MAXVALUE 999999 '
;

trig_name := rec_seq.table_name||'_TRIG';
execute immediate '
CREATE OR REPLACE TRIGGER '||trig_name||'
BEFORE INSERT
ON  '||rec_seq.table_name ||'
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
'||
  ':new.'|| rec_seq.column_name  ||':= '||seq_name||'.nextval'||';
END;';

end loop;
   
end;


insert into locations(LOCATION_ID    ,     
STREET_ADDRESS    ,         
POSTAL_CODE    ,          
CITY    ,                
COUNTRY_ID             ) values (4000,'el-haram','244-0','Cairo','US');
