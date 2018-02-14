FROM nginx:1.13-alpine

# Need to delete default config which can end up as the default server
RUN rm /etc/nginx/conf.d/*.conf

COPY site.conf /etc/nginx/conf.d/

EXPOSE 80 443
