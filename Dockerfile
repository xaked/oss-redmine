FROM redmine:4.0.5
COPY --chown=redmine:redmine ./ ./
