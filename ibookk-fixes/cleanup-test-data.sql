-- 출시 직전 테스트 데이터 정리 스크립트 (⚠️ 실행 전 반드시 백업 확인 — 실행은 사용자 결정)
-- 대상: test+*/plaidtest*/apitest*/full+*/notice+*/cd+*/all+*/prod+*/m4+*/polish+*/verify-*/
--       ledger-e2e*/money-e2e*/tour+*/disp-e2e* 계정과 그 조직들.
-- admin@ibookk.test (Ibookk Demo Co)는 데모용으로 보존 — 지우려면 아래 주석 해제.
begin;
set local session_replication_role = replica;
create temp table _del_users as
  select id from auth.users
  where email ~ '^(test|plaidtest|apitest|full|notice|cd|all|prod|m4|polish|ledger-e2e|money-e2e|tour|disp-e2e)\+'
     or email like 'verify-%@ibookk.test';
  -- or email = 'admin@ibookk.test';
create temp table _del_orgs as
  select distinct organization_id as id from members where user_id in (select id from _del_users);
create temp table _del_entities as
  select id from entities where organization_id in (select id from _del_orgs);
delete from journal_lines where entity_id in (select id from _del_entities);
delete from journal_entries where entity_id in (select id from _del_entities);
delete from bill_payments where entity_id in (select id from _del_entities);
delete from bill_lines where bill_id in (select id from bills where entity_id in (select id from _del_entities));
delete from bills where entity_id in (select id from _del_entities);
delete from invoice_payments where entity_id in (select id from _del_entities);
delete from invoice_lines where invoice_id in (select id from invoices where entity_id in (select id from _del_entities));
delete from invoices where entity_id in (select id from _del_entities);
delete from transactions where entity_id in (select id from _del_entities);
delete from bank_connections where entity_id in (select id from _del_entities);
delete from plaid_items where entity_id in (select id from _del_entities);
delete from receipts where entity_id in (select id from _del_entities);
delete from irs_notices where entity_id in (select id from _del_entities);
delete from compliance_obligations where entity_id in (select id from _del_entities);
delete from owner_basis where entity_id in (select id from _del_entities);
delete from business_owners where entity_id in (select id from _del_entities);
delete from tax_assets where entity_id in (select id from _del_entities);
delete from tax_returns where entity_id in (select id from _del_entities);
delete from tax_forms where entity_id in (select id from _del_entities);
delete from tax_profiles where entity_id in (select id from _del_entities);
delete from tax_recommendations where entity_id in (select id from _del_entities);
delete from bank_reconciliations where entity_id in (select id from _del_entities);
delete from shopify_synced_orders where shopify_connection_id in
  (select id from shopify_connections where entity_id in (select id from _del_entities));
delete from shopify_connections where entity_id in (select id from _del_entities);
delete from classification_rules where entity_id in (select id from _del_entities);
delete from contacts where entity_id in (select id from _del_entities);
delete from employees where entity_id in (select id from _del_entities);
delete from pay_run_entries where pay_run_id in (select id from pay_runs where entity_id in (select id from _del_entities));
delete from pay_runs where entity_id in (select id from _del_entities);
delete from licenses where entity_id in (select id from _del_entities);
delete from integration_failures where entity_id in (select id from _del_entities);
delete from entities where id in (select id from _del_entities);
delete from audit_log where organization_id in (select id from _del_orgs);
delete from billing_events where organization_id in (select id from _del_orgs);
delete from org_invites where organization_id in (select id from _del_orgs);
delete from members where organization_id in (select id from _del_orgs);
delete from organizations where id in (select id from _del_orgs);
delete from auth.identities where user_id in (select id from _del_users);
delete from auth.users where id in (select id from _del_users);
select (select count(*) from _del_users) as users_deleted, (select count(*) from _del_orgs) as orgs_deleted;
commit;
