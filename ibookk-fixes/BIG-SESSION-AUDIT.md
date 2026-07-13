# BIG 저장소(앱 소스) 감사·수정 지시서

이 세션은 BIG 저장소에 네트워크 접근이 하드 차단되어 앱 소스(React/Next.js, tax-engine)를
직접 읽거나 고칠 수 없습니다. 그러나 이 세션이 DB에 적용한 변경(마이그레이션 054~067)이
앱 코드에 **결정론적으로 유발하는 버그**가 있습니다 — 소스를 안 봐도 예측 가능한 것들입니다.

**BIG 저장소에서 Claude Code 세션을 열고 이 파일을 읽힌 뒤, 아래를 순서대로 실행하세요.**
각 항목은 "왜 버그인지 + 어디를 볼지 + 어떻게 고칠지"를 담았습니다.

---

## 🔴 P0 — DB 변경으로 지금 깨져 있을 앱 코드

### B1. `match_tax_citations` RPC 반환 형태 변경 (056) — 세무 Q&A 인용 렌더 깨짐
- **원인**: DB 함수가 `irc_sections text[]` 반환을 중단하고 `url text`를 반환하도록 바뀜(삭제된 컬럼 참조 크래시 수정).
- **찾을 곳**: `grep -rn "match_tax_citations\|irc_sections" 11-ibookk-os` — RPC 호출부, 결과 타입/인터페이스, 인용 카드 렌더 컴포넌트, tax-qa 관련 파일.
- **수정**: 결과 타입에서 `irc_sections: string[]` → `url: string | null`. 인용 UI가 IRC 섹션 배열을 렌더하던 부분을 `url`(있으면 링크) 기반으로 교체. TypeScript union이면 컴파일 에러로 바로 드러남.

### B2. `overpaid` 상태 추가 (062) — 인보이스/청구서 상태 렌더 누락
- **원인**: invoices/bills status에 `'overpaid'` 값 추가됨.
- **찾을 곳**: `grep -rn "'paid'\|\"paid\"\|status.*partial\|InvoiceStatus\|BillStatus" 11-ibookk-os` — 상태 라벨/색상 매핑, 상태 union 타입, 필터 드롭다운.
- **수정**: status→라벨/색 매핑에 `overpaid` 추가(예: 라벨 "초과 지불", 경고색). TS union 타입에 `'overpaid'` 추가(안 하면 빌드 실패). DESIGN.md의 시맨틱 색 `--warn` 사용 권장.

### B3. 신규 RPC 미연결 — 준비도 미터·Form 7203 카드가 데이터 없음
- **원인**: 이 세션이 `entity_1120s_readiness(entity,year)`, `form_7203_data(entity,year)`,
  `compliance_effective_status(due,status)` 함수를 새로 만들었으나 앱이 호출하지 않음.
- **수정**:
  - 대시보드/세금 화면 준비도 미터 → `supabase.rpc('entity_1120s_readiness',{p_entity,p_tax_year})`.
    반환 jsonb: `{percent, passed, total, checks:{...}}`. checks의 false 항목을 "남은 작업"으로 렌더.
  - Form 7203 카드 → `supabase.rpc('form_7203_data',{p_entity,p_tax_year})`. 행별 필드:
    ending_basis, computed_ending, **reconciles(불일치 시 경고 배지)**.
  - compliance 목록의 연체 표시 → 저장된 status 대신 `compliance_effective_status(due_date,status)`
    를 쓰거나 클라이언트에서 동일 로직(`due<today && status∉{filed,waived} ⇒ overdue`) 적용.

### B4. Postgres 예외 → 사용자 친화 에러 매핑 (054·063·064·065 트리거/제약)
- **원인**: 원장·마감·자산 가드가 DB 예외(SQLSTATE)를 raise함. API 라우트가 이를 잡지 않으면 사용자는 500을 봄.
- **찾을 곳**: 분개/결제/자산/조정 관련 API 라우트의 try/catch, supabase 에러 핸들링.
- **매핑해야 할 에러들**:
  - `check_violation` "period closed: ..." → "마감된 기간에는 기입할 수 없습니다"
  - "unbalanced" (P0001) → "차변과 대변이 일치하지 않습니다"
  - "cannot modify lines of a posted journal entry" → "게시된 분개는 수정할 수 없습니다. 역분개하세요"
  - "cannot delete a posted journal entry" → "게시된 분개는 삭제 대신 무효(void) 처리하세요"
  - `tax_assets_not_over_depreciated` → "감가상각 누계가 취득원가를 초과할 수 없습니다"
  - `bank_recon_reconciled_is_zero` → "차액이 0일 때만 조정 완료할 수 있습니다"
  - `overpaid` 관련 없음(상태로 표현)

---

## 🟠 P1 — 소스를 봐야 확정되나 높은 확률로 존재하는 문제

### B5. tax-engine 순수 계산 로직 자체 (DB는 입력 제약만 검증함)
- MACRS 200DB/150DB, half-year/mid-quarter/mid-month convention, §179/보너스, §1245 리캡처,
  §1231, 처분연도 일할계산 — **계산 정확성은 tax-engine 유닛테스트로만 검증됨**.
- 실행: `pnpm --filter @ibookk/tax-engine test` 그리고 경계 케이스 추가:
  자산을 취득 당해에 처분, 완전상각 자산 처분, §179가 basis 초과, 음수 §1231 순손실,
  mid-quarter 판정 임계(4분기 40% 룰). 이 세션이 DB에서 막은 입력(과상각 등)과
  엔진 계산이 일치하는지 교차 확인.

### B6. API 라우트 입력 검증·인증 가드
- 이 세션 커밋 로그(Vercel 이력)에서 과거에 zod 미검증 라우트 2곳(receipts match, notices fta)을
  고친 이력이 있음. `grep -rn "await req.json()" 11-ibookk-os/apps/web` 로 전 라우트를 훑어
  body 검증(zod) 누락·역할 가드(viewer/bookkeeper/admin) 누락을 점검.
- 특히 서비스 롤(admin client)로 RLS를 우회하는 라우트는 반드시 역할 재확인 필요.

### B7. React 예외 처리 (빈 상태·로딩 실패·null 렌더)
- 신규 조직/엔티티(데이터 0건) 상태에서 각 화면이 크래시 없이 빈 상태를 렌더하는지.
- RPC/쿼리 실패 시 error boundary 또는 fallback UI 존재 여부.
- 금액 포맷터가 null/undefined에 `toLocaleString` 호출로 터지지 않는지.

### B8. tax_recommendations 생성 흐름(AI 호출·프롬프트)
- DB는 저장 정합성만 검증됨(strategy_code FK 등). 생성 시 AI가 존재하지 않는 strategy_code를
  만들거나 citations 빈 배열을 넣으면 제약 위반으로 실패 → 에러 핸들링 확인.
- AI 응답 파싱 실패·타임아웃·비용 상한 처리.

### B9. 연동 에러 핸들링 (Plaid/Shopify/Check HQ/TaxBandits)
- 토큰 만료·webhook 실패·부분 동기화 시 `integration_failures` 재시도 큐에 올바로 적재되는지
  (앱이 5분마다 이 큐를 폴링 중인 것은 이 세션 로그로 확인됨).

---

## 실행용 프롬프트 (BIG 세션에 붙여넣기)

```
11-ibookk-os 작업이야. 이 파일(BIG-SESSION-AUDIT.md, predictionedge 저장소 PR #2의
ibookk-fixes/ 폴더)을 먼저 읽어. 프로덕션 DB에는 마이그레이션 054~067이 이미 적용됐어.
/goal 로 목표를 "이 문서의 B1~B9를 전부 감사하고 실제 버그를 심각도별로 정리해서 다 고쳐줘"
로 설정하고, B1~B4(P0, DB 변경으로 지금 깨진 것)부터 순서대로 수정한 뒤 B5~B9를 감사해.
동시에 ibookk-fixes/의 마이그레이션 054~067을 이 저장소 마이그레이션 폴더에 복사해 동기화하고,
DESIGN.md·ui/ 폴더대로 UI를 개편해. 전부 물어보지 말고 진행하고 결과만 알려줘.
```
