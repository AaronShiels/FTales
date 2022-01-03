FROM node:17-alpine
WORKDIR /usr/

COPY package.json .
RUN npm install

COPY tsconfig.server.json .
COPY src/server/ ./src/server/
RUN npm run 'build: server: release'

EXPOSE 5000
CMD [ "node", "./dist/server/index.js" ]