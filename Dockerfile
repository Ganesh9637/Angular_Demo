# Build stage
FROM node:20-alpine as build
WORKDIR /app
COPY Angular_Demo/angular-realworld-example-app/package.json Angular_Demo/angular-realworld-example-app/package-lock.json* ./
RUN npm install
COPY Angular_Demo/angular-realworld-example-app/ .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist/angular-conduit/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]