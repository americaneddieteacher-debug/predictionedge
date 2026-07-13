# ibookk 디자인 시스템 v1 — "Ledger Modern"

인터랙티브 목업: https://claude.ai/code/artifact/d8f3ea1b-b87b-4bc3-90cb-22d0e8d4e509
(대시보드 / 거래 검토 / 세금 3개 화면 · 라이트/다크 · 승인 인터랙션 포함)

## 컨셉

**숫자가 주인공인, 장부의 정밀함.** 미국 S-corp 오너가 세금과 돈을 맡기는 앱이므로
신뢰가 제1원칙: 화려한 그라데이션·이모지·과장된 히어로 금지. 배경에 흐린 장부 괘선(ruled line),
금액은 전부 모노스페이스 tabular numerals. AI는 별도의 "브랜드 보이스 컬러"(황동색)를 갖되
조용한 부기사(copilot)로만 등장 — Intuit의 "끌 수 없는 AI 패널" 반발을 반면교사로,
AI 요소는 전부 사용자가 승인하는 제안 형태.

## 토큰 (CSS custom properties)

| 토큰 | Light | Dark | 용도 |
|---|---|---|---|
| `--paper` | `#F7F9F6` | `#0D1411` | 페이지 바탕 (녹색기 도는 종이) |
| `--panel` | `#FFFFFF` | `#141D17` | 카드/패널 |
| `--panel-2` | `#F0F4EF` | `#18231C` | hover·보조면 |
| `--ink` | `#17231D` | `#E6EEE8` | 본문 |
| `--ink-2` / `--ink-3` | `#43544B` / `#71827A` | `#A7B6AC` / `#75857B` | 보조/캡션 |
| `--line` / `--rule` | `#DDE5DE` / `#E7EDE7` | `#243129` / `#1B2620` | 경계선 / 장부 괘선 |
| `--brand` | `#135C48` | `#3D9B7E` | 액션·네비·포커스 (에버그린) |
| `--ai` | `#8F6400` | `#D9A93E` | **AI 전용** (황동) — 다른 용도 사용 금지 |
| `--good/--warn/--crit` | `#256E46/#A05A12/#A83A30` | `#5DB284/#D9924A/#DB7168` | 시맨틱 상태 (accent와 분리) |

다크모드: `prefers-color-scheme` 기본 + `:root[data-theme=…]` 오버라이드 (토큰 재정의 방식만 사용).

## 타이포

- UI/본문: **Public Sans** (400/600/700) — 미 연방 디자인시스템 서체, "세금 앱"과 의미적 결
- 숫자/데이터/워드마크: **IBM Plex Mono** (400/600) + `font-variant-numeric: tabular-nums` 필수
- 금액은 큰 사이즈의 모노 숫자가 히어로. 라벨은 11px 대문자 letter-spacing .07em

## 핵심 UX 원칙 (구현 시 지킬 것)

1. **"처리가 필요한 3가지"가 대시보드의 중심** — AI가 우선순위(통지서 > 중복 > 미분류 > 영수증)로
   선별. 앱이 할 일을 말해주고, 사용자는 승인만 한다.
2. **AI 확신도는 항상 노출** (바 + %). 90%+ 는 일괄 승인 허용, 미만은 개별 검토 유도.
   승인 시 즉시 "✓ 원장 반영됨" 피드백.
3. **부기사(AI 패널)의 모든 답은 인용 칩과 "실제 원장 기반" 표시를 동반** — 이미 백엔드가
   지원하는 ask-the-books를 UI 신뢰 장치로 승격.
4. 세금 화면은 **준비도 미터(%)** 중심 — 남은 작업을 사람이 할 일(분)과 엔진이 한 일로 구분 표기.
5. 시맨틱 컬러(good/warn/crit)는 브랜드 컬러와 절대 혼용하지 않는다.
6. 모든 인터랙티브 요소에 `:focus-visible`, `prefers-reduced-motion` 대응.

## 구현 노트 (BIG 저장소)

- Tailwind 사용 중이면 위 토큰을 `tailwind.config` theme.extend.colors로 이식, CSS 변수 참조 방식 유지
- 폰트: `@fontsource/public-sans`, `@fontsource/ibm-plex-mono` (npm, self-host)
- 목업 HTML 소스는 이 커밋 기준 아티팩트에서 그대로 열람 가능 — 마크업·컴포넌트 구조 참고용
