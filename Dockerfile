FROM redmine:4.2.3
LABEL maintainer="m.kravtsov@ossystem.ua"\
      APP="redmine"\
      ORGANIZATION="ossystem"

COPY --chown=redmine:redmine ./ ./
