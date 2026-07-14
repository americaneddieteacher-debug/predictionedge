# 사용자님이 직접 하셔야 하는 것 (마스터 목록)

Claude(이 세션)가 물리적으로 할 수 없는 것들만 모았습니다. 이유: 이 세션은
**앱 도메인(Railway)·BIG 저장소·비밀번호 로그인**에 네트워크/자격증명이 차단돼 있습니다.
Claude가 할 수 있는 DB·로직·문서 작업은 전부 진행 중이며 이 폴더에 저장됩니다.

우선순위 순서대로 정리했습니다.

---

## 🔴 A. 로그인 복구 (지금 앱에 못 들어가는 원인)

증상: 로그인 시 **"Invalid API key"**. 계정·비밀번호는 서버에서 유효함이 확인됨(원인 아님).
진짜 원인: 배포된 앱에 심긴 Supabase 공개키가 빌드에 안 들어갔거나 옛 값임.
Next.js는 `NEXT_PUBLIC_*` 변수를 **빌드 시점에 굽기 때문에**, 변수만 맞추고 재배포를 안 하면 안 고쳐짐.

**할 일 (브라우저 어시스턴트에게 시켜도 됨):**
1. Railway → BIG → **Variables**에서 아래 두 개 확인
   - `NEXT_PUBLIC_SUPABASE_URL` = `https://dikdzguigukiyepunruu.supabase.co`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = (끝 6자가 `IrEkw4`, JWT에 `role:anon` 이어야 함.
     혹시 `service_role` 키가 잘못 들어가 있으면 그것도 "Invalid API key" 원인)
2. 값이 맞든 틀리든 → **Deployments → 최신 배포 ⋯ → Redeploy** (필수)
3. 재배포 후 https://big-production-fdaf.up.railway.app/signin 에서 로그인:
   - 이메일 `j951012@gmail.com` / 비밀번호 `ibookk-start-2026`
4. 로그인 후 **비밀번호 변경**(채팅에 노출됐으므로)

> anon 키 실제 값이 필요하면 Claude에게 "anon 키 확인해줘" 하면 Supabase에서 다시 읽어 알려줌.

---

## 🟠 B. AI 기능 켜기 (자동분류·세무 Q&A)

현재 AI 키 미입력이라 AI 기능만 꺼진 상태(나머지는 정상).
- Railway → BIG → Variables에 `GOOGLE_AI_STUDIO_API_KEY` 추가
  (키 없으면 https://aistudio.google.com/apikey 에서 무료 발급 → 복사)
- `IBOOKK_AI_PROVIDER=gemini` 가 있는지 확인
- (선택) `ANTHROPIC_API_KEY` 도 추가하면 Claude 경로 백업
- 추가 후 Redeploy

---

## 🟠 C. BIG 저장소 코드 작업 (Claude Code 새 세션)

claude.ai/code에서 저장소를 **BIG**으로 선택해 새 세션을 열고, 아래를 붙여넣으세요.
(안 보이면 github.com/settings/installations → Claude → BIG 접근 허용)

```
11-ibookk-os 작업이야. predictionedge 저장소 PR #2의 ibookk-fixes/ 폴더를 전부 읽어.
프로덕션 DB에는 마이그레이션 054~067이 이미 적용·검증됐어. 해야 할 일:
1. ibookk-fixes의 마이그레이션(054~067)을 이 저장소 마이그레이션 폴더에 복사해 동기화
2. match_tax_citations RPC 호출부: 반환 필드가 irc_sections → url 로 바뀌었으니 앱 코드 수정
3. 새로 추가된 DB 함수를 UI에 연결:
   - form_7203_data(entity,year) → 세금 화면 Form 7203 카드
   - entity_1120s_readiness(entity,year) → 대시보드/세금 준비도 미터
   - 인보이스/청구서에 'overpaid' 상태 렌더링 추가(색/라벨)
4. tax_citations 7,819건 임베딩(768차원) 생성 배치 실행 → AI 세무 검색 활성화
5. railway.json을 현 배포(Root=11-ibookk-os, RAILPACK_BUILD_CMD/START_CMD)와 일치시킴
6. ibookk-fixes/DESIGN.md + ui/ 폴더(tokens.css, tailwind-theme.ts, components-reference.tsx)
   대로 UI 전면 개편. 목업: https://claude.ai/code/artifact/d8f3ea1b-b87b-4bc3-90cb-22d0e8d4e509
전부 물어보지 말고 진행하고 결과만 알려줘.
```

---

## 🟡 D. 도메인 연결 (ibookk.com → 앱)

지금 주소가 임시(big-production-fdaf.up.railway.app)라 정식 도메인 연결이 남음.
ibookk.com은 이미 등록·Cloudflare 연결됨(루트/www는 건드리지 말 것).
1. Railway → BIG → Settings → Networking → Custom Domain에 `app.ibookk.com` 입력 → CNAME 대상값 복사
2. Cloudflare → ibookk.com → DNS → CNAME / Name `app` / Target=(복사값) / Proxy는 DNS only(회색)
3. Railway 인증서 초록불 후 → Variables의 `NEXT_PUBLIC_APP_URL=https://app.ibookk.com` → Redeploy

---

## 🟡 E. 출시 직전 최종 점검

- [ ] Supabase 대시보드에서 **Leaked password protection** 켜져 있는지 재확인
- [ ] `SUPABASE_SERVICE_ROLE_KEY` 로테이션(채팅 노출됨) → Railway 변수도 새 키로 교체
- [ ] 며칠 Railway 안정 확인 후 **홈PC :3100 서버 종료**
- [ ] `ibookk-fixes/legal/`의 개인정보처리방침·이용약관 **변호사 검토 후** /privacy, /terms에 게시
- [ ] Stripe 실결제 1건 테스트 (체험→결제 전환)
- [ ] 본인 회사 데이터로 1120-S 생성 → PDF 출력까지 한 바퀴
- [ ] 출시 직전 `ibookk-fixes/cleanup-test-data.sql` 실행(테스트 계정 ~30개 삭제, 백업 확인 후)
- [ ] 베타 문구: "신고서 준비 + PDF 제공" (e-file 계약 전 "원클릭 신고" 금지)

---

## 참고: Claude가 이미 끝낸 것 (사용자 조치 불필요)

DB 보안(진단 108→0 수준)·성능·실버그 15건 수정·E2E 14+건 검증·마이그레이션 054~067·
전략 카탈로그·Form 7203/준비도 함수·디자인 시스템·법률 초안·정리 스크립트.
상세는 같은 폴더 README.md 참조.
