#!/bin/sh
echo -e "\e[1;36m 下载屏蔽广告规则 \e[0m\n"
TMP_ADBLOCK_DL=/tmp/tmp_adblock_dl
TMP_ADBLOCK_HOSTS=/tmp/tmp_adblock_hosts
TMP_ADBLOCK_WHITE=/tmp/tmp_adblock_white

ADBLOCK_HOSTS=/jffs/configs/adblock_hosts
ADBLOCK_WHITE=/jffs/adblock_white
##########################################################################################################
# 下载规则
wget --no-check-certificate -t 20 -T 60 -O- https://cdn.jsdelivr.net/gh/neoFelhz/neohosts@gh-pages/127.0.0.1/full/hosts > ${TMP_ADBLOCK_DL}.1
wget --no-check-certificate -t 20 -T 60 -O- https://raw.githubusercontent.com/ilpl/ad-hosts/master/hosts > ${TMP_ADBLOCK_DL}.2
wget --no-check-certificate -t 20 -T 60 -O- https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts > ${TMP_ADBLOCK_DL}.3
#wget --no-check-certificate -t 20 -T 60 -O- https://raw.githubusercontent.com/Goooler/1024_hosts/master/hosts > ${TMP_ADBLOCK_DL}.4
wget -t 15 -T 50 --no-check-certificate -O- http://winhelp2002.mvps.org/hosts.txt \
| sed -E -e "s/#.*$//" -e "/^$/d" -e "/::/d" -e "/localhos/d" -e "s/0.0.0.0/127.0.0.1/" -e "s/[[:space:]][[:space:]]*/ /g" > ${TMP_ADBLOCK_DL}.5
##########################################################################################################

# 合并规则
awk '{print $0}' ${TMP_ADBLOCK_DL}.* > ${TMP_ADBLOCK_HOSTS}

echo -e "\033[45;37m 'Hosts_Ad' 规则下载完成 \033[0m\n"
# 删除临时缓存
rm -rf ${TMP_ADBLOCK_DL}.* 2> /dev/null

# 删除注释
sed -i '/::/d' ${TMP_ADBLOCK_HOSTS}
sed -i '/#/d' ${TMP_ADBLOCK_HOSTS}

# 创建 hosts 规则文件
# echo "127.0.0.1 localhost
# ::1 localhost
# ::1 ip6-localhost
# ::1 ip6-loopback
# " > ${ADBLOCK_HOSTS}

# 整理文本
sed -i -e "s/^[ \t]*//g" -e "s/[ \t]*$//g" -e "s/\r//g" -e "s/[ \t][ \t]*/ /g" -e "/^$/d" ${TMP_ADBLOCK_HOSTS}
# 去重排序规则
sort -n ${TMP_ADBLOCK_HOSTS} | uniq  > ${TMP_ADBLOCK_HOSTS}.2 && mv ${TMP_ADBLOCK_HOSTS}.2 ${TMP_ADBLOCK_HOSTS}
# 白名单
if [ -f ${ADBLOCK_WHITE} ]; then
    #sed -i -e "s/^[ \t]*//g" -e "s/[ \t]*$//g" -e "s/\r//g" -e "/^$/d" ${ADBLOCK_WHITE}
    #sed 's/^/127.0.0.1 &/g' ${ADBLOCK_WHITE} > ${TMP_ADBLOCK_WHITE}
    sed -e "s/^[ \t]*//g" -e "s/[ \t]*$//g" -e "s/\r//g" -e "/^$/d" -e 's/^/127.0.0.1 &/g' ${ADBLOCK_WHITE} > ${TMP_ADBLOCK_WHITE}
    sort ${TMP_ADBLOCK_HOSTS} ${TMP_ADBLOCK_WHITE} ${TMP_ADBLOCK_WHITE} | uniq -u > ${TMP_ADBLOCK_HOSTS}.2 && mv ${TMP_ADBLOCK_HOSTS}.2 ${TMP_ADBLOCK_HOSTS}
    rm -rf ${TMP_ADBLOCK_WHITE}
fi

ln -sf ${TMP_ADBLOCK_HOSTS} ${ADBLOCK_HOSTS}

# 删除 hosts 合并缓存
#rm -rf ${TMP_ADBLOCK_HOSTS}


if [ ! -f /jffs/configs/dnsmasq.d/adblock.conf ]; then
    echo "addn-hosts=${ADBLOCK_HOSTS}" > /jffs/configs/dnsmasq.d/adblock.conf
fi

service restart_dnsmasq >/dev/null 2>&1
echo -e "\033[45;37m 完成 \033[0m\n"