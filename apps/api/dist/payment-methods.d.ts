export declare function listPaymentMethods(userId: string, request: Request, env: any): Promise<import("undici-types").Response | undefined>;
export declare function createMockCard(userId: string, request: Request, env: any): Promise<import("undici-types").Response | undefined>;
export declare function setDefaultPaymentMethod(userId: string, methodId: string, request: Request, env: any): Promise<import("undici-types").Response | undefined>;
export declare function deletePaymentMethod(userId: string, methodId: string, request: Request, env: any): Promise<import("undici-types").Response | undefined>;
