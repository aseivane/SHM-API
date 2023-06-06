FROM node:18-alpine

# Create app directory
WORKDIR /app
RUN apk add --no-cache mosquitto-clients bash
# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodejs

# If you are building your code for production
#RUN npm ci --omit=dev

# Bundle app source
# COPY public ./public
# COPY src ./src
# COPY app.js .
# COPY cluster.js .
# COPY bash_scripts ./bash_scripts
# COPY python ./python

#RUN chown -R node /app/node_modules
#USER nodejs


CMD [ "npm", "run", "start" ]