#!/bin/sh
echo -e "\e[1;36m 下载屏蔽广告规则 \e[0m\n"
TMP_AD=/tmp/tmp_adblock
TMP_AD1=/tmp/tmp_adblock1
TMP_AD2=/tmp/tmp_adblock2
TMP_AD3=/tmp/tmp_adblock3
TMP_AD4=/tmp/tmp_adblock4
AD=/tmp/hosts_ad

# 下载规则
wget --no-check-certificate -t 20 -T 60 -O- https://cdn.jsdelivr.net/gh/neoFelhz/neohosts@gh-pages/127.0.0.1/full/hosts > ${TMP_AD}
wget --no-check-certificate -t 20 -T 60 -O- https://raw.githubusercontent.com/ilpl/ad-hosts/master/hosts > ${TMP_AD1}
wget --no-check-certificate -t 20 -T 60 -O- https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts > ${TMP_AD2}
wget --no-check-certificate -t 20 -T 60 -O- https://raw.githubusercontent.com/Goooler/1024_hosts/master/hosts > ${TMP_AD3}
wget -t 15 -T 50 --no-check-certificate -O- http://winhelp2002.mvps.org/hosts.txt \
| sed -E -e "s/#.*$//" -e "/^$/d" -e "/::/d" -e "/localhos/d" -e "s/0.0.0.0/127.0.0.1/" -e "s/[[:space:]][[:space:]]*/ /g" > ${TMP_AD4}
# 合并规则
awk '{print $0}' ${TMP_AD} ${TMP_AD1} ${TMP_AD2} ${TMP_AD3} ${TMP_AD4} > ${AD}

echo -e "\033[45;37m 'Hosts_Ad' 规则下载完成 \033[0m\n"
# 删除临时缓存
rm -rf /tmp/tmp_adblock* 2> /dev/null
# 删除注释
sed -i '/::/d' ${AD}
sed -i '/#/d' ${AD}
# 创建 hosts 规则文件
# echo "127.0.0.1 localhost
# ::1 localhost
# ::1 ip6-localhost
# ::1 ip6-loopback
# " > /jffs/configs/ad-hosts

# 整理文本
sed -i -e "s/^[ \t]*//g" -e "s/[ \t]*$//g" -e "s/\r//g" -e "s/[ \t][ \t]*/ /g" -e "/^$/d" ${AD}
# 去重排序规则
sort -n ${AD} | uniq  > /jffs/configs/ad-hosts
# 白名单
if [ -f /jffs/ad-white ]; then
    cp -f /jffs/configs/ad-hosts ${AD}
    sed -i -e "s/^[ \t]*//g" -e "s/[ \t]*$//g" -e "s/\r//g" -e "/^$/d" /jffs/ad-white
    sed 's/^/127.0.0.1 &/g' /jffs/ad-white > /tmp/ad-white
    sort ${AD} /tmp/ad-white /tmp/ad-white | uniq -u > /jffs/configs/ad-hosts
fi
# 修饰结束
#sed -i '$a # 修饰 hosts 结束' /jffs/configs/ad-hosts
# 删除 hosts 合并缓存
rm -rf ${AD}
rm -rf /tmp/ad-white

echo "addn-hosts=/jffs/configs/ad-hosts" > /jffs/configs/dnsmasq.d/adblock.conf
service restart_dnsmasq >/dev/null 2>&1
echo -e "\033[45;37m 完成 \033[0m\n"