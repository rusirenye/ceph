sysdunitfiles = \
	ceph.target \
    ceph-mds@.service \
    ceph-mon@.service \
    ceph-osd@.service

sysdunit_DATA = $(sysdunitfiles)

sysdtmpdfiles = \
    ceph.tmpfiles.d

sysdtmpd_DATA = $(sysdtmpdfiles)


EXTRA_DIST = $(sysdtmpdfiles) \
    $(sysdunitfiles)
sysdunitdir=/tmp/sysd/unit/
sysdtmpddir=/tmp/sysd/tmpdir.d/@VERSION@

