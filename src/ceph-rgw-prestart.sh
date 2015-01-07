#!/bin/sh

eval set -- "$(getopt -o n: --long name:,cluster: -- $@)"

while true ; do
	case "$1" in
		-n|--name) name=$2; shift 2 ;;
		--cluster) cluster=$2; shift 2 ;;
		--) shift ; break ;;
	esac
done


# prefix for radosgw instances in ceph.conf
PREFIX='client.radosgw.'

if [ -z "$name"  ]; then
    echo "no name paramter"
    exit 1
fi

testname=$(ceph-conf --list-sections $PREFIX | grep $name )

if [ -z "$testname"  ]; then
    echo $name
    echo "error parsing '$name' : valid types are: $(echo $(ceph-conf --list-sections $PREFIX))"
    exit 1
fi


RADOSGW=`which radosgw`

if [ -z "$RADOSGW"  ]; then
    RADOSGW=/usr/bin/radosgw
fi

if [ ! -x "$RADOSGW" ]; then
    [ $VERBOSE -eq 1 ] && echo "$RADOSGW could not start, it is not executable."
    exit 1
fi

auto_start=`ceph-conf -n $name 'auto start'`
if [ "$auto_start" = "no" ] || [ "$auto_start" = "false" ] || [ "$auto_start" = "0" ]; then
  echo "ceph.conf:[$name], says not to start."
  exit 1
fi

# is the socket defined?  if it's not, this instance shouldn't run as a daemon.
rgw_socket=`$RADOSGW -n $name --show-config-value rgw_socket_path`
if [ -z "$rgw_socket" ]; then
  echo "socket $rgw_socket could not be found in ceph.conf:[$name], not starting."
  exit 1
fi

# mapped to this host?
host=`ceph-conf -n $name host`
hostname=`hostname -s`
if [ "$host" != "$hostname" ]; then
  echo "hostname $hostname could not be found in ceph.conf:[$name], not starting."
  exit 1
fi

user=`ceph-conf -n $name user`
if [ -n "$user" ]; then
  if [ "$USER" != "$user" ]; then
    echo "enviroment \$USER '$USER' does not match '$name' user '$user'"
    exit 1
  fi
fi


log_file=`$RADOSGW -n $name --show-config-value log_file`
if [ -n "$log_file" ]; then
  if [ ! -e "$log_file" ]; then
    touch "$log_file"
  fi
  chown $USER $log_file
fi
