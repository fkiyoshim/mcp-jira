-- Atualiza somente FIDs da OT 12771 nas oito camadas VWS; COMMIT apos validacao.
set serveroutput on size unlimited
set autocommit off
whenever oserror exit failure rollback
whenever sqlerror exit sql.sqlcode rollback

declare
  v_layers sys.odcivarchar2list := sys.odcivarchar2list(
    'VWS_POLE','VWS_MANHOLE','VWS_OPT_CABLE','VWS_ROUTE',
    'VWS_DUCT','VWS_OPT_COTO','VWS_OTH_BLG','VWS_OP_TERMINAL'
  );
  v_uws varchar2(128);
  v_fids varchar2(32767);
  v_source_count number;
  v_cache_count number;
  v_total number := 0;
begin
  for i in 1..v_layers.count loop
    v_uws:=replace(v_layers(i),'VWS_','UWS_');
    execute immediate
      'select listagg(to_char(u.fid),'','') within group(order by u.fid),count(*) '||
      'from '||v_uws||' u join feature f on f.id=u.fid where f.version_id=:v'
      into v_fids,v_source_count using 12771;
    if v_source_count>0 then
      simbcachetools.refresh_vws_rows(v_layers(i),v_fids);
    end if;
    execute immediate
      'select count(*) from '||v_layers(i)||' v join feature f on f.id=v.fid '||
      'where f.version_id=:x'
      into v_cache_count using 12771;
    dbms_output.put_line(v_layers(i)||': UWS='||v_source_count||', VWS='||v_cache_count);
    if v_cache_count<>v_source_count then
      raise_application_error(-20101,'Cache incompleto em '||v_layers(i));
    end if;
    v_total:=v_total+v_cache_count;
  end loop;
  if v_total<>37 then raise_application_error(-20102,'Total de simbolos inesperado: '||v_total); end if;
  dbms_output.put_line('Total de simbolos validados='||v_total);
  commit;
  dbms_output.put_line('COMMIT concluido.');
exception when others then
  dbms_output.put_line('ERRO '||sqlcode||': '||sqlerrm);
  rollback;
  raise;
end;
/
exit rollback
