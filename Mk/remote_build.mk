# Variables:
#
# ROBORIO - the RoboRIO DNS name / IP address (expected to be set by user)
# BUILD_USER - the RoboRIO login to use (defaults to admin)
# BUILD_HOME - where build packages should be extracted (defaults to home)
#
# TGZ - the tar.gz source code file; defaults to last part of SOURCE
# EXTRA_CLEAN - extra files to be cleaned in clean
# BUILD_DEPS - a space-delimited list of opkg dependencies (for install-deps)
# BUILD_DIR - the directory where the TGZ gets extracted to.
#             defaults to TGZ with .tgz and .tar.gz stripped
# BUILD_DIR_EXTRA - the directory inside the TGZ that builds should happen in
# CONFIGURE_CMD - the build command
# BUILD_CMD - the build command
# INSTALL_CMD - the install command
# GETDATA_TARARGS - the args to use for tar when getting data
# GETDATA_DEV_TARARGS - if specified args to use for tar when getting development data
# GETDATA_DBG_TARARGS - if specified args to use for tar when getting debug data
# EXTRA_CONTROL - extra files to include in control.tar.gz
#
TGZ ?= $(lastword $(subst /, ,${SOURCE}))
BUILD_DIR ?= $(subst .tgz,,$(subst .tar.gz,,${TGZ}))
BUILD_USER ?= admin
STACK_SIZE ?= 4096

# Used by ipkwhl
GETDATA_EXTRA_TARARGS ?= 


ifndef ROBORIO
$(error ROBORIO is not set, use 'make ROBORIO=roborio-XXXX-frc.local')
endif

.PHONY: all init-ssh sync-date install-deps fetch extract patch build install strip-exes fetch-src getdata getdata-pkg getdata-dev getdata-dbg

ifdef GETDATA_DEV_TARARGS
GETDATA_DEV_TARGET=getdata-dev
endif

ifdef GETDATA_DBG_TARARGS
GETDATA_DBG_TARGET=getdata-dbg
endif

ALLTARGETS ?= clean \
	sync-date install-deps \
	fetch extract patch configure build install strip-exes \
	getdata ipk
all: ${ALLTARGETS}

init-ssh:
	ssh ${BUILD_USER}@${ROBORIO} 'mkdir -p .ssh && cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub

sync-date:
ifneq (${NOSETDATE}, 1)
	ssh ${BUILD_USER}@${ROBORIO} "date -s '`date -u +'%Y-%m-%d %H:%m:%S'`'"
endif

install-deps:
ifneq ($(strip ${DEPS}),)
	ssh ${BUILD_USER}@${ROBORIO} 'opkg update && opkg install ${DEPS} && (opkg clean || true)'
endif

fetch: ${TGZ}
${TGZ}:
	wget ${SOURCE}

extract: ${TGZ}
	ssh ${BUILD_USER}@${ROBORIO} 'cd ${BUILD_HOME} && rm -rf ${BUILD_DIR}'
	cat ${TGZ} | ssh ${BUILD_USER}@${ROBORIO} 'cd ${BUILD_HOME} && mkdir ${BUILD_DIR} && cd ${BUILD_DIR} && tar xzf - --strip-components=1'

patch:
ifdef PATCHES
	$(foreach patch, $(PATCHES), ssh ${BUILD_USER}@${ROBORIO} 'cd ${BUILD_HOME} && cd ${BUILD_DIR} && patch -p1' < $(patch))
endif	

configure:
	ssh ${BUILD_USER}@${ROBORIO} 'ulimit -s ${STACK_SIZE} && cd ${BUILD_HOME} && cd ${BUILD_DIR}/${BUILD_DIR_EXTRA} && ${CONFIGURE_CMD}'

build:
	ssh ${BUILD_USER}@${ROBORIO} 'ulimit -s ${STACK_SIZE} && cd ${BUILD_HOME} && cd ${BUILD_DIR}/${BUILD_DIR_EXTRA} && ${BUILD_CMD}'

install:
	ssh ${BUILD_USER}@${ROBORIO} 'ulimit -s ${STACK_SIZE} && cd ${BUILD_HOME} && cd ${BUILD_DIR}/${BUILD_DIR_EXTRA} && ${INSTALL_CMD}'

strip-exes:
ifneq ($(strip ${EXES}),)
	ssh ${BUILD_USER}@${ROBORIO} 'for exes in ${EXES}; do for exe in /$$exes; do \
		fdir=$$(dirname $$exe) && fbase=$$(basename "$$exe") && \
		fdebug="$${fbase%.*}.debug" && \
		mkdir -p "$$fdir"/.debug && \
		chmod u+w $$exe && \
		objcopy --only-keep-debug $$exe "$$fdir/.debug/$$fdebug" && \
		chmod 755 "$$fdir/.debug/$$fdebug" && \
		objcopy --strip-debug "$$exe" && \
		objcopy --add-gnu-debuglink="$$fdir/.debug/$$fdebug" "$$exe"; \
		done; done'
endif

getdata: getdata-pkg ${GETDATA_DEV_TARGET} ${GETDATA_DBG_TARGET}

getdata-pkg:
	mkdir -p data
	rm -rf data.new
	mkdir data.new
	set -o pipefail; cd data.new && ssh ${BUILD_USER}@${ROBORIO} 'cd / && tar ${GETDATA_EXTRA_TARARGS} -cf - ${GETDATA_TARARGS}' | tar xf -
	rm -rf data.old && mv data data.old && mv data.new data
	[ ! -d extra ] || cp -r extra/* data/

ifdef GETDATA_DEV_TARARGS
getdata-dev:
	mkdir -p devdata
	rm -rf devdata.new
	mkdir devdata.new
	set -o pipefail; cd devdata.new && ssh ${BUILD_USER}@${ROBORIO} 'cd / && tar ${GETDATA_EXTRA_TARARGS} -cf - ${GETDATA_DEV_TARARGS}' | tar xf -
	rm -rf devdata.old && mv devdata devdata.old && mv devdata.new devdata
	[ ! -d extradev ] || cp -r extradev/* devdata/
endif

ifdef GETDATA_DBG_TARARGS
getdata-dbg:
	mkdir -p dbgdata
	rm -rf dbgdata.new
	mkdir dbgdata.new
	set -o pipefail; cd dbgdata.new && ssh ${BUILD_USER}@${ROBORIO} 'cd / && tar ${GETDATA_EXTRA_TARARGS} -cf - ${GETDATA_DBG_TARARGS}' | tar xf -
	rm -rf dbgdata.old && mv dbgdata dbgdata.old && mv dbgdata.new dbgdata
	[ ! -d extradev ] || cp -r extradev/* dbgdata/
endif