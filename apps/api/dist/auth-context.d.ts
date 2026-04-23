export declare function requireAuth(request: Request, env: any): Promise<{
    ok: boolean;
    response: import("undici-types").Response;
    userId?: undefined;
    user?: undefined;
    role?: undefined;
} | {
    ok: boolean;
    userId: any;
    user: any;
    role: any;
    response?: undefined;
}>;
export declare function requireRequestUserId(request: Request): {
    ok: boolean;
    response: import("undici-types").Response;
    userId?: undefined;
} | {
    ok: boolean;
    userId: string;
    response?: undefined;
};
