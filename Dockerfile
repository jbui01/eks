# ---- Build stage ----
# Using ECR Public mirror to avoid Docker Hub rate limits in CodeBuild
FROM public.ecr.aws/docker/library/node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# ---- Runtime stage ----
FROM public.ecr.aws/docker/library/node:20-alpine
WORKDIR /app
# Non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/
COPY package.json ./
# Give the non-root user ownership of all app files
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 3000
CMD ["node", "src/index.js"]
