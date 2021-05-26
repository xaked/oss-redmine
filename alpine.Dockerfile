FROM redmine:4.2.1-alpine
LABEL maintainer="m.kravtsov@ossystem.ua"\
      APP="redmine"\
      ORGANIZATION="ossystem"

COPY --chown=redmine:redmine ./ ./
