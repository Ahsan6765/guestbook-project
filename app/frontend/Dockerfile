FROM nginx:1.25-alpine

#Remove default Nginx welcome configuration files
RUN rm -rf /usr/share/nginx/html/*

# Copy local presentation assets directly into the nginx public folder
COPY . /usr/share/nginx/html

# Expose the Nginx HTTP port
EXPOSE 80

#Run Nginx in the foreground to keep the container stays alive
CMD ["nginx", "-g", "daemon off;"]