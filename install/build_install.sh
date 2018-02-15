#!/bin/bash

echo "PRO  =============================  KS Review App =========================
" > master_install.sql
cat constraint_lookup.sql >> master_install.sql
cat ks_session_load.sql >> master_install.sql
cat ks_users.sql >> master_install.sql
cat ks_parameters.sql >> master_install.sql
cat ks_tracks.sql >> master_install.sql
cat ks_events.sql >> master_install.sql
cat ks_event_tracks.sql >> master_install.sql
cat ks_sessions.sql >> master_install.sql
cat ks_session_votes.sql >> master_install.sql
cat ks_tags.sql >> master_install.sql
cat ks_session_status.sql >> master_install.sql
echo '--  Seed Values -----------------------------' >> master_install.sql
cat ../conversion/seed_ks_tracks.sql >> master_install.sql
cat ../conversion/seed_ks_sessions_status.sql >> master_install.sql
cat ../conversion/seed_ks_events.sql >> master_install.sql
cat ../conversion/seed_ks_event_tracks.sql >> master_install.sql
cat ../conversion/seed_constraint_lookup.sql >> master_install.sql
echo '--  Install Code -----------------------------' >> master_install.sql
cat ../plsql/ks_tags_api.pls >> master_install.sql
cat ../plsql/ks_sec.pls >> master_install.sql
cat ../plsql/ks_api.pls >> master_install.sql
cat ../plsql/ks_util.pls >> master_install.sql
cat ../plsql/ks_error_handler.pls >> master_install.sql
cat ../plsql/ks_session_load_api.pls >> master_install.sql
cat ../plsql/ks_session_api.pls >> master_install.sql
cat ../plsql/ks_tags_api.plb >> master_install.sql
cat ../plsql/ks_error_handler.plb >> master_install.sql
cat ../plsql/ks_sec.plb >> master_install.sql
cat ../plsql/ks_api.plb >> master_install.sql
cat ../plsql/ks_util.plb >> master_install.sql
cat ../plsql/ks_session_load_api.plb >> master_install.sql
cat ../plsql/ks_session_api.plb >> master_install.sql
cat ../plsql/ks_users_iu.sql >> master_install.sql
echo '--  Post Install ---------------------------' >> master_install.sql
cat ks_tags_post_install.sql >> master_install.sql
echo '--  Seed Users -----------------------------' >> master_install.sql
cat ../conversion/seed_ks_users.sql >> master_install.sql

echo "Install file master_install.sql ready."
