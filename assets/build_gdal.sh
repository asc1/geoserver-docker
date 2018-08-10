#! /bin/bash -x

cd /workspace 
tar -xzf /workspace/archive/gdal-${GDAL_VERSION}.tar.gz
cd gdal-${GDAL_VERSION}
./configure --prefix=/opt/gdal --with-pg=/usr/pgsql-9.6/bin/pg_config --with-curl=/usr/bin/curl-config --with-libz=internal --with-sqlite3 --with-java --with-xml2 --with-proj=/usr/proj49
make -j4
make install
cd swig/java
make -j4
make install
cp gdal.jar .libs/*.so /opt/gdal/lib
ln -s /opt/gdal/lib/libgdalalljni.so /opt/gdal/lib/libgdaljni.so
# cd ../python
# make -j4
# make install
echo "gdal-${GDAL_VERSION} Build Complete"