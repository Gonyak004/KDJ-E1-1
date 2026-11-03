FROM nginx:alpine

LABEL description="Development Workstation Web Server"

COPY app/index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]