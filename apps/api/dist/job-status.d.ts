export declare const JOB_STATUS: {
    readonly draft: "draft";
    readonly awaiting_payment: "awaiting_payment";
    readonly open: "open";
    readonly master_selected: "master_selected";
    readonly in_progress: "in_progress";
    readonly completed: "completed";
    readonly cancelled: "cancelled";
    readonly disputed: "disputed";
};
export type JobStatus = (typeof JOB_STATUS)[keyof typeof JOB_STATUS];
export declare function canTransition(from: string, to: string): boolean;
export declare function assertTransition(from: string, to: string): void;
