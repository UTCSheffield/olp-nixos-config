FROM node:lts-alpine
WORKDIR /usr/server

COPY package.json ./
COPY yarn.lock ./
RUN yarn config set strict-ssl false
RUN yarn

COPY . .
RUN yarn build
# RUN yarn prisma generate

EXPOSE 3000
EXPOSE 8080

CMD ["yarn", "start"]