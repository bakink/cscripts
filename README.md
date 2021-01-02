CS Scripts Inventory by Type
============================
* Latency
* Load
* SQL Performance
* SPBL - SQL Plan Baselines
* SPCH - SQL Patches
* SPRF - SQL Profiles
* Sessions
* Blocked Sessions
* Snapper (by Tanel Poder)
* Locks
* Space
* Container
* System - Resources, Metrics, Stats and Events
* Configuration
* Logs
* Traces
* Reports
* Miscellaneous Utilities

Latency
-------
* l.sql | cs_latency.sql                                        - Current SQL latency (elapsed time over executions)
* cs_sql_latency_histogram.sql                                  - SQL Latency Histogram (elapsed time over executions)
* cs_sql_perf_long_executions.sql                               - SQL Executions longer than N seconds
* cs_dg_redo_dest_resp_histogram_chart.sql                      - Data Guard (DG) REDO Transport Duration Chart
* cs_dg_redo_dest_resp_histogram_report.sql                     - Data Guard (DG) REDO Transport Duration Report

Load
----
* ta.sql | t.sql | cs_top.sql                                   - Top N Active SQL as per recent (AAS) Average Active Sessions (text report)
* aa.sql | cs_ash_analytics.sql                                 - Poor-man's version of ASH Analytics for all Timed Events (Average Active Sessions AAS)
* ma.sql | cs_max_ash_analytics.sql                             - Poor-man's version of ASH Analytics for all Timed Events (Maximum Active Sessions MAS)
* cpu.sql | cs_cpu_demand.sql                                   - Poor-man's version of ASH Analytics for CPU Demand (ON CPU + Scheduler)
* cs_timed_event_top_consumers_pie.sql                          - Top contributors of a given Wait Class or Event (pie chart)
* cs_timed_event_top_consumers_report.sql                       - Top contributors of a given Wait Class or Event (text report)
* cs_osstat_cpu_load_chart.sql                                  - CPU Cores Load as per OS Stats from AWR (time series chart)
* cs_osstat_cpu_busy_chart.sql                                  - CPU Cores Busyness as per OS Stats from AWR (time series chart)
* cs_osstat_cpu_report.sql                                      - CPU Cores Load and Busyness as per OS Stats from AWR (time series report)
* cs_pdb_cpu_iod_chart.sql                                      - AAS on CPU percentiles for one PDB as per IOD metadata (time series chart)

SQL Performance
---------------
* p.sql | cs_sqlperf.sql                                        - Basic SQL performance metrics for a given SQL_ID
* x.sql | cs_planx.sql                                          - Execution Plans and SQL performance metrics for a given SQL_ID
* tc.sql | cs_top_chart.sql                                     - Top SQL as per some SQL Statistics Computed Metric (time series chart)
* tr.sql | cs_top_report.sql                                    - Top SQL as per some SQL Statistics Computed Metric (text report)
* tsh.sql | cs_sqlstat_hist_top_report.sql                      - SQL Statistics History (AWR) - Top SQL Report
* tsm.sql | cs_sqlstat_mem_top_report.sql                       - SQL Statistics Current (MEM) - Top SQL Report
* ssc.sql | cs_sqlstat_chart.sql                                - SQL Statistics for a SQL set (time series chart)
* cs_sqltext.sql                                                - SQL Text for a given SQL_ID
* pm.sql | cs_planm.sql                                         - Execution Plans in Memory for a given SQL_ID
* ph.sql | cs_planh.sql                                         - Execution Plans in AWR for a given SQL_ID
* dc.sql                                                        - Display Cursor Execution Plan. Execute this script after one SQL for which you want to see the Execution Plan
* dp.sql                                                        - Display Plan Table Explain Plan. Execute this script after one EXPLAIN PLAN FOR for a SQL for which you want to see the Explain Plan
* cs_sqlmon_hist.sql                                            - SQL Monitor Report for a given SQL_ID (from AWR)
* cs_sqlmon_mem.sql                                             - SQL Monitor Report for a given SQL_ID (from MEM)
* cs_sqlmon_duration_chart.sql                                  - SQL Monitor Reports duration for a given SQL_ID (time series chart)
* cs_sqlmon_capture.sql                                         - Generate SQL Monitor Reports for given SQL_ID for a short period of time
* cs_sql_perf_concurrency.sql                                   - Concurrency Histogram of SQL with more than N Concurrent Sessions
* cs_sql_perf_high_aas.sql                                      - SQL with AAS per hour for a given Timed Event higher than N (time series text report)
* cs_purge_cursor.sql                                           - Purge Cursor(s) for SQL_ID using DBMS_SHARED_POOL.PURGE and SQL Patch

SPBL - SQL Plan Baselines
-------------------------
* cs_spbl_create.sql                                            - Create a SQL Plan Baseline for given SQL_ID
* cs_spbl_drop.sql                                              - Drop one or all SQL Plan Baselines for given SQL_ID
* cs_spbl_list.sql                                              - Summary list of SQL Plan Baselines for given SQL_ID
* cs_spbl_plan.sql                                              - Display SQL Plan Baseline for given SQL_ID
* cs_spbl_enable.sql                                            - Enable one or all SQL Plan Baselines for given SQL_ID
* cs_spbl_disable.sql                                           - Disable one or all SQL Plan Baselines for given SQL_ID
* cs_spbl_accept.sql                                            - Accept one or all SQL Plan Baselines for given SQL_ID
* cs_spbl_fix.sql                                               - Fix one or all SQL Plan Baselines for given SQL_ID
* cs_spbl_unfix.sql                                             - Unfix one or all SQL Plan Baselines for given SQL_ID
* z.sql | cs_spbl_zap.sql                                       - Zap a SQL Plan Baseline for given SQL_ID or entire PDB or entire CDB
* zl.sql | cs_spbl_zap_hist_list.sql                            - SQL Plan Baseline - Zapper History List
* zr.sql | cs_spbl_zap_hist_report.sql                          - SQL Plan Baseline - Zapper History Report
* zi.sql | cs_spbl_zap_ignore.sql                               - Add SQL_ID to Zapper white list (Zapper to ignore such SQL_ID)
* zd.sql | cs_spbl_zap_disable.sql                              - Disable ZAPPER on CDB
* ze.sql | cs_spbl_zap_enable.sql                               - Enable ZAPPER on CDB
* cs_spbl_stgtab.sql                                            - Creates Staging Table for SQL Plan Baselines
* cs_spbl_stgtab_delete.sql                                     - Deletes Staging Table for SQL Plan Baselines
* cs_spbl_pack.sql                                              - Packs into staging table one or all SQL Plan Baselines for given SQL_ID
* cs_spbl_unpack.sql                                            - Unpacks from staging table one or all SQL Plan Baselines for given SQL_ID
* cs_spbl_expdp.sql                                             - Packs into staging table one or all SQL Plan Baselines for given SQL_ID and Exports such Baselines using Datapump
* cs_spbl_impdp.sql                                             - Imports from Datapump file into a staging table all SQL Plan Baselines and Unpacks from staging table one or all SQL Plan Baselines for given SQL
* create_spb_from_awr                                           - Create SQL Plan Baselin from AWR Plan (legacy script)
* create_spb_from_cur                                           - Create SQL Plan Baseline from SQL Cursor (legacy script)
* spm_backup.sql                                                - Create DATAPUMP backup of SQL Plan Management (SPM) Repository for one PDB

SPCH - SQL Patches
------------------
* cs_spch_create.sql                                            - Create a SQL Patch for given SQL_ID
* cs_spch_drop.sql                                              - Drop all SQL Patches for given SQL_ID
* cs_spch_list.sql                                              - Summary list of SQL Patches for given SQL_ID
* cs_spch_plan.sql                                              - Display SQL Patch Plan for given SQL_ID
* cs_spch_enable.sql                                            - Enable one or all SQL Patches for given SQL_ID
* cs_spch_disable.sql                                           - Disable one or all SQL Patches for given SQL_ID
* cs_spch_stgtab.sql                                            - Creates Staging Table for SQL Patches
* cs_spch_pack.sql                                              - Packs into staging table one or all SQL Patches for given SQL_ID
* cs_spch_unpack.sql                                            - Unpack from staging table one or all SQL Patches for given SQL_ID
* cs_spch_xfr.sql                                               - Transfers a SQL Patch for given SQL_ID
* cs_spch_category.sql                                          - Changes category for a SQL Patch for given SQL_ID

SPRF - SQL Profiles
-------------------
* cs_sprf_create.sql                                            - Create a SQL Profile for given SQL_ID
* cs_sprf_drop.sql                                              - Drop all SQL Profiles for given SQL_ID
* cs_sprf_list.sql                                              - Summary list of SQL Profiles for given SQL_ID
* cs_sprf_plan.sql                                              - Display SQL Profile Plan for given SQL_ID
* cs_sprf_enable.sql                                            - Enable one or all SQL Profiles for given SQL_ID
* cs_sprf_disable.sql                                           - Disable one or all SQL Profiles for given SQL_ID
* cs_sprf_stgtab.sql                                            - Creates Staging Table for SQL Profiles
* cs_sprf_pack.sql                                              - Packs into staging table one or all SQL Profiles for given SQL_ID
* cs_sprf_unpack.sql                                            - Unpack from staging table one or all SQL Profiles for given SQL_ID
* cs_sprf_xfr.sql                                               - Transfers a SQL Profile for given SQL_ID
* cs_sprf_export.sql                                            - Exports Execution Plans for some SQL_ID or all SQL on a PDB using SQL Profile(s)
* cs_sprf_category.sql                                          - Changes category for a SQL Profile for given SQL_ID
* coe_xfr_sql_profile.sql                                       - Transfer (copy) a SQL Profile from PDBx on CDBa into PDBy on CDBb (legacy script)

Sessions
--------
* ah.sql | cs_ash_awr_sample_report.sql                         - Detailed List of ASH samples from AWR
* am.sql | cs_ash_mem_sample_report.sql                         - Detailed List of ASH Samples from MEM
* a.sql | as.sql | cs_active_sessions.sql                       - Active Sessions including SQL Text and Exection Plan
* cs_sql_sessions.sql                                           - Recent and Active Sessions executing a SQL_ID
* cs_sessions.sql                                               - Simple list of all current Sessions (all types and all statuses)
* cs_sessions_PCTL_by_machine.sql                               - Sessions Percentiles by Machine
* cs_sessions_by_type_and_status_chart.sql                      - Sessions by Type and Status (time series chart)
* cs_sessions_by_machine_chart.sql                              - Sessions by Machine (time series chart)
* cs_sessions_by_pdb_chart.sql                                  - Sessions by PDB (time series chart)
* cs_sess_mon.sql                                               - Monitored Sessions
* cs_kill_sid.sql                                               - Kill one User Session
* cs_kill_sql_id.sql                                            - Kill User Sessions executing some SQL_ID
* cs_kill_root_blockers.sql                                     - Kill Root Blocker User Sessions 
* cs_kill_machine.sql                                           - Kill User Sessions connected from some Machine(s)
* cs_kill_scheduler.sql                                         - Kill User Sessions waiting on Scheduler (Resource Manager)
* mysid.sql                                                     - Get SID and SPID of own Session
* open_cursor.sql                                               - Open Cursors and Count of Distinct SQL_ID per Session
* session_undo.sql                                              - Displays undo information on relevant database sessions (by Tim Hall)

Blocked Sessions
----------------
* cs_blocked_sessions_ash_awr_report.sql                        - Top Session Blockers as per ASH from AWR (text report)
* cs_blocked_sessions_ash_awr_chart.sql                         - Top Session Blockers as per ASH from AWR (time series chart)
* cs_blocked_sessions_ash_awr_pie.sql                           - Top Session Blockers as per ASH from AWR (summary pie chart)
* cs_blocked_sessions_ash_awr_pie_detailed.sql                  - Top Session Blockers as per ASH from AWR (detailed pie chart)
* cs_blocked_sessions_ash_mem_report.sql                        - Top Session Blockers as per ASH from Memory (text report)
* cs_blocked_sessions_ash_mem_chart.sql                         - Top Session Blockers as per ASH from Memory (time series chart)
* cs_blocked_sessions_ash_mem_pie.sql                           - Top Session Blockers as per ASH from Memory (summary pie chart)
* cs_blocked_sessions_ash_mem_pie_detailed.sql                  - Top Session Blockers as per ASH from Memory (detailed pie chart)
* cs_blocked_sessions_by_inactive_machine_ash_awr_chart.sql     - Top Session Blockers by Inactive Machine as per ASH from AWR (time series chart)
* cs_blocked_sessions_by_inactive_machine_ash_mem_chart.sql     - Top Session Blockers by Inactive Machine as per ASH from Memory (time series chart)
* cs_blocked_sessions_by_session_ash_awr_chart.sql              - Top Session Blockers by Root Session as per ASH from AWR (time series chart)
* cs_blocked_sessions_by_session_ash_mem_chart.sql              - Top Session Blockers by Root Session as per ASH from Memory (time series chart)

Snapper (by Tanel Poder)
------------------------
* snap.sql                                                      - Sampling SID all with interval 5 seconds, taking 1 snapshots
* snapper_top.sql | cs_snapper_top.sql                          - Sessions Snapper for all sessions using Tanel Poder Snapper
* snapper_sql_id.sql | cs_snapper_sql_id.sql                    - Sessions Snapper for one SQL_ID using Tanel Poder Snapper
* snapper_sid.sql | cs_snapper_sid.sql                          - Sessions Snapper for one SID using Tanel Poder Snapper
* snapper_spid.sql | cs_snapper_spid.sql                        - Sessions Snapper for one SPID (OS PID) using Tanel Poder Snapper
* snapper_machine.sql | cs_snapper_machine.sql                  - Sessions Snapper for one Machine using Tanel Poder Snapper
* snapper_module.sql | cs_snapper_module.sql                    - Sessions Snapper for one Module using Tanel Poder Snapper
* snapper_service.sql | cs_snapper_service.sql                  - Sessions Snapper for one Service using Tanel Poder Snapper

Locks
-----
* locks.sql | cs_locks.sql                                      - Locks Summary and Details
* cs_locks_mon.sql                                              - Locks Summary and Details - Monitor
* cs_wait_chains.sql                                            - Wait Chains (text report)

Space
-----
* cs_df_u02_chart.sql                                           - Disk FileSystem u02 Utilization Chart
* cs_top_pdb_size_chart.sql                                     - Top PDB Disk Size Utilization (time series chart)
* cdb_tablespace_usage_metrics.sql                              - Application Tablespace Inventory for all PDBs
* cs_tablespaces.sql                                            - Tablespace Utilization (text report)
* cs_tablespace_chart.sql                                       - Tablespace Utilization (time series chart)
* cs_extents_map.sql                                            - Tablespace Block Map
* cs_top_segments.sql                                           - Top CDB or PDB Segments (text report)
* cs_top_segments_pdb.sql                                       - Top PDB Segments (text report)
* cs_segment_chart.sql                                          - Segment Size GBs for given Segment (time series chart)
* cs_tempseg_usage.sql                                          - Temporary (Temp) Segment Usage (text report)
* cs_table_segments_chart.sql                                   - Table-related Segment Size GBs (Table, Indexes and Lobs) for given Table (time series chart)
* cs_redef_table.sql                                            - Table Redefinition
* cs_redef_table_with_purge.sql                                 - Table Redefinition with Purge
* cs_redef_schema.sql                                           - Schema Redefinition (by moving all objects into new Tablespace)
* drop_redef_table_pdb.sql                                      - Generate commands to drop stale objects from failed Table Redefinitions for PDB
* drop_redef_table_cdb.sql                                      - Generate commands to drop stale objects from failed Table Redefinitions for CDB
* cs_table_redefinition_hist_report.sql                         - Table Redefinition History Report (IOD_REPEATING_SPACE_MAINTENANCE log)
* cs_estimate_table_size.sql                                    - Estimate Table Size
* cs_tables.sql                                                 - All Tables and Top N Tables (text report)
* cs_top_tables.sql                                             - Top Tables according to Segment(s) size (text report)
* cs_top_table_size_chart.sql                                   - Top PDB Tables (time series chart)
* cs_table.sql                                                  - Table Details
* cs_table_stats_chart.sql                                      - CBO Statistics History for given Table (time series chart)
* cs_table_stats_report.sql                                     - CBO Statistics History for given Table (time series text report)
* cs_table_mod_chart.sql                                        - Table Modification History (INS, DEL and UPD) for given Table (time series chart)
* cs_table_mod_report.sql                                       - Table Modification History (INS, DEL and UPD) for given Table (text report)
* cs_estimate_index_size.sql                                    - Estimate Index Size
* cs_top_bloated_indexes.sql                                    - Top bloated indexes on a PDB (text report)
* cs_top_indexes.sql                                            - Top Indexes according to Segment(s) size
* cs_index_part_reorg.sql                                       - Calculate index reorg savings
* cs_index_usage.sql                                            - Index Usage (is an index still in use?)
* cs_index_rebuild_hist_report.sql                              - Index Rebuild History (IOD_REPEATING_SPACE_MAINTENANCE log)
* cs_recyclebin.sql                                             - Recyclebin Content
* cs_top_lobs.sql                                               - Top Lobs according to Segment(s) size

Container
---------
* cdb.sql                                                       - Connect into CDB$ROOT
* pdb.sql                                                       - List all PDBs and Connect into one PDB

System - Resources, Metrics, Stats and Events
---------------------------------------------
* dbrmr.sql | cs_rsrc_mgr_report.sql                            - Database Resource Manager (DBRM) Report
* dbrmu.sql | cs_rsrc_mgr_update.sql                            - Database Resource Manager (DBRM) Update
* cs_resource_limit_chart.sql                                   - Resource Limit (time series chart)
* cs_sysmetric_hist_chart.sql                                   - Subset of System Metrics Summary from AWR (time series chart)
* cs_sysmetric_mem_chart.sql                                    - Subset of System Metrics Summary for last one hour (time series chart)
* cs_sysmetric_last_hour.sql                                    - All System Metrics Summary (AVG and MAX) for last one hour (text report)
* cs_sysmetric_current.sql                                      - All System Metrics current value  (text report)
* cs_sysmetric_hist_chart_cpu                                   - CPU System Metrics Summary from AWR (time series chart)
* cs_sysmetric_mem_chart_cpu.sql                                - CPU System Metrics Summary for last one hour (time series chart)
* cs_sysstat_hist_chart.sql                                     - Subset of System Statistics from AWR (time series chart)
* cs_sysstat_hist_chart_io.sql                                  - IO System Statistics from AWR (time series chart)
* cs_system_event_hist_latency_chart.sql                        - Subset of System Event Latency from AWR (time series chart)
* cs_system_event_hist_load_char.sql                            - Subset of System Event AAS Load from AWR (time series chart)
* cs_system_event_histogram_chart.sql                           - One System Event AAS Load Histogram from AWR as per Latency Bucket (time series chart)
* cs_total_and_parse_cpu_to_db_chart.sql                        - Total and Parse CPU-to-DB Ratio from AWR (time series chart)
* cs_total_and_parse_db_and_cpu_aas_chart.sql                   - Total and Parse DB and CPU Average Active Sessions (AAS) from AWR (time series chart)

Configuration
-------------
* cs_dba_hist_parameter.sql                                     - System Parameters History
* cs_sgastat_awr_area_chart.sql                                 - SGA Pools History Chart from AWR
* cs_sgastat_awr_line_chart.sql                                 - SGA Pools History Chart from AWR (include free memory)
* cs_sgastat_awr_report.sql                                     - SGA Pools History Report from AWR (include free memory)
* dba_high_water_mark_statistics                                - Database High Water Mark (HWM) Statistics
* spfile.sql                                                    - SPFILE Parameters (from PDB or CDB)
* pdb_spfile.sql                                                - PDB SPFILE Parameters (from CDB)
* syncup_pdb_parameters_to_standbys.sql                         - Sync up SPFILE PDB Parameters from Primary into Standby and Bystander
* hidden_parameter.sql                                          - Get value of one hidden parameter
* hidden_parameters.sql                                         - Get value of all hidden parameters

Logs
----
* log.sql                                                       - REDO Log on Primary and Standby
* log_history.sql                                               - REDO Log History 
* archived_log.sql                                              - Archived Logs list

Traces
------
* alert_log_tail.sql                                            - Last 50 lines of alert log refreshed every 5 seconds 20 times 
* cs_alert_log.sql                                              - Get alert log
* cs_LGWR_trc.sql                                               - Get log writer LGWR trace
* cs_DBRM_trc.sql                                               - Get database resource manager DBRM trace
* cs_hanganalyze.sql                                            - Generate Hanganalyze Trace
* cs_systemstate.sql                                            - Generate System State Dump Trace
* cs_trace_session.sql                                          - Trace one session given a SID
* trace_10046_on.sql                                            - Turn ON SQL Trace EVENT 10046 LEVEL 12 on own Session
* trace_10046_off.sql                                           - Turn OFF SQL Trace on own Session
* trace_10053_on.sql                                            - Turn ON CBO EVENT 10053 LEVEL 1 on own Session
* trace_10053_off.sql                                           - Turn OFF CBO EVENT 10053 on own Session

Reports
-------
* awrrpt.sql                                                    - AWR Report
* awrddrpt.sql                                                  - AWR Difference Report
* ashrpt.sql                                                    - ASH report
* awrsqrpt.sql                                                  - AWR SQL Report
* awr_snapshot.sql                                              - Create AWR snapshot
* dbms_stats_report.sql                                         - DBMS_STATS Report
* cs_amw_report.sql                                             - Automatic Maintenance Window Report

Miscellaneous Utilities
-----------------------
* cs_fs.sql                                                     - Find SQL statements matching some string
* pr.sql | cs_pr.sql                                            - Print Table (vertical display of result columns for last query)
* cs_burn_cpu.sql                                               - Burn CPU in multiple cores/threads for some time
* cs_hexdump_to_timestamp.sql                                   - Convert Hexadecimal Dump to Time
* cs_epoch_to_time.sql                                          - Convert Epoch to Time
* cs_time_to_epoch.sql                                          - Convert Time to Epoch
* opatch.sql                                                    - Oracle Patch Registry and History
* reason_not_shared.sql                                         - Reasons for not sharing Cursors
* sysdate.sql                                                   - Display SYSDATE in Filename safe format and in YYYY-MM-DDTHH24:MI:SS UTC format
* view.sql                                                      - Display Text of a given VIEW name

Use h.sql or help.sql for "cs" scripts inventory by type, and ls.sql for alphabetical list of "cs" scripts.
Type q to exit. 
