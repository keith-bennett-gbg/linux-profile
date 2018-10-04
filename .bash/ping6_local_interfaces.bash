

#
ping6_local_interfaces()
{
	for iface
	do
		search="([0-9a-f]{1,4}::?){1,7}([0-9a-f]{1,4})%.*: "
		# echo "ping6 -I \"${iface}\" ff02::1 -c 2 | grep "bytes from" | grep -oP \"${search}\" | sed -r 's/: $//g' | sort -u"
		ping6 -I "${iface}" ff02::1 -c 2 | grep "bytes from" | grep -oP "${search}" | sed -r 's/: $//g' | sort -u
	done
	wait
}

