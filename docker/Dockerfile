# ---------- 前端 UI 构建 ----------
FROM node:lts-bookworm-slim AS ui
WORKDIR /src/apps
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate
COPY apps/package.json apps/pnpm-lock.yaml apps/vite.config.js apps/index.html ./
COPY apps/src ./src
COPY apps/tests ./tests
COPY apps/scripts ./scripts
RUN pnpm install --frozen-lockfile --registry=https://registry.npmmirror.com
RUN pnpm run build

# ---------- Rust 构建 ----------
FROM rust:1-bookworm AS builder
WORKDIR /src
COPY Cargo.toml Cargo.lock ./
COPY crates ./crates
COPY --from=ui /src/apps/dist ./apps/dist
RUN cargo build -p codexmanager-service --release
RUN cargo build -p codexmanager-web --release --features embedded-ui

# ---------- 运行镜像 ----------
FROM debian:bookworm-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/target/release/codexmanager-service /usr/local/bin/codexmanager-service
COPY --from=builder /src/target/release/codexmanager-web /usr/local/bin/codexmanager-web

ENV CODEXMANAGER_SERVICE_ADDR=0.0.0.0:48760
ENV CODEXMANAGER_WEB_ADDR=0.0.0.0:48761
ENV CODEXMANAGER_WEB_NO_SPAWN_SERVICE=1
ENV CODEXMANAGER_WEB_NO_OPEN=1
ENV CODEXMANAGER_DB_PATH=/data/codexmanager.db
ENV CODEXMANAGER_RPC_TOKEN=CodexRpcToken

VOLUME ["/data"]
EXPOSE 48761 48760

# 启动 service + web
CMD ["/bin/sh", "-c", "codexmanager-service & codexmanager-web"]
