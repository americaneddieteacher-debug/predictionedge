# 게임을 "재밌게" 만드는 디자인 프레임워크 & 벤치마크

- **조사일**: 2026-07-02
- **목적**: 특정 게임 분석이 아닌, 재사용 가능한 설계 원칙 레퍼런스. 브라우저 기반 용병단/상점 경영 RPG에 적용할 체크리스트 포함.
- **조사 방법**: WebSearch 기반 사실 확인 (일부 원문 페이지는 프록시 403으로 직접 열람 불가, 검색 결과 요약으로 교차 검증)

**요약 (5줄)**
1. 재미의 뼈대는 "행동→피드백→보상→동기" 코어 루프이며, 30초/5분/세션/주간의 중첩된 보상 주기와 가변 비율 보상이 지속 동기를 만든다 — 단, FOMO·강박 유도는 윤리적 경계 밖이다.
2. 경제는 소스(수도꼭지)와 싱크(배수구)의 비율 관리가 전부에 가깝다. 소프트/하드/에너지 3종 재화 분리와 지수 비용 성장 + 프레스티지 리셋이 인플레이션과 지루함을 동시에 막는 검증된 공식이다.
3. Sid Meier의 "게임은 흥미로운 결정의 연속" — 정답이 없는 트레이드오프, 부분 정보 공개, 리스크/리워드가 결정을 흥미롭게 만들고, Rimworld/Battle Brothers식 절차적 드라마(트레잇+이벤트+영구사망)가 유닛 애착과 이야깃거리를 만든다.
4. 온보딩은 튜토리얼이 아니라 점진적 공개(A Dark Room식 UI 해금)로 하고, 첫 5분 안에 코어 루프의 재미에 도달시켜야 한다 (D1 리텐션 벤치마크 25~40%).
5. 2024~2026 시장은 하이브리드 캐주얼·방치형 RPG 융합(Legend of Mushroom $3.6억/년)·브라우저 게임 재부상(Poki 월 10억 플레이)이 뚜렷해, 브라우저 경영 RPG는 시류에 부합한다.

---

## 1. 코어 루프 설계 이론

### 핵심 원칙

- **코어 루프의 기본형**: `행동(Action) → 피드백(Feedback) → 보상(Reward) → 동기(Motivation) → 반복`. 코어 루프는 플레이어가 가장 자주 반복하는 30초~5분짜리 사이클이며, 이 루프 자체가 재미없으면 그 위에 쌓는 어떤 메타 시스템도 소용없다.
- **중첩된 보상 주기 (Nested Loops)**: 잘 설계된 게임은 서로 다른 시간 단위의 루프를 겹쳐 놓는다.
  - **초 단위 (30초~1분)**: 전투 1회, 아이템 1개 판매, 클릭 1회의 즉각 피드백 (숫자, 사운드, 이펙트)
  - **분 단위 (5~10분)**: 퀘스트/계약 1건 완료, 레벨업, 장비 1개 획득
  - **세션 단위 (30~60분)**: 던전 1회 클리어, 상점 하루 영업 마감, 용병 1명 성장 마일스톤
  - **주간/장기**: 시즌 목표, 프레스티지, 콘텐츠 해금, 리더보드
  - 하나의 루프가 보상 피드백을 멈추는 순간 다른 루프가 이어받아야 한다. Civilization이 "한 턴만 더"를 만드는 원리가 바로 이 상호 연결된 다중 보상 시스템이다.
- **가변 비율 보상 (Variable Ratio Reinforcement)**: 보상이 "매번 n번째마다"가 아니라 확률적으로 주어질 때 (루트 드랍 등) 도파민은 보상 획득 순간이 아니라 **기대(anticipation) 단계**에서 분비되며, 이것이 가장 강한 반복 행동 유도 스케줄이다. 고정 보상(확정 퀘스트 보수)과 가변 보상(전리품 등급 랜덤)을 섞는 것이 정석.
- **compulsion loop vs core loop**: compulsion loop는 코어 루프에 심리적 강화 장치(가변 보상, 미완결 목표, 알림)를 결합해 "그만두기 어렵게" 만든 것. 둘은 같은 뼈대지만 목적이 다르다.
- **윤리적 경계**: 2024년 학술 연구 기준 상위 매출 게임의 80% 이상이 최소 1개의 조작적(dark pattern) 설계를 사용한다. 경계선의 기준:
  - **괜찮음**: 재미있는 루프의 반복, 가변 드랍, 장기 목표 제시, 오프라인 진행 보상
  - **위험 (피해야 함)**: FOMO 기반 시한부 보상으로 플레이를 "불안 회피 노동"으로 만들기, 손실 회피 협박 (연속 출석 끊기면 초기화), 지불 강제형 대기시간, 취약층(미성년) 겨냥 지출 유도
  - 원칙: **"플레이어가 그만둘 때 후회가 아니라 만족을 느끼게"**. 리텐션은 즐거움의 결과여야지 불안의 결과면 안 된다.

### 실제 게임 사례

1. **Civilization 시리즈**: 턴 종료 시점마다 "거의 완성된 무언가"(연구 1턴 남음, 유닛 생산 2턴 남음)가 항상 존재하도록 여러 진행 트랙의 완료 시점을 어긋나게 배치 → "한 턴만 더" 신드롬의 교과서.
2. **Diablo 계열 ARPG**: 30초 전투 루프(즉시 보상) + 가변 등급 루트 드랍(가변 비율) + 빌드 완성(장기)의 3층 구조.
3. **A Dark Room / 방치형 게임**: 타이머 기반 자원 축적으로 "돌아오면 항상 새로운 것이 있는" 리듬을 설계 — 자리를 비워도 루프가 돌아간다.

### 우리 게임 적용 체크리스트

- [ ] 30초 루프 정의: "아이템 감정→가격 책정→판매" 또는 "전투 1교전"이 그 자체로 만족스러운 피드백(골드 소리, 손익 숫자 팝업)을 주는가?
- [ ] 5분 루프 정의: 용병 계약 1건 / 상점 하루 영업이 명확한 시작-끝-정산을 갖는가?
- [ ] 세션 루프: 접속 1회(30~60분)마다 "오늘의 성과"를 요약해 주는 정산 화면이 있는가?
- [ ] 매 세션 종료 시점에 "거의 완성된 것" 1개 이상 남기기 (다음 접속 동기)
- [ ] 전리품/이벤트에 가변 등급 도입하되, 핵심 진행(스토리, 필수 장비)은 확정 보상으로
- [ ] 시한부 FOMO 보상·연속 출석 페널티 금지. 오프라인 진행은 "보너스"로만 설계
- [ ] 루프 어디서 도파민 기대가 발생하는지 표로 그려서 빈 구간 확인

---

## 2. 경제 설계 원칙

### 핵심 원칙

- **소스(Faucet)/싱크(Sink) 균형**: 재화가 생기는 곳(전투 보상, 판매 수익, 일일 보너스)과 사라지는 곳(구매, 업그레이드, 소모품, 수리비, 세금/수수료)의 비율이 경제 건강의 전부. **모든 소스에는 대응하는 싱크가 있어야 한다.** 소스 > 싱크면 인플레이션(재화가 의미 없어짐), 싱크 > 소스면 결핍 스트레스.
- **인플레이션 방지 기법**:
  - 획득 소프트캡 (일일 수익 상한, 반복 시 보상 체감)
  - 비례 확대 싱크: 업그레이드 비용 상승, 거래 수수료, 경매 세금 등 부유해질수록 더 빨아들이는 "탄력적 싱크(elastic sink)"
  - 소모성 싱크의 순환 (장비 내구도, 식량/급여 유지비 — 용병단 게임과 특히 궁합이 좋음)
  - 로테이션 상품/한정 유틸리티로 잉여 재화 흡수
- **재화 3종 구조**:
  - **소프트 재화 (골드)**: 플레이로 대량 획득, 대량 소비. 일상 루프의 윤활유. 인플레이션 관리 대상 1순위.
  - **하드 재화 (젬/명성 등 희소 재화)**: 획득 경로가 좁고 가치가 안정적. 프리미엄 또는 마일스톤 보상. 소프트로 환전 가능하되 역방향은 제한.
  - **에너지 재화 (행동력/시간)**: 세션당 행동량을 제한해 과소비를 막고 "내일 또 오게" 만드는 페이싱 장치. 단, 유료 충전을 붙이면 다크 패턴 경계에 근접하므로 주의.
- **숫자 성장 곡선 (incremental 수학)**:
  - 생산력은 구매 수에 선형~완만하게, **비용은 지수적으로** (`cost = base × r^n`, r ≈ 1.07~1.15가 관용적) 성장시켜 긴장을 유지한다.
  - 성장이 정체되는 지점에서 **프레스티지 리셋** (진행 초기화 + 영구 배수 획득)을 제공하면 "리셋 후 더 빠르게 재도달"하는 메타 루프가 생긴다. 이는 정체감을 리셋하고 숙련감을 보상하는 검증된 장치.
  - 큰 숫자는 표기 체계(K/M/B, 과학적 표기)까지 설계 대상이다 — 숫자가 읽히지 않으면 성장이 체감되지 않는다.

### 실제 게임 사례

1. **EVE Online / MMO 경제 일반**: 파괴되는 함선(싱크)이 생산(소스)을 상쇄하는 "파괴 기반 경제"로 수년간 인플레이션 통제 — 손실이 있어야 경제가 산다.
2. **Cookie Clicker / IdleOn**: 지수 비용 곡선 + 프레스티지의 원형. IdleOn은 이 공식으로 Steam에서 약 $59M 매출을 기록한 대표 방치형.
3. **Battle Brothers**: 급여·식량·수리비라는 **일일 유지비 싱크**가 계약 보수(소스)를 압박해 "계속 일감을 받아야 하는" 용병단의 경제적 절박함 자체를 게임플레이로 만듦.

### 우리 게임 적용 체크리스트

- [ ] 모든 재화의 소스/싱크 목록을 스프레드시트로 작성하고 시간당 유입/유출량 추정
- [ ] 용병 급여·식량·장비 수리 = 상시 유지비 싱크로 설계 (수익 압박이 곧 동기)
- [ ] 골드(소프트) / 명성·희귀 재화(하드) / 행동력·영업시간(에너지) 3종 분리
- [ ] 부유해질수록 커지는 탄력적 싱크 1개 이상 (상점 확장 비용, 고급 용병 몸값, 세금)
- [ ] 업그레이드 비용은 지수 성장 (r=1.07~1.15 사이에서 튜닝 시작)
- [ ] 중반 정체 구간에 프레스티지성 리셋 고려 (예: 용병단 재창단 → 영구 보너스)
- [ ] 인플레이션 지표 정의: "표준 아이템 1개의 골드 가치"를 주기적으로 추적

---

## 3. 의미 있는 선택 이론

### 핵심 원칙

- **Sid Meier (GDC 1989/2012)**: "게임은 흥미로운 결정의 연속(a series of interesting decisions)이다."
  - 흥미로운 결정의 조건: ① 어느 선택지도 명백히 우월하지 않다 ② 그러나 선택지들이 균등하게 매력적이지도 않다 (상황·성향에 따라 답이 갈린다) ③ 플레이어가 **정보에 근거해** 선택할 수 있다.
  - 흥미롭지 않은 결정의 판별: 모두가 항상 같은 것을 고른다면(우월 전략) 결정이 아니고, 아무 정보 없이 찍는다면 도박이지 결정이 아니다.
  - 흥미로운 결정의 4가지 속성: **트레이드오프**(하나를 얻으면 하나를 포기), **상황 의존적**(같은 선택지도 상황 따라 답이 다름), **개인적**(플레이 스타일 표현), **지속적**(결과가 이후에 영향).
- **리스크/리워드 트레이드오프**: 좋은 트레이드오프의 핵심은 리스크가 "계획 실패 가능성"만이 아니라 **"포기한 다른 선택지가 더 나았을 수도 있다"는 기회비용**까지 포함하는 것. 안전한 저수익 vs 위험한 고수익 구조를 기본 문법으로.
- **정보의 부분 공개**: 결정이 의미 있으려면 플레이어가 선택의 범위를 이해해야 하며, 오히려 정보를 넉넉히 주는 쪽으로 기울어도 된다 (Meier). 단, **불확실성의 위치**를 설계하라 — "무엇을 걸고 무엇을 얻을 수 있는지"는 명확히, "정확히 어떤 결과가 나올지"는 확률적으로. 예: 계약 보수는 확정 표시, 적 전력은 "약함/강함/미상" 수준의 부분 정보.

### 실제 게임 사례

1. **Civilization**: 같은 "도시 하나 더" 결정도 지형·이웃 문명·시대에 따라 답이 달라지는 상황 의존적 트레이드오프의 집합.
2. **FTL / Slay the Spire**: 경로 선택(상점 vs 엘리트전 vs 이벤트)에서 부분 정보(노드 종류는 보이지만 내용물은 미상)로 리스크/리워드 결정을 매 순간 강제.
3. **Darkest Dungeon**: "부상당한 정예를 회복 없이 한 탐사 더 보낼 것인가" — 자원(스트레스/체력)이 결정마다 지속되는 persistent decision의 모범.

### 우리 게임 적용 체크리스트

- [ ] 계약 선택 화면: 보수(확정 표시) vs 위험도(부분 정보: 소문/등급) 구조로 리스크·리워드 명시
- [ ] 모든 주요 선택에 "우월 전략 테스트": 시뮬레이션에서 90% 이상이 같은 걸 고르면 재설계
- [ ] 상점 가격 책정을 결정으로: 비싸게 팔면 마진↑ 평판↓, 싸게 팔면 회전율↑ — 상황 의존적으로
- [ ] 용병 파견 vs 상점 근무 같은 **기회비용형 배치 결정**을 코어에 배치
- [ ] 선택의 결과가 이후 세션까지 이어지는 지속성 1개 이상 (평판, 부상, 관계)
- [ ] 정보 UI 원칙: 판돈과 잠재 보상은 항상 보여주고, 결과의 분산만 감춘다

---

## 4. 드라마 생성기 (절차적 내러티브)

### 핵심 원칙

- **Rimworld 스토리텔러 방식**: 난이도를 고정 곡선이 아니라 **"연출 AI"**로 관리. Cassandra(고전적 상승 긴장 — 아리스토텔레스식 드라마 아크), Phoebe(완급 조절, 휴식 긴 페이싱), Randy(순수 랜덤 — 아포페니아 유발)처럼 이벤트 발생기를 페르소나화한다. 핵심 기법:
  - 콜로니 자산/전력 규모를 측정해 위협 강도를 스케일링
  - 큰 사건 후 회복 시간을 보장 (긴장-이완 사이클)
  - 승리 서사만이 아니라 **몰락도 이야기로 가치 있게** — "파워 판타지"가 아닌 "함께 만드는 이야기"
  - 아포페니아(무관한 사건에서 의미와 인과를 읽어내는 인간 성향)가 랜덤 이벤트를 "내 콜로니의 서사"로 바꿔 준다. 시스템은 사건만 던지고, 이야기는 플레이어의 뇌가 쓴다.
- **유닛 애착 형성 장치** (Battle Brothers/XCOM/Rimworld 공통 문법):
  - **이름 + 배경**: 고용 순간부터 "농부 출신", "탈영병" 같은 배경이 스탯과 이벤트를 결정 → 클론 병사가 아닌 개인
  - **트레잇**: 무작위 0~2개, 의도적으로 **불균형하게** (겁쟁이, 대식가, 낙천가) — 밸런스가 아니라 개성이 목적
  - **전투 기록**: 킬 수, 흉터, 부상 이력, 참전 전투 목록이 자동으로 쌓여 "이 녀석의 역사"가 됨
  - **영구사망(permadeath)**: 잃을 수 있어야 아낀다. 애착의 강도는 상실 가능성에 비례
- **Battle Brothers식 이벤트 시스템**: 이동 중/특정 장소/특정 배경·트레잇 보유 시 발동하는 조건부 텍스트 이벤트(출시 전 기준 47종에서 시작). 이벤트 선택지가 개별 용병의 **무드 시스템**(euphoric~angry)에 영향을 주고, 무드가 전투 결의(resolve)에 반영됨 → 서사적 선택이 기계적 결과로 되먹임되는 구조. 트레잇이 이벤트를 해금하고, 이벤트가 트레잇을 부여하는 순환.

### 실제 게임 사례

1. **Rimworld**: 스토리텔러 3종으로 같은 시스템에서 다른 장르의 드라마를 생성. 유저 커뮤니티의 "우리 콜로니 이야기" 공유가 최고의 마케팅이 됨.
2. **Battle Brothers**: 배경+트레잇+무드+영구사망+조건부 이벤트의 결합으로 "이름 없는 용병"이 3시간 만에 "우리 에이스"가 되는 파이프라인.
3. **XCOM 시리즈**: 사망 기념 벽(memorial wall)과 커스텀 이름 붙이기 — 친구 이름을 붙인 병사의 전사가 만드는 서사는 어떤 스크립트보다 강하다.

### 우리 게임 적용 체크리스트

- [ ] 용병 생성 시: 이름 + 배경 1개 + 불균형 트레잇 0~2개 (밸런스보다 개성 우선)
- [ ] 자동 기록: 참전 횟수, 킬, 부상/흉터, "첫 임무", "최다 킬" 등 이력 탭
- [ ] 영구사망 기본 + 사망 시 기념(묘비/명예의 전당) — 상실을 서사로 전환
- [ ] 조건부 이벤트 시스템: (장소, 배경, 트레잇, 무드) 튜플로 트리거되는 텍스트 이벤트 20종부터 시작
- [ ] 이벤트 선택 → 무드 변화 → 전투/근무 성능 반영의 되먹임 고리
- [ ] 위협 스케일링: 용병단 자산·전력 기반으로 사건 강도 조정 + 큰 사건 후 회복기 보장 (Cassandra 방식)
- [ ] "이야기 공유 가능성" 테스트: 플레이어가 남에게 말하고 싶은 사건이 세션당 1개 나오는가?

---

## 5. 온보딩 / 점진적 공개

### 핵심 원칙

- **첫 5분 설계**: D1 리텐션은 사실상 FTUE(첫 사용자 경험)의 성적표. 벤치마크는 D1 24~40% (25% 이상이면 준수, 40%면 우수), D7 20%, D30 10%. 첫 몇 분 안에 코어 게임플레이에 도달시키고, 첫 5분 안에 "강해지는 순간" 또는 흥미로운 사건 1개를 배치하라. 계정 생성 강제·초반 결제 팝업·광고는 금물.
- **튜토리얼 없이 가르치기**: 설명 텍스트 대신 **상황이 가르치게** 한다. 첫 번째 확장(새 기능 해금)이 "이 게임은 계속 커진다"는 사실 자체를 가르치고, 다음이 궁금해지는 것이 장르의 동력이 되게 한다 (A Dark Room의 설계 철학).
- **A Dark Room식 UI 해금 (progressive disclosure)**:
  - 시작 화면에는 버튼 1개("불 지피기")만. 행동할 때마다 새 버튼/탭/자원이 **화면에 물리적으로 나타난다** — UI 자체가 진행도이자 보상
  - 처음부터 전체 메뉴를 보여주지 않음으로써 인지 부하를 줄이고, "다음에 뭐가 열릴까"라는 호기심을 리텐션 장치로 사용
  - 지루하지만 효율적인 반복 구간에 도달할 때쯤 **새 자원/건물을 등장시켜** 최적화 노가다 대신 새 콘텐츠를 기다리게 유도
  - 자리를 비워도 진행되게 타이밍을 조정해 "돌아오면 항상 새로운 것이 있는" 상태 유지

### 실제 게임 사례

1. **A Dark Room**: 버튼 1개에서 시작해 텍스트 한 줄씩 세계가 열리는 점진적 공개의 정점. 튜토리얼 텍스트 0줄로 방치형+어드벤처를 가르침.
2. **Slay the Spire**: 메타 진행(카드/유물 해금)을 사실상 **분할 튜토리얼**로 사용 — 초반엔 단순한 카드풀만 주고 승급(Ascension)으로 난이도도 점진 해금.
3. **Universal Paperclips / 인크리멘털 장르 전반**: 새 시스템이 항상 "이전 시스템을 마스터한 직후"에 등장하는 페이싱.

### 우리 게임 적용 체크리스트

- [ ] 첫 화면은 행동 버튼 1~2개로 시작 (예: "가게 문 열기") — 전체 탭/메뉴는 숨김
- [ ] 첫 60초 안에 첫 판매/첫 전투, 첫 5분 안에 첫 용병 고용 또는 첫 희귀 아이템
- [ ] 모든 신규 시스템은 설명 팝업 대신 "해금 이벤트"로 등장 (UI에 새 요소가 생기는 연출)
- [ ] 튜토리얼 텍스트 최소화: 첫 행동은 실패 불가능하게 설계해 시행착오로 배우게
- [ ] 계정 생성/저장은 진행 후 요청 (브라우저 게임은 즉시 플레이가 최대 강점)
- [ ] FTUE 퍼널 계측: 단계별 이탈 지점 로깅 (버튼 클릭 → 첫 판매 → 첫 전투 → 재방문)
- [ ] "다음 해금 예고"를 은근히 노출 (잠긴 실루엣, 소문 텍스트)해 호기심 리텐션 확보

---

## 6. 세션 설계

### 핵심 원칙

- **로그라이트 런 구조 (한 판 30~60분)**:
  - Slay the Spire 표준 런 = 45~60분. 명확한 시작-긴장 상승-보스-정산의 완결 구조
  - 장점: 실패가 "게임 오버"가 아니라 "런 1회 종료"로 재정의됨, 매 판 새 조합(리플레이성), 짧은 결심 비용("한 판만"), 밸런스 리셋이 쉬움
  - 단점: 런 간 단절로 장기 애착이 약해질 수 있음 → **메타 진행**(해금, 영구 업그레이드)으로 보완. 메타 진행은 분할 튜토리얼 역할도 함
- **무한 세이브 구조 (Civilization/경영 시뮬형)**:
  - 장점: 깊은 애착과 소유감, 자산이 계속 쌓이는 만족, 세계의 연속성
  - 단점: 후반 인플레이션·최적화 고착·세이브 스노볼(망하면 접음), 세션 끊을 지점이 없어 피로 유발
- **"한 판만 더" 심리 (Civilization 분석)**:
  - 핵심 기제: ① 항상 2~3턴 뒤에 완성되는 무언가가 있음 (미완결 목표 = 자이가르닉 효과) ② 여러 보상 트랙의 완료 시점을 서로 어긋나게 배치 — 하나가 끝나는 순간 다른 것이 "거의 다 됨" ③ 턴 넘김의 비용이 아주 낮음 (클릭 1번)
  - 역설적 교훈: 승리가 확정되면(모든 트랙이 수렴하면) 세션 매력이 급락 → **불확실성이 남아 있는 동안이 재미의 전성기**. 게임을 너무 일찍 "다 이긴 상태"로 만들지 말 것
  - 윤리 노트: "한 판만 더"는 재미의 신호이기도 하지만, 세션 종료 지점을 일부러 없애는 것은 다크 패턴에 근접. 자연스러운 휴식 지점(하루 마감, 정산 화면)을 주고도 다시 오고 싶게 만드는 것이 건강한 설계
- **하이브리드 절충** (경영 RPG에 유효): 영속적인 기반(상점, 용병단 명부)+ 완결형 단위(계약/원정 1건 = 30~60분 런)의 조합. Battle Brothers가 이 구조 — 캠페인은 영속, 계약은 런.

### 실제 게임 사례

1. **Slay the Spire**: 45~60분 런 + 빠른 초반 해금 메타 진행 + Ascension 20단계로 "졸업 후 도전" 제공.
2. **Civilization**: 어긋난 보상 트랙 완료 시점으로 "한 턴만 더"를 구조적으로 생산.
3. **Battle Brothers**: 영속 캠페인 안에 계약(30분~1시간 단위 목표)을 넣은 하이브리드 — 경영의 연속성과 런의 완결감을 동시에.

### 우리 게임 적용 체크리스트

- [ ] 기본 구조: 영속 캠페인(상점+용병단) + 완결 단위(계약/원정 = 30~60분) 하이브리드
- [ ] 계약 종료마다 정산 화면 = 자연스러운 세션 종료 지점 (건강한 휴식점 제공)
- [ ] 정산 화면에 "다음에 거의 완성될 것" 2개 이상 노출 (레벨업 임박 용병, 입고 예정 상품)
- [ ] 보상 트랙(용병 성장/상점 확장/평판/컬렉션)의 완료 주기를 서로 어긋나게 설계
- [ ] 실패한 원정 = 캠페인 종료가 아니라 손실 이벤트 (부상, 장비 손실)로 — 스노볼 붕괴 방지
- [ ] 브라우저 특성상 5~10분 "미니 세션"(상점 관리만)도 성립하는지 확인
- [ ] 망한 캠페인용 프레스티지/재창단 경로 제공 (접기 대신 리셋 보상)

---

## 7. 밸런싱 실무

### 핵심 원칙

- **스프레드시트 기반 밸런싱**:
  - 모든 수치(스탯, 비용, 보상)는 코드 하드코딩이 아니라 **런타임에 다시 불러올 수 있는 데이터 테이블**로 — 수백 시간의 튜닝을 전제로 한 구조를 처음부터
  - 레벨/장비/스킬을 입력하면 기대 피해·명중·TTK(처치 소요 턴)가 나오는 **기준 수식**을 먼저 만들고, 개별 콘텐츠는 그 기준선에서 ±로 배치
  - **몬테카를로 시뮬레이션**: 전투를 수천 번 자동 실행해 승률 분포·평균·분산을 확인 — 스프레드시트 스크립트나 간단한 시뮬레이터로 충분
- **전투 수식 설계 (명중/피해 분산)**:
  - 명중 공식은 (공격 스킬 vs 방어/회피 + 레벨 차 보정 + 상황 보정)의 형태가 관용적. 표시 확률과 체감 확률의 괴리에 주의 (XCOM의 "95%가 빗나감" 불만 → 저난이도에서 몰래 보정하는 게임 다수)
  - **피해 분산(damage variance)**은 양날의 검: 분산이 크면 드라마(운 좋은 일격, 아슬아슬한 생존)가 생기고, 작으면 계획 가능성이 커진다. 운의 재미를 원하면 분산↑, 전술적 통제를 원하면 분산↓ — 장르 정체성에 맞춰 의도적으로 선택
  - 영구사망 게임에서는 "한 방에 죽는 분산"이 애착 시스템과 충돌하므로, 치명 피해에 완충(부상 단계, 빈사)을 두는 것이 일반적
- **난이도 곡선**:
  - 목표는 flow channel (Jesse Schell): 실력과 도전이 균형 잡힌 띠 안에 플레이어를 유지 — 도전 과잉 = 불안, 도전 부족 = 지루함
  - 단조 상승이 아니라 **톱니(sawtooth) 곡선**: 도전 상승 → 극복 → 잠시 "강해진 기분"을 즐기는 이완 구간 → 다시 상승. "긴장과 이완(tense and release)"의 반복이 인간 즐거움의 기본 리듬
  - 플레이어 성장 속도(장비+숙련)와 적 강화 속도의 상대 기울기가 실제 체감 난이도 — 두 곡선을 같은 시트에서 관리할 것

### 실제 게임 사례

1. **JRPG 전통 (드래곤 퀘스트/FF 계열)**: `피해 = 공격/2 − 방어/4 ± 분산` 류의 단순 기준 수식 + 레벨 테이블 — 단순한 수식일수록 튜닝과 예측이 쉽다.
2. **XCOM**: 표시 명중률과 심리적 체감의 괴리 문제의 대표 사례 — 낮은 난이도에서 명중 보정으로 좌절 완화.
3. **Slay the Spire**: 개발 중 수천 판의 플레이 데이터/시뮬레이션으로 카드 승률을 추적해 밸런싱한 것으로 유명 — 데이터 주도 밸런싱의 인디 모범.

### 우리 게임 적용 체크리스트

- [ ] 밸런스 수치는 전부 JSON/시트 기반 데이터 테이블로 — 코드 수정 없이 리로드 가능하게
- [ ] 기준 수식 먼저: 용병 레벨 n에서 기대 DPS, 기대 생존 턴, 계약 등급별 기대 수익 공식화
- [ ] 전투 몬테카를로 시뮬레이터 (Node 스크립트)로 승률 40~80% 구간 검증 후 콘텐츠 배치
- [ ] 피해 분산 정책 결정: 경영+애착 게임이므로 분산은 중간, 즉사는 완충(빈사/중상)으로
- [ ] 명중률 표시 정책: 표시 확률에 소폭 플레이어 우호 보정 검토 (좌절 방지)
- [ ] 난이도는 톱니형: 힘든 계약 클리어 후 "장비 값 하는" 쉬운 구간을 의도적으로 배치
- [ ] 플레이어 성장 곡선 vs 적 강화 곡선을 한 차트에 겹쳐 관리 (교차 지점 = 체감 스파이크)

---

## 8. 2024~2026 시장 트렌드

### 핵심 동향

- **하이브리드 캐주얼/하이브리드 코어**: 캐주얼 프레임에 미드코어 시스템(RPG 성장, 수집, 길드)을 겹겹이 얹는 것이 2024년 이후 지배적 문법. 단일 메커니즘 게임보다 다층 시스템 융합이 리텐션과 LTV에서 우위.
- **방치형+RPG 융합의 폭발**:
  - Legend of Mushroom: 2024년 글로벌 매출 약 **$3.61억**, 순위 596계단 상승해 전체 19위. 한때 일 매출 $250만
  - AFK Journey: 출시 첫해 IAP **$1.52억**, 다운로드 1,600만+
  - 방치형 RPG는 2020년 장르 매출 비중 1.7% → 2024년 **16%**로 급성장. 평균 이용 패턴은 일 5.2세션 / 총 50분 — 짧고 잦은 캐주얼 접점이 핵심 소구
- **Steam 인디 경영/로그라이트**: 방치형 게임 세계 시장은 2024년 약 $24억 → 2033년 $56억 전망 (CAGR ~10%). IdleOn 누적 약 $59M, The Farmer Was Replaced $6.8M/96만 장 등 1인~소규모 팀의 니치 히트가 지속 — 인디에겐 "지금이 골든 에이지"라는 낙관론도 유력 (경영/자동화/로그라이트가 니치 강세 장르).
- **브라우저 게임 재부상**:
  - Poki: 월 사용자 **1억 명**, 2025년 6월 월 **10억 플레이** 돌파. CrazyGames와 합산 월 1억+ 유저, 2025~2026년 두 자릿수 성장 지속
  - Poki 상위 개발사 수익이 5년 새 10배 (연 $5만 → 최대 $100만 수준)
  - 브라우저 게임 시장 규모: 2024년 약 $77억 → 2029년 $90억+ 전망
  - 동력: HTML5/WebAssembly 성능 향상, 설치 없는 즉시 플레이, 모바일 브라우저 지원, 스토어 수수료 회피. itch.io는 실험적 인디/웹 빌드의 유통·커뮤니티 허브로 정착
- **시사점**: "브라우저 기반 + 경영 + RPG + 짧은 세션도 성립"이라는 조합은 2026년 현재 시장의 성장 축 세 개(웹 게임, 방치형 융합, 인디 경영/로그라이트)와 정확히 겹친다.

### 실제 게임 사례

1. **Legend of Mushroom / AFK Journey**: 방치 코어 + 히어로 수집 + 내러티브 + 길드 소셜의 융합으로 캐주얼과 RPG 유저를 동시 흡수.
2. **IdleOn / The Farmer Was Replaced**: Steam에서 방치형·자동화 니치가 수백만~수천만 달러 규모로 성립함을 증명.
3. **Poki 생태계의 브라우저 히트작들**: 단순 코어 + 즉시 플레이로 월 수천만 세션 — 웹 유통의 마찰 제로가 최대 자산.

### 우리 게임 적용 체크리스트

- [ ] 즉시 플레이(설치·가입 없음)를 첫 화면 원칙으로 — 웹의 최대 경쟁력을 버리지 말 것
- [ ] 방치 요소(오프라인 상점 매출, 용병 자동 훈련)를 보조 루프로 탑재 — 짧고 잦은 세션 지원
- [ ] 하이브리드 문법 채택: 경영(캐주얼 접점) + 용병 RPG 성장(미드코어 깊이)의 2층 구조
- [ ] 세션 패턴 목표: 일 2~5회 × 10~30분도 성립하도록 (방치형 RPG 이용 패턴 벤치마크)
- [ ] 유통 실험: itch.io로 초기 피드백 → Poki/CrazyGames류 포털 진출 검토 (수익화는 광고+선택적 지원)
- [ ] 니치 명확화: "Battle Brothers 라이트 + 상점 경영"처럼 검색 가능한 장르 태그 조합으로 포지셔닝
- [ ] 공유 가능한 드라마(4장)를 커뮤니티 마케팅 자산으로 — 인디 성공작의 공통 성장 경로

---

## 출처

### 코어 루프 / compulsion loop / 윤리
- https://en.wikipedia.org/wiki/Compulsion_loop
- https://gamedesignskills.com/game-design/core-loops-in-gameplay/
- https://www.gamemakers.com/p/the-compulsion-loop-explained
- https://medium.com/@DanlWebster/whats-the-difference-between-a-core-loop-and-a-compulsion-loop-f02d20479cc7
- https://medium.com/@algoryte/action-feedback-reward-motivation-repeat-the-compulsive-game-loop-that-hooks-you-0ce432bd7463
- https://www.skeletoncodemachine.com/p/core-game-loop
- https://lost-on-arrival.com/en/ethical-design/
- https://www.gamedesignknowledge.com/blog-post/the-ethics-of-dark-patterns-in-game-design
- https://dl.acm.org/doi/fullHtml/10.1145/3491101.3519837 (A Game of Dark Patterns, CHI EA '22)
- https://www.researchgate.net/publication/390235729_Dark_Patterns_in_Games_An_Empirical_Study_of_Their_Harmfulness

### 경제 설계 / 인크리멘털 수학
- https://machinations.io/articles/what-is-game-economy-inflation-how-to-foresee-it-and-how-to-overcome-it-in-your-game-design
- https://www.gamedeveloper.com/design/book-excerpt-game-economy-design-metagame-monetization-and-live-operations
- https://pulsegeek.com/articles/in-game-economy-basics-from-rewards-to-prices/
- https://kevurugames.com/blog/what-is-video-game-economy-design/
- https://300mind.studio/blog/what-is-game-economy-design/
- https://en.wikipedia.org/wiki/Incremental_game
- https://missionszanx.com/guides/progression-and-scaling-in-incremental-games

### 의미 있는 선택
- https://www.gamedeveloper.com/design/gdc-2012-sid-meier-on-how-to-see-games-as-sets-of-interesting-decisions
- https://www.gamedeveloper.com/design/designing-interesting-decisions-in-games-and-when-not-to-
- https://www.bosnan.net/essays/sid-meier
- https://www.linkedin.com/pulse/interesting-decisions-games-jannick-hynding-lund

### 드라마 생성기
- https://rimworldwiki.com/wiki/AI_Storytellers
- https://medium.com/@coyega1328/algorithmic-authors-rimworlds-ai-storytellers-as-agents-of-literary-genre-eff70ea4560c
- https://www.gamedeveloper.com/design/rimworld-dwarf-fortress-and-procedurally-generated-story-telling
- https://www.researchgate.net/publication/387200649_Players_Retell_This_Story_A_Critical_Analysis_of_AI_Storytelling_and_Meaning-Making_Processes_in_Rimworld
- https://battlebrothersgame.com/dev-blog-43-event-system/
- https://battlebrothersgame.com/dev-blog-18-character-traits-and-backgrounds/

### 온보딩 / 점진적 공개
- https://adarkroom.doublespeakgames.com/
- https://github.com/doublespeakgames/adarkroom
- https://www.uxpin.com/studio/blog/what-is-progressive-disclosure/
- https://www.blog.udonis.co/mobile-marketing/mobile-games/first-time-user-experience
- https://www.devtodev.com/education/articles/en/348/main-metrics-ftue
- https://business.mistplay.com/resources/mobile-game-retention-metrics
- https://maf.ad/en/blog/mobile-game-retention-benchmarks/

### 세션 설계
- https://www.gamedeveloper.com/game-platforms/just-one-more-turn---game-development-tips-and-tricks-from-the-creator-of-civilization-sid-meier-
- https://neurospicyreviews.wordpress.com/2023/05/16/the-psychology-behind-one-more-turn/
- https://thehappyphalanx.blog/2025/02/09/civilization-or-the-curse-of-just-one-more-turn/
- https://notes.hamatti.org/gaming/video-games/meta-progression-with-gradual-tutorial-in-roguelike-games
- https://screenrant.com/roguelike-roguelite-difference-permadeath-hades-rogue-slay-spire/

### 밸런싱 실무
- https://gamedesignskills.com/game-design/game-balance/
- https://blog.userwise.io/blog/the-mathematics-of-game-balance
- https://gamedev.net/forums/topic/658758-how-to-make-combat-formulas-work-better/5167142/
- https://askagamedev.tumblr.com/post/634419522804334592/how-do-you-balance-an-rpg-seems-impossible-to-go
- https://www.gamedeveloper.com/design/understanding-the-flow-channel-in-game-design
- https://www.learninggamedev.com/the-art-of-game-design-by-jesse-schell-6-takeaways/

### 시장 트렌드 (2024~2026)
- https://mobilegamer.biz/the-top-grossing-mobile-games-of-2024/
- https://wnhub.io/news/other/item-43195 (Legend of Mushroom 일 매출)
- https://www.devtodev.com/resources/articles/game-market-overview-the-most-important-reports-published-in-september-2024
- https://appmagic.rocks/research/idle-steam-games-2026
- https://growthmarketreports.com/report/idle-games-market
- https://howtomarketagame.com/2025/11/04/the-optimistic-case-that-indie-games-are-in-a-golden-age-right-now/
- https://naavik.co/digest/web-gaming-strikes-back/
- https://www.superjumpmagazine.com/what-pokis-100-million-monthly-gamers-reveal-about-the-future-of-browser-games/
- https://techfundingnews.com/browser-gaming-website-poki-won-big-at-the-dutch-game-awards-celebrating-hitting-1-billion-monthly-plays/
- https://poki.com/blog/state-of-web-gaming-report-2026
- https://dataintelo.com/report/browser-game-market

> 참고: 조사 환경의 프록시 정책으로 일부 원문 페이지 직접 열람(WebFetch)이 차단되어, 위 출처들은 검색 엔진 요약을 통해 교차 확인함. 시장 수치는 조사 기관별 집계 기준이 달라 범위로 이해할 것.
