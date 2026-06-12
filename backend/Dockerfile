FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json tsconfig.json ./
RUN npm ci --only=production && cp -R node_modules /prod_modules && npm install

COPY src/ ./src/
RUN npm run build

FROM node:18-alpine AS production

WORKDIR /app

RUN addgroup --system app && adduser --system --ingroup app app

COPY --from=builder /app/dist ./dist
COPY --from=builder /prod_modules ./node_modules
COPY package.json ./

USER app

EXPOSE 3000

ENV NODE_ENV=production

CMD ["node", "dist/server.js"]
