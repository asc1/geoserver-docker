FROM centos:7 as builder

RUN set -x && \
	yum install -y epel-release && \
	yum -y install https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm && \
	yum update -y && \
	yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip dejavu-fonts postgresql96 libcurl libsqlite3x sqlite3x wget openssl libxml2 proj49 && \
	yum -y clean all

RUN set -x && \
    yum groupinstall -y "Development Tools" && \
    yum install -y postgresql96-devel libcurl-dev libsqlite3x-devel openssl-devel libxml2-devel proj49-devel python-devel ant

ENV GDAL_VERSION=2.3.1

 ADD http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz /workspace/archive/

 RUN set -x && \
    cd /workspace && \
    find /workspace -ls && \
    tar -xzf /workspace/archive/gdal-${GDAL_VERSION}.tar.gz && \
    cd gdal-${GDAL_VERSION} && \
    ./configure --prefix=/opt/gdal --with-pg=/usr/pgsql-9.6/bin/pg_config --with-curl=/usr/bin/curl-config --with-libz=internal --with-sqlite3 --with-java --with-xml2 --with-proj=/usr/proj49 && \
    make -j4 && \
    make install && \
    cd swig/java && \
    make -j4 && \
    make install && \
    cp gdal.jar .libs/*.so /opt/gdal/lib && \
    ln -s /opt/gdal/lib/libgdalalljni.so /opt/gdal/lib/libgdaljni.so && \
    # cd ../python && \
    # make -j4 && \
    # make install && \
    echo "gdal-${GDAL_VERSION}} Build Complete"


FROM centos:7

RUN set -x && \
	yum install -y epel-release && \
	yum -y install https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm && \
	yum update -y && \
	yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip dejavu-fonts postgresql96 libcurl libsqlite3x sqlite3x wget openssl libxml2 proj49 && \
	yum -y clean all

ENV BUILD=/workspace 
ENV TOMCAT_HOME=/tomcat TOMCAT_VERSION=9.0.10

# TOMCAT
ADD https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz ${BUILD}/

RUN set -x && \
    groupadd -g 501 tomcat && \
    useradd -g tomcat -u 501 tomcat && \
	mkdir -p ${TOMCAT_HOME} && \
    tar --strip-components=1 -xzf ${BUILD}/apache-tomcat-${TOMCAT_VERSION}.tar.gz -C ${TOMCAT_HOME} && \
	rm -rf ${TOMCAT_HOME}/webapps/* && \
	chown -R tomcat:tomcat ${TOMCAT_HOME}

COPY ./context.xml ${TOMCAT_HOME}/conf/context.xml
# GEOSERVER
ENV GEOSERVER_VERSION=2.13.2 GEOSERVER_DATA_DIR=/geoserver/config GEOSERVER_DATA=/geoserver/data

# Hack to get around sourceforge issues with ADD files...
RUN set -x && \
	mkdir -p ${BUILD}/plugins && \
	curl -L -o ${BUILD}/geoserver-${GEOSERVER_VERSION}-war.zip http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip && \
	curl -L -o ${BUILD}/plugins/geoserver-${GEOSERVER_VERSION}-wps-plugin.zip http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-wps-plugin.zip && \
	curl -L -o ${BUILD}/plugins/geoserver-${GEOSERVER_VERSION}-vectortiles-plugin.zip http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-vectortiles-plugin.zip && \
	curl -L -o ${BUILD}/plugins/geoserver-${GEOSERVER_VERSION}-gdal-plugin.zip http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-gdal-plugin.zip


COPY --from=builder /opt/gdal /opt/gdal
COPY ./run.sh ${TOMCAT_HOME}/bin/run.sh
COPY ./config ${GEOSERVER_DATA_DIR}
COPY ./index.html ${TOMCAT_HOME}/webapps/ROOT/index.html

RUN set -x && \
	echo "/opt/gdal/lib/" > /etc/ld.conf.d/gdal-lib.conf
	unzip -n ${BUILD}/geoserver-${GEOSERVER_VERSION}-war.zip -d ${BUILD}/ geoserver.war && \
	mkdir -p ${GEOSERVER_DATA_DIR} ${GEOSERVER_DATA} ${BUILD}/geoserver && \
	cd ${BUILD}/geoserver && \
	jar -xf ${BUILD}/geoserver.war && \
	for plugin in $(/usr/bin/ls ${BUILD}/plugins/geoserver*.zip); do \
    	unzip -n ${plugin} -d ${BUILD}/geoserver/WEB-INF/lib; \
	done && \
	for jar in $(/usr/bin/ls ${BUILD}/plugins/*.jar); do \
	 	cp ${jar} ${BUILD}/geoserver/WEB-INF/lib/; \
	done && \
	mv ${BUILD}/geoserver ${TOMCAT_HOME}/webapps/ && \
	chown -R tomcat:tomcat ${TOMCAT_HOME} ${GEOSERVER_DATA_DIR} ${GEOSERVER_DATA}

ENV PATH="/opt/gdal/bin:${PATH}"

VOLUME ${GEOSERVER_DATA_DIR}
VOLUME ${GEOSERVER_DATA}

EXPOSE 8080

CMD [ "su", "-m", "-c", "${TOMCAT_HOME}/bin/run.sh", "tomcat"]



