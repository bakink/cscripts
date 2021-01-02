----------------------------------------------------------------------------------------
--
-- File name:   cs_sprf_export.sql
--
-- Purpose:     Exports Execution Plans for some SQL_ID or all SQL on a PDB using SQL Profile(s)
--
-- Author:      Carlos Sierra
--
-- Version:     2020/12/31
--
-- Usage:       Connecting into PDB.
--
--              Enter optional SQL Text Piece or SQL_ID when requested.
--
-- Example:     $ sqlplus / as sysdba
--              SQL> @cs_sprf_export.sql
--
-- Notes:       Developed and tested on 12.1.0.2 and 19c.
--              Application agnostic
--              KIEV aware
--              KIEV Statement Caching aware
--
---------------------------------------------------------------------------------------
--
@@cs_internal/cs_primary.sql
@@cs_internal/cs_cdb_warn.sql
@@cs_internal/cs_set.sql
@@cs_internal/cs_def.sql
@@cs_internal/cs_file_prefix.sql
--
DEF cs_script_name = 'cs_sprf_export';
--
PRO
PRO 1. SQL Text piece (e.g.: ScanQuery, getValues, TableName, IndexName): (opt)
DEF cs_sql_text_piece = '&1.';
UNDEF 1;
--
PRO
PRO 2. SQL_ID: (opt)
DEF cs_sql_id = '&2.';
UNDEF 2;
--
SELECT '&&cs_file_prefix._&&cs_script_name.' AS cs_file_name FROM DUAL;
--
@@cs_internal/cs_spool_head.sql
PRO SQL> @&&cs_script_name..sql "&&cs_sql_text_piece." "&&cs_sql_id."  
@@cs_internal/cs_spool_id.sql
--
PRO SQL_TEXT     : "&&cs_sql_text_piece."
PRO SQL_ID       : "&&cs_sql_id."
--
COL double_ampersand NEW_V double_ampersand NOPRI;
SELECT CHR(38)||CHR(38) AS double_ampersand FROM DUAL;
PRO
VAR v_version               VARCHAR2(12);
VAR v_rgn                   VARCHAR2(3);
VAR v_cdb_name              VARCHAR2(9);
VAR v_pdb_name              VARCHAR2(30);
VAR v_reference             VARCHAR2(30);
VAR v_exported              NUMBER;
--
EXEC :v_version             := TO_CHAR(SYSDATE, 'YYMMDDHH24MISS');
EXEC :v_rgn                 := SUBSTR('&&cs_rgn.', 1, 3);
EXEC :v_cdb_name            := SUBSTR('&&cs_db_name_u.', 1, 9);
EXEC :v_pdb_name            := SUBSTR('&&cs_con_name.', 1, 30);
EXEC :v_reference           := SUBSTR('&&cs_reference.', 1, 30);
EXEC :v_exported            := 0;
--
PRO please wait...
SET HEA OFF PAGES 0 TERM OFF SERVEROUT ON;
/* ========================================================================================== */
-- IMPLEMENT scrip
SPO &&cs_file_name._IMPLEMENT.sql;
PRO /* -------------------------------------------------------------------------------------- */
PRO REM
PRO REM File name:   &&cs_file_name._IMPLEMENT.sql
PRO REM
PRO REM Purpose:     Implements Execution Plans for some SQL_ID or all SQL on a PDB using SQL Profile(s)
PRO REM
PRO REM Author:      Carlos Sierra
PRO REM
PRO REM Version:     2020/12/31
PRO REM
PRO REM Usage:       Connecting into PDB.
PRO REM
PRO REM Example:     $ sqlplus / as sysdba
PRO REM              SQL> @&&cs_file_name._IMPLEMENT.sql
PRO REM
PRO /* -------------------------------------------------------------------------------------- */
PRO SET HEA ON LIN 2490 PAGES 100 TAB OFF FEED OFF ECHO OFF VER OFF TRIMS ON TRIM ON TI OFF TIMI OFF LONG 240000 LONGC 2400 NUM 20 SERVEROUT OFF;;
PRO SET SERVEROUT ON;;
PRO COL report_time NEW_V report_time NOPRI;;
PRO SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24.MI.SS') AS report_time FROM DUAL;;
PRO SPO &&cs_file_name._IMPLEMENT_&&double_ampersand.report_time..txt;;
PRO PRO REM
PRO PRO REM &&cs_file_name._IMPLEMENT_&&double_ampersand.report_time..txt
PRO PRO REM
PRO VAR v_implemented NUMBER;;
PRO EXEC :v_implemented := 0;;
PRO DEF kievbuckets_owner = '';;
PRO COL kievbuckets_owner NEW_V kievbuckets_owner NOPRI;;
PRO SELECT owner AS kievbuckets_owner FROM dba_tables WHERE table_name = 'KIEVBUCKETS' AND owner NOT IN ('APP_USER', 'PDBADMIN') ORDER BY last_analyzed DESC NULLS FIRST FETCH FIRST 1 ROW ONLY;;
--
DECLARE
    l_sql_id            VARCHAR2(13) := TRIM('&&cs_sql_id.');
    l_sql_text_piece    VARCHAR2(1000) := '&&cs_sql_text_piece.';
    l_pos               INTEGER;
    l_pos2              INTEGER;
    l_hint              VARCHAR2(4000);
    --
    PROCEDURE o(p_line IN VARCHAR2) IS BEGIN DBMS_OUTPUT.put_line(p_line); END;
BEGIN
    -- main cursor
    FOR i IN (WITH 
              u AS 
              (SELECT user_id, username FROM dba_users WHERE oracle_maintained = 'N' AND username NOT LIKE 'C##%' AND  ROWNUM >= 1 /* MATERIALIZE NO_MERGE */),
              s AS
              (
              SELECT  s.exact_matching_signature AS signature, s.sql_id, s.plan_hash_value, x.plan_hash_value_2, s.sql_text, s.sql_fulltext, p.other_xml,
                      ROW_NUMBER() OVER (PARTITION BY s.exact_matching_signature, s.sql_id ORDER BY s.last_active_time DESC, p.id) AS rn,
                      -- bucket_name and bucket_id are KIEV specific, and needed to support statement caching on KIEV, which requires to embed the bucket_id into sql decoration (e.g. /* performScanQuery(NOTIFICATION_BOARD,EVENT_BY_SCHEDULED_TIME) [1002] */)
                      CASE 
                        WHEN s.sql_text LIKE '/* %(%,%)% [%] */%' AND SUBSTR(s.sql_text, INSTR(s.sql_text, '/* ') + 3, INSTR(s.sql_text, '(') - INSTR(s.sql_text, '/*') - 3) IN ('performScanQuery','performSegmentedScanQuery','getValues') 
                        THEN SUBSTR(s.sql_fulltext, INSTR(s.sql_fulltext, '(') + 1, INSTR(s.sql_fulltext, ',') -  INSTR(s.sql_fulltext, '(') - 1) 
                      END AS bucket_name,
                      CASE 
                        WHEN s.sql_text LIKE '/* %(%,%)% [%] */%' AND SUBSTR(s.sql_text, INSTR(s.sql_text, '/* ') + 3, INSTR(s.sql_text, '(') - INSTR(s.sql_text, '/*') - 3) IN ('performScanQuery','performSegmentedScanQuery','getValues') 
                        THEN SUBSTR(s.sql_fulltext, INSTR(s.sql_fulltext, '[') + 1, INSTR(s.sql_fulltext, ']') -  INSTR(s.sql_fulltext, '[') - 1) 
                      END AS bucket_id
              FROM    v$sql s, u u1, u u2, v$sql_plan p
                      , XMLTABLE('for $i in /other_xml/info where $i/@type eq "plan_hash_2" return $i' PASSING XMLTYPE(p.other_xml) COLUMNS plan_hash_value_2 NUMBER PATH '.') x
              WHERE   s.plan_hash_value > 0 -- e.g.: PL/SQL has 0 on PHV
              AND     s.exact_matching_signature > 0 -- INSERT from values has 0 on signature
              AND     s.executions > 0
              AND     s.cpu_time > 0
              AND     s.buffer_gets > 0
              AND     s.buffer_gets > s.executions
              AND     s.object_status = 'VALID'
              AND     s.is_obsolete = 'N'
              AND     s.is_shareable = 'Y'
              AND     s.is_bind_aware = 'N' -- to ignore cursors using adaptive cursor sharing ACS as per CHANGE-190522
              AND     s.is_resolved_adaptive_plan IS NULL -- to ignore adaptive plans which cause trouble when combined with SPM
              AND     s.is_reoptimizable = 'N' -- to ignore cursors which require adjustments as per cardinality feedback  
              AND     s.last_active_time > SYSDATE - 1
              AND     s.sql_id = NVL(l_sql_id, s.sql_id)
              AND     UPPER(s.sql_text) LIKE '%'||UPPER(l_sql_text_piece)||'%'
              AND     u1.user_id = s.parsing_user_id
              AND     u2.user_id = s.parsing_schema_id
              AND     p.address = s.address
              AND     p.hash_value = s.hash_value
              AND     p.sql_id = s.sql_id
              AND     p.plan_hash_value = s.plan_hash_value
              AND     p.child_address = s.child_address
              AND     p.child_number = s.child_number
              AND     p.other_xml IS NOT NULL
              AND     p.id = 1
              AND     x.plan_hash_value_2 > 0
              AND     ROWNUM >= 1 /* MATERIALIZE NO_MERGE */
              )
              SELECT  signature, sql_id, plan_hash_value, plan_hash_value_2, SUBSTR(sql_text, 1, 100) AS sql_text_100, sql_text, sql_fulltext, other_xml,
                      bucket_name, bucket_id, CASE WHEN bucket_id IS NULL THEN 'NORMAL' ELSE 'BUCKET' END AS type
              FROM    s
              WHERE   rn = 1
              ORDER BY
                      signature)
    LOOP
        o('--');
        o('PRO');
        o('PRO '||i.sql_text_100);
        o('PRO ['||i.signature||']['||i.sql_id||']['||i.plan_hash_value||']['||i.plan_hash_value_2||']['||i.bucket_name||']['||i.bucket_id||']['||i.type||']');
        o('DECLARE');
        o('l_version            VARCHAR2(12)   := '''||:v_version||''';');
        o('l_rgn                VARCHAR2(3)    := '''||:v_rgn||''';');
        o('l_cdb_name           VARCHAR2(9)    := '''||:v_cdb_name||''';');
        o('l_pdb_name           VARCHAR2(30)   := '''||:v_pdb_name||''';');
        o('l_reference          VARCHAR2(30)   := '''||:v_reference||''';');
        o('l_plan_name          VARCHAR2(30);');
        o('l_description        VARCHAR2(500);');
        o('l_count              NUMBER;');
        o('l_plans              NUMBER;');
        o('l_target_bucket_id   VARCHAR2(6);');
        o('l_target_signature   NUMBER;');
        o('l_sql_text_clob      CLOB;');
        o('l_profile_attr       SYS.SQLPROF_ATTR;');
        o('PROCEDURE o(p_line IN VARCHAR2) IS BEGIN DBMS_OUTPUT.put_line(p_line); END;');
        o('BEGIN');
        o('-- sql_text');
        o(q'{l_sql_text_clob := q'[}'); -- '
        l_pos := 1;
        WHILE l_pos > 0
        LOOP
            l_pos2 := INSTR(i.sql_fulltext||CHR(10), CHR(10), l_pos);
            o(SUBSTR(i.sql_fulltext, l_pos, l_pos2 - l_pos));
            l_pos := NULLIF(l_pos2, 0) + 1;
        END LOOP;
        o(q'{]';}'); -- '
        o('-- hints');
        o('l_profile_attr := SYS.SQLPROF_ATTR(');
        o(q'{q'[BEGIN_OUTLINE_DATA]',}');
        FOR j IN (SELECT hint FROM XMLTABLE('other_xml/outline_data/hint' PASSING XMLTYPE(i.other_xml) COLUMNS hint VARCHAR2(4000) PATH '.'))
        LOOP
            l_hint := j.hint;
            WHILE l_hint IS NOT NULL
            LOOP
                IF LENGTH(l_hint) <= 500 THEN
                    o(q'{q'[}'||l_hint||q'{]',}');
                    l_hint := NULL;
                ELSE
                    l_pos := INSTR(SUBSTR(l_hint, 1, 500), ' ', -1);
                    o(q'{q'[}'||SUBSTR(l_hint, 1, l_pos)||q'{]',}');
                    l_hint := SUBSTR(l_hint, l_pos);
                END IF;
            END LOOP;
        END LOOP;
        o(q'{q'[END_OUTLINE_DATA]'}');
        o(');');
        o('-- transformations');
        o('IF '''||i.bucket_id||''' IS NOT NULL THEN -- KIEV Statement Caching specific');
        o('EXECUTE IMMEDIATE ''SELECT TO_CHAR(bucketid) AS bucket_id FROM &&double_ampersand.kievbuckets_owner..kievbuckets WHERE name = '''''||i.bucket_name||''''''' INTO l_target_bucket_id;');
        o('END IF;');
        o('IF l_target_bucket_id IS NOT NULL THEN');
        o('l_sql_text_clob := REPLACE(l_sql_text_clob, ''['||i.bucket_id||']'', ''[''||l_target_bucket_id||'']'');');
        o('l_target_signature := DBMS_SQLTUNE.sqltext_to_signature (sql_text => l_sql_text_clob);');
        o('ELSE');
        o('l_target_signature := '||i.signature||';');
        o('END IF;');
        o('o(''[''||l_target_signature||''][''||l_target_bucket_id||'']'');');
        o('l_plan_name := ''exp_'||i.sql_id||'_''||l_version;');
        o('l_description := ''[''||l_target_signature||'']['||i.plan_hash_value||']['||i.plan_hash_value_2||']['||i.signature||']['||i.sql_id||']['||i.bucket_name||']['||i.bucket_id||'][''||l_rgn||''][''||l_cdb_name||''][''||l_pdb_name||''][EXP]['||i.type||'][''||l_reference||'']'';');
        o('-- disable prior sql_profile');
        o('FOR i IN (SELECT p.name FROM dba_sql_profiles p WHERE p.signature = l_target_signature AND p.category = ''DEFAULT'' AND p.status = ''ENABLED'' AND NVL(p.description, ''NULL'') NOT LIKE ''%][EXP][%'' AND NOT EXISTS (SELECT NULL FROM dba_sql_profiles e WHERE e.name = p.name AND e.category = ''BACKUP''))');
        o('LOOP');
        o('o(''SPRF disable: ''||i.name);');
        o('DBMS_SQLTUNE.alter_sql_profile(name => i.name, attribute_name => ''CATEGORY'', value => ''BACKUP'');');
        o('END LOOP;');
        o('-- create new sql_profile');
        o('SELECT COUNT(*) INTO l_count FROM dba_sql_profiles WHERE name = l_plan_name;');
        o('IF l_count = 0 THEN');
        o('o(''SPRF create: ''||l_plan_name||'' ''||l_description);');
        o('DBMS_SQLTUNE.import_sql_profile(sql_text => l_sql_text_clob, profile => l_profile_attr, name => l_plan_name, description => l_description, replace => TRUE);');
        o(':v_implemented := :v_implemented + 1;');
        o('END IF;');
        o('-- disable prior sql_patch');
        o('FOR i IN (SELECT p.name FROM dba_sql_patches p WHERE p.signature = l_target_signature AND p.category = ''DEFAULT'' AND p.status = ''ENABLED'' AND NOT EXISTS (SELECT NULL FROM dba_sql_patches e WHERE e.name = p.name AND e.category = ''BACKUP''))');
        o('LOOP');
        o('o(''SPCH disable: ''||i.name);');
        o('DBMS_SQLDIAG.alter_sql_patch(name => i.name, attribute_name => ''CATEGORY'', attribute_value => ''BACKUP'');');
        o('END LOOP;');
        o('-- disable prior sql_plan_baseline');
        o('FOR i IN (SELECT p.sql_handle, p.plan_name, p.description FROM dba_sql_plan_baselines p WHERE p.signature = l_target_signature AND p.enabled = ''YES'' AND p.accepted = ''YES'')');
        o('LOOP');
        o('o(''SPBL disable: ''||i.sql_handle||'' ''||i.plan_name||'' ''||i.description);');
        o('l_plans := DBMS_SPM.alter_sql_plan_baseline(sql_handle => i.sql_handle, plan_name => i.plan_name, attribute_name => ''ENABLED'', attribute_value => ''NO'');');
        o('IF NVL(i.description, ''NULL'') NOT LIKE ''%[''||l_version||'']%'' THEN');
        o('IF LENGTH(i.description) > 470 THEN');
        o('l_plans := DBMS_SPM.alter_sql_plan_baseline(sql_handle => i.sql_handle, plan_name => i.plan_name, attribute_name => ''DESCRIPTION'', attribute_value => ''[EXP][''||l_version||'']'');');
        o('ELSE');
        o('l_plans := DBMS_SPM.alter_sql_plan_baseline(sql_handle => i.sql_handle, plan_name => i.plan_name, attribute_name => ''DESCRIPTION'', attribute_value => i.description||'' [EXP][''||l_version||'']'');');
        o('END IF;');
        o('o(''SPBL update: [EXP][''||l_version||'']'');');
        o('END IF;');
        o('END LOOP;');
        o('END;');
        o('/');
        :v_exported := :v_exported + 1;
    END LOOP;
    o('--');
END;
/
--
PRO PRINT v_implemented;;
PRO PRO REM
PRO PRO REM &&cs_file_name._IMPLEMENT_&&double_ampersand.report_time..txt
PRO PRO REM
PRO SPO OFF;;
PRO SET SERVEROUT OFF;;
PRO REM
PRO REM &&cs_file_name._IMPLEMENT.sql
PRO REM
PRO HOS ls -l &&cs_file_name._IMPLEMENT*
SPO OFF;
/* ========================================================================================== */
-- ROLLBACK scrip
SPO &&cs_file_name._ROLLBACK.sql;
PRO /* -------------------------------------------------------------------------------------- */
PRO REM
PRO REM File name:   &&cs_file_name._ROLLBACK.sql
PRO REM
PRO REM Purpose:     Rollsback Execution Plans for some SQL_ID or all SQL on a PDB using SQL Profile(s)
PRO REM
PRO REM Author:      Carlos Sierra
PRO REM
PRO REM Version:     2020/12/31
PRO REM
PRO REM Usage:       Connecting into PDB.
PRO REM
PRO REM Example:     $ sqlplus / as sysdba
PRO REM              SQL> @&&cs_file_name._ROLLBACK.sql
PRO REM
PRO /* --------------------------------------------------------------------------------------- */
PRO SET HEA ON LIN 2490 PAGES 100 TAB OFF FEED OFF ECHO OFF VER OFF TRIMS ON TRIM ON TI OFF TIMI OFF LONG 240000 LONGC 2400 NUM 20 SERVEROUT OFF;;
PRO SET SERVEROUT ON;;
PRO COL report_time NEW_V report_time NOPRI;;
PRO SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24.MI.SS') AS report_time FROM DUAL;;
PRO SPO &&cs_file_name._ROLLBACK_&&double_ampersand.report_time..txt;;
PRO PRO REM
PRO PRO REM &&cs_file_name._ROLLBACK_&&double_ampersand.report_time..txt
PRO PRO REM
PRO VAR v_rolled_back NUMBER;;
PRO EXEC :v_rolled_back := 0;;
--
DECLARE
    PROCEDURE o(p_line IN VARCHAR2) IS BEGIN DBMS_OUTPUT.put_line(p_line); END;
BEGIN
    o('--');
    o('DECLARE');
    o('l_version    VARCHAR2(12) := '''||:v_version||''';');
    o('l_plans      NUMBER;');
    o('PROCEDURE o(p_line IN VARCHAR2) IS BEGIN DBMS_OUTPUT.put_line(p_line); END;');
    o('BEGIN');
    o('o(''~~~~~~~~~~~~~~~~~~~~~~~~~~'');');
    o('o(''drop imported sql_profiles'');');
    o('o(''~~~~~~~~~~~~~~~~~~~~~~~~~~'');');
    o('FOR i IN (SELECT name FROM dba_sql_profiles WHERE name LIKE ''exp_%_''||l_version AND category = ''DEFAULT'' AND status = ''ENABLED'' AND description LIKE ''%][EXP][%'')');
    o('LOOP');
    o('o(''SPRF drop: ''||i.name);');
    o('DBMS_SQLTUNE.drop_sql_profile(name => i.name);');
    o(':v_rolled_back := :v_rolled_back + 1;');
    o('END LOOP;');
    o('o(''~~~~~~~~~~~~~~~~~~~~~~~~~'');');
    o('o(''enable prior sql_profiles'');');
    o('o(''~~~~~~~~~~~~~~~~~~~~~~~~~'');');
    o('FOR i IN (SELECT name FROM dba_sql_profiles WHERE name NOT LIKE ''exp_%_''||l_version AND category = ''BACKUP'' AND status = ''ENABLED'' AND NVL(description, ''NULL'') NOT LIKE ''%][EXP][%'')');
    o('LOOP');
    o('o(''SPRF enable: ''||i.name);');
    o('DBMS_SQLTUNE.alter_sql_profile(name => i.name, attribute_name => ''CATEGORY'', value => ''DEFAULT'');');
    o('END LOOP;');
    o('o(''~~~~~~~~~~~~~~~~~~~~~~~~'');');
    o('o(''enable prior sql_patches'');');
    o('o(''~~~~~~~~~~~~~~~~~~~~~~~~'');');
    o('FOR i IN (SELECT p.name FROM dba_sql_patches p WHERE p.category = ''BACKUP'' AND p.status = ''ENABLED'' AND NOT EXISTS (SELECT NULL FROM dba_sql_patches e WHERE e.name = p.name AND e.category = ''DEFAULT''))');
    o('LOOP');
    o('o(''SPCH enable: ''||i.name);');
    o('DBMS_SQLDIAG.alter_sql_patch(name => i.name, attribute_name => ''CATEGORY'', attribute_value => ''DEFAULT'');');
    o('END LOOP;');
    o('o(''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'');');
    o('o(''enable prior sql_plan_baselines'');');
    o('o(''~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'');');
    o('FOR i IN (SELECT p.sql_handle, p.plan_name, p.description FROM dba_sql_plan_baselines p WHERE p.enabled = ''NO'' AND p.accepted = ''YES'' AND p.description  LIKE ''%[''||l_version||'']%'')');
    o('LOOP');
    o('o(''SPBL enable: ''||i.sql_handle||'' ''||i.plan_name||'' ''||i.description);');
    o('l_plans := DBMS_SPM.alter_sql_plan_baseline(sql_handle => i.sql_handle, plan_name => i.plan_name, attribute_name => ''ENABLED'', attribute_value => ''YES'');');
    o('END LOOP;');
    o('END;');
    o('/');
    o('--');
END;
/
--
PRO PRINT v_rolled_back;;
PRO PRO REM
PRO PRO REM &&cs_file_name._ROLLBACK_&&double_ampersand.report_time..txt
PRO PRO REM
PRO SPO OFF;;
PRO SET SERVEROUT OFF;;
PRO REM
PRO REM &&cs_file_name._ROLLBACK.sql
PRO REM
PRO HOS ls -l &&cs_file_name._ROLLBACK*
SPO OFF;
/* ========================================================================================== */
SET HEA ON PAGES 100 TERM ON SERVEROUT OFF;
--
-- continues with original spool
SPO &&cs_file_name..txt APP
PRO
PRINT v_exported;
--
PRO
PRO SQL> @&&cs_script_name..sql "&&cs_sql_text_piece." "&&cs_sql_id."  
--
@@cs_internal/cs_spool_tail.sql
@@cs_internal/cs_undef.sql
@@cs_internal/cs_reset.sql
--
PRO
HOS ls -l &&cs_file_prefix._&&cs_script_name.*.*
--