FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json ./
COPY apps/admin/package.json apps/admin/package.json

RUN npm install

COPY . .

WORKDIR /app/apps/admin

RUN npm run build

FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY package.json ./
COPY apps/admin/package.json apps/admin/package.json

RUN npm install --omit=dev --workspace=apps/admin

COPY --from=builder /app/apps/admin/.next /app/apps/admin/.next
COPY --from=builder /app/apps/admin/public /app/apps/admin/public 2>/dev/null || true
COPY --from=builder /app/apps/admin/package.json /app/apps/admin/package.json
COPY --from=builder /app/apps/admin/next.config.ts /app/apps/admin/next.config.ts
COPY --from=builder /app/apps/admin/src /app/apps/admin/src

WORKDIR /app/apps/admin

EXPOSE 3001

CMD ["npm", "run", "start", "--", "-p", "3001"]
