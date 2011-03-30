# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

OFED_VER="1.5.3"
OFED_PATCH=".1"
OFED_SUFFIX="1.18.gb810a27"

inherit openib

DESCRIPTION="OpenIB userspace driver for Mellanox ConnectX HCA"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=sys-infiniband/libibverbs-1.1.4-r1"
RDEPEND="${DEPEND}
        !sys-infiniband/openib-userspace"

src_install() {
    make DESTDIR="${D}" install || die "install failed"
    dodoc README AUTHORS ChangeLog
}
