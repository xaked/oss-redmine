FROM redmine:latest
COPY --chown=redmine:redmine ./ ./
