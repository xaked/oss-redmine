FROM redmine:4.1.2

COPY --chown=redmine:redmine ./ ./

# RUN apt-get update && apt-get install -y build-essential libffi-dev\
#   && rm /usr/src/redmine/Gemfile.lock.mysql2\
#   && touch /usr/src/redmine/Gemfile.lock.mysql2\
#   && bundle exec rake --trace redmine:plugins:assets RAILS_ENV=production\
#   # && mkdir -p /usr/src/redmine/app/assets/config\
#   # && echo '{}' > /usr/src/redmine/app/assets/config/manifest.js\
#   && rm -rf /var/lib/apt/lists/*
