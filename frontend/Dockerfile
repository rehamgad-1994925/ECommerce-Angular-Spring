FROM node:12.7-alpine AS build
WORKDIR /usr/src/app
COPY . .
RUN npm install
RUN ng build --prod

FROM nginx:alpine

COPY --from=build /usr/src/app/dist/frontend  /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
