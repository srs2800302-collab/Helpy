export declare function buildTranslationsJson({ text, sourceLanguage, env, entityType, entityId, fieldName, }: {
    text: string;
    sourceLanguage: string | null | undefined;
    env: any;
    entityType: string;
    entityId: string;
    fieldName: string;
}): Promise<string>;
export declare function cleanupTranslationTasksForEntity({ env, entityType, entityId, }: {
    env: any;
    entityType: string;
    entityId: string;
}): Promise<void>;
export declare function processPendingTranslationTasks({ env, entityType, entityId, limit, }: {
    env: any;
    entityType?: string;
    entityId?: string;
    limit?: number;
}): Promise<{
    processed: {
        id: any;
        entity_id: any;
        field_name: any;
        target_language: any;
    }[];
    failed: {
        id: any;
        error: any;
    }[];
    pending_checked: any;
}>;
