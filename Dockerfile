FROM node:10

WORKDIR /app

COPY . . 

RUN npm install

ENV SECRET_WORD="TwelveFactor"

EXPOSE 3000

CMD [ "node", "src/000.js" ]
