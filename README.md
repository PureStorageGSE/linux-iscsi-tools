# linux-iscsi-tools
Bash scripts for Linux and iscsi for FA and CBS

# Functionality.

This script will:

* detach an existing FlashArray or CBS volume from a Linux host, specifically the device mapper multipath `mpath[a-z]` device, deactivate any LVM volume group/LV's and the underlying scsi block devices (`sd[a-z`) presented to the host using iSCSI.
* remove any remaining iSCSI block devices
* rescan the underlying iSCSI block volumes associated to a volume that was resized on FA/CBS and initiate multipathd to refresh it's size so that it can be used.

Usage:

1. Clone this repo.

2. Check the permissions of the file are user executable, if required `chmod u+x remove-scsi-devs.sh`.
3. To use, run ```./remove-iscsi-devs.sh  -m <mpath[a-z]> to remove the multipath device mapper dev.```
4. Refresh device mapper and iSCSI devices after resizing ```./remove-iscsi-devs.sh  -s ```
5. Remove remaining iSCSI devices ```./remove-iscsi-devs.sh  -s```
   
Expected output for (3)
~~~
./remove-iscsi-devs.sh -m mpathf
mpathf
Are there any LVM volume groups associated to to mpathf?
Found a LVM volume on mpathf which is cbs-vg
Deactivating LVM volume on cbs-vg using vgchange -an cbs-vg
  0 logical volume(s) in volume group "cbs-vg" now active
Finding the list of scsi devices as part of mpathf...
Identified these devices as : sda
sdb
sdc
sdd
Removing device mapper dev mpathf
Now removing scsi block devices from bus..
sda
sdb
sdc
sdd

[Fri Oct 25 17:16:14 2024] scsi 2:0:0:1: alua: Detached
[Fri Oct 25 17:16:14 2024] scsi 3:0:0:1: alua: Detached
[Fri Oct 25 17:16:14 2024] scsi 4:0:0:1: alua: Detached
[Fri Oct 25 17:16:14 2024] scsi 5:0:0:1: alua: Detached
~~~

Daniel Cave, Pure storage, October 2024.
