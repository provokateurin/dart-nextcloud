FROM nextcloud

WORKDIR /usr/src/nextcloud
RUN chown -R www-data:www-data .
USER www-data
RUN ./occ maintenance:install --admin-user admin --admin-pass password --admin-email admin@example.com
RUN OC_PASS=passworddoesntmatter ./occ user:add --password-from-env --display-name="Test" test
RUN ./occ app:install spreed