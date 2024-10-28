# rebuild at: Mon Oct 28 16:52:01 CET 2024
ARG FROM=python:3.8-alpine

FROM $FROM as builder
ADD . /opt/app
WORKDIR /opt/app
RUN apk add git gcc g++ python3-dev linux-headers libc-dev
RUN pip3 wheel --wheel-dir /opt/wheels --find-links /opt/wheels /opt/app[mysql,pgsql,serve]


FROM $FROM

COPY --from=builder /opt/wheels /opt/wheels
COPY --from=builder /opt/app /opt/app
RUN set -xe \
    && apk -U upgrade \
    && pip3 install --no-index --no-cache --find-links /opt/wheels openstack-refapp[mysql,pgsql,serve]
RUN sh -c "echo -e \"LABELS:\n  IMAGE_TAG: $(python3 -c 'from openstack_refapp import version; print(version.release_string)')\" > /dockerimage_metadata"
RUN rm -rvf /opt/wheels /var/cache/apk/*

CMD ["/usr/local/bin/gunicorn", "-c", "/opt/app/gunicorn.conf.py", "openstack_refapp.app:create_app()"]

