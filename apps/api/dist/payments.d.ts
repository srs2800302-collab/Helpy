export declare function ensurePaymentsSchema(env: any): Promise<void>;
export declare function createRefundPayment(jobId: string, env: any): Promise<any>;
export declare function createDeposit(jobId: string, request: Request, env: any): Promise<import("undici-types").Response | undefined>;
export declare function getPayments(jobId: string, request: Request, env: any): Promise<import("undici-types").Response | undefined>;
