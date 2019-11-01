FROM redmine:4
COPY --chown=redmine:redmine ./ ./
RUN bundle install
