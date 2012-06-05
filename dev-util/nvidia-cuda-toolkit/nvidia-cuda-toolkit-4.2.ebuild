# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/nvidia-cuda-toolkit/nvidia-cuda-toolkit-4.1.ebuild,v 1.7 2012/02/21 21:42:21 spock Exp $

EAPI=2

inherit eutils multilib unpacker

DESCRIPTION="NVIDIA CUDA Toolkit"
HOMEPAGE="http://developer.nvidia.com/cuda"
RESTRICT="binchecks"

CUDA_V=${PV//_/-}
DIR_V=${CUDA_V//./_}
DIR_V=${DIR_V//beta/Beta}

BASE_URI="http://developer.download.nvidia.com/compute/cuda/${DIR_V}/rel/toolkit"
SRC_URI="amd64? ( ${BASE_URI}/cudatoolkit_${CUDA_V}.28_linux_64_ubuntu11.04.run )
	x86? ( ${BASE_URI}/cudatoolkit_${CUDA_V}.28_linux_32_ubuntu11.04.run )"

LICENSE="NVIDIA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debugger doc profiler"

RDEPEND="${DEPEND}
	>=sys-devel/binutils-2.20
	>=sys-devel/gcc-4.5
	debugger? ( >=sys-libs/libtermcap-compat-2.0.8-r2 )
	!<=x11-drivers/nvidia-drivers-270.41"

S="${WORKDIR}"

#QA_DT_HASH_x86="opt/cuda/.*"
#QA_DT_HASH_amd64="opt/cuda/.*"

src_install() {
	local DEST=/opt/cuda

	into ${DEST}
	dobin bin/*
	dobin nvvm/*
	dolib $(get_libdir)/*

	if ! use debugger; then
		rm -f "${D}/${DEST}/bin/cuda-gdb"
	else
		insinto ${DEST}/extras
		doins -r extras/Debugger
	fi

	if use profiler; then
		# TODO: Use system JRE for the profiler?
		insinto ${DEST}
		doins -r libnvvp
		fperms a+x ${DEST}/libnvvp/nvvp ${DEST}/libnvvp/jre/bin/* ${DEST}/libnvvp/*.so

		cat > "${T}/nvv" << EOF
#!/bin/sh
LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${DEST}/lib:${DEST}/lib64 ${DEST}/libnvvp/nvvp
EOF
		dobin "${T}/nvv"
		insinto ${DEST}/extras
		doins -r extras/CUPTI
	fi

	chmod a-x "${D}/${DEST}/bin/nvcc.profile"
	chmod a-x "${D}/${DEST}/bin/ci_include.h"

	# TODO: Manuals are missing from this release. Remove the following
	# commented-out lines if they are not restored in the next releases.
	# doman does not respect DESTTREE
	#insinto ${DEST}/man/man1
	#doins man/man1/*
	#insinto ${DEST}/man/man3
	#doins man/man3/*
	#prepman ${DEST}

	insinto ${DEST}/include
	doins -r include/*

	insinto ${DEST}/src
	doins src/*

	if use doc ; then
		insinto ${DEST}/doc
		doins -r doc/*
	fi

	cat > "${T}/env" << EOF
PATH=${DEST}/bin
ROOTPATH=${DEST}/bin
LDPATH=${DEST}/$(get_libdir)
MANPATH=${DEST}/man
EOF
	newenvd "${T}/env" 99cuda

	export CONF_LIBDIR_OVERRIDE="lib"
	# HACK: temporary workaround until CONF_LIBDIR_OVERRIDE is respected.
	export LIBDIR_amd64="lib"

	into ${DEST}/open64
	dobin open64/bin/*
	libopts -m0755
	dolib open64/lib/*
}

pkg_postinst() {
	elog "If you want to natively run the code generated by this version of the"
	elog "CUDA toolkit, you will need >=x11-drivers/nvidia-drivers-260.19.21."
	elog ""
	elog "Run '. /etc/profile' before using the CUDA toolkit. "
}
