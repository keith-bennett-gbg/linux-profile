

#
ping6_local_interfaces()
{
	for iface
	do
		search="([0-9a-f]{1,4}::?){1,7}([0-9a-f]{1,4})%.*: "
		# echo "ping6 -I \"${iface}\" ff02::1 -c 2 -w 1 | grep "bytes from" | grep -oP \"${search}\" | sed -r 's/: $//g' | sort -u"
		#
		# -I interface
		# ff02::1 RFC4291 All Nodes Address, Link-Local: https://tools.ietf.org/html/rfc4291
		# -c count
		# -w number of seconds to wait for each ping
		ping6 -I "${iface}" ff02::1 -c 2 -w 1 | grep "bytes from" | grep -oP "${search}" | sed -r 's/: $//g' | sort -u
	done
	wait
}

