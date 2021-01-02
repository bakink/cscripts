----------------------------------------------------------------------------------------
--
-- File name:   cs_blocked_sessions_ash_mem_chart.sql
--
-- Purpose:     Top Session Blockers as per ASH from Memory (time series chart)
--
-- Author:      Carlos Sierra
--
-- Version:     2020/12/06
--
-- Usage:       Execute connected to CDB or PDB
--
--              Enter range of dates and filters when requested.
--
-- Example:     $ sqlplus / as sysdba
--              SQL> @cs_blocked_sessions_ash_mem_chart.sql
--
-- Notes:       Developed and tested on 12.1.0.2.
--
---------------------------------------------------------------------------------------
--
@@cs_internal/cs_primary.sql
@@cs_internal/cs_set.sql
@@cs_internal/cs_def.sql
@@cs_internal/cs_file_prefix.sql
--
DEF cs_script_name = 'cs_blocked_sessions_ash_mem_chart';
DEF cs_hours_range_default = '3';
--
@@cs_internal/cs_sample_time_from_and_to.sql
@@cs_internal/cs_snap_id_from_and_to.sql
--
--ALTER SESSION SET container = CDB$ROOT;
--
SELECT '&&cs_file_prefix._&&cs_script_name.' cs_file_name FROM DUAL;
--
DEF report_title = 'Sample of Blocked Sessions between &&cs_sample_time_from. and &&cs_sample_time_to. UTC';
DEF chart_title = '&&report_title.';
DEF xaxis_title = 'Root Blocker Status: ACTIVE(inside DB), INACTIVE(outside DB) or UNKNOWN';
DEF vaxis_title = 'Blocked Sessions Count';
--
-- (isStacked is true and baseline is null) or (not isStacked and baseline >= 0)
DEF is_stacked = "isStacked: false,";
--DEF is_stacked = "isStacked: true,";
--DEF vaxis_baseline = ", baseline:&&cs_num_cpu_cores., baselineColor:'red'";
DEF vaxis_baseline = "";
DEF chart_foot_note_2 = '<br>2) ROOT BLOCKER SESSION STATUS "INACTIVE" means: Database is waiting for Application Host to release LOCK, while "UNKNOWN" could be a BACKGROUND session on CDB$ROOT.';
DEF chart_foot_note_3 = "<br>";
--DEF chart_foot_note_3 = "";
DEF chart_foot_note_4 = "";
DEF report_foot_note = 'SQL> @&&cs_script_name..sql "&&cs_sample_time_from." "&&cs_sample_time_to."';
--
@@cs_internal/cs_spool_head_chart.sql
--
PRO ,{label:'ACTIVE ON CPU', id:'1', type:'number'}
PRO ,{label:'ACTIVE WAITING', id:'2', type:'number'}
PRO ,{label:'INACTIVE', id:'3', type:'number'}
PRO ,{label:'UNKNOWN', id:'4', type:'number'}    
PRO ]
--
SET HEA OFF PAGES 0;
/****************************************************************************************/
WITH
FUNCTION num_format (p_number IN NUMBER, p_round IN NUMBER DEFAULT 0) 
RETURN VARCHAR2 IS
BEGIN
  IF p_number IS NULL OR ROUND(p_number, p_round) <= 0 THEN
    RETURN 'null';
  ELSE
    RETURN TO_CHAR(ROUND(p_number, p_round));
  END IF;
END num_format;
/****************************************************************************************/
ash AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       sample_id, 
       sample_time, 
       machine, 
       session_id, 
       session_serial#, 
       blocking_session, 
       blocking_session_serial#, 
       session_state, 
       wait_class, 
       event,
       sql_id,
       top_level_sql_id
  FROM v$active_session_history
 WHERE sample_time >= TO_TIMESTAMP('&&cs_sample_time_from.', '&&cs_datetime_full_format.') 
   AND sample_time < TO_TIMESTAMP('&&cs_sample_time_to.', '&&cs_datetime_full_format.')
),
inactive_sessions AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       DISTINCT 
       i.sample_id, 
       CAST(i.sample_time AS DATE) sample_time,
       i.blocking_session session_id,
       i.blocking_session_serial# session_serial#
  FROM ash i
 WHERE i.blocking_session IS NOT NULL
   AND i.blocking_session_serial# IS NOT NULL
   AND NOT EXISTS (
SELECT /*+ MATERIALIZE NO_MERGE */
       NULL
  FROM ash a
 WHERE a.sample_id = i.sample_id
   AND a.session_id = i.blocking_session
   AND a.session_serial# = i.blocking_session_serial#
)),
all_sessions AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       a.sample_id, CAST(a.sample_time AS DATE) sample_time, a.machine, a.session_id, a.session_serial#, a.blocking_session, a.blocking_session_serial#, 
       'ACTIVE' status, session_state, wait_class, event, sql_id, top_level_sql_id
  FROM ash a
 UNION ALL
SELECT /*+ MATERIALIZE NO_MERGE */
       i.sample_id, i.sample_time, NULL machine, i.session_id, i.session_serial#, TO_NUMBER(NULL), TO_NUMBER(NULL), 
       'INACTIVE or UNKNOWN' status, NULL session_state, NULL wait_class, NULL event, NULL sql_id, NULL top_level_sql_id
  FROM inactive_sessions i
),
sess_history AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       sample_id, sample_time, machine, session_id, session_serial#, status, session_state, wait_class, event, sql_id, top_level_sql_id,
       LEVEL lvl,
       CONNECT_BY_ROOT machine blocker_machine,
       CONNECT_BY_ROOT session_id blocker_session,
       CONNECT_BY_ROOT session_serial# blocker_session_serial#,
       CONNECT_BY_ISLEAF AS leaf
  FROM all_sessions
 START WITH blocking_session IS NULL AND blocking_session_serial# IS NULL
CONNECT BY sample_id = PRIOR sample_id AND blocking_session = PRIOR session_id AND blocking_session_serial# = PRIOR session_serial#
),
blockers AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       sample_id, sample_time, status, session_state, wait_class, event, sql_id, top_level_sql_id, session_id, session_serial#
  FROM sess_history
 WHERE lvl = 1
),
blockees AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       sample_id, sample_time, status, wait_class, event, blocker_session, blocker_session_serial#, COUNT(*) cnt
  FROM sess_history
 WHERE lvl > 1
 GROUP BY
       sample_id, sample_time, status, wait_class, event, blocker_session, blocker_session_serial#
),
machines AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       session_id, session_serial#, MAX(machine) machine
  FROM sess_history
 WHERE machine IS NOT NULL
 GROUP BY
       session_id, session_serial#
 UNION
SELECT /*+ MATERIALIZE NO_MERGE */
       sid session_id, serial# session_serial#, machine
  FROM v$session
),
blockers_and_blockees AS (
SELECT /*+ MATERIALIZE NO_MERGE */
       b.sample_id, 
       b.sample_time time, 
       a.wait_class||' - '||a.event AS wait_class_event,
       b.status blocker_status,
       b.session_state blocker_session_state, 
       b.wait_class blocker_wait_class, 
       b.event blocker_event,
       COALESCE(b.sql_id, b.top_level_sql_id) AS blocker_sql_id,
       NVL(m.machine, 'unknown') machine,
       b.session_id blocker_session_id, 
       b.session_serial# blocker_session_serial#,
       NVL(a.cnt, 0) sessions_blocked
  FROM blockers b,
       blockees a,
       machines m
 WHERE a.sample_id(+) = b.sample_id
   AND a.sample_time(+) = b.sample_time
   AND a.blocker_session(+) = b.session_id
   AND a.blocker_session_serial#(+) = b.session_serial#
   AND m.session_id(+) = b.session_id
   AND m.session_serial#(+) = b.session_serial#
)
/****************************************************************************************/
SELECT ', [new Date('||
       TO_CHAR(q.time, 'YYYY')|| /* year */
       ','||(TO_NUMBER(TO_CHAR(q.time, 'MM')) - 1)|| /* month - 1 */
       ','||TO_CHAR(q.time, 'DD')|| /* day */
       ','||TO_CHAR(q.time, 'HH24')|| /* hour */
       ','||TO_CHAR(q.time, 'MI')|| /* minute */
       ','||TO_CHAR(q.time, 'SS')|| /* second */
       ')'||
       ','||num_format(SUM(CASE q.blocker_session_state WHEN 'ON CPU' THEN q.sessions_blocked ELSE 0 END))|| -- ACTIVE ON CPU
       ','||num_format(SUM(CASE q.blocker_session_state WHEN 'WAITING' THEN q.sessions_blocked ELSE 0 END))|| -- ACTIVE WAITING
       ','||num_format(SUM(CASE q.blocker_status WHEN 'INACTIVE or UNKNOWN' THEN (CASE q.machine WHEN '&&cs_host_name.' THEN 0 ELSE q.sessions_blocked END) ELSE 0 END))|| -- INACTIVE
       ','||num_format(SUM(CASE q.blocker_status WHEN 'INACTIVE or UNKNOWN' THEN (CASE q.machine WHEN '&&cs_host_name.' THEN q.sessions_blocked ELSE 0 END) ELSE 0 END))|| -- UNKNOWN
       ']'
  FROM blockers_and_blockees q
 WHERE q.sessions_blocked > 0
 GROUP BY
       q.time
 ORDER BY
       q.time
/
/****************************************************************************************/
SET HEA ON PAGES 100;
--
-- [Line|Area|SteppedArea|Scatter]
DEF cs_chart_type = 'Scatter';
-- disable explorer with "//" when using Pie
DEF cs_chart_option_explorer = '';
-- enable pie options with "" when using Pie
DEF cs_chart_option_pie = '//';
-- use oem colors
DEF cs_oem_colors_series = '//';
DEF cs_oem_colors_slices = '//';
-- for line charts
DEF cs_curve_type = '//';
--
@@cs_internal/cs_spool_id_chart.sql
@@cs_internal/cs_spool_tail_chart.sql
PRO
PRO &&report_foot_note.
--
--ALTER SESSION SET CONTAINER = &&cs_con_name.;
--
@@cs_internal/cs_undef.sql
@@cs_internal/cs_reset.sql
--