ARG BASE_IMAGE=node:18.8-alpine
FROM $BASE_IMAGE as base

FROM base as builder

ARG INSTALL_CMD="yarn install"
ARG INSTALL_CMD_DEV_FLAGS=""
ARG BUILD_CMD="yarn build"
ARG RUN_CMD="yarn serve"

RUN echo "INSTALL_CMD: ${INSTALL_CMD}"
RUN echo "INSTALL_CMD_DEV_FLAGS: ${INSTALL_CMD_DEV_FLAGS}"
RUN echo "BUILD_CMD: ${BUILD_CMD}"
RUN echo "RUN_CMD: ${RUN_CMD}"

WORKDIR /home/node/app
COPY package*.json ./

COPY src src
COPY tsconfig.json .

RUN $INSTALL_CMD $INSTALL_CMD_DEV_FLAGS
RUN $BUILD_CMD

FROM base as runtime

ARG INSTALL_CMD="yarn install"
ARG INSTALL_CMD_PROD_FLAGS="--production"
ARG RUN_CMD="yarn serve"

RUN echo "RUNTIME VAL: INSTALL_CMD: ${INSTALL_CMD}"
RUN echo "RUNTIME VAL: INSTALL_CMD_PROD_FLAGS: ${INSTALL_CMD_PROD_FLAGS}"
RUN echo "RUNTIME VAL: RUN_CMD: ${RUN_CMD}"

ENV RUN_CMD $RUN_CMD

RUN echo "RUNTIME ENV: RUN_CMD: ${RUN_CMD}"

ENV NODE_ENV=production
ENV PAYLOAD_SECRET=MY_SECRET
ENV PAYLOAD_CONFIG_PATH=dist/payload.config.js

WORKDIR /home/node/app
COPY package*.json  ./

RUN ${INSTALL_CMD} ${INSTALL_CMD_PROD_FLAGS}
COPY --from=builder /home/node/app/dist ./dist
COPY --from=builder /home/node/app/build ./build

EXPOSE 3000

CMD ${RUN_CMD}
