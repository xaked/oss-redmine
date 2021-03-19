FROM redmine:4.1.1
COPY --chown=redmine:redmine ./ ./
