# ibookk-os 프로덕션 DB 적용 내역 (2026-07-02 ~ 07-10)

아래 마이그레이션 4개는 **ibookk-os Supabase 프로덕션(dikdzguigukiyepunruu)에 이미 적용·검증 완료**된 상태입니다.
`BIG` 저장소의 `11-ibookk-os` 마이그레이션 디렉터리에 같은 이름으로 복사해 로컬/스테이징 DB와 동기화하세요.
(055~057의 전체 SQL은 Supabase 대시보드 → Database → Migrations에서 그대로 복사할 수 있습니다. 054는 이 폴더에 포함.)

| 마이그레이션 | 내용 |
|---|---|
| `054_security_and_ledger_hardening` | 시산표 draft/void 합산 버그 수정, anon 전면 차단, DEFINER 함수 잠금, search_path 고정, org_insert 정책 교체, bill/invoice 상태 고착 수정, FK 인덱스 28개 |
| `055_move_vector_extension` | pgvector를 `extensions` 스키마로 이동 (lint 0014 해소) |
| `056_fix_match_tax_citations` | RAG 검색 함수가 삭제된 `irc_sections` 컬럼을 참조해 **호출 즉시 크래시**하던 버그 수정. 반환 필드가 `irc_sections text[]` → `url text`로 변경됨 (**앱 코드에서 RPC 결과 타입 업데이트 필요**). 추가로 대체(superseded)된 인용을 결과에서 제외 |
| `057_rls_performance_hardening` | RLS 정책의 `auth.uid()/auth.role()` 행별 재평가 8건을 쿼리당 1회로 래핑, `FOR ALL` 쓰기 정책 13개를 INSERT/UPDATE/DELETE로 분리(SELECT 중복 평가 제거), 정책 `authenticated` 롤 한정 |
| `065_tax_assets_integrity` | **🔴 감가상각 데이터 무결성**: tax_assets에 취득원가>0·상각기간>0·금액 비음수·총상각액≤원가·처분일≥취득일·판매가 정합성 제약 추가. 잘못된 자산 데이터가 §1245/§1231 계산을 오염시켜 틀린 1120-S를 만드는 것을 차단. 검증: 과상각($10k 자산에 $12k) 거부 확인 ✅ |
| `066_compliance_effective_overdue` | **연체 상태 표류 수정**: overdue가 저장값이라 마감일 지나도 pending으로 남던 문제. compliance_effective_status()로 읽기 시점 계산 + entity_1120s_readiness가 날짜 기준으로 연체 판정하도록 수정(이전엔 표류된 연체를 놓쳐 준비도 과대평가). 검증 통과 ✅ |
| `064_closed_period_update_guard` | **🔴 마감기간 무결성 구멍 수정**: 마감 가드가 INSERT에만 걸려 있어, draft를 열린 기간에 만든 뒤 날짜를 마감기간으로 UPDATE→게시하면 마감된 장부가 뚫렸음. 날짜가 마감기간으로 변경될 때 차단(UPDATE OF entry_date)하되 정상 마감/void 워크플로는 유지. 검증: 공격 재현→수정 후 차단 확인, 정상 흐름 통과 ✅ |
| `063_reconciliation_integrity` | **은행 조정 무결성 가드 추가**: 차액(difference)이 명세서잔액−계산잔액과 일치하도록 강제 + 차액이 0이 아니면 '조정완료'(reconciled) 불가. 앱 버그가 거짓 "조정완료"를 저장하는 것을 DB가 차단. 검증: 차액 100 조정완료 시도→거부, in_progress는 허용 ✅ |
| `062_overpayment_visibility` | **AR/AP 초과결제 은폐 버그 수정**: 인보이스/청구서에 금액 초과 지불 시 amount_paid가 total을 넘어도 status가 'paid'로 위장돼 현금-AR 불일치가 숨겨졌음. 'overpaid' 상태 추가 + 트리거가 감지하도록 수정. 검증: $1000 인보이스에 $1500 지불→overpaid, 환불 시 sent 복귀 ✅ |
| `060_members_bootstrap_owner` | **온보딩 교착 버그 수정**: 새 조직 생성자가 자기 자신을 owner로 등록할 수 없던 닭-달걀 문제. 멤버가 0명인 조직에 한해 본인·owner로만 부트스트랩 허용(SECURITY DEFINER 헬퍼로 안전하게 검사). 검증: 신규 계정 온보딩 시뮬레이션 성공 + 기존 조직 가로채기 시도 RLS 차단 확인 |
| `058_seed_tax_strategies` + `059_dedupe_seeded_strategies` | 전략 카탈로그에 **기존에 없던 4개 추가** (`SCORP_REASONABLE_COMP`, `DE_MINIMIS_SAFE_HARBOR`, `HIRE_YOUR_KIDS`, `GA_RURAL_HOSPITAL_CREDIT`) — 인용 포함, conditions/formula는 엔진 DSL 확인 전까지 기본값. 최종 59개 (기존 55 + 신규 4). ⚠️ 참고: `list_tables`의 행 수는 플래너 추정치라 0으로 보였지만 실제로는 전략 55개·인용 7,819건·추천 27건이 이미 적재돼 있었음 — 분석 보고서의 "카탈로그 미탑재" 서술은 이 통계 착시였음 |

## 검증 결과 (2차: E2E 12/12)
- 원장: 분개 게시·불균형 거부·역분개·마감기간 가드·게시분개 불변성 ✅
- 결제: 부분납→완납→환불 시 open 복귀 ✅
- RLS: 실사용자 격리·시산표 뷰 격리·조직 가로채기 차단 ✅
- 온보딩: 신규 계정 셀프서브 전 과정 (org→owner→entity→가시성) ✅
- **연말 마감**: 마감 후 P&L 0·이익잉여금 정확·손익 리포트는 마감 무시 ✅
- 재분개(repost): 역분개+신규 원자성, 멱등성 상호작용 검토 ✅
- **AR 인보이스 흐름**: 부분→완납→초과결제→환불 상태 전이 전부 정확 ✅
- 데이터 제약 감사: 결제 양수·분개 단면·중복방지(계정/기준액/멤버/거래/은행) 전부 가동 ✅
- 보안 어드바이저 회귀: 마이그레이션 054~062 이후 새 ERROR·anon 노출 0건 ✅

## 검증 결과
- 보안 어드바이저: 108건 → **HaveIBeenPwned 토글 1건만 잔존** (나머지는 의도된 구조인 authenticated RLS 접근)
- 성능 어드바이저: `auth_rls_initplan` 0, `multiple_permissive_policies` 0 (unused_index INFO 96건은 프리런치 DB의 정상 noise — 출시 4~6주 후 재평가)
- anon 롤: `plaid_items` 등 조회 시 permission denied 확인, BasisCheck 이메일 INSERT 정상
- 시산표: $999,999 draft 분개 주입 시 불변 확인
- RAG: 더미 임베딩으로 `match_tax_citations` 검색 1건 정확 매치 확인 (테스트 데이터 정리 완료)

## 사용자가 직접 해야 할 것
1. **Supabase 대시보드 → Authentication → Passwords → Leaked password protection 켜기** (API 미제공)
2. `BIG` 저장소에 위 마이그레이션 복사 + `match_tax_citations` RPC 호출부의 `irc_sections` → `url` 반영
3. Vercel `ibookk-web` 프로젝트 Root Directory를 `11-ibookk-os/apps/web`으로 수정하거나 프로젝트 연결 해제 (17개 배포 전부 ERROR 상태)
4. 무료 플랜 자동 일시정지로 DB가 내려가 있었음 — 실서비스 전 **Supabase Pro 전환 필수**
