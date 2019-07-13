begin
for i in (select * from tabs) loop
execute immediate ('drop table ' || i.table_name || ' cascade constraints');
end loop;
end;
/