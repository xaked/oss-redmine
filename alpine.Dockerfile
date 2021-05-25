FROM redmine:4.2.1-alpine

COPY --chown=redmine:redmine ./ ./

# RUN apk add --no-cache build-base libffi-dev\
#   && rm /usr/src/redmine/Gemfile.lock.mysql2\
#   && touch /usr/src/redmine/Gemfile.lock.mysql2\
#   && bundle exec rake --trace redmine:plugins:assets RAILS_ENV=production
  # && mkdir -p /usr/src/redmine/app/assets/config\
  # && echo '{}' > /usr/src/redmine/app/assets/config/manifest.js
