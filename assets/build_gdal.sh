#! /bin/bash -x

mkdir -p /opt/gdal/include /opt/gdal/lib /opt/gdal/bin
echo "Installing MrSID Libraries"
cd /workspace
tar -xzf /workspace/archive/MrSID_DSDK-${MRSID_VERSION}.tar.gz
cp -rp /workspace/MrSID_DSDK-${MRSID_VERSION}/Raster_DSDK/include/* /opt/gdal/include/
cp -rp /workspace/MrSID_DSDK-${MRSID_VERSION}/Raster_DSDK/lib/* /opt/gdal/lib/
cp -rp /workspace/MrSID_DSDK-${MRSID_VERSION}/Raster_DSDK/bin/* /opt/gdal/bin/
echo "Building OpenJpeg libraries"
cd /workspace
tar -xzf /workspace/archive/openjpeg-${OPENJPEG_VERSION}.tar.gz
cd openjpeg-${OPENJPEG_VERSION}
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/gdal
make -j4
make install
echo "Building GDAL"
cd /workspace
tar -xzf /workspace/archive/gdal-${GDAL_VERSION}.tar.gz
cd gdal-${GDAL_VERSION}
export PKG_CONFIG_PATH=/opt/gdal/lib/pkgconfig
./configure --prefix=/opt/gdal --with-pg=/usr/pgsql-9.6/bin/pg_config --with-curl=/usr/bin/curl-config --with-libz=internal --with-sqlite3 --with-java --with-xml2 --with-proj=/usr/proj49 --with-mrsid=/opt/gdal --with-openjpeg=/opt/gdal
make -j4
make install
cd /workspace/gdal-${GDAL_VERSION}/swig/java
make -j4
make install
cp gdal.jar .libs/*.so /opt/gdal/lib
ln -s /opt/gdal/lib/libgdalalljni.so /opt/gdal/lib/libgdaljni.so
cd /workspace/gdal-${GDAL_VERSION}/swig/python
make
make install
echo "/opt/gdal/lib/" > /etc/ld.so.conf.d/gdal-lib.conf
echo "gdal-${GDAL_VERSION} Build Complete"