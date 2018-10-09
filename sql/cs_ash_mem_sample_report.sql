----------------------------------------------------------------------------------------
--
-- File name:   cs_ash_mem_sample_report.sql
--
-- Purpose:     List ASH Samples from MEM
--
-- Author:      Carlos Sierra
--
-- Version:     2018/08/06
--
-- Usage:       Execute connected to CDB or PDB.
--
--              Enter optional parameters when requested.
--
-- Example:     $ sqlplus / as sysdba
--              SQL> @cs_ash_mem_sample_report.sql
--
-- Notes:       *** Requires Oracle Diagnostics Pack License ***
--
--              Developed and tested on 12.1.0.2.
--
---------------------------------------------------------------------------------------
--
@@cs_internal/cs_primary.sql
@@cs_internal/cs_cdb_warn.sql
@@cs_internal/cs_set.sql
@@cs_internal/cs_def.sql
@@cs_internal/cs_file_prefix.sql
--
DEF cs_script_name = 'cs_ash_mem_sample_report';
--
SELECT '&&cs_file_prefix._&&cs_file_date_time._&&cs_reference_sanitized._&&cs_script_name.' cs_file_name FROM DUAL;
--
DEF cs_hours_range_default = '1';
@@cs_internal/cs_sample_time_from_and_to.sql
--
@@cs_internal/cs_spool_head.sql
PRO SQL> @&&cs_script_name..sql "&&cs_sample_time_from." "&&cs_sample_time_to."
@@cs_internal/cs_spool_id.sql
--
PRO TIME_FROM    : &&cs_sample_time_from.
PRO TIME_TO      : &&cs_sample_time_to.
--
CL BREAK
COL sql_text_100_only FOR A100 HEA 'SQL Text';
COL sample_date_time FOR A20 HEA 'Sample Date and Time';
COL samples FOR 9999,999 HEA 'Sessions';
COL on_cpu_or_wait_class FOR A14 HEA 'ON CPU or|Wait Class';
COL on_cpu_or_wait_event FOR A50 HEA 'ON CPU or Timed Event';
COL session_serial FOR A16 HEA 'Session,Serial';
COL blocking_session_serial FOR A16 HEA 'Blocking|Session,Serial';
COL machine FOR A60 HEA 'Application Server';
COL con_id FOR 999999;
COL plans FOR 99999 HEA 'Plans';
COL sessions FOR 9999,999 HEA 'Sessions|this SQL';
--
PRO
PRO ASH spikes by sample time and top SQL (spikes higher than &&cs_sample_time_from. cpu cores)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WITH 
ash_by_sample_and_sql AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       h.sample_time,
       h.sql_id,
       h.con_id,
       COUNT(*) samples,
       COUNT(DISTINCT h.sql_plan_hash_value) plans,
       ROW_NUMBER () OVER (PARTITION BY h.sample_time ORDER BY COUNT(*) DESC NULLS LAST, h.sql_id) row_number
  FROM v$active_session_history h
 WHERE h.sample_time BETWEEN TO_TIMESTAMP('&&cs_sample_time_from.', '&&cs_datetime_full_format.') AND TO_TIMESTAMP('&&cs_sample_time_to.', '&&cs_datetime_full_format.')
 GROUP BY
       h.sample_time,
       h.sql_id,
       h.con_id
)
SELECT TO_CHAR(h.sample_time, '&&cs_datetime_full_format.') sample_date_time,
       SUM(h.samples) samples,
       MAX(CASE h.row_number WHEN 1 THEN h.sql_id END) sql_id,
       SUM(CASE h.row_number WHEN 1 THEN h.samples ELSE 0 END) sessions,
       MAX(CASE WHEN h.row_number = 1 AND h.sql_id IS NOT NULL THEN h.plans END) plans,
       MAX(CASE h.row_number WHEN 1 THEN h.con_id END) con_id,       
       MAX(CASE WHEN h.row_number = 1 AND h.sql_id IS NOT NULL THEN (SELECT SUBSTR(q.sql_text, 1, 100) FROM v$sqlstats q WHERE q.sql_id = h.sql_id AND ROWNUM = 1) END) sql_text_100_only
  FROM ash_by_sample_and_sql h
 GROUP BY
       h.sample_time
HAVING SUM(h.samples) >= &&cs_num_cpu_cores.
 ORDER BY
       h.sample_time
/
--
PRO
PRO ASH by sample time and top SQL
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WITH 
ash_by_sample_and_sql AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       h.sample_time,
       h.sql_id,
       h.con_id,
       COUNT(*) samples,
       COUNT(DISTINCT h.sql_plan_hash_value) plans,
       ROW_NUMBER () OVER (PARTITION BY h.sample_time ORDER BY COUNT(*) DESC NULLS LAST, h.sql_id) row_number
  FROM v$active_session_history h
 WHERE h.sample_time BETWEEN TO_TIMESTAMP('&&cs_sample_time_from.', '&&cs_datetime_full_format.') AND TO_TIMESTAMP('&&cs_sample_time_to.', '&&cs_datetime_full_format.')
 GROUP BY
       h.sample_time,
       h.sql_id,
       h.con_id
)
SELECT TO_CHAR(h.sample_time, '&&cs_datetime_full_format.') sample_date_time,
       SUM(h.samples) samples,
       MAX(CASE h.row_number WHEN 1 THEN h.sql_id END) sql_id,
       SUM(CASE h.row_number WHEN 1 THEN h.samples ELSE 0 END) sessions,
       MAX(CASE WHEN h.row_number = 1 AND h.sql_id IS NOT NULL THEN h.plans END) plans,
       MAX(CASE h.row_number WHEN 1 THEN h.con_id END) con_id,       
       MAX(CASE WHEN h.row_number = 1 AND h.sql_id IS NOT NULL THEN (SELECT SUBSTR(q.sql_text, 1, 100) FROM v$sqlstats q WHERE q.sql_id = h.sql_id AND ROWNUM = 1) END) sql_text_100_only
  FROM ash_by_sample_and_sql h
 GROUP BY
       h.sample_time
 ORDER BY
       h.sample_time
/
--
BREAK ON sample_date_time SKIP PAGE;
PRO
PRO ASH by sample time, SQL_ID and timed class
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT TO_CHAR(h.sample_time, '&&cs_datetime_full_format.') sample_date_time,
       COUNT(*) samples, 
       h.sql_id, 
       h.con_id,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class END on_cpu_or_wait_class,
       (SELECT SUBSTR(q.sql_text, 1, 100) FROM v$sqlstats q WHERE q.sql_id = h.sql_id AND ROWNUM = 1) sql_text_100_only
  FROM v$active_session_history h
 WHERE h.sample_time BETWEEN TO_TIMESTAMP('&&cs_sample_time_from.', '&&cs_datetime_full_format.') AND TO_TIMESTAMP('&&cs_sample_time_to.', '&&cs_datetime_full_format.')
 GROUP BY
       h.sample_time,
       h.sql_id, 
       h.con_id,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class END
 ORDER BY
       h.sample_time,
       samples DESC,
       h.sql_id,
       h.con_id,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class END
/
--
COL blocking_session_status FOR A11 HEA 'Blocking|Session|Status';
COL sql_plan_hash_value FOR 9999999999 HEA 'Plan|Hash Value';
COL sql_plan_line_id FOR 9999 HEA 'Plan|Line';
COL sql_child_number FOR 999999 HEA 'Child|Number';
COL sql_exec_id FOR 99999999 HEA 'Exec ID';
COL current_obj# FOR 9999999999 HEA 'Current|Obj#';
COL current_file# FOR 9999999999 HEA 'Current|File#';
COL current_block# FOR 9999999999 HEA 'Current|Block#';
COL current_row# FOR 9999999999 HEA 'Current|Row#';
COL in_connection_mgmt FOR A6 HEA 'In|Connec|Mgmt';
COL in_parse FOR A6 HEA 'In|Parse';
COL in_hard_parse FOR A6 HEA 'In|Hard|Parse';
COL in_sql_execution FOR A6 HEA 'In|SQL|Exec';
COL in_plsql_execution FOR A6 HEA 'In|PLSQL|Exec';
COL in_plsql_rpc FOR A6 HEA 'In|PLSQL|RPC';
COL in_plsql_compilation FOR A6 HEA 'In|PLSQL|Compil';
COL in_java_execution FOR A6 HEA 'In|Java|Exec';
COL in_bind FOR A6 HEA 'In|Bind';
COL in_cursor_close FOR A6 HEA 'In|Cursor|Close';
COL in_sequence_load FOR A6 HEA 'In|Seq|Load';
COL top_level_sql_id FOR A13 HEA 'Top Level|SQL_ID';
COL is_sqlid_current FOR A4 HEA 'Is|SQL|Exec';
--
BREAK ON sample_date_time SKIP PAGE ON machine SKIP 1;
PRO
PRO ASH by sample time, appl server, session and SQL_ID
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT TO_CHAR(h.sample_time, '&&cs_datetime_full_format.') sample_date_time,
       h.machine,
       's:'||h.session_id||','||h.session_serial# session_serial,
       h.blocking_session_status,
       CASE WHEN h.blocking_session IS NOT NULL THEN 'b:'||h.blocking_session||','||h.blocking_session_serial# END blocking_session_serial,
       h.sql_id,
       h.is_sqlid_current,
       h.sql_plan_hash_value,
       h.sql_plan_line_id,
       h.sql_child_number,
       h.sql_exec_id,
       h.top_level_sql_id,
       h.con_id,
       CASE h.session_state WHEN 'ON CPU' THEN h.session_state ELSE h.wait_class||' - '||h.event END on_cpu_or_wait_event,
       (SELECT SUBSTR(q.sql_text, 1, 100) FROM v$sqlstats q WHERE q.sql_id = h.sql_id AND ROWNUM = 1) sql_text_100_only,
       h.current_obj#,
       h.current_file#,
       h.current_block#,
       h.current_row#,
       h.in_connection_mgmt,
       h.in_parse,
       h.in_hard_parse,
       h.in_sql_execution,
       h.in_plsql_execution,
       h.in_plsql_rpc,
       h.in_plsql_compilation,
       h.in_java_execution,
       h.in_bind,
       h.in_cursor_close,
       h.in_sequence_load
  FROM v$active_session_history h
 WHERE h.sample_time BETWEEN TO_TIMESTAMP('&&cs_sample_time_from.', '&&cs_datetime_full_format.') AND TO_TIMESTAMP('&&cs_sample_time_to.', '&&cs_datetime_full_format.')
 ORDER BY
       h.sample_time,
       h.machine,
       h.session_id,
       h.session_serial#,
       h.sql_id
/
--
PRO
PRO SQL> @&&cs_script_name..sql "&&cs_sample_time_from." "&&cs_sample_time_to."
--
@@cs_internal/cs_spool_tail.sql
@@cs_internal/cs_undef.sql
@@cs_internal/cs_reset.sql
--