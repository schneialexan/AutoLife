-- Ensure pgTAP exists for subsequent RLS SQL tests (no enclosing transaction — other suites re-run fixtures).

\set ON_ERROR_STOP on

create extension if not exists pgtap with schema extensions;

select plan(1);

select ok(true, 'pgtap extension is available');

select * from finish();
