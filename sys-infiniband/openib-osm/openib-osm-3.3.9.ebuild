# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

OFED_VER="1.5.3"
OFED_PATCH=".1"
OFED_SUFFIX="1"

inherit openib

DESCRIPTION="OpenSM - InfiniBand Subnet Manager and Administration for OpenIB"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=sys-infiniband/libibmad-1.3.7
		>=sys-infiniband/libibumad-1.3.7"
RDEPEND="$DEPEND
		 sys-infiniband/openib-files
		 net-misc/iputils"

src_configure() {
	econf \
		--enable-perf-mgr \
		--enable-default-event-plugin \
		--with-osmv="openib"
}

src_install() {
	make DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS README NEWS ChangeLog
	newconfd "${S}/scripts/opensm.sysconfig" opensm
	newinitd "${FILESDIR}/opensm.init.d" opensm
	insinto /etc/logrotate.d
	newins "${S}/scripts/opensm.logrotate" opensm
	# we dont nee this int script
	rm "${D}/etc/init.d/opensmd" || die "Dropping of upstream initscript failed"
}

pkg_postinst() {
	einfo "To automatically configure the infiniband subnet manager on boot,"
	einfo "edit /etc/opensm.conf and add opensm to your start-up scripts:"
	einfo "\`rc-update add opensm default\`"
}
