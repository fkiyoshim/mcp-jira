-- Copia validada dos objetos existentes, COM COMMIT. Executar em sessao nova e exclusiva.
set serveroutput on size unlimited
set autocommit off
whenever oserror exit failure rollback
whenever sqlerror exit sql.sqlcode rollback

declare
  type num_map is table of number index by varchar2(100);
  type bind_map is table of number index by pls_integer;
  type str_map is table of varchar2(128) index by varchar2(260);
  v_ids num_map;
  v_logical_ids num_map;
  v_binds bind_map;
  v_fk_cache str_map;
  v_tables sys.odcivarchar2list := sys.odcivarchar2list(
    'CR_ACC_POINT','ACC_POINT','CR_SITE','CABLE_SEG','CONDUIT','CONDUIT_FORM',
    'BORE','CR_EQUIPMENT','CR_TRANSMISSION_MEAN','CR_LOGICAL_CABLE',
    'CR_EQ_UNIT','CR_TRANSMISSION_UNIT','IP_NE','NE','IP_NE_PORT',
    'IP_NE_TR_MEAN','IP_NE_TR_UNIT','IP_RACK','NE_MODULE','NE_TRAY',
    'PORT','MANHOLE','POLE','OTHER','OP_TERMINAL','ROUTE','NET_LINE',
    'FIBER','OP_CABLE_SPAN','FEATURE','CABLE_SEG_F','CONDUIT_F',
    'MANHOLE_F','OP_TERMINAL_F','OTHER_F','POLE_F','ROUTE_F','SUB_FEATURE'
  );
  v_old_project constant number := 12128;
  v_new_project number;
  v_new_feature number;
  v_global_next number := 0;
  v_new_id number;
  v_old_value number;
  v_mapped_value number;
  v_seq_exists number;
  v_fk_parent varchar2(128);
  v_old_table varchar2(128);
  v_cols varchar2(32767);
  v_expr varchar2(32767);
  v_sql varchar2(32767);
  v_piece varchar2(1000);
  v_bind_count pls_integer;
  v_cursor integer;
  v_dummy integer;
  v_dx number;
  v_dy number;
  v_count number;
  v_total number := 0;
  v_skipped_version number := 0;
  v_skipped_projected number := 0;
  v_skipped_connection number := 0;
  v_project cr_project%rowtype;
  v_project_f cr_project_f%rowtype;
  v_po cr_projected_object%rowtype;
  v_spatial_count number := 0;
  v_bad_geom number;

  function k(p_table varchar2, p_id number) return varchar2 is
  begin
    return p_table || ':' || to_char(p_id, 'FM999999999999999999999999999999');
  end;

  function selected(p_table varchar2) return boolean is
  begin
    for i in 1..v_tables.count loop
      if v_tables(i) = p_table then return true; end if;
    end loop;
    return false;
  end;

  function mapped(p_table varchar2, p_old number) return number is
  begin
    if p_old is null then return null; end if;
    if v_ids.exists(k(p_table,p_old)) then return v_ids(k(p_table,p_old)); end if;
    return p_old;
  end;

  function logical_mapped(p_old number) return number is
  begin
    if p_old is null then return null; end if;
    if not v_logical_ids.exists(k('LOGICAL',p_old)) then
      raise_application_error(-20011,'Referencia logica sem mapa: '||p_old);
    end if;
    return v_logical_ids(k('LOGICAL',p_old));
  end;

  function soft_parent(p_table varchar2, p_column varchar2) return varchar2 is
  begin
    if p_column='OBJ_REF_ID' and p_table in
       ('CR_EQUIPMENT','CR_EQ_UNIT','CR_TRANSMISSION_MEAN',
        'CR_TRANSMISSION_UNIT','CR_LOGICAL_CABLE') then return '@POLY'; end if;
    if p_table='CR_EQUIPMENT' and p_column='EQ_HOLDER_ID' then return 'CR_ACC_POINT'; end if;
    if p_table='CR_LOGICAL_CABLE' and p_column='CR_EQUIPMENT_ID' then return 'CR_EQUIPMENT'; end if;
    if p_table='CR_LOGICAL_CABLE' and p_column='CR_LOGICAL_CABLE_ID_ID' then return 'CR_LOGICAL_CABLE'; end if;
    if p_table in ('IP_NE','IP_NE_TR_MEAN') and p_column='CR_SITE_ID' then return 'CR_SITE'; end if;
    if p_table='IP_NE_PORT' and p_column='IP_NE_ID' then return 'IP_NE'; end if;
    if p_table='IP_NE_TR_MEAN' and p_column='COMMONS_REF_ID' then return 'CR_TRANSMISSION_MEAN'; end if;
    if p_table='IP_NE_TR_UNIT' and p_column='COMMONS_REF_ID' then return 'CR_TRANSMISSION_UNIT'; end if;
    if p_table='IP_NE_TR_UNIT' and p_column='IP_NE_TRANSMISSION_MEAN_ID' then return 'IP_NE_TR_MEAN'; end if;
    if p_table='NE_MODULE' and p_column='IP_RACK_ID' then return 'IP_RACK'; end if;
    if p_table='NET_LINE' and p_column='NET_LINE_ID' then return '@POLY'; end if;
    if p_table='PORT' and p_column='TRAY_ID' then return 'NE_TRAY'; end if;
    if p_table='NE_TRAY' and p_column='NE_MODULE_ID' then return 'NE_MODULE'; end if;
    return null;
  end;

  function poly_mapped(p_old number) return number is
    v_found number := 0;
    v_result number;
    v_source_count number := 0;
  begin
    if p_old is null then return null; end if;
    for x in (select distinct table_name from version_content
              where project_version_id=v_old_project and table_id=p_old) loop
      v_source_count:=v_source_count+1;
      if v_ids.exists(k(x.table_name,p_old)) then
        v_found:=v_found+1;
        v_result:=v_ids(k(x.table_name,p_old));
      end if;
    end loop;
    if v_found=1 then return v_result; end if;
    if v_found>1 then raise_application_error(-20019,'Referencia polimorfica ambigua: '||p_old); end if;
    if v_source_count>0 then return null; end if;
    return p_old;
  end;

  procedure add_bind(p_value number, p_column varchar2) is
  begin
    v_bind_count := v_bind_count+1;
    v_binds(v_bind_count) := p_value;
    v_piece := ':B'||v_bind_count;
  end;

begin
  select count(*) into v_count from cr_project where code='OT_AUTO_TST';
  if v_count<>0 then raise_application_error(-20001,'OT_AUTO_TST ja existe'); end if;
  select * into v_project from cr_project where id=v_old_project and code='WO-TRANSFER-04';
  select * into v_project_f from cr_project_f where cr_project_id=v_old_project;
  v_dx := -38.44606614 - sdo_geom.sdo_centroid(v_project_f.geometry,0.00000005).sdo_point.x;
  v_dy := -12.98624034 - sdo_geom.sdo_centroid(v_project_f.geometry,0.00000005).sdo_point.y;

  -- Bloqueia apenas as tabelas sem sequencia propria enquanto usa MAX(ID)+N.
  -- NOWAIT evita esperar ou interferir silenciosamente em outra carga.
  for i in 1..v_tables.count loop
    select count(*) into v_seq_exists from user_sequences
      where sequence_name='SEQ_'||v_tables(i);
    if v_seq_exists=0 and v_tables(i) not like '%\_F' escape '\' then
      execute immediate 'lock table '||v_tables(i)||' in exclusive mode nowait';
    end if;
  end loop;

  -- Reserva IDs de fallback acima de todos os IDs das tabelas selecionadas.
  for i in 1..v_tables.count loop
    execute immediate 'select nvl(max(id),0) from '||v_tables(i) into v_count;
    v_global_next := greatest(v_global_next,v_count);
  end loop;
  dbms_output.put_line('Maior ID nas tabelas selecionadas='||v_global_next);

  -- A aplicacao usa um identificador logico adicional, compartilhado por
  -- ACC_POINT.ACC_POINT_ID e CR_ACC_POINT.OBJ_REF_ID.
  for r in (select distinct obj_ref_id old_ref from cr_acc_point
            where version_id=v_old_project and obj_ref_id is not null order by obj_ref_id) loop
    select seq_acc_point.nextval into v_new_id from dual;
    v_logical_ids(k('LOGICAL',r.old_ref)) := v_new_id;
  end loop;

  -- Prealoca IDs para permitir referencias a registros ainda nao inseridos.
  for i in 1..v_tables.count loop
    select count(*) into v_seq_exists from user_sequences
      where sequence_name='SEQ_'||v_tables(i);
    for r in (select table_id from version_content
              where project_version_id=v_old_project and table_name=v_tables(i)
              order by table_id) loop
      execute immediate 'select count(*) from '||v_tables(i)||' where id=:x'
        into v_count using r.table_id;
      if v_count=0 then
        v_skipped_version:=v_skipped_version+1;
        continue;
      end if;
      if v_tables(i)='CR_TRANSMISSION_UNIT' then
        select count(*) into v_count from cr_transmission_unit t
        join version_content v on v.project_version_id=v_old_project
          and v.table_id=t.obj_ref_id
          and v.table_name in ('CR_JUMPER','IP_NE_CONNECTION')
        where t.id=r.table_id;
        if v_count>0 then
          v_skipped_connection:=v_skipped_connection+1;
          continue;
        end if;
      end if;
      if v_tables(i) like '%\_F' escape '\' then
        if not v_ids.exists(k('FEATURE',r.table_id)) then
          raise_application_error(-20012,'Camada _F sem FEATURE: '||v_tables(i)||':'||r.table_id);
        end if;
        v_new_id := v_ids(k('FEATURE',r.table_id));
      elsif v_seq_exists=1 then
        execute immediate 'select seq_'||v_tables(i)||'.nextval from dual' into v_new_id;
      else
        v_global_next := v_global_next+1;
        v_new_id := v_global_next;
      end if;
      execute immediate 'select count(*) from '||v_tables(i)||' where id=:x'
        into v_count using v_new_id;
      if v_count<>0 then
        raise_application_error(-20013,'ID ocupado em '||v_tables(i)||':'||v_new_id);
      end if;
      v_ids(k(v_tables(i),r.table_id)) := v_new_id;
    end loop;
  end loop;

  select seq_cr_project.nextval into v_new_project from dual;
  insert into project(id) values(v_new_project);
  v_project.id:=v_new_project;
  v_project.code:='OT_AUTO_TST';
  v_project.wo_lock:=null;
  v_project.wo_lock_date:=null;
  v_project.lock_time:=null;
  v_project.lock_username:=null;
  v_project.lock_sessionid:=null;
  v_project.initial_date:=trunc(sysdate);
  v_project.estimate_end_date:=trunc(sysdate);
  v_project.creation_date:=sysdate;
  v_project.last_update_date:=sysdate;
  insert into cr_project values v_project;
  insert into project_version(id,project_id) values(v_new_project,v_new_project);
  insert into cr_project_hist(id,cr_project_id,update_date,current_state,username)
    values(seq_cr_project_hist.nextval,v_new_project,sysdate,v_project.current_state,
           sys_context('USERENV','SESSION_USER'));
  select seq_feature.nextval into v_new_feature from dual;
  v_project_f.id:=v_new_feature;
  v_project_f.cr_project_id:=v_new_project;
  v_project_f.geometry:=sdo_util.affinetransforms(v_project_f.geometry,
    translation=>'TRUE',tx=>v_dx,ty=>v_dy);
  insert into cr_project_f values v_project_f;

  for i in 1..v_tables.count loop
    for r in (select table_id from version_content
              where project_version_id=v_old_project and table_name=v_tables(i)
              order by table_id) loop
      if not v_ids.exists(k(v_tables(i),r.table_id)) then continue; end if;
      v_cols:=''; v_expr:=''; v_bind_count:=0; v_binds.delete;
      for c in (select column_name,data_type from user_tab_columns
                where table_name=v_tables(i) order by column_id) loop
        if v_cols is not null then v_cols:=v_cols||','; v_expr:=v_expr||','; end if;
        v_cols:=v_cols||'"'||c.column_name||'"';
        v_piece:='"'||c.column_name||'"';
        if c.column_name='ID' then
          add_bind(v_ids(k(v_tables(i),r.table_id)),c.column_name);
        elsif c.column_name='VERSION_ID' then
          add_bind(v_new_project,c.column_name);
        elsif c.column_name='GEOMETRY' and c.data_type='SDO_GEOMETRY' then
          v_piece:='sdo_util.affinetransforms("GEOMETRY",translation=>''TRUE'',tx=>:DX,ty=>:DY)';
        elsif v_tables(i)='ACC_POINT' and c.column_name='ACC_POINT_ID' then
          execute immediate 'select acc_point_id from acc_point where id=:x'
            into v_old_value using r.table_id;
          add_bind(logical_mapped(v_old_value),c.column_name);
        elsif v_tables(i)='CR_ACC_POINT' and c.column_name='OBJ_REF_ID' then
          execute immediate 'select obj_ref_id from cr_acc_point where id=:x'
            into v_old_value using r.table_id;
          add_bind(logical_mapped(v_old_value),c.column_name);
        elsif v_tables(i)='FEATURE' and c.column_name='OBJ_ID' then
          select min(obj_table),count(distinct obj_table) into v_old_table,v_count
            from cr_projected_object where cr_project_id=v_old_project
              and obj_id=(select obj_id from feature where id=r.table_id)
              and obj_table<>'FEATURE';
          if v_count<>1 then raise_application_error(-20014,'FEATURE com objeto ambiguo: '||r.table_id); end if;
          execute immediate 'select obj_id from feature where id=:x' into v_old_value using r.table_id;
          if not v_ids.exists(k(v_old_table,v_old_value)) then
            raise_application_error(-20015,'FEATURE sem objeto clonado: '||r.table_id);
          end if;
          add_bind(v_ids(k(v_old_table,v_old_value)),c.column_name);
        elsif v_tables(i)='SUB_FEATURE' and c.column_name='FEATURE_ID' then
          execute immediate 'select feature_id from sub_feature where id=:x'
            into v_old_value using r.table_id;
          if not v_ids.exists(k('FEATURE',v_old_value)) then
            raise_application_error(-20016,'SUB_FEATURE sem FEATURE: '||r.table_id);
          end if;
          add_bind(v_ids(k('FEATURE',v_old_value)),c.column_name);
        elsif v_tables(i)='NE_TRAY' and c.column_name='NE_MODULE_ID' then
          execute immediate 'select ne_module_id from ne_tray where id=:x'
            into v_old_value using r.table_id;
          if not v_ids.exists(k('NE_MODULE',v_old_value)) then
            raise_application_error(-20018,'NE_TRAY sem modulo clonado: '||r.table_id);
          end if;
          add_bind(v_ids(k('NE_MODULE',v_old_value)),c.column_name);
        elsif c.data_type='NUMBER' then
          v_fk_parent:=soft_parent(v_tables(i),c.column_name);
          if v_fk_parent is not null then
            null;
          elsif v_fk_cache.exists(v_tables(i)||':'||c.column_name) then
            v_fk_parent:=v_fk_cache(v_tables(i)||':'||c.column_name);
          else
            select min(p.table_name) into v_fk_parent
              from user_constraints fk
              join user_cons_columns fc on fc.constraint_name=fk.constraint_name
              join user_constraints p on p.constraint_name=fk.r_constraint_name
              where fk.table_name=v_tables(i) and fk.constraint_type='R'
                and fc.column_name=c.column_name;
            v_fk_cache(v_tables(i)||':'||c.column_name):=nvl(v_fk_parent,'#');
          end if;
          if v_fk_parent is not null and
             (selected(v_fk_parent) or v_fk_parent in ('CR_PROJECT','PROJECT','@POLY')) then
            execute immediate 'select "'||c.column_name||'" from '||v_tables(i)||' where id=:x'
              into v_old_value using r.table_id;
            if v_fk_parent='@POLY' then
              v_mapped_value:=poly_mapped(v_old_value);
            elsif v_fk_parent in ('CR_PROJECT','PROJECT') and v_old_value=v_old_project then
              v_mapped_value:=v_new_project;
            else
              v_mapped_value:=mapped(v_fk_parent,v_old_value);
            end if;
            add_bind(v_mapped_value,c.column_name);
          end if;
        end if;
        v_expr:=v_expr||v_piece;
      end loop;
      v_sql:='insert into '||v_tables(i)||'('||v_cols||') select '||v_expr||
             ' from '||v_tables(i)||' where id=:OLDID';
      v_cursor:=dbms_sql.open_cursor;
      begin
        dbms_sql.parse(v_cursor,v_sql,dbms_sql.native);
        for b in 1..v_bind_count loop
          dbms_sql.bind_variable(v_cursor,'B'||b,v_binds(b));
        end loop;
        if instr(v_sql,':DX')>0 then
          dbms_sql.bind_variable(v_cursor,'DX',v_dx);
          dbms_sql.bind_variable(v_cursor,'DY',v_dy);
        end if;
        dbms_sql.bind_variable(v_cursor,'OLDID',r.table_id);
        v_dummy:=dbms_sql.execute(v_cursor);
        dbms_sql.close_cursor(v_cursor);
      exception when others then
        if dbms_sql.is_open(v_cursor) then dbms_sql.close_cursor(v_cursor); end if;
        dbms_output.put_line('FALHA '||v_tables(i)||':'||r.table_id||' -> '||sqlerrm);
        raise;
      end;
      v_total:=v_total+1;
    end loop;
    dbms_output.put_line(v_tables(i)||' clonado. Total acumulado='||v_total);
  end loop;

  for r in (select * from cr_projected_object where cr_project_id=v_old_project
            and obj_table not in ('IP_NE_CONNECTION','NET_LINE_ROUTE') order by id) loop
    if not v_ids.exists(k(r.obj_table,r.obj_id)) then
      execute immediate 'select count(*) from '||r.obj_table||' where id=:x'
        into v_count using r.obj_id;
      if v_count=0 then
        v_skipped_projected:=v_skipped_projected+1;
        continue;
      end if;
      raise_application_error(-20017,'Objeto existente sem clone: '||r.obj_table||':'||r.obj_id);
    end if;
    v_po:=r;
    select seq_cr_projected_object.nextval into v_po.id from dual;
    v_po.cr_project_id:=v_new_project;
    v_po.obj_id:=v_ids(k(r.obj_table,r.obj_id));
    insert into cr_projected_object values v_po;
  end loop;
  select count(*) into v_count from cr_projected_object where cr_project_id=v_new_project;
  dbms_output.put_line('CR_PROJECTED_OBJECT novo='||v_count);
  if v_count<>378 then raise_application_error(-20021,'Quantidade de objetos inesperada'); end if;
  select count(*) into v_count from version_content where project_version_id=v_new_project;
  dbms_output.put_line('VERSION_CONTENT novo='||v_count);
  if v_count<>v_total then raise_application_error(-20022,'VERSION_CONTENT nao corresponde aos objetos inseridos'); end if;
  for t in (select distinct table_name from version_content
            where project_version_id=v_old_project and table_name in
              ('FEATURE','SUB_FEATURE','CABLE_SEG_F','CONDUIT_F','MANHOLE_F',
               'OP_TERMINAL_F','OTHER_F','POLE_F','ROUTE_F')) loop
    execute immediate 'select count(*),sum(case when geometry is not null and sdo_geom.validate_geometry_with_context(geometry,0.00000005)<>''TRUE'' then 1 else 0 end) from '||t.table_name||' where version_id=:x'
      into v_count,v_bad_geom using v_new_project;
    v_spatial_count:=v_spatial_count+v_count;
    if nvl(v_bad_geom,0)<>0 then
      raise_application_error(-20023,'Geometria invalida em '||t.table_name||': '||v_bad_geom);
    end if;
  end loop;
  dbms_output.put_line('Geometrias de objetos validadas='||v_spatial_count);
  if v_spatial_count<>103 then raise_application_error(-20024,'Quantidade de geometrias inesperada'); end if;
  for r in (select obj_table,obj_id from cr_projected_object where cr_project_id=v_new_project) loop
    execute immediate 'select count(*) from '||r.obj_table||' where id=:x and version_id=:v'
      into v_count using r.obj_id,v_new_project;
    if v_count<>1 then
      raise_application_error(-20025,'Objeto projetado sem cadastro: '||r.obj_table||':'||r.obj_id);
    end if;
  end loop;
  for i in 1..v_tables.count loop
    for c in (select column_name from user_tab_columns
              where table_name=v_tables(i) and data_type='NUMBER'
                and column_name not in ('ID','VERSION_ID')) loop
      v_fk_parent:=soft_parent(v_tables(i),c.column_name);
      if v_fk_parent is null then
        select min(p.table_name) into v_fk_parent
          from user_constraints fk
          join user_cons_columns fc on fc.constraint_name=fk.constraint_name
          join user_constraints p on p.constraint_name=fk.r_constraint_name
          where fk.table_name=v_tables(i) and fk.constraint_type='R'
            and fc.column_name=c.column_name;
      end if;
      if v_fk_parent='@POLY' then
        execute immediate 'select count(*) from '||v_tables(i)||' x join version_content src on src.project_version_id=:old and src.table_id=x."'||c.column_name||'" where x.version_id=:new'
          into v_count using v_old_project,v_new_project;
      elsif selected(v_fk_parent) then
        execute immediate 'select count(*) from '||v_tables(i)||' x join version_content src on src.project_version_id=:old and src.table_name=:parent and src.table_id=x."'||c.column_name||'" where x.version_id=:new'
          into v_count using v_old_project,v_fk_parent,v_new_project;
      else
        v_count:=0;
      end if;
      if v_count<>0 then
        raise_application_error(-20027,'Referencia antiga em '||v_tables(i)||'.'||c.column_name||': '||v_count);
      end if;
    end loop;
  end loop;
  dbms_output.put_line('Referencias para IDs da origem=0');
  select count(*) into v_count from cr_project_f
    where cr_project_id=v_new_project
      and abs(sdo_geom.sdo_centroid(geometry,0.00000005).sdo_point.x-(-38.44606614))<0.00000002
      and abs(sdo_geom.sdo_centroid(geometry,0.00000005).sdo_point.y-(-12.98624034))<0.00000002;
  if v_count<>1 then raise_application_error(-20026,'Centro da OT incorreto'); end if;
  dbms_output.put_line('Referencias versionadas sem registro-fonte='||v_skipped_version);
  dbms_output.put_line('Objetos projetados sem registro-fonte='||v_skipped_projected);
  dbms_output.put_line('Unidades de conexao excluidas='||v_skipped_connection);
  commit;
  dbms_output.put_line('COMMIT concluido; objetos confirmados.');
exception when others then
  dbms_output.put_line('ERRO '||sqlcode||': '||sqlerrm);
  rollback;
  raise;
end;
/
exit rollback
