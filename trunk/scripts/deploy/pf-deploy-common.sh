#!/bin/bash
###########################################################################
# Copyright (C) 2013 Ping Identity Corporation
# All rights reserved.
#
# The contents of this file are the property of Ping Identity Corporation.
# For further information please contact:
#
# Ping Identity Corporation
# 1099 18th St Suite 2950
# Denver, CO 80202
# 303.468.2900
#       http://www.pingidentity.com
#
# DISCLAIMER OF WARRANTIES:
#
# THE SOFTWARE PROVIDED HEREUNDER IS PROVIDED ON AN "AS IS" BASIS, WITHOUT
# ANY WARRANTIES OR REPRESENTATIONS EXPRESS, IMPLIED OR STATUTORY; INCLUDING,
# WITHOUT LIMITATION, WARRANTIES OF QUALITY, PERFORMANCE, NONINFRINGEMENT,
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  NOR ARE THERE ANY
# WARRANTIES CREATED BY A COURSE OR DEALING, COURSE OF PERFORMANCE OR TRADE
# USAGE.  FURTHERMORE, THERE ARE NO WARRANTIES THAT THE SOFTWARE WILL MEET
# YOUR NEEDS OR BE FREE FROM ERRORS, OR THAT THE OPERATION OF THE SOFTWARE
# WILL BE UNINTERRUPTED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###########################################################################
#
# Author: Hans Zandbelt <hzandbelt@pingidentity.com>
#
# Common functions for deploying PingFederate and its Integration Kits.
#
##########################################################################

pf_deploy_utility_check() {
	for f in $* ; do if [ -z `which $f` ] ; then echo " Required utility ${f} is missing: install it first (perhaps from MacPorts)." ; exit ; fi ; done
}

pf_deploy_unzip() {
	local NAME=$1
	local DESC=$2
	local DIR
	ZIP=`find . -maxdepth 1 -name "${NAME}-[0-9]*.zip" -print -prune`
	if [ -z ${ZIP} ] ; then echo " The $DESC distribution is missing: download it to this directory first." ; exit ; fi
	BASE=`basename ${ZIP} .zip`
	if [ ! -z $3 ] ; then DIR="-d ${BASE}" ; fi
	echo " [${BASE}] unzip ${ZIP} ... "
	unzip ${DIR} -q ${ZIP}
}

pf_deploy_license_check() {
	if [ ! -r pingfederate.lic ] ; then echo " The PingFederate license file is missing: download it to this directory first." ; exit ; fi
}

pf_deploy_runsh_jvm_patch() {
	local BASE=$1
	echo " [${BASE}] patching run.sh for JVM location ... "
	cat <<EOF | patch -s -p0 ${BASE}/pingfederate/bin/run.sh
9a10,11
> JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_07.jdk/Contents/Home
> 
EOF
}

pf_deploy_secondary_port_patch() {
	local BASE=$1
	local PORT=$2
	echo " [${BASE}] patching run.properties for secondary port ${PORT} ... "
	cat <<EOF | patch -s -p0 ${BASE}/pingfederate/bin/run.properties
--- pingfederate-7.1.1.org/pingfederate/bin/run.properties	2013-11-07 17:20:18.000000000 +0100
+++ pingfederate-7.1.1/pingfederate/bin/run.properties	2013-11-16 23:59:41.000000000 +0100
@@ -101,7 +101,7 @@
 # authentication or for SAML back-channel authentication, you must use this 
 # port for security reasons (or use a similarly configured new listener, 
 # with either "WantClientAuth" or "NeedClientAuth" set to "true".
-pf.secondary.https.port=-1
+pf.secondary.https.port=9032
 # 
 # This property defines the IP address over which the PingFederate server 
 # communicates with partner federation gateways. Use for deployments where 
EOF
}

pf_deploy_license_copy() {
	local BASE=$1
	echo " [${BASE}] copying license file ... "
	cp pingfederate.lic ${BASE}/pingfederate/server/default/conf
}

pf_deploy_set_first_login_done() {
	local BASE=$1
	echo " [${BASE}] set first login done ... "
	cat > ${BASE}/pingfederate/server/default/data/config-store/com.pingidentity.page.Login.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<con:config xmlns:con="http://www.sourceid.org/2004/05/config">
    <con:map name="license-map">
        <con:item name="hasConfiguredServerSettings">true</con:item>
        <con:item name="key">true</con:item>
    </con:map>
</con:config>
EOF
}

pf_deploy_set_default_admin_password() {
	local BASE=$1
	echo " [${BASE}] set default admin password ... "
	cat > ${BASE}/pingfederate/server/default/data/pingfederate-admin-user.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<adm:administrative-users multi-admin="true" xmlns:adm="http://pingidentity.com/2006/01/admin-users">
    <adm:user>
        <adm:user-name>Administrator</adm:user-name>
        <adm:salt>C0A527949CA5FACEA6D4AD5A6D90868894F53674</adm:salt>
        <adm:hash>FA947876446F0DF8A123E691A9302C643DBCC91F</adm:hash>
        <adm:phone-number/>
        <adm:email-address/>
        <adm:department/>
        <adm:description/>
        <adm:admin-manager>true</adm:admin-manager>
        <adm:admin>true</adm:admin>
        <adm:crypto-manager>true</adm:crypto-manager>
        <adm:auditor>false</adm:auditor>
        <adm:active>true</adm:active>
        <adm:password-change-required>false</adm:password-change-required>
    </adm:user>
</adm:administrative-users>
EOF
}

pf_deploy_browser_open() {
	local URL=$1
	if [ -x /usr/bin/firefox ] ; then
		nohup /usr/bin/firefox ${URL} & 2>/dev/null
	fi
	# at least Mac OS X default browser
	if [ -x /usr/bin/open ] ; then
		/usr/bin/open ${URL}
	fi
}

pf_deploy_browser_open_admin_login() {
	local URL=https://localhost:9999/pingfederate/app
	local ADMIN=administrator
	local PASSWD=2Federate
	local TMPFILE=/tmp/autopost.html
cat > ${TMPFILE} <<EOF
<html><body onload="document.forms[0].submit()">
<form method="post" action="${URL}">
<input name="service" value="direct/0/login/\$Form"/>
<input name="sp" value="S0"/>
<input name="Form0" value="\$FormConditional,\$FormConditional\$0,\$FormConditional\$1,username,password,\$Submit"/>
<input name="\$FormConditional" value="F"/>
<input name="\$FormConditional\$0" value="F"/>
<input name="\$FormConditional\$1" value="T"/>
<input name="username" value="${ADMIN}"/>
<input name="password" value="${PASSWD}"/>
<input name="\$Submit" value="Login"/>
</body></html>
EOF
	pf_deploy_browser_open ${TMPFILE}
}

pf_deploy_launch_terminal() {
	local BASE=$1
	local SCRIPT=$2
	local TITLE=$3
	local LOGFILE=$4
	echo " [${BASE}] launch ${TITLE} ... "
	mkdir -p `dirname ${BASE}/${LOGFILE}` ; rm -f ${BASE}/${LOGFILE} ; touch ${BASE}/${LOGFILE}
	if [ `uname -s` = "Darwin" ] ; then
		# avoid Mac OS X warning about files downloaded from the Internet
		xattr -d -r com.apple.quarantine ${BASE}/${SCRIPT}
		# start script in a new Terminal
		osascript >/dev/null <<EOF
tell application "Terminal" to do script "printf \"\\\033]0;${TITLE}\\\007\" && cd ${PWD}/${BASE} && ${SCRIPT} | tee ${LOGFILE}"
EOF
	elif [ -x /usr/bin/gnome-terminal ] ; then
		/usr/bin/gnome-terminal --profile=Default -t "${TITLE}" --working-directory=${PWD}/${BASE} -e "${SCRIPT} | tee ${LOGFILE}"
	else
		xterm -T ${TITLE} -e "cd ${PWD}/${BASE} && ${SCRIPT} | tee ${LOGFILE}" &
	fi
}

pf_deploy_launch_and_wait() {
	local BASE=$1
	local SCRIPT=$2
	local TITLE=$3
	local LOGFILE=$4
	local SEARCH=$5
	pf_deploy_launch_terminal ${BASE} ${SCRIPT} ${TITLE} ${LOGFILE}
	echo " [$BASE] Waiting for ${TITLE} to startup ... "
	while [ ! -r ${BASE}/${LOGFILE} ] ; do sleep 1 ; done
	while [ `tail ${BASE}/${LOGFILE} | grep "${SEARCH}"  | wc -l` == 0 ] ; do sleep 1 ; done
	echo " [$BASE] ${TITLE} started ... "			
}

pf_deploy_pingfederate() {
	# NB: global BASE var
	pf_deploy_utility_check unzip
	if [ -z $1 ] ; then
		pf_deploy_license_check
		pf_deploy_unzip pingfederate "PingFederate ZIP"
		# BASE set now
		# pf_deploy_runsh_jvm_patch ${BASE}
		pf_deploy_license_copy ${BASE}
		pf_deploy_set_first_login_done ${BASE}
		pf_deploy_set_default_admin_password ${BASE}
	else
		BASE=$1
	fi
}

pa_deploy_license_check() {
	if [ ! -r pingaccess.lic ] ; then echo " The PingAccess license file is missing: download it to this directory first." ; exit ; fi
}

pa_deploy_license_copy() {
	local BASE=$1
	echo " [${BASE}] copying license file ... "
	cp pingaccess.lic ${BASE}/conf
}

pa_deploy_pingaccess() {
	# NB: global BASE var
	pf_deploy_utility_check unzip
	if [ -z $1 ] ; then
		pa_deploy_license_check
		pf_deploy_unzip pingaccess "PingAccess ZIP"
		# BASE set now
		pa_deploy_license_copy ${BASE}
	else
		BASE=$1
	fi
}

pf_deploy_launch() {
	local BASE=$1
	if [ -z $2 ] ; then
		pf_deploy_launch_and_wait ${BASE} pingfederate/bin/run.sh PingFederate pingfederate/log/boot.log "PingFederate started in"		
		pf_deploy_browser_open_admin_login
	fi
}

pa_deploy_launch() {
	local BASE=$1
	if [ -z $2 ] ; then
		SCRIPT=bin/run.sh
		MAJOR=`echo ${BASE} | cut -d"-" -f2 | cut -d"." -f 1`
		MINOR=`echo ${BASE} | cut -d"-" -f2 | cut -d"." -f 2`
		if [[ ${MAJOR} -lt "2" || ( ${MAJOR} -eq "2" && ${MINOR} -lt "1" ) ]] ; then SCRIPT=run.sh; fi
		pf_deploy_launch_and_wait ${BASE} ${SCRIPT} PingAccess logs/boot.log "PingAccess running"				
		pf_deploy_browser_open https://localhost:9000
	fi
}
