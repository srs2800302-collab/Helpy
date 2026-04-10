FROM node:22-alpine AS builder

WORKDIR /app

COPY package.json ./
COPY apps/api/package.json apps/api/package.json

RUN npm install

COPY . .

WORKDIR /app/apps/api

RUN npm run prisma:generate
RUN npm run build

FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

COPY package.json ./
COPY apps/api/package.json apps/api/package.json

RUN npm install --omit=dev --workspace=apps/api

COPY --from=builder /app/apps/api/dist /app/apps/api/dist
COPY --from=builder /app/apps/api/prisma /app/apps/api/prisma

WORKDIR /app/apps/api

EXPOSE 3000

CMD ["node", "dist/main.js"]
