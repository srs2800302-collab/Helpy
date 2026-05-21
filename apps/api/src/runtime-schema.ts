import { ensureChatSchema } from './chat';
import { ensureDisputesSchema } from './disputes';
import { ensureBaseSchema } from './init-schema';
import { ensureJobsSchema } from './jobs';
import { ensureJobPhotosSchema } from './job-photos';
import { ensureOffersSchema } from './offers';
import { ensurePaymentMethodsSchema } from './payment-methods';
import { ensurePaymentsSchema } from './payments';
import { ensureReviewsSchema } from './reviews';
import { ensurePaymentCustomersSchema } from './stripe-setup';
import { ensurePaymentEventsSchema } from './stripe-webhook';
import { ensureTranslationTasksSchema } from './translation';

export async function ensureRuntimeSchema(env: any) {
  await ensureJobsSchema(env);
  await ensureOffersSchema(env);
  await ensureChatSchema(env);
  await ensureReviewsSchema(env);
  await ensurePaymentsSchema(env);
  await ensureDisputesSchema(env);
  await ensureJobPhotosSchema(env);
  await ensurePaymentMethodsSchema(env);
  await ensurePaymentCustomersSchema(env);
  await ensurePaymentEventsSchema(env);
  await ensureTranslationTasksSchema(env);
  await ensureBaseSchema(env);
}
