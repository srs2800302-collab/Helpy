export const JOB_STATUS = {
  draft: 'draft',
  awaiting_payment: 'awaiting_payment',
  open: 'open',
  master_selected: 'master_selected',
  in_progress: 'in_progress',
  completed: 'completed',
  cancelled: 'cancelled',
  disputed: 'disputed',
} as const;

export type JobStatus = (typeof JOB_STATUS)[keyof typeof JOB_STATUS];

const ALLOWED_TRANSITIONS: Record<string, string[]> = {
  draft: ['awaiting_payment', 'cancelled'],
  awaiting_payment: ['open', 'cancelled'],
  open: ['master_selected', 'cancelled'],
  master_selected: ['in_progress', 'completed', 'cancelled'],
  in_progress: ['completed', 'disputed', 'cancelled'],
  completed: [],
  cancelled: [],
  disputed: ['completed', 'cancelled'],
};

export function canTransition(from: string, to: string) {
  return (ALLOWED_TRANSITIONS[from] ?? []).includes(to);
}

export function assertTransition(from: string, to: string) {
  if (!canTransition(from, to)) {
    throw new Error(`Invalid job status transition: ${from} -> ${to}`);
  }
}
