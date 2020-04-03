FROM python:3.6-alpine
ADD . /opt/app
WORKDIR /opt/app
RUN apk add git && \
    pip3 install .[mysql,pgsql,serve] && \
    sh -c "echo -e \"LABELS:\n  IMAGE_TAG: $(pip freeze | awk -F '==' '/^openstack-refapp=/ {print $2}')\" > /dockerimage_metadata"

ENTRYPOINT gunicorn -c gunicorn.conf.py "openstack_refapp.app:create_app()"
