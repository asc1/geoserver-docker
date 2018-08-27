#! /bin/bash 

. ./env

mkdir -p assets/blobs/plugins
echo "Fetching GDAL Source (${GDAL_VERSION})"
curl -s -L -o assets/blobs/gdal-${GDAL_VERSION}.tar.gz  -z assets/blobs/gdal-${GDAL_VERSION}.tar.gz http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz 
curl -s -L -o assets/blobs/MrSID_DSDK-${MRSID_VERSION}.tar.gz -z assets/blobs/MrSID_DSDK-${MRSID_VERSION}.tar.gz http://bin.lizardtech.com/download/developer/MrSID_DSDK-${MRSID_VERSION}.tar.gz

echo "Fetching GeoServer Version (${GEOSERVER_VERSION})"
curl -s -L -o assets/blobs/geoserver-${GEOSERVER_VERSION}-war.zip -z assets/blobs/geoserver-${GEOSERVER_VERSION}-war.zip  http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip
curl -s -L -o assets/blobs/plugins/geoserver-${GEOSERVER_VERSION}-wps-plugin.zip -z assets/blobs/plugins/geoserver-${GEOSERVER_VERSION}-wps-plugin.zip http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-wps-plugin.zip && \
curl -s -L -o assets/blobs/plugins/geoserver-${GEOSERVER_VERSION}-vectortiles-plugin.zip -z ssets/blobs/plugins/geoserver-${GEOSERVER_VERSION}-vectortiles-plugin.zip http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-vectortiles-plugin.zip && \
curl -s -L -o assets/blobs/plugins/geoserver-${GEOSERVER_VERSION}-gdal-plugin.zip -z assets/blobs/plugins/geoserver-${GEOSERVER_VERSION}-gdal-plugin.zip http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-gdal-plugin.zip

echo "Fetching Tomcat Version (${TOMCAT_VERSION})"
curl -s -L -o assets/blobs/apache-tomcat-${TOMCAT_VERSION}.tar.gz -z assets/blobs/apache-tomcat-${TOMCAT_VERSION}.tar.gz  https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz


echo "Building Docker Image"

BUILD_ARGS=""
while read e; do
    BUILD_ARGS="${BUILD_ARGS} --build-arg $e";
done <env

echo $BUILD_ARGS
docker build --rm --target=builder   -t local/gdal-builder:${GDAL_VERSION} ${BUILD_ARGS} . 
docker build --rm --target=geoserver -t local/geoserver:${GEOSERVER_VERSION} ${BUILD_ARGS} .