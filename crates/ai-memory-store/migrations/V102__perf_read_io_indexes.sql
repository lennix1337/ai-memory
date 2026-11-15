-- Lookup index for handoffs by source session, avoiding project-wide handoff scans
-- in `latest_interrupted_session_candidate` and `recent_session_activity`.
CREATE INDEX IF NOT EXISTS idx_handoffs_from_session
    ON handoffs(workspace_id, project_id, from_session_id, created_at DESC)
    WHERE from_session_id IS NOT NULL;

-- Partial index for open sessions per project regardless of agent_kind,
-- avoiding scanning closed session rows in `latest_interrupted_session_candidate`
-- and `list_projects_with_stats`.
CREATE INDEX IF NOT EXISTS idx_sessions_open_started
    ON sessions(workspace_id, project_id, started_at DESC)
    WHERE ended_at IS NULL;

-- Populate sqlite_stat1 so SQLite's query planner selects selective partial
-- indexes (e.g. is_latest = 1) over broad validity indexes.
ANALYZE;
