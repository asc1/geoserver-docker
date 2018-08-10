#! /bin/bash -x

. ./env
echo "Installing Tomcat (${TOMCAT_VERSION})"
groupadd -g 501 tomcat
useradd -g tomcat -u 501 tomcat
mkdir -p ${TOMCAT_HOME}
tar --strip-components=1 -xzf ${BUILD}/apache-tomcat-${TOMCAT_VERSION}.tar.gz -C ${TOMCAT_HOME}
rm -rf ${TOMCAT_HOME}/webapps/*
chown -R tomcat:tomcat ${TOMCAT_HOME}
echo "Finished Tomcat Install (${TOMCAT_VERSION})"

echo "Installing Tomcat (${TOMCAT_VERSION})"
echo "/opt/gdal/lib/" > /etc/ld.conf.d/gdal-lib.conf
unzip -n ${BUILD}/geoserver-${GEOSERVER_VERSION}-war.zip -d ${BUILD}/ geoserver.war
mkdir -p ${GEOSERVER_DATA_DIR} ${GEOSERVER_DATA} ${BUILD}/geoserver
cd ${BUILD}/geoserver
jar -xf ${BUILD}/geoserver.war
for plugin in $(/usr/bin/ls ${BUILD}/plugins/geoserver*.zip); do \
    unzip -n ${plugin} -d ${BUILD}/geoserver/WEB-INF/lib; \
done
for jar in $(/usr/bin/ls ${BUILD}/plugins/*.jar); do \
    cp ${jar} ${BUILD}/geoserver/WEB-INF/lib/; \
done
rm ${BUILD}/geoserver/WEB-INF/lib/imageio-ext-gdal-bindings-*.jar
cp /opt/gdal/lib/gdal.jar ${BUILD}/geoserver/WEB-INF/lib/gdal-bindings-${GDAL_VERSION}.jar
mv ${BUILD}/geoserver ${TOMCAT_HOME}/webapps/

chown -R tomcat:tomcat ${TOMCAT_HOME} ${GEOSERVER_DATA_DIR} ${GEOSERVER_DATA}