include ./Mk/pkgdata.mk

DEPS = binutils-symlinks gcc-symlinks g++-symlinks libgcc-s-dev gcov make libreadline-dev openssl-dev libz-dev libsqlite3-dev libexpat-dev libxml2-dev libbz2-dev liblzma-dev libgdbm-dev libffi-dev pkgconfig

CONFIGURE_CMD = TMPDIR=${BUILD_HOME}/tmp CXX=/usr/bin/g++ ./configure --enable-shared --with-system-expat --enable-optimizations

BUILD_CMD = TMPDIR=${BUILD_HOME}/tmp CXX=/usr/bin/g++ make

INSTALL_CMD = make install

PATCHES = disable-re-test.patch

GETDATA_TARARGS = --exclude=usr/local/lib/python3.13/site-packages/numpy\* \
		  --exclude=usr/local/lib/python3.13/ensurepip \
		  --exclude=usr/local/lib/python3.13/idlelib \
		  --exclude=usr/local/lib/python3.13/pydoc_data \
		  --exclude=usr/local/lib/python3.13/test \
		  --exclude=usr/local/lib/python3.13/tkinter \
		  --exclude=usr/local/lib/python3.13/config-3.13-arm-linux-gnueabi/libpython3.13.a \
		  --exclude=usr/local/lib/python3.13/lib-dynload/.debug \
		  --exclude=\*.py[co] \
		  --exclude=__pycache__ \
		  usr/local/include/python3.13/pyconfig.h \
		  usr/local/lib/libpython3* \
		  usr/local/bin/*3.13 \
		  usr/local/bin/pip3 \
		  usr/local/bin/python3 \
		  usr/local/bin/python3-config \
		  usr/local/lib/python3.13 \
		  usr/local/bin/python3.13-config

GETDATA_DEV_TARARGS = --exclude=usr/local/include/python3.13/pyconfig.h \
		  usr/local/include/python3.13 \
		  usr/local/lib/pkgconfig/python3.pc \
		  usr/local/lib/pkgconfig/python3-embed.pc \
		  usr/local/lib/pkgconfig/python-3.13.pc \
		  usr/local/lib/pkgconfig/python-3.13-embed.pc \
		  usr/local/lib/python3.13/config-3.13-arm-linux-gnueabi/libpython3.13.a

GETDATA_DBG_TARARGS = usr/local/bin/.debug/python3.debug \
		  usr/local/lib/.debug/libpython3* \
		  usr/local/lib/python3.13/lib-dynload/.debug

EXTRA_CONTROL = postinst prerm

EXES = usr/local/bin/python3.13 \
       usr/local/lib/libpython3.13.so.1.0 \
       usr/local/lib/python3.13/lib-dynload/*.so

include ./Mk/remote_build.mk
include ./Mk/ipk.mk
