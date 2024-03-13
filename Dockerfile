FROM node:20.11.1-alpine3.19 as build

WORKDIR /usr/src/node-red

COPY package.json .
# COPY settings.js .

RUN apk update && apk add git \
    && npm install axios@1.6.5 \
    && npm install --unsafe-perm --no-update-notifier --no-fund --omit=dev

COPY --chown=node-red:node-red . .


FROM node:20.11.1-alpine3.19

RUN addgroup -S node-red && adduser -S node-red -G node-red \
    && mkdir /data \
    && chown node-red:node-red /data

USER node-red

COPY --chown=node-red:node-red --from=build /usr/src/node-red/package.json /usr/src/node-red/package.json
COPY --chown=node-red:node-red --from=build /usr/src/node-red/packages /usr/src/node-red/packages
COPY --chown=node-red:node-red --from=build /usr/src/node-red/node_modules /usr/src/node-red/node_modules
COPY --chown=node-red:node-red --from=build /usr/src/node-red/scripts /usr/src/node-red/scripts

WORKDIR /usr/src/node-red

EXPOSE 1880

CMD ["npm", "start", "--", "--userDir", "/data"]
