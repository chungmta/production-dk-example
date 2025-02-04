FROM node:18-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Install pnpm directly instead of using Corepack
RUN npm install -g pnpm

FROM base AS build
WORKDIR /app

# Copy only package files to optimize caching
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

# Copy the rest of the app files
COPY . .
ENV NODE_ENV=production
RUN pnpm run build

FROM base AS deploy
WORKDIR /app
ENV NODE_ENV=production

# Copy only necessary files
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/node_modules ./node_modules

EXPOSE 3000
CMD ["pnpm", "start"]
