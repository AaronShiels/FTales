FROM node:17-alpine
WORKDIR /usr/

RUN apk --no-cache add curl

COPY package.json .
RUN npm install

COPY tsconfig*.json .
COPY src/server/ ./src/server/
RUN npm run 'build: server: release'

ENV PORT=80
EXPOSE 80
CMD [ "node", "./dist/server/index.js" ]