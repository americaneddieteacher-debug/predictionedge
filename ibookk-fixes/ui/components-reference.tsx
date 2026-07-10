/**
 * ibookk "Ledger Modern" — 참조 컴포넌트 3종.
 * 목업(https://claude.ai/code/artifact/d8f3ea1b-b87b-4bc3-90cb-22d0e8d4e509)의
 * 핵심 패턴을 React+Tailwind로 옮긴 예시. 실제 구현 시 기존 컴포넌트 구조에 맞춰
 * 이 "패턴"을 유지할 것: 토큰만 참조 / 금액은 mono+tabular / AI 색은 AI에만.
 */

// 1) 금액 히어로 — 모든 통계 카드의 기본형
export function StatCard({ label, value, cents, delta, deltaGood, badge }: {
  label: string; value: string; cents?: string;
  delta?: string; deltaGood?: boolean; badge?: React.ReactNode;
}) {
  return (
    <div className="rounded-card border border-line bg-panel shadow-card px-[18px] py-4">
      <div className="flex items-center gap-2 text-[11.5px] font-semibold uppercase tracking-[.07em] text-ink-3">
        {label}{badge}
      </div>
      <div className="figure mt-1.5 text-[34px] leading-tight font-semibold">
        {value}{cents && <small className="text-[19px] text-ink-3">{cents}</small>}
      </div>
      {delta && (
        <div className="text-[12.5px] text-ink-2">
          <span className={deltaGood ? 'font-semibold text-good' : 'font-semibold text-crit'}>{delta}</span>
        </div>
      )}
    </div>
  );
}

// 2) AI 확신도 — 분류 제안 어디에나 (숫자 숨기지 말 것)
export function ConfidenceMeter({ pct }: { pct: number }) {
  const high = pct >= 90;
  return (
    <span className="inline-flex items-center gap-[7px] text-[12.5px] font-semibold text-ink-2">
      <span className="h-[5px] w-11 overflow-hidden rounded-full bg-line">
        <i
          className={`block h-full rounded-full ${high ? 'bg-good' : 'bg-ai'}`}
          style={{ width: `${pct}%` }}
        />
      </span>
      {pct}%
    </span>
  );
}

// 3) "처리가 필요한 N가지" — 대시보드의 중심. 심각도 스트라이프 + 마감 + 단일 CTA
export type QueueItem = {
  severity: 'crit' | 'warn' | 'ai';
  title: string; detail: string; due: string;
  action: string; onAction: () => void; primary?: boolean;
};

export function NeedsYouQueue({ items }: { items: QueueItem[] }) {
  const stripe = { crit: 'bg-crit', warn: 'bg-warn', ai: 'bg-ai' } as const;
  return (
    <div className="rounded-card border border-line bg-panel shadow-card">
      <h2 className="flex items-center gap-2 px-[18px] pt-3.5 text-[13px] font-semibold uppercase tracking-[.06em] text-ink-3">
        처리가 필요한 {items.length}가지
        <span className="rounded-full bg-ai-soft px-2 py-0.5 text-[11px] font-semibold normal-case tracking-normal text-ai">✦ 자동 선별</span>
      </h2>
      <ul className="m-0 list-none px-1.5 pb-2 pt-2">
        {items.map((it, i) => (
          <li key={i} className={`flex items-center gap-3 rounded-lg px-3 py-[11px] hover:bg-panel-2 ${i > 0 ? 'border-t border-line' : ''}`}>
            <span className={`w-[3px] self-stretch rounded ${stripe[it.severity]}`} />
            <div className="flex-1">
              <b className="block text-[13.5px] font-semibold">{it.title}</b>
              <span className="text-[12.5px] text-ink-2">{it.detail}</span>
            </div>
            <span className="figure whitespace-nowrap text-[11.5px] font-semibold text-ink-3">{it.due}</span>
            <button
              onClick={it.onAction}
              className={it.primary
                ? 'whitespace-nowrap rounded-lg bg-brand px-[13px] py-[7px] text-[12.5px] font-semibold text-brand-on hover:brightness-110'
                : 'whitespace-nowrap rounded-lg border border-line-2 bg-panel px-[13px] py-[7px] text-[12.5px] font-semibold text-ink-2 hover:border-brand hover:text-brand-ink'}
            >
              {it.action}
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
