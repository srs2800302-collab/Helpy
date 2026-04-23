export declare function ensureJobsSchema(env: any): Promise<void>;
export declare function getJobs(request: Request, env: any): Promise<import("undici-types").Response | undefined>;
export declare function getAvailableJobs(request: Request, env: any): Promise<import("undici-types").Response | undefined>;
export declare function getJobById(id: string, request: Request, env: any): Promise<import("undici-types").Response | undefined>;
export declare function createJob(request: Request, env: any): Promise<import("undici-types").Response | undefined>;
export declare function updateJobStatus(id: string, request: Request, env: any): Promise<import("undici-types").Response>;
export declare function getJobsByUser(userId: string, request: Request, env: any): Promise<import("undici-types").Response | undefined>;
