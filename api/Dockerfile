FROM node:20-slim

WORKDIR /app

# Copy package files
COPY package*.json ./
# Install all dependencies (including devDependencies for build)
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# Remove dev dependencies to reduce image size
RUN npm prune --production

# Expose port (Cloud Run sets PORT env var)
ENV PORT=8080
ENV NODE_ENV=production

# Start the server
CMD ["node", "dist/index.js"]

