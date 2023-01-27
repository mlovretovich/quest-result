FROM node:10

WORKDIR /app

COPY . . 

RUN npm install

EXPOSE 3000

CMD [ "node", "src/000.js" ]
