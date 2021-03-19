FROM redmine:4.1.1-alpine
COPY --chown=redmine:redmine ./ ./
