#!/bin/bash
while getopts "m:s:r:" option; do
  case $option in
    h) # show help
      Help
      	echo "Run the command as './remove-mpath-devs.sh -m mpathf' "
	echo "or.. ./remove-mpath-devs.sh -s   to clear up remaining scsi devices"
	exit 1
      ;;


    m) mpath_device=$OPTARG

	echo $OPTARG
	echo "Are there any LVM volume groups associated to to $mpath_device? "
	is_lvm_vg_on_mapth_dev=$( pvs|grep mpathf | awk {'print $2}' )
	if [[ -n "$is_lvm_vg_on_mapth_dev" ]] ; then
		echo "Found a LVM volume on $mpath_device which is $is_lvm_vg_on_mapth_dev"
		echo "Deactivating LVM volume on $is_lvm_vg_on_mapth_dev using vgchange -an $is_lvm_vg_on_mapth_dev"
		vgchange -an $is_lvm_vg_on_mapth_dev
	else
		echo "Couldn't find an LVM volume on the device $mpath_device, continuing with removing the it and scsi devices."
		echo
	fi
	echo "Finding the list of scsi devices as part of $mpath_device..."
	mpath_devs_list=$( multipath -l | awk {'print $3'} |grep sd )
	ret_code=$?
	if [[ "$ret_code" -gt "0" ]] ; then
		echo "No scsi block devices were found for $mpath_device, exiting."
		exit 1
	else
	echo  "Identified these devices as : ${mpath_devs_list}"
	echo "Removing device mapper dev $mpath_device"
	multipath -f $mpath_device

	echo "Now removing scsi block devices from bus.."
	for dev in $mpath_devs_list
	do
		echo $dev
		echo 1 > /sys/block/$dev/device/delete
	done
	sleep 5
	dmesg -T |tail -f |grep "Detached"
	fi
    ;;

# recscan scsi devs on mpath due to resizing changes
    r) mpath_device=$OPTARG

	# echo $OPTARG
	# echo "Are there any LVM volume groups associated to to $mpath_device? "
	# is_lvm_vg_on_mapth_dev=$( pvs|grep mpathf | awk {'print $2}' )
	# if [[ -n "$is_lvm_vg_on_mapth_dev" ]] ; then
	# 	echo "Found a LVM volume on $mpath_device which is $is_lvm_vg_on_mapth_dev"
	# 	echo "Deactivating LVM volume on $is_lvm_vg_on_mapth_dev using vgchange -an $is_lvm_vg_on_mapth_dev"
	# 	vgchange -an $is_lvm_vg_on_mapth_dev
	# else
	# 	echo "Couldn't find an LVM volume on the device $mpath_device, continuing with removing the it and scsi devices."
	# 	echo
	# fi

	echo "Finding the list of scsi devices as part of $mpath_device..."
	mpath_devs_list=$( multipath -l | awk {'print $3'} |grep sd )
	ret_code=$?
	if [[ "$ret_code" -gt "0" ]] ; then
		echo "No scsi block devices were found for $mpath_device, exiting."
		exit 1
	else
	echo  "Identified these devices as : ${mpath_devs_list}"
	echo "Rescanning scsi devices on dev $mpath_device"

	echo "Rescanning changes for devices listed below.."
	for dev in $mpath_devs_list
	do
		echo $dev
		echo 1 > /sys/block/$dev/device/rescan
	done
    echo "Refreshing $mpath_device"
    multipath -r $mpath_device
    
	sleep 5
	dmesg -T |tail -f |grep "Detached"
	fi
    ;;

	# -s scsi devices removal
	s)
	iscsi_devs=$(lsblk -S |grep sd| awk {'print $1'})
	ret_code=$?
	if [[ "$ret_code" -gt "0" ]] ; then
		echo "No scsi block devices were found for $mpath_device, exiting."
		echo 1
	else
	echo "Identified these devices as :"
        echo $iscsi_devs
	echo
	echo -n "Are you sure you want to remove these devices? (y/n) : "
	read -r answer
	
    case $answer in
	y|Y|yes|Yes|YES)

	echo "Now removing scsi block devices from bus.."
	for dev in $iscsi_devs
	do
		echo Removing $dev
		echo 1 > /sys/block/$dev/device/delete
	done
	sleep 5
	dmesg -T |tail -f |grep "Detached"
	;;

	n|N|no|No|NO)
	echo "Okay, accepted you said no, exiting."
	exit 1
	;;
	esac

	fi
	;;
esac
done
