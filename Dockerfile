FROM node:18-alpine

# Create app directory
WORKDIR /app

# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodejs

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

RUN \
    if [ -f package-lock.json ]; then npm ci; \
    else npm install; \
    fi
# If you are building your code for production
#RUN npm ci --omit=dev

# Bundle app source
COPY public ./public
COPY src ./src
COPY app.js .
COPY cluster.js .
COPY bash_scripts ./bash_scripts
COPY mediciones ./mediciones
COPY python ./python

RUN chown -R node /app/node_modules
USER nodejs


CMD [ "npm", "run", "start" ]