#! /usr/bin/env bash


MARLIN_JAR=$(ls /tomcat/webapps/geoserver/WEB-INF/lib/marlin-*.jar)
MARLIN=""

if [[ -n "${MARLIN_JAR}" ]]; then
	MARLIN="-Xbootclasspath/a:${MARLIN_JAR} -Dsun.java2d.renderer=org.marlin.pisces.PiscesRenderingEngine"
fi
export CATALINA_OPTS="${MARLIN} -Dorg.geotools.coverage.jaiext.enabled=true -Djava.library.path=/opt/gdal/lib"

${TOMCAT_HOME}/bin/catalina.sh run
