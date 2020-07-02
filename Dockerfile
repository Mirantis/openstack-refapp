FROM python:3.6-alpine
ADD . /opt/app
WORKDIR /opt/app
RUN apk add git && \
    pip3 install --no-cache .[mysql,pgsql,serve] && \
    sh -c "echo -e \"LABELS:\n  IMAGE_TAG: $(python3 -c 'from openstack_refapp import version; print(version.release_string)')\" > /dockerimage_metadata"

CMD ["/usr/local/bin/gunicorn", "-c", "/opt/app/gunicorn.conf.py", "openstack_refapp.app:create_app()"]
