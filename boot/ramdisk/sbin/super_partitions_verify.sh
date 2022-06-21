#!/system/bin/sh
#===============================================================================
#
#        AUTHOR: Leon (80119410)
#
#===============================================================================
result_file=$1
result_flag=$2
touch $result_file
touch $result_flag
echo "fail" > $result_flag
check_result="校验结果：\n"

#No my_preload and my_company in list
component_list=(my_carrier my_engineering my_heytap my_manifest my_product my_region my_stock odm product system system_ext vendor)
for name in ${component_list[@]}; do
	block_device="/dev/block/mapper/"$name
	checksum=`sha1sum $block_device | awk '{print $1}'`
	check_result=$check_result$checksum"    "$name"\n"
done
echo $check_result > $result_file
echo "success" > $result_flag
sync
