FROM centos:7 as builder

ARG GDAL_VERSION
ARG MRSID_VERSION
ARG OPENJPEG_VERSION

RUN set -x && \
	yum install -y epel-release && \
	yum -y install https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm && \
	yum update -y && \
	yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip dejavu-fonts postgresql96 libcurl libsqlite3x sqlite3x wget openssl libxml2 proj49 && \
	yum -y clean all

RUN set -x && \
    yum groupinstall -y "Development Tools" && \
    yum install -y postgresql96-devel libcurl-devel libsqlite3x-devel openssl-devel libxml2-devel proj49-devel python-devel ant cmake

COPY assets/blobs/gdal-${GDAL_VERSION}.tar.gz /workspace/archive/
COPY assets/blobs/MrSID_DSDK-${MRSID_VERSION}.tar.gz /workspace/archive/
COPY assets/blobs/openjpeg-${OPENJPEG_VERSION}.tar.gz /workspace/archive/
COPY assets/build_gdal.sh /workspace/

RUN /workspace/build_gdal.sh
ENV PATH="/opt/gdal/bin:${PATH}" 
CMD [ "/bin/bash" ]

FROM centos:7 as geoserver
ARG GDAL_VERSION 
ARG GEOSERVER_VERSION 
ARG TOMCAT_VERSION

RUN set -x && \
	yum install -y epel-release && \
	yum -y install https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm && \
	yum update -y && \
	yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip dejavu-fonts postgresql96 libcurl libsqlite3x sqlite3x wget openssl libxml2 proj49 && \
	yum -y clean all

ENV BUILD=/workspace TOMCAT_HOME=/tomcat PATH="/opt/gdal/bin:${PATH}"  GEOSERVER_DATA_DIR=/geoserver/config GEOSERVER_DATA=/geoserver/data

COPY assets/blobs/apache-tomcat-${TOMCAT_VERSION}.tar.gz ${BUILD}/
COPY assets/blobs/geoserver-${GEOSERVER_VERSION}-war.zip ${BUILD}/
COPY assets/blobs/plugins ${BUILD}/plugins
COPY --from=builder /opt/gdal /opt/gdal
COPY assets/install_geoserver.sh ${BUILD}/
COPY assets/entrypoint.sh /entrypoint.sh
COPY assets/config ${GEOSERVER_DATA_DIR}

RUN ${BUILD}/install_geoserver.sh

COPY assets/index.html ${TOMCAT_HOME}/webapps/ROOT/index.html


VOLUME ${GEOSERVER_DATA_DIR}
VOLUME ${GEOSERVER_DATA}

EXPOSE 8080

CMD [ "su", "-m", "-c", "/entrypoint.sh", "tomcat"]



