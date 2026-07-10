# ibookk 종합 분석 및 개선 로드맵

*작성일: 2026-07-02 · 분석 근거: ibookk-os Supabase 스키마(테이블 41개) 전수 분사, Supabase 보안 진단(108건), 마이그레이션 이력 53건, Vercel 배포 이력·빌드 로그, 그리고 경쟁 서비스·AI 회계/세무 시장에 대한 5건의 병렬 웹 리서치.*

> **분석 범위 주의**: 소스코드가 있는 `BIG` 저장소(비공개)는 이 세션의 GitHub 접근 범위 밖이라 코드를 직접 읽지는 못했습니다. 대신 프로덕션 DB 스키마, 53개 마이그레이션, 17건의 배포 커밋 메시지(상세한 엔지니어링 로그), Supabase 보안 어드바이저, Vercel 빌드 로그를 근거로 분석했습니다.

---

## 1. ibookk의 현재 모습 (역설계 결과)

**ibookk는 미국 소기업(특히 S-corp·파트너십) 대상 AI 회계+세무 운영체제(OS)** 입니다. QuickBooks(장부) + Bench(대행) + TurboTax Business(신고)를 하나의 데이터 모델로 합치려는 제품으로, 다음이 이미 구축되어 있습니다.

### 아키텍처
- **프론트/백엔드**: Next.js 모노레포(`apps/web`, pnpm), 로컬 서버 :3100에 배포. 패키지: `tax-engine`(테스트 68개), `web`(라우트 14개, 테스트 38개), `db`(테스트 95개)
- **DB**: Supabase(Postgres 17) `ibookk-os` — 테이블 41개, 전부 RLS 활성. pgvector 기반 세법 인용 임베딩
- **AI**: Claude 경로 + `IBOOKK_AI_PROVIDER` 플래그 뒤의 무료 Gemini 경로
- **연동**: Plaid(은행), Shopify(커머스), Check HQ(급여), TaxBandits(1099/W-2/941/940), Stripe(구독 결제)

### 기능 인벤토리 (스키마·커밋 기준)
| 영역 | 구축 상태 |
|---|---|
| 복식부기 원장 | ✅ journal_entries/lines, 시산표 뷰, 기간 마감(period close), 연말 마감, 재분개(repost), 은행 조정(reconciliation) |
| 은행 피드 | ✅ Plaid 연동 + AI 자동분류(`ai_suggested_account_id`, `ai_confidence`, `ai_reasoning`), 사용자 규칙 엔진, 중복 청구 감지 |
| AR/AP | ✅ 인보이스/청구서 + 결제 → 원장 자동 분개 |
| 영수증 | ✅ 업로드 + AI(Vision) 추출 + 거래 자동 매칭 |
| 급여 | 🔶 Check HQ 연동 스키마 완성(연방/주 원천징수 전체 컬럼), 데이터 0건 — 미가동 |
| 세무 엔진 | ✅ MACRS 감가상각(half-year/mid-quarter/mid-month convention, 처분연도 일할계산), §179/보너스, §1245 리캡처, §1231, 1120-S/1065 조립, K-1 생성, 고정자산 원장 계정(1500/1590/4950/6850) |
| 주주/파트너 기준액 | ✅ owner_basis(기초·출자·손익배분·분배·기말), BasisCheck 리드젠 테이블 |
| IRS 통지서 | ✅ 업로드 + AI 분석 + 대응 초안(납부/이의/분할납부/CDP 청문 등) + 최초 감면(FTA) + 리마인더 |
| AI 세무 Q&A | ✅ 세법 인용(IRC/재무부 규정/판례) RAG + **실제 원장 스냅샷 grounding**("ask the books") |
| 세무 전략 추천 | 🔶 tax_strategies/tax_recommendations 스키마 완성(절세액 추정, 감사위험 점수, 인용 필수), 카탈로그 0건 — 콘텐츠 미탑재 |
| 컴플라이언스 캘린더 | ✅ 18건 시딩, 라이선스/허가 추적 |
| e-file | 🔶 MeF 스키마·플러그인 포인트(efile/route.ts) 준비, **전송자(transmitter) 계약이 마지막 블로커** — april은 1040 전용, TaxBandits는 정보성 신고 전용으로 확인됨 |
| 멀티테넌트 | ✅ organizations(cpa_firm 타입 포함) → entities → members(5개 역할), Stripe 5개 요금제, 14일 체험 |

### 개발 성숙도
- 마이그레이션 53개(4/15~6/30), 최근 커밋은 자산 생애주기 온-레저화. 커밋 로그 품질이 매우 높음(테스트 수, 설계 근거, 한계 명시)
- 데이터는 테스트 수준(조직 3, 거래 287건) — **프리런치 단계**
- 지역 초점: GA/AL(조지아·앨라배마) 주 세법부터

**총평**: 설계 방향이 시장 데이터와 정확히 일치하는, 완성도 높은 프리런치 제품입니다. 특히 "결정론적 세무 엔진 + 인용 grounded LLM"이라는 하이브리드 설계는 2025-26년의 모든 벤치마크가 지지하는 유일하게 옳은 구조입니다(아래 §4).

---

## 2. 즉시 수정이 필요한 문제 (P0)

### 2-1. 🔴 RLS를 우회하는 뷰 — 보안 진단 유일한 ERROR
`public.v_trial_balance` 뷰가 **SECURITY DEFINER**로 동작합니다. 뷰 소유자(postgres) 권한으로 실행되므로 RLS가 무력화되어, 이론상 **다른 조직의 시산표(전 재무제표의 원천)가 노출**될 수 있습니다.
```sql
ALTER VIEW public.v_trial_balance SET (security_invoker = on);
```
적용 후 org 간 격리가 실제로 되는지 두 테스트 계정으로 검증하세요.

### 2-2. 🔴 anon 키로 노출된 테이블 42개 (GraphQL/API)
로그인 전 anon 키만으로 41개 테이블 + 시산표 뷰의 스키마가 열거 가능하고, RLS 정책 실수 하나면 곧바로 대량 유출입니다. 이 DB에는 은행 토큰, SSN/TIN, 급여 데이터가 있습니다.
```sql
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM anon;
-- basischeck_subscribers 등 리드젠 테이블만 INSERT 정책을 남기고 재부여
```
특히 `plaid_items`, `bank_connections`, `shopify_connections`(토큰), `tax_forms`/`business_owners`(TIN), `employees`/`pay_run*`(급여)는 **authenticated에서도 직접 SELECT을 막고** 서비스 롤/서버 라우트를 통해서만 접근하는 것이 맞습니다.

### 2-3. 🔴 인증 없이 호출 가능한 SECURITY DEFINER 함수 6개
`database_size()`, `rls_auto_enable()`(DDL을 건드리는 관리 함수!), `ibookk_mtd_stats()`(엔터티별 재무 집계 노출 가능), `is_org_member()`/`has_org_role()`(멤버십 오라클), `entity_org_id()` — 전부 anon 실행 가능. 여기에 **8개 함수가 search_path 미고정**이라 definer 권한 + 탈취 가능한 이름 해석이라는 최악의 조합입니다.
```sql
REVOKE EXECUTE ON FUNCTION public.database_size(), public.rls_auto_enable() FROM anon, authenticated, public;
REVOKE EXECUTE ON FUNCTION public.ibookk_mtd_stats(uuid,date), public.is_org_member(uuid),
  public.has_org_role(uuid,text), public.entity_org_id(uuid) FROM anon, public;
-- 8개 함수 전부:
ALTER FUNCTION public.set_updated_at() SET search_path = public, pg_temp;
-- (is_org_member, has_org_role, entity_org_id, compliance_obligations_touch_updated_at,
--  shopify_connections_touch_updated_at, match_tax_citations, ibookk_mtd_stats 동일 적용)
```

### 2-4. 🔴 `organizations`의 항상-참 INSERT 정책
`org_insert` 정책이 `WITH CHECK (true)` + 전체 롤 대상입니다. 누구나 조직 행을 만들 수 있어 스팸·권한 부트스트랩 경로가 됩니다. `authenticated` 한정 + `created_by = auth.uid()` 체크로 교체하세요.

### 2-5. 🔴 Vercel 배포 17건 전부 실패 — 프로덕션이 사실상 로컬 PC 한 대
모든 배포가 ERROR입니다(최근 로그: `apps/web/noop.js` → `Cannot find module 'next/dist/compiled/next-server/server.runtime.prod.js'`). 커밋 로그상 실제 서비스는 로컬 `:3100` + post-merge 훅 배포입니다. 이대로면:
- 그 PC가 꺼지면 서비스 전체 중단 (가용성·DR 부재)
- "committed but not deployed" 문제를 CI로 풀었지만 클라우드 배포는 여전히 깨져 있음

**선택지**: (a) Vercel 프로젝트의 Root Directory를 모노레포의 `11-ibookk-os/apps/web`으로 지정하고 noop.js 우회물을 제거해 진짜 클라우드 배포 복구, 또는 (b) Vercel 배포를 쓰지 않기로 했다면 프로젝트 연결을 끊어 실패 알림 소음과 혼동을 제거. 금융 데이터를 다루는 SaaS라면 (a)를 강력 권장합니다. ibookk-market/ibookk-marketing 프로젝트도 동일하게 정리가 필요합니다.

### 2-6. 🟠 평문 민감정보
커밋 이력상 Plaid·Shopify 토큰은 encrypt-on-write(`readSecret()`)로 전환된 것으로 보이지만, 스키마상 여전히 평문인 것들: **`tax_forms.recipient_tin`(SSN/EIN 전체), `business_owners.tin`, `employees.direct_deposit_routing`(라우팅 번호 전체), 생년월일·주소**. 같은 암호화 유틸을 이 컬럼들에도 적용하고, 조회 시 마스킹을 기본으로 하세요. (참고: 국세 정보를 다루는 서비스는 IRS Pub 4557/FTC Safeguards Rule 수준의 보호가 사실상 요구됩니다.)

### 2-7. 🟠 기타
- Auth의 유출 비밀번호 차단(HaveIBeenPwned) 꺼짐 — 대시보드에서 원클릭 활성화
- `vector` 확장이 public 스키마에 설치됨 — `extensions` 스키마로 이동
- 다형성 참조(`journal_entries.source_id`, `compliance_obligations.source_ref`)에 FK 없음 — 고아 참조 감시 쿼리라도 추가
- `audit_log.organization_id` nullable — RLS 사각지대 여부 정책 확인
- `tax_year >= 2026` CHECK — 과거연도 수정신고(amended return)를 원천 차단하므로 의도 확인 필요
- 성능 어드바이저는 현재 Supabase 린터 버그로 실행 실패 — 추후 재실행 권장

---

## 3. 경쟁 지형 (2026년 7월 기준 요약)

### 시장이 ibookk 방향으로 움직이고 있다는 신호
- **Basis**: 2026-02 $100M 시리즈B, **$1.15B 유니콘** — AI 회계 에이전트(단, 회계법인 대상 B2B)
- **Instead**(구 Corvee): 2026-04 **AI 네이티브 1120-S/1065 신고를 월 $30/엔터티**로 출시, IRS+주 MeF 승인 99%+ 주장 — **ibookk와 가장 직접 겹치는 경쟁자**, 아직 첫 시즌
- **Intuit**: QBO 가격 연 8~17% 인상(AI 명목), 사용자들은 끌 수 없는 AI 패널에 반발("turn off ia assist" 스레드) — AI를 유료 부가물이 아닌 엔진으로 쓰는 신생 제품에 기회
- **Bench 붕괴**(2024-12): 12,000 고객이 연말에 장부 접근을 잃음 → 시장 전체가 **데이터 이식성·검증 가능한 장부**를 구매 조건으로 학습
- **CPA 공급 붕괴**: 회계 졸업생 20년 최저, 3년간 30만 명 이탈, 1120-S 수임료 $1,200~3,500로 상승
- 자금 유입: Rillet($95M), Campfire($35M), Numeric($51M), Accrual($75M), Pennylane($4.25B 밸류) 등 — 단, 대부분 **미드마켓/회계법인 대상**이고 솔로 S-corp 오너 직접 대상은 비어 있음

### 카테고리별 vs ibookk
| 카테고리 | 대표 | ibookk와의 관계 |
|---|---|---|
| AI 장부(스타트업용) | Puzzle(자동분류 98% 주장), Digits(AGL), Kick, Zeni | 장부는 겹치나 **세무 신고까지 안 함**. VC 스타트업/프리랜서 초점, S-corp 컴플라이언스 캘린더 없음 |
| 회계법인용 AI | Basis, Black Ore(1040 GA), Filed, TaxGPT, Accrual | 법인 채널 B2B. 1040 중심, 1120-S/1065는 "로드맵" |
| 임베디드 세무 API | april($78M, 1040 전국 라이선스), Column Tax | **둘 다 1120-S/1065 API 없음** — ibookk의 전송자 후보가 못 됨(이미 커밋 로그에서 파악하신 대로) |
| S-corp 백오피스 번들 | Collective($299/mo), Formations, Lettuce($28M), 1-800Accountant | 사람+소프트웨어 하이브리드, 연 $3.6~4.2K. 불만: 느린 응대, 신고 지연, BBB 민원 다수 — **ibookk가 소프트웨어 마진으로 언더컷할 우산 가격** |
| DIY 신고 | TurboTax Business(윈도우 전용/온라인은 $1,169+), TaxAct($160+$55/주) | **장부와 단절**. 유일하게 QBO가 Live Tax(TurboTax 기반)로 장부→1120-S/1065를 제품 안에서 잇지만 전문가 보조 $489~풀서비스 $1,749로 비쌈 — 소프트웨어 가격으로 이 루프를 닫는 제품은 없음 |

### 추가로 주시해야 할 2026년 신호
- **Pilot "AI Accountant"**(2026-02): 완전 자율 부기 주장 + **$99/mo Essentials 티어** 신설 — AI 부기의 가격 하한선이 내려오는 중. 단 Pilot도 세무는 연 $2,450~4,950 별도
- **Xero**: JAX 챗 2026-06-01 GA(자동 은행조정 >80% 주장) + Melio $2.5B 인수로 미국 결제 공략 — 그러나 **미국 법인세 신고는 여전히 불가**
- **Intuit·Xero 모두 Anthropic 파트너십 체결**(2026-02/03) — 에이전트 회계가 업계 공식 방향. 다만 GA 기준 "사람 개입 없는 완전 마감"은 아직 아무도 없음
- **영수증 OCR은 커머디티화**: 헤더 필드(총액·날짜·상호)는 클라우드 API/LLM으로 95~99% 도달, 라인아이템(구겨진 영수증)은 최고 ~87%가 한계 — ibookk는 OCR 자체가 아니라 "추출→원장 분개→세무 라인 매핑" 연결로 차별화해야 함
- **신뢰 격차가 실제 구매 요인**: Kick 트러스트파일럿 ~1.8점, doola BBB 1점, 1-800Accountant BBB 민원 516건, Bench 재과금 소송 — AI 자동화 + 신뢰성(감사추적·이식성·사람 책임)을 같이 주는 곳이 없음

### 검증된 whitespace (ibookk가 정조준 중인 것)
1. **장부→법인신고의 단절**: 같은 데이터 모델에서 장부 마감→1120-S+K-1+주 신고까지 가는 제품이 없음. ibookk의 핵심 설계와 정확히 일치
2. **Form 7203/주주 기준액**: IRS가 "회사는 안 해주니 주주가 알아서 추적하라"고 명시한, 소비자용 도구가 전무한 영역 — **ibookk는 이미 `owner_basis` 테이블과 BasisCheck 리드젠까지 준비되어 있음. 최고의 차별화 포인트**
3. **S-corp 컴플라이언스 자동화**: 합리적 보수(reasonable comp) 산정·문서화(현재 RCReports가 전문가용 독점, CPA 수임료 $400~1,200), accountable plan/홈오피스 정산, 분기 safe-harbor 추정세 — 전부 미자동화
4. **가격 슬롯**: 툴만 조합($55~120/mo)과 대행($300/mo) 사이의 **$99~199/mo 올인원 소프트웨어** 자리가 비어 있음

---

## 4. AI 전략 검증 — ibookk의 설계가 옳다는 외부 증거

- **TaxCalcBench**(Column Tax, 2025-07): 최전선 LLM도 단순화된 1040 전체 계산 정확도 **33% 미만**(2026 리더보드 최고 ~63%). 계산을 LLM에 맡기면 안 됨 → ibookk의 **결정론적 tax-engine + 테스트 68개** 접근이 정답
- **TaxEval v2**: 어려운 세무 Q&A에서 최상위 모델 ~77% — RAG 인용 grounding 필수 → ibookk의 `tax_citations` pgvector 코퍼스 + "인용 없으면 답 없음" 설계가 정답
- **WaPo 테스트**: TurboTax AI 50%+ 오답, H&R Block 30% 오답. **IRS 2026 Dirty Dozen이 사상 처음 "AI 세무 답변에 의존하지 말라" 경고** → "실제 장부에 grounding + 숫자 창작 금지" 커밋(ask the books)이 정확한 방어
- 시장 전체가 2025-26에 "에이전트"를 출시했지만 전부 human-in-the-loop. 완전 자율 마감은 아무도 못 함 → ibookk도 **승인 흐름(사용자 확인 후 반영)** 을 유지할 것. Intuit의 강제 AI 반발이 반면교사

**권고**: 이 하이브리드 구조를 마케팅 전면에 세우세요. "LLM이 세금을 계산하지 않습니다. 검증된 엔진이 계산하고, AI는 당신의 실제 장부를 근거로 설명하며, 모든 답에 법조문 인용이 붙습니다" — 정확도 벤치마크(TaxCalcBench류)를 자체 공개하면 Instead 등과의 신뢰 격차를 만들 수 있습니다.

---

## 5. 우선순위 로드맵

### P0 — 이번 주 (보안·생존)
1. §2의 SQL 수정 일괄 적용(마이그레이션 054로): security_invoker, REVOKE anon, 함수 권한·search_path, org_insert 정책
2. HaveIBeenPwned 활성화, TIN/라우팅번호 암호화
3. Vercel 배포 복구 또는 명시적 폐기 + **DB 백업/PITR 확인과 로컬 서버 장애 시 복구 절차 문서화**
4. Supabase 무료 플랜 한계(프로젝트 2개 캡, 스테이징 부재) — 유료 전환($25/mo)은 사용자 데이터를 받기 시작하는 시점의 필수 비용

### P1 — 출시 전 (차별화 완성)
5. **Form 7203 자동 생성** — owner_basis 데이터로 PDF까지. "당신의 CPA도 안 해주는 것"이라는 마케팅 메시지가 성립하는 킬러 기능. BasisCheck 무료 도구 → 이메일 캡처 → 본 제품 퍼널 완성
6. **합리적 보수(reasonable comp) 엔진** — BLS/급여 데이터 기반 산정 + 문서화 리포트. S-corp 감사 리스크 1순위 항목이고 소비자 가격대 도구가 없음
7. **분기 추정세 safe-harbor 계산기** — 실제 원장 + 급여 원천징수 연동 실시간 계산(경쟁자들은 블로그 글로만 때움)
8. **e-file 경로 확정** — 조사 결과 실행 가능한 순서: (a) 단기: **FileYourTaxes.com iFile API**(1120/1120-S/1065 지원 확인) 또는 Thomson Reuters GoSystem Tax API로 전송 위탁 + PDF 폴백 유지, (b) 중기: 자체 EFIN/ETIN + ATS 통과(연방은 수개월, 주 승인이 1~2시즌). 이미 작성해둔 transmitter 아웃리치 이메일 발송을 진행하되 후보에 FileYourTaxes를 추가할 것
9. **데이터 이식성** — QBO/Xero 포맷 내보내기 + "당신의 장부는 표준 복식부기, 언제든 가져갈 수 있음"을 온보딩에 명시(Bench 붕괴 이후 구매 결정 요인)
10. 급여(Check HQ) 가동 또는 1차 출시 범위에서 명시적 제외 — 스키마만 있고 미가동인 상태가 가장 위험

### P2 — 출시 후 (성장)
11. **가격**: $99~199/mo 올인원(장부+추정세+1120-S/K-1/주 신고+7203+RC 문서화). 앵커: "Collective 대비 연 $1,500~2,400 절약, CPA+툴 조합 대비 $1,000~3,000 절약". 프로핏 $40K 미만은 S-corp 자체가 부적합하므로 ICP에서 제외
12. **CPA 채널**: `org_type='cpa_firm'`이 이미 있음 — CPA 부족으로 수임 거절당하는 고객을 CPA가 ibookk로 셀프서브시키는 화이트라벨/리뷰 모드. Basis($1.15B)가 증명한 채널
13. GA/AL → 주 확장 로드맵(주 MeF 승인 그라인드와 동기화), Shopify 회계 강화(A2X가 $20~100/mo 패치로 존재하는 불만 영역), IRS 통지서 AI를 독립 마케팅 훅으로("IRS 편지 사진 찍으면 대응 초안까지")
14. 신뢰 자산 공개: 테스트 수(현재 200개+), 정확도 벤치마크, 보안 문서, (커밋 로그의 습관을 살려) 엔지니어링 블로그

---

## 6. 한 줄 결론

**ibookk는 "AI가 장부를 맞추고, 검증된 엔진이 세금을 계산하고, 같은 데이터로 신고까지 하는" — 시장에 아직 없는 제품을 거의 다 만들었습니다.** 지금 갈림길은 기능이 아니라 (1) 보안 마감(§2, 하루 작업), (2) e-file 전송자 확정(§5-8), (3) 이미 가진 기준액·보수·추정세 자산을 소비자용 킬러 기능으로 포장하는 것(§5-5~7)입니다. 가장 직접적인 경쟁자 Instead가 첫 시즌인 지금이 창입니다.
