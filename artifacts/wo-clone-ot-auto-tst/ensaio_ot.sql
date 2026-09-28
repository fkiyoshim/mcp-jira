-- Executar em uma sessao SQL*Plus ja autenticada como CLARO_BRASIL.
-- Ensaio limitado ao cabecalho da OT e a sua geometria; sempre faz ROLLBACK.
-- Nao executar COMMIT nesta sessao.
set serveroutput on size unlimited
set autocommit off
set verify off
set feedback on
whenever oserror exit failure rollback
whenever sqlerror exit sql.sqlcode rollback

declare
  v_project      cr_project%rowtype;
  v_project_f    cr_project_f%rowtype;
  v_new_id       cr_project.id%type;
  v_new_feature  cr_project_f.id%type;
  v_lon          number;
  v_lat          number;
  v_dx           number;
  v_dy           number;
  v_valid        varchar2(4000);
  v_count        number;
begin
  select count(*) into v_count from cr_project where code = 'OT_AUTO_TST';
  if v_count <> 0 then
    raise_application_error(-20001, 'OT_AUTO_TST ja existe; ensaio interrompido');
  end if;

  select * into v_project from cr_project where id = 12128 and code = 'WO-TRANSFER-04';
  select * into v_project_f from cr_project_f where cr_project_id = 12128;
  v_dx := -38.44606614 - sdo_geom.sdo_centroid(v_project_f.geometry, 0.00000005).sdo_point.x;
  v_dy := -12.98624034 - sdo_geom.sdo_centroid(v_project_f.geometry, 0.00000005).sdo_point.y;
  v_new_id := seq_cr_project.nextval;
  v_new_feature := seq_feature.nextval;
  v_project.id := v_new_id;
  v_project.code := 'OT_AUTO_TST';
  v_project.wo_lock := null;
  v_project.wo_lock_date := null;
  v_project.lock_time := null;
  v_project.lock_username := null;
  v_project.lock_sessionid := null;

  insert into project(id) values (v_new_id);
  insert into cr_project values v_project;
  insert into project_version(id, project_id) values (v_new_id, v_new_id);

  v_project_f.id := v_new_feature;
  v_project_f.cr_project_id := v_new_id;
  v_project_f.geometry := sdo_util.affinetransforms(
    v_project_f.geometry,
    translation => 'TRUE',
    tx => v_dx,
    ty => v_dy
  );
  insert into cr_project_f values v_project_f;

  select sdo_geom.sdo_centroid(geometry, 0.00000005).sdo_point.x,
         sdo_geom.sdo_centroid(geometry, 0.00000005).sdo_point.y,
         sdo_geom.validate_geometry_with_context(geometry, 0.00000005)
    into v_lon, v_lat, v_valid
    from cr_project_f where cr_project_id = v_new_id;
  select count(*) into v_count from cr_project where id = v_new_id and code = 'OT_AUTO_TST';
  dbms_output.put_line('OT de ensaio: id=' || v_new_id || ', linhas=' || v_count);
  dbms_output.put_line('Geometria: lon=' || to_char(v_lon, 'FM9990D00000000') ||
                       ', lat=' || to_char(v_lat, 'FM9990D00000000') ||
                       ', validacao=' || v_valid);
  if v_count <> 1 or abs(v_lon - (-38.44606614)) > 0.00000002
     or abs(v_lat - (-12.98624034)) > 0.00000002 or v_valid <> 'TRUE' then
    raise_application_error(-20002, 'Verificacao do ensaio falhou');
  end if;
  rollback;
  dbms_output.put_line('ROLLBACK executado; nenhum insert deste bloco foi confirmado.');
exception
  when others then
    dbms_output.put_line('ERRO ' || sqlcode || ': ' || sqlerrm);
    rollback;
    dbms_output.put_line('ROLLBACK executado apos erro.');
    raise;
end;
/
exit rollback
