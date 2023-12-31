FROM node:18-alpine AS base

# ARG PNPM_VERSION=v8.2.0
ARG PNPM_VERSION=latest
ENV PNPM_HOME=/root/.local/share/pnpm
ENV PATH=$PATH:$PNPM_HOME

RUN apk add --no-cache libc6-compat
RUN apk add --no-cache curl && \
  curl -fsSL "https://github.com/pnpm/pnpm/releases/${PNPM_VERSION}/download/pnpm-linuxstatic-x64" -o /bin/pnpm && chmod +x /bin/pnpm && \
  apk del curl

RUN apk update
 
FROM base AS builder

# Set working directory
WORKDIR /app
RUN pnpm i -g turbo
COPY . .
RUN turbo prune --scope=web --docker
 
# Add lockfile and package.json's of isolated subworkspace
FROM base AS installer
RUN apk update
WORKDIR /app
 
# ENV NODE_ENV=production
# First install the dependencies (as they change less often)
COPY .gitignore .gitignore
COPY --from=builder /app/out/json/ .
COPY --from=builder /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
RUN pnpm i --frozen-lockfile
 
# Build the project
COPY --from=builder /app/out/full/ .
RUN pnpm turbo run build --filter=web...
 
FROM node:18-alpine AS runner
WORKDIR /app

 
ENV NODE_ENV=production
# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs
 
COPY --from=installer /app/apps/web/next.config.js .
COPY --from=installer /app/apps/web/package.json .
 
# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=installer --chown=nextjs:nodejs /app/apps/web/.next/standalone ./
COPY --from=installer --chown=nextjs:nodejs /app/apps/web/.next/static ./apps/web/.next/static
COPY --from=installer --chown=nextjs:nodejs /app/apps/web/public ./apps/web/public
 
CMD node apps/web/server.js