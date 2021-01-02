----------------------------------------------------------------------------------------
--
-- File name:   ssc.sql | cs_sqlstat_chart.sql
--
-- Purpose:     SQL Statistics for a SQL set (time series chart)
--
-- Author:      Carlos Sierra
--
-- Version:     2020/12/16
--
-- Usage:       Execute connected to CDB or PDB.
--
--              Enter optional parameters when requested.
--
-- Example:     $ sqlplus / as sysdba
--              SQL> @cs_sqlstat_chart.sql
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
DEF cs_script_name = 'cs_sqlstat_chart';
DEF cs_script_acronym = 'ssc.sql | ';
--
DEF cs_display_awr_days = '60';
DEF cs_hours_range_default = '168';
--
@@cs_internal/cs_sample_time_from_and_to.sql
@@cs_internal/cs_snap_id_from_and_to.sql
--
COL oldest_snap_id NEW_V oldest_snap_id NOPRI;
SELECT TO_CHAR(MAX(snap_id)) oldest_snap_id 
  FROM dba_hist_snapshot
 WHERE dbid = &&cs_dbid.
   AND instance_number = &&cs_instance_number.
   AND end_interval_time < SYSDATE - &&cs_display_awr_days.
/
SELECT NVL('&&oldest_snap_id.', TO_CHAR(MIN(snap_id))) oldest_snap_id 
  FROM dba_hist_snapshot
 WHERE dbid = &&cs_dbid.
   AND instance_number = &&cs_instance_number.
/
--
PRO
PRO Metric Group
PRO ~~~~~~~~~~~~
PRO db_time      : ET, CPU, IO, Appl and Conc Times as AAS
PRO latency      : ET, CPU, IO, Appl and Conc Times per Exec
PRO time_per_row : ET, CPU, IO, Appl and Conc Times per Row Returned
PRO calls        : Parse, Execution and Fetch counts
PRO rows_sec     : Rows Processed per Second
PRO rows_exec    : Rows Processed per Exec
PRO reads_sec    : Buffer Gets and Disk Reads per Second
PRO reads_exec   : Buffer Gets and Disk Reads per Exec
PRO reads_per_row: Buffer Gets and Disk Reads per Row Returned
PRO cursors      : Loads, Invalidations and Version Count
PRO memory       : Sharable Memory
PRO ~~~ groups ~~~
PRO Main         : db_time, latency, calls, rows_exec, reads_exec, reads_per_row
PRO Time         : db_time, latency, time_per_row
PRO Rows         : time_per_row, rows_sec, rows_exec, reads_per_row
PRO Gets         : reads_sec, reads_exec, reads_per_row
PRO *            : All
PRO
PRO 3. Metric Group (name or group, case sensitive): [{Main}|<metric_group>|<group_name>]
DEF metric_group = '&3.';
UNDEF 3;
COL metric_group NEW_V metric_group NOPRI;
SELECT NVL('&&metric_group.', 'Main') metric_group FROM DUAL
/
--
PRO
PRO Filtering SQL to reduce search space.
PRO Ignore this parameter when executed on a non-KIEV database.
PRO *=All, TP=Transaction Processing, RO=Read Only, BG=Background, IG=Ignore, UN=Unknown
PRO
PRO 4. SQL Type: [{*}|TP|RO|BG|IG|UN|TP,RO|TP,RO,BG] 
DEF kiev_tx = '&4.';
UNDEF 4;
COL kiev_tx NEW_V kiev_tx NOPRI;
SELECT UPPER(NVL(TRIM('&&kiev_tx.'), '*')) kiev_tx FROM DUAL
/
--
PRO
PRO Filtering SQL to reduce search space.
PRO Enter additional SQL Text filtering, such as Table name or SQL Text piece
PRO
PRO 5. SQL Text piece (e.g.: ScanQuery, getValues, TableName, IndexName):
DEF sql_text_piece = '&5.';
UNDEF 5;
--
PRO
PRO Filtering SQL to reduce search space.
PRO
PRO 6. SQL_ID (optional):
DEF sql_id = '&6.';
UNDEF 6;
--
PRO
PRO Filtering SQL to reduce search space.
PRO
PRO 7. Plan Hash Value (optional):
DEF phv = '&7.';
UNDEF 7;
--
PRO
PRO Filtering SQL to reduce search space.
PRO
PRO 8. Parsing Schema Name (optional):
DEF parsing_schema_name = '&8.';
UNDEF 8;
--
SET HEA OFF;
SPO cs_dynamic_driver.sql
          SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "db_time"' FROM DUAL WHERE '&&metric_group.' IN ('db_time', 'Time', 'Main', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "latency"' FROM DUAL WHERE '&&metric_group.' IN ('latency', 'Time', 'Main', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "time_per_row"' FROM DUAL WHERE '&&metric_group.' IN ('time_per_row', 'Time', 'Rows', 'Main', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "calls"' FROM DUAL WHERE '&&metric_group.' IN ('calls', 'Main', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "rows_sec"' FROM DUAL WHERE '&&metric_group.' IN ('rows_sec', 'Rows', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "rows_exec"' FROM DUAL WHERE '&&metric_group.' IN ('rows_exec', 'Rows', 'Main', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "reads_sec"' FROM DUAL WHERE '&&metric_group.' IN ('reads_sec', 'Gets', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "reads_exec"' FROM DUAL WHERE '&&metric_group.' IN ('reads_exec', 'Gets', 'Main', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "reads_per_row"' FROM DUAL WHERE '&&metric_group.' IN ('reads_per_row', 'Rows', 'Gets', 'Main', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "cursors"' FROM DUAL WHERE '&&metric_group.' IN ('cursors', '*')
UNION ALL SELECT '@@cs_internal/cs_sqlstat_chart_internal.sql "memory"' FROM DUAL WHERE '&&metric_group.' IN ('memory', '*')
/
SPO OFF;
SET HEA ON;
@cs_dynamic_driver.sql
HOST rm cs_dynamic_driver.sql
--
@@cs_internal/cs_undef.sql
@@cs_internal/cs_reset.sql
--