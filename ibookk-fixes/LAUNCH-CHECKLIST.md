# ibookk 출시 전 체크리스트 (사용자 작업용 — 쉬운 버전)

Claude가 할 수 있는 것은 전부 완료된 상태입니다 (DB 보안·성능·버그 수정, 마이그레이션 054~059).
아래 5개만 순서대로 하시면 클로즈드 베타를 받을 수 있는 상태가 됩니다.

---

## 1️⃣ 유출 비밀번호 차단 켜기 (2분)
1. https://supabase.com/dashboard 접속 → **ibookk-os** 프로젝트 클릭
2. 왼쪽 메뉴 **Authentication** → **Sign In / Providers** (또는 Passwords 섹션)
3. **"Leaked password protection"** 스위치 ON → Save

## 2️⃣ Supabase Pro 전환 (5분, $25/월)
1. 같은 대시보드에서 왼쪽 하단 **Settings** → **Billing**
2. **Pro Plan** 선택 → 결제 등록
- 이유: 지금 무료 플랜이라 **일주일 안 쓰면 DB가 자동으로 꺼집니다** (이번 분석 중에도 두 번 꺼져 있었음). Pro는 자동 정지 없음 + 7일 백업 포함.

## 3️⃣ Vercel 배포 고치기 (5분)
1. https://vercel.com 접속 → **ibookk-web** 프로젝트 클릭
2. **Settings** → **Build and Deployment** (또는 General)
3. **Root Directory** 항목을 `11-ibookk-os/apps/web` 으로 수정 → Save
4. **Deployments** 탭 → 최신 항목 → ⋯ 메뉴 → **Redeploy**
- 성공하면: 집 PC가 꺼져도 서비스가 살아 있게 됩니다. (실패하면 빌드 로그를 Claude에게 보여주세요)
- Vercel을 안 쓰기로 했다면: Settings → Git → Disconnect 로 연결만 끊어도 됩니다 (실패 알림 제거).

## 4️⃣ 코드 작업은 Claude에게 시키기 (5분이면 시작됨)
`BIG` 저장소에서 Claude Code 세션을 새로 열어야 합니다 (지금 세션은 predictionedge 저장소 전용이라 BIG 접근이 안 됨).

1. https://claude.ai/code 접속 → 새 세션 → 저장소 선택에서 **americaneddieteacher-debug/BIG** 선택
2. 아래 문장을 그대로 붙여넣기:

```
11-ibookk-os 작업이야. predictionedge 저장소의 PR #2에 있는
ibookk-fixes/ 폴더(README.md, 054 SQL, LAUNCH-CHECKLIST.md)를 먼저 읽어.
프로덕션 DB에는 마이그레이션 054~059가 이미 적용돼 있어. 해야 할 일:
1. ibookk-fixes의 마이그레이션들을 이 저장소 마이그레이션 폴더에 복사해 동기화
2. match_tax_citations RPC 호출부에서 irc_sections 대신 url을 읽도록 수정
   (DB 함수는 이미 url을 반환하도록 고쳐져 있음)
3. tax_forms.recipient_tin, business_owners.tin, employees.direct_deposit_routing을
   기존 readSecret()/암호화 패턴으로 encrypt-on-write 전환
4. tax_citations 7,819건의 임베딩(768차원) 생성 배치 실행
5. Vercel 빌드 실패 원인(apps/web/noop.js) 정리
전부 물어보지 말고 진행하고 결과만 알려줘.
```

## 5️⃣ 출시 직전 확인 (반나절)
- [ ] Stripe 실결제 1건 테스트 (14일 체험 → 결제 전환)
- [ ] 개인정보처리방침 + 이용약관 페이지 (세무 데이터라 필수)
- [ ] 본인 회사 데이터로 1120-S 생성 → PDF 출력까지 한 바퀴
- [ ] 베타 문구: "신고서 준비 + PDF 제공" (e-file 계약 전까지 "원클릭 신고" 표현 금지)

---

이 5개가 끝나면: **클로즈드 베타(5~10팀) 출시 가능 상태**입니다.
e-file 전송자 계약(FileYourTaxes.com iFile API 추천, 준비된 아웃리치 이메일 발송)은 베타와 병행하세요.
