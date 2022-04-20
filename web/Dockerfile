FROM node:16 as base

# Copy dependency files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install

# Copy web files
COPY public/ ./public/
COPY src/ ./src/

###
# Dev website deploy
###
FROM base as dev
ENTRYPOINT [ "yarn", "run", "start" ]

###
# Prod website deploy
###
FROM base as prod
RUN yarn build
ENTRYPOINT [ "yarn", "run", "serve" ]
