#!/bin/sh
# copy specs to separate tree, make rpmcs and printout diff

# load common functions, compatible with local and installed script
. `dirname $0`/../share/eterbuild/functions/common

get_wd()
{
	apt-cache whatdepends $1 | grep "^  [a-zA-Z]" | sed -e "s|^ *||g"
}
list_wd()
{
	for i in $@ ; do
		#echo i=$i
		get_wd `echo $i | sed "s|-[0-9].*||g"`
	done
}

print_usedby()
{
	echo "Required by:"
	print_list $USEDBY
	echo "Second required by:"
	print_list `list_wd $USEDBY`
}


SPECLIST=`find $RPMDIR/SPECS -type f -name "*.spec"`
for i in $SPECLIST ; do
	if echo $i | grep -q HELP ; then
		continue
	fi
	LANG=C rpmgp -c $i 2>&1 | grep -v "^Note" | grep -v "^Checking" | grep -v "^Repository"
	USEDBY=$(get_wd `basename $i .spec`)
	if [ -n "$USEDBY" ] ; then 
		print_usedby $i $USEDBY >$i.usedby
		#[ -n "`cat $i.usedby`" ] || 
	else
		if [ -r $i.usedby ] ; then
			echo "$i do not required anymore"
		else
			rm -f $i.usedby
		fi
	fi
done
