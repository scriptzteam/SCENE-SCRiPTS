#!/bin/bash

###################################################################################################################
# slv-vnstat v0.2 01122007 silver
###################################################################################################################
# todo:
###################################################################################################################

vnstat="/usr/bin/vnstat"
devices="
eth0
eth1
eth4
"
sepline="------------------------------------------------------------------"

###################################################################################################################
# ONLY EDIT BELOW IF YOU KNOW WHAT YOU'RE DOING
###################################################################################################################

proc_convert() {
    if [ "${1}" -ge "0" ] && [ "${1}" -lt "1024" ]; then
        echo "${1} MB" | sed -e :a -e "s/^.\{1,9\}$/ &/;ta"
    fi
    if [ "${1}" -ge "1024" ]; then
        echo "`echo "${1} 1024" | awk '{printf "%0.2f", $1 / $2}'` GB" | sed -e :a -e "s/^.\{1,9\}$/ &/;ta"
    fi
}

if [ "`echo "$1" | grep -v -i "^-ad$"`" ] && [ "`echo "$1" | grep -v -i "^-am$"`" ] && [ "`echo "$1" | grep -v -i "^-at$"`" ] || [ "$1" == "" ]; then
  echo "slv-vnstat v0.2"
  echo " -ad, show total traffic today over all interfaces"
  echo " -am, show total traffic this month over all interfaces"
  echo " -ad 2007-01-01, show total traffic for 2007-01-01 over all interfaces"
  echo " -am 2007-02, show total traffic for 2007-02 over all interfaces"
  exit 0
fi

if [ "$1" == "-ad" ]; then
  period="day"; switch="d"
  if [ "$2" == "" ]; then
    epoch1=`date --date "\`date +"%Y-%m-%d 00:00:01"\`" +"%s"`
    epoch2=`date --date "\`date +"%Y-%m-%d 00:00:02"\`" +"%s"`
  else
    epoch1=`date --date "\`date +"$2 00:00:01"\`" +"%s"`
    epoch2=`date --date "\`date +"$2 00:00:02"\`" +"%s"`
  fi
header="`date --date "01/01/1970 +$epoch1 seconds GMT" +"%Y-%m-%d"`"
fi

if [ "$1" == "-am" ]; then
  period="month"; switch="m"
  if [ "$2" == "" ]; then
    epoch1=`date --date "\`date +"%Y-%m-01 00:00:01"\`" +"%s"`
    epoch2=`date --date "\`date +"%Y-%m-01 00:00:02"\`" +"%s"`
  else
    epoch1=`date --date "\`date +"$2-01 00:00:01"\`" +"%s"`
    epoch2=`date --date "\`date +"$2-01 00:00:02"\`" +"%s"`
  fi
header="`date --date "01/01/1970 +$epoch1 seconds GMT" +"%Y-%m"`"
if [ "$2" == "2006-11" ]; then
    echo " data incomplete for this month"  
    exit 0
  fi
fi

if [ "$1" == "-at" ]; then
  period="total"; switch="t"
  for device in $devices; do
    for line in `$vnstat --dumpdb -i $device|egrep total.x\;|sed '/./N;s/\n/;/'`;do
#      echo $line
      up=`echo $line|cut -d ';' -f 2`
      dn=`echo $line|cut -d ';' -f 4`
      tl=`echo "$up + $dn" | bc`
      echo " $device   up: `proc_convert ${up}`  /  down: `proc_convert ${dn}`  /  total: `proc_convert ${tl}`"
      tmp_up[i]="${up}";tmp_dn[i]="${dn}";tmp_tl[i]="${tl}"
      let "i=i+1"
    done
  done

  element_count=${#tmp_up[@]}; index=0
  total_up="0";total_dn="0";total_tl="0"
  while [ "${index}" -lt "${element_count}" ]
  do    # List all the elements in the array.
      total_up=`echo "${total_up} + ${tmp_up[$index]}" | bc`
      total_dn=`echo "${total_dn} + ${tmp_dn[$index]}" | bc`
      total_tl=`echo "${total_tl} + ${tmp_tl[$index]}" | bc`
      let "index = ${index} + 1"
  done
  echo $sepline
  echo "  all   up: `proc_convert ${total_up}`  /  down: `proc_convert ${total_dn}`  /  total: `proc_convert ${total_tl}`"
exit 0
fi

echo " traffic for $period: $header"
echo $sepline

if [ "$2" == "debug" ] || [ "$3" == "debug" ]; then
  echo "DEBUG: $epoch1 $epoch2"
fi

i=0

for device in $devices; do
  for line in `$vnstat --dumpdb -i $device|egrep "^${switch}\;"`; do
    ce=`echo $line|cut -d ';' -f 3`
    if [ "$ce" == "$epoch1" ] || [ "$ce" == "$epoch2" ]; then
      up=`echo $line|cut -d ';' -f 4`
      dn=`echo $line|cut -d ';' -f 5`
      tl=`echo "$up + $dn" | bc`
      echo " $device   up: `proc_convert ${up}`  /  down: `proc_convert ${dn}`  /  total: `proc_convert ${tl}`"
      tmp_up[i]="${up}";tmp_dn[i]="${dn}";tmp_tl[i]="${tl}"
      let "i=i+1"
    fi
  done
done

element_count=${#tmp_up[@]}; index=0
total_up="0";total_dn="0";total_tl="0"
while [ "${index}" -lt "${element_count}" ]
do    # List all the elements in the array.
    total_up=`echo "${total_up} + ${tmp_up[$index]}" | bc`
    total_dn=`echo "${total_dn} + ${tmp_dn[$index]}" | bc`
    total_tl=`echo "${total_tl} + ${tmp_tl[$index]}" | bc`
    let "index = ${index} + 1"
done

echo $sepline
echo "  all   up: `proc_convert ${total_up}`  /  down: `proc_convert ${total_dn}`  /  total: `proc_convert ${total_tl}`"

