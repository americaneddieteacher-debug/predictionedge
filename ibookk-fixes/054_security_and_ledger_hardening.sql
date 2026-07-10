-- ============================================================
-- 054_security_and_ledger_hardening
-- 2026-07-02에 ibookk-os 프로덕션(dikdzguigukiyepunruu)에 적용 완료.
-- BIG 저장소의 마이그레이션 디렉터리(11-ibookk-os/...)에 이 파일을
-- 그대로 복사해 로컬/스테이징 DB와 동기화하세요.
--
-- 내용:
--  1) v_trial_balance — draft/void 분개가 합산되던 잠복 버그 수정 + security_invoker
--  2) anon 롤 전체 테이블 권한 회수 (BasisCheck INSERT만 유지)
--  3) SECURITY DEFINER 함수 EXECUTE 잠금 (database_size/rls_auto_enable는 클라이언트 롤 전체 차단)
--  4) 어드바이저 지적 함수 8개 search_path 고정
--  5) organizations.org_insert 항상-참 정책 → authenticated 한정
--  6) recompute_bill_paid / recompute_invoice_paid — 결제 전부 삭제 시 상태가
--     'paid'/'partial'에 고착되던 엣지 케이스 수정 ('open'으로 복귀)
--  7) 미인덱스 FK 28개 인덱스 추가 (journal_lines.account_id 등)
-- ============================================================

CREATE OR REPLACE VIEW public.v_trial_balance
WITH (security_invoker = on) AS
SELECT a.entity_id,
       a.id AS account_id,
       a.code,
       a.name,
       a.account_type,
       COALESCE(SUM(jl.debit), 0)             AS total_debit,
       COALESCE(SUM(jl.credit), 0)            AS total_credit,
       COALESCE(SUM(jl.debit - jl.credit), 0) AS balance
FROM accounts a
LEFT JOIN (
  SELECT l.account_id, l.debit, l.credit
  FROM journal_lines l
  JOIN journal_entries je ON je.id = l.entry_id
   AND je.status = 'posted'
   AND je.reversal_of IS NULL
) jl ON jl.account_id = a.id
GROUP BY a.entity_id, a.id, a.code, a.name, a.account_type;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
GRANT INSERT ON public.basischeck_subscribers TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM anon;
REVOKE TRUNCATE ON ALL TABLES IN SCHEMA public FROM authenticated;

REVOKE EXECUTE ON FUNCTION public.database_size() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.ibookk_mtd_stats(uuid, date) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.is_org_member(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.has_org_role(uuid, text) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.entity_org_id(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.ibookk_mtd_stats(uuid, date) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.is_org_member(uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.has_org_role(uuid, text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.entity_org_id(uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.database_size() TO service_role;

ALTER FUNCTION public.set_updated_at() SET search_path = public, pg_temp;
ALTER FUNCTION public.compliance_obligations_touch_updated_at() SET search_path = public, pg_temp;
ALTER FUNCTION public.shopify_connections_touch_updated_at() SET search_path = public, pg_temp;
ALTER FUNCTION public.entity_org_id(uuid) SET search_path = public, pg_temp;
ALTER FUNCTION public.has_org_role(uuid, text) SET search_path = public, pg_temp;
ALTER FUNCTION public.is_org_member(uuid) SET search_path = public, pg_temp;
ALTER FUNCTION public.ibookk_mtd_stats(uuid, date) SET search_path = public, pg_temp;
ALTER FUNCTION public.match_tax_citations(vector, double precision, integer, text, text) SET search_path = public, pg_temp;

DROP POLICY IF EXISTS org_insert ON public.organizations;
CREATE POLICY org_insert ON public.organizations
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE OR REPLACE FUNCTION public.recompute_bill_paid()
RETURNS trigger LANGUAGE plpgsql SET search_path TO 'public' AS $$
DECLARE
  v_bill  UUID := COALESCE(NEW.bill_id, OLD.bill_id);
  v_paid  NUMERIC;
  v_total NUMERIC;
BEGIN
  SELECT COALESCE(SUM(amount), 0) INTO v_paid FROM bill_payments WHERE bill_id = v_bill;
  SELECT COALESCE(total, 0) INTO v_total FROM bills WHERE id = v_bill;
  UPDATE bills
     SET amount_paid = v_paid,
         status = CASE WHEN v_total > 0 AND v_paid >= v_total THEN 'paid'
                       WHEN v_paid > 0 THEN 'partial'
                       WHEN v_paid = 0 AND status IN ('paid','partial') THEN 'open'
                       ELSE status END,
         updated_at = NOW()
   WHERE id = v_bill;
  RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.recompute_invoice_paid()
RETURNS trigger LANGUAGE plpgsql SET search_path TO 'public' AS $$
DECLARE
  v_invoice UUID := COALESCE(NEW.invoice_id, OLD.invoice_id);
  v_paid    NUMERIC;
  v_total   NUMERIC;
BEGIN
  SELECT COALESCE(SUM(amount), 0) INTO v_paid FROM invoice_payments WHERE invoice_id = v_invoice;
  SELECT COALESCE(total, 0) INTO v_total FROM invoices WHERE id = v_invoice;
  UPDATE invoices
     SET amount_paid = v_paid,
         status = CASE WHEN v_total > 0 AND v_paid >= v_total THEN 'paid'
                       WHEN v_paid > 0 THEN 'partial'
                       WHEN v_paid = 0 AND status IN ('paid','partial') THEN 'open'
                       ELSE status END,
         updated_at = NOW()
   WHERE id = v_invoice;
  RETURN NULL;
END;
$$;

CREATE INDEX IF NOT EXISTS idx_journal_lines_account          ON public.journal_lines(account_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_reversal_of    ON public.journal_entries(reversal_of);
CREATE INDEX IF NOT EXISTS idx_journal_entries_created_by     ON public.journal_entries(created_by);
CREATE INDEX IF NOT EXISTS idx_transactions_ai_suggested_acct ON public.transactions(ai_suggested_account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_bank_connection   ON public.transactions(bank_connection_id);
CREATE INDEX IF NOT EXISTS idx_transactions_journal_entry     ON public.transactions(journal_entry_id);
CREATE INDEX IF NOT EXISTS idx_bank_connections_account       ON public.bank_connections(account_id);
CREATE INDEX IF NOT EXISTS idx_accounts_parent                ON public.accounts(parent_account_id);
CREATE INDEX IF NOT EXISTS idx_invoices_customer              ON public.invoices(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoice_lines_revenue_account  ON public.invoice_lines(revenue_account_id);
CREATE INDEX IF NOT EXISTS idx_invoice_payments_journal_entry ON public.invoice_payments(journal_entry_id);
CREATE INDEX IF NOT EXISTS idx_bills_vendor                   ON public.bills(vendor_id);
CREATE INDEX IF NOT EXISTS idx_bill_lines_expense_account     ON public.bill_lines(expense_account_id);
CREATE INDEX IF NOT EXISTS idx_bill_payments_journal_entry    ON public.bill_payments(journal_entry_id);
CREATE INDEX IF NOT EXISTS idx_bank_recs_account              ON public.bank_reconciliations(account_id);
CREATE INDEX IF NOT EXISTS idx_bank_recs_bank_connection      ON public.bank_reconciliations(bank_connection_id);
CREATE INDEX IF NOT EXISTS idx_classification_rules_set_acct  ON public.classification_rules(set_account_id);
CREATE INDEX IF NOT EXISTS idx_members_invited_by             ON public.members(invited_by);
CREATE INDEX IF NOT EXISTS idx_org_invites_invited_by         ON public.org_invites(invited_by);
CREATE INDEX IF NOT EXISTS idx_audit_log_user                 ON public.audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_irs_notices_uploaded_by        ON public.irs_notices(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_receipts_uploaded_by           ON public.receipts(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_employees_manager              ON public.employees(manager_employee_id);
CREATE INDEX IF NOT EXISTS idx_pay_runs_approved_by           ON public.pay_runs(approved_by);
CREATE INDEX IF NOT EXISTS idx_tax_forms_recipient_contact    ON public.tax_forms(recipient_contact_id);
CREATE INDEX IF NOT EXISTS idx_tax_forms_recipient_employee   ON public.tax_forms(recipient_employee_id);
CREATE INDEX IF NOT EXISTS idx_tax_recommendations_profile    ON public.tax_recommendations(tax_profile_id);
CREATE INDEX IF NOT EXISTS idx_shopify_orders_transaction     ON public.shopify_synced_orders(ibookk_transaction_id);
