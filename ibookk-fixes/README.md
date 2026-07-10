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
