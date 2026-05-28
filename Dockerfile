# ── Stage 1: Builder ──────────────────────────────────────
FROM node:18-alpine AS builder
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --only=production

# ── Stage 2: Runtime ──────────────────────────────────────
FROM node:18-alpine AS runtime
WORKDIR /app

# Security: non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/node_modules ./node_modules
COPY app/ .

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

USER appuser
EXPOSE 3000

CMD ["node", "app.js"]
