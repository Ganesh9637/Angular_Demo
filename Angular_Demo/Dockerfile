# Build stage
FROM node:20-alpine as build
WORKDIR /app

# Copy package files first for better caching
COPY Angular_Demo/angular-realworld-example-app/package*.json ./
RUN npm install

# Copy the rest of the application
COPY Angular_Demo/angular-realworld-example-app/ .

# Fix vulnerabilities
RUN npm audit fix --force

# Build the application
RUN npm run build -- --configuration production

# Production stage
FROM nginx:alpine
# Copy from the correct output path based on angular.json
COPY --from=build /app/dist/angular-conduit/browser /usr/share/nginx/html
# Create a basic nginx config if it doesn't exist
RUN if [ ! -f /app/nginx.conf ]; then \
    echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf; \
fi
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]