# Build stage
FROM node:20-alpine as build

RUN npm install -g @angular/cli

WORKDIR /app
COPY angular-realworld-example-app/package.json angular-realworld-example-app/package-lock.json* ./
RUN npm install
COPY angular-realworld-example-app/ .
RUN 
RUN npm run build -- --configuration production

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist/angular-conduit/browser /usr/share/nginx/html
COPY angular-realworld-example-app/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]