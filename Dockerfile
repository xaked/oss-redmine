# Using 4.0.5 because our DB can't do new migrations from redmine
# To select latest version we need to upgrade DB instance.
FROM redmine:4.0.5
COPY --chown=redmine:redmine ./ ./
