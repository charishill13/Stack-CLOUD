#!/bin/bash
sudo yum update -y
###CREATE EBS###
#ebs_vol="/dev/sdb /dev/sdc /dev/sdd"
###PARTITION ADDED DISKS###
sudo fdisk /dev/sdb <<EOT
n
p
1
2048
16777215
w
EOT
sudo fdisk /dev/sdc <<EOT
n
p
1
2048
16777215
w
EOT
sudo fdisk /dev/sdd <<EOT
n
p
1
2048
16777215
w
EOT
sudo fdisk /dev/sde <<EOT
n
p
1
2048
16777215
w
EOT
###CREATE DISK LABELS###
sudo pvcreate  /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1
###CREATE VOLUME GROUP###
sudo vgcreate stack_vg /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1
###CREATE LOGICAL VOLUMES###
sudo lvcreate -L 5G -n Lv_u01 stack_vg
sudo lvcreate -L 5G -n Lv_u02 stack_vg
sudo lvcreate -L 5G -n Lv_u03 stack_vg
sudo lvcreate -L 5G -n Lv_u04 stack_vg
###CREATE ext4 FILE SYSTEMS ON LOGICAL VOLUMES###
sudo mkfs.ext4 /dev/stack_vg/Lv_u01
sudo mkfs.ext4 /dev/stack_vg/Lv_u02
sudo mkfs.ext4 /dev/stack_vg/Lv_u03
sudo mkfs.ext4 /dev/stack_vg/Lv_u04
###CREATE MOUNT POINTS###
sudo mkdir /u01
sudo mkdir /u02
sudo mkdir /u03
sudo mkdir /u04
###MOUNT NEWLY CREATED DISKS###
sudo mount /dev/stack_vg/Lv_u01 /u01
sudo mount /dev/stack_vg/Lv_u02 /u02
sudo mount /dev/stack_vg/Lv_u03 /u03
sudo mount /dev/stack_vg/Lv_u04 /u04
###EXTEND DISK SIZES###
sudo lvextend -L +3G /dev/mapper/stack_vg-Lv_u01
sudo lvextend -L +3G /dev/mapper/stack_vg-Lv_u02
sudo lvextend -L +3G /dev/mapper/stack_vg-Lv_u03
sudo lvextend -L +3G /dev/mapper/stack_vg-Lv_u04
###RESIZE DISK SIZES###
sudo resize2fs /dev/mapper/stack_vg-Lv_u01
sudo resize2fs /dev/mapper/stack_vg-Lv_u02
sudo resize2fs /dev/mapper/stack_vg-Lv_u03
sudo resize2fs /dev/mapper/stack_vg-Lv_u04






