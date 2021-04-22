#!/bin/bash
###########################################################################
# Copyright (C) 2013-2016 Ping Identity Corporation
# All rights reserved.
#
# The contents of this file are the property of Ping Identity Corporation.
# For further information please contact:
#
# Ping Identity Corporation
# 1099 18th St Suite 2950
# Denver, CO 80202
# 303.468.2900
# http://www.pingidentity.com
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
# Author: Hans Zandbelt <hans.zandbelt@zmartzone.eu>
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
cat <<EOF | patch -s -p0 -d ${BASE} pingfederate/bin/run.properties
--- pingfederate/bin/run.properties.orig
+++ pingfederate/bin/run.properties
@@ -119,7 +119,7 @@
 # authentication or for SAML back-channel authentication, you must use this 
 # port for security reasons (or use a similarly configured new listener, 
 # with either "WantClientAuth" or "NeedClientAuth" set to "true".
-pf.secondary.https.port=-1
+pf.secondary.https.port=9032
 
 #
 # This property defines the IP address over which the PingFederate server 
EOF
}

pf_deploy_ciphers_patch() {
	local BASE=$1
	echo " [${BASE}] patching com.pingidentity.crypto.SunJCEManager.xml for cipher suite... "
	cat <<EOF | patch -s -p0 ${BASE}/pingfederate/server/default/data/config-store/com.pingidentity.crypto.SunJCEManager.xml
96a97
> 	<!--
102a104,110
> 	-->
>         <con:item name="TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA"/>
>         <con:item name="TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"/>
>         <con:item name="TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA"/>
>         <con:item name="TLS_ECDH_RSA_WITH_AES_128_CBC_SHA"/>
>         <con:item name="TLS_RSA_WITH_AES_128_CBC_SHA"/>
> 
EOF
}

pf_deploy_ognl_patch() { 
	local BASE=$1
	echo " [${BASE}] patching for OGNL expressions support (restart after this sequence completes to enable)... "
	cat > ${BASE}/pingfederate/server/default/data/config-store/org.sourceid.common.ExpressionManager.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<config xmlns="http://www.sourceid.org/2004/05/config">
    <item name="evaluateExpressions">true</item>
</config>
EOF
}

pa_deploy_logging_patch() {
	local BASE=$1
	echo " [${BASE}] patching log level... "
	cat <<EOF | patch -s -p0 ${BASE}/conf/log4j2.xml
--- conf/log4j2.xml.org	2016-12-21 08:49:44.000000000 +0100
+++ conf/log4j2.xml	2016-12-22 20:43:04.000000000 +0100
@@ -514,9 +514,9 @@
 
     <Loggers>
         <!-- PingAccess Loggers-->
-        <AsyncLogger name="com.pingidentity" level="INFO" additivity="false" includeLocation="false">
+        <AsyncLogger name="com.pingidentity" level="DEBUG" additivity="false" includeLocation="false">
             <AppenderRef ref="File"/>
-            <!--<AppenderRef ref="CONSOLE" />-->
+            <AppenderRef ref="CONSOLE" />
             <!--<AppenderRef ref="SYSLOG" />-->
         </AsyncLogger>
         <!-- Log incoming and outgoing cookies-->
EOF
}

pf_deploy_logging_patch() {
	local BASE=$1
	echo " [${BASE}] patching log level... "
	cat <<EOF | patch -s -p0 ${BASE}/pingfederate/server/default/conf/log4j2.xml
--- pingfederate-10.0.0/pingfederate/server/default/conf/log4j2.xml.org	2019-12-17 19:55:30.000000000 +0100
+++ pingfederate-10.0.0/pingfederate/server/default/conf/log4j2.xml	2020-01-31 13:56:23.000000000 +0100
@@ -1193,8 +1193,8 @@
         <!--
         <Logger name="com.pingidentity.pf.datastore.other" level="TRACE" />
         -->
-        <Logger name="org.sourceid" level="INFO" />
-        <Logger name="org.sourceid.saml20.util.SystemUtil" level="INFO" additivity="false">
+        <Logger name="org.sourceid" level="DEBUG" />
+        <Logger name="org.sourceid.saml20.util.SystemUtil" level="DEBUG" additivity="false">
             <AppenderRef ref="CONSOLE" />
             <AppenderRef ref="FILE" />
         </Logger>
@@ -1234,8 +1234,8 @@
         <!-- Adjust the priority value to DEBUG to get additional logging to help troubleshoot XML Signature problems -->
         <Logger name="org.sourceid.common.dsig" level="INFO" />
         <Logger name="org.sourceid.saml20.domain.mgmt.impl.PluginSupport" level="INFO" />
-        <Logger name="com.pingidentity" level="INFO" />
-        <Logger name="com.pingidentity.common.util.ErrorHandler" level="INFO" additivity="false">
+        <Logger name="com.pingidentity" level="DEBUG" />
+        <Logger name="com.pingidentity.common.util.ErrorHandler" level="DEBUG" additivity="false">
             <AppenderRef ref="CONSOLE" />
             <AppenderRef ref="FILE" />
         </Logger>
@@ -1512,7 +1512,7 @@
             For database logging, comment the <AsyncRoot> block and uncomment the <Root> block.
         -->
         <AsyncRoot level="INFO" includeLocation="false">
-            <!-- <AppenderRef ref="CONSOLE" /> -->
+            <AppenderRef ref="CONSOLE" />
             <AppenderRef ref="FILE" />
         </AsyncRoot>
 
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

pf_deploy_wait_for() {
	local TITLE=$1
	local BASE=$2
	local FILE=$3
	local MATCH=$4
	echo " [$BASE] waiting for ${TITLE} ... "	
	while [ ! -r "${FILE}" ] ; do sleep 1 ; done
	while ! tail -n 50 ${FILE} | grep -q "${MATCH}" ; do sleep 1; done
}

pf_deploy_browser_open_admin_login_prepare() {
	local BASE=$1
	local USERNAME=$2
	local PASSWD=$3
	local PF="https://localhost:9999"
	local FILENAME="autopost.html"
	local TMPFILE="api-docs/${FILENAME}"
		
	mkdir -p `dirname ${TMPFILE}`
		
cat > ${TMPFILE} <<EOF
<html>
<head><script>
function onLoad() {
	document.cookie="PFCSRF=bogus; path=/";
	document.forms[0].submit();
}
</script> </head>
<body onload="onLoad()">
Logging in to the PingFederate Administration Console as ${USERNAME}...
<form method="post" action="${PF}/render/pingfederate/app">
<input type="hidden" name="service" value="direct/0/login/\$Form"/>
<input type="hidden"name="sp" value="S0"/>
<input type="hidden"name="Form0" value="cSRFToken,\$FormConditional,\$FormConditional\$0,\$FormConditional\$1,username,password,\$Submit"/>
<input type="hidden"name="cSRFToken" value="bogus"/>
<input type="hidden"name="\$FormConditional" value="F"/>
<input type="hidden"name="\$FormConditional\$0" value="F"/>
<input type="hidden"name="\$FormConditional\$1" value="T"/>
<input type="hidden"name="username" value="${USERNAME}"/>
<input type="hidden"name="password" value="${PASSWD}"/>
<input type="hidden"name="\$Submit" value="Sign On"/>
</form>
</body></html>
EOF
	jar uf ${BASE}/pingfederate/server/default/deploy2/pf-admin-api.war ${TMPFILE}
	rm -rf api-docs
}

pf_deploy_browser_open_admin_login_complete() {
	local BASE=$1

	local PF="https://localhost:9999"
	local FILENAME="autopost.html"
	local TMPFILE="api-docs/${FILENAME}"
		
	pf_deploy_browser_open "${PF}/pf-admin-api/api-docs/${FILENAME}"
	pf_deploy_wait_for "PingFederate admin login" "${BASE}" "${BASE}/pingfederate/log/admin.log" "Login was successful"
	zip -q -d ${BASE}/pingfederate/server/default/deploy2/pf-admin-api.war ${TMPFILE}
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
		pf_deploy_logging_patch ${BASE}
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
		pa_deploy_logging_patch ${BASE}		
	else
		BASE=$1
	fi
}

pf_deploy_launch() {
	local BASE="$1"
	local LOGFILE="pingfederate/log/server.log"
	if [ -z $2 ] ; then
		pf_deploy_browser_open_admin_login_prepare ${BASE} "Administrator" "2Federate"
		pf_deploy_launch_terminal "${BASE}" "pingfederate/bin/run.sh" "PingFederate" "${LOGFILE}"
		pf_deploy_wait_for "PingFederate to startup" "${BASE}" "${BASE}/${LOGFILE}" "Configuration update has finished"
		pf_deploy_browser_open_admin_login_complete "${BASE}"
	fi
}

pa_deploy_browser_open_admin_login_prepare() {
	local BASE=$1
	local USERNAME=$2
	local PASSWD=$3
	
	local PA="https://localhost:9000"
	local FILENAME="autopost.html"
	local TMPFILE="com/pingidentity/pa/adminui/frontend/dist/${FILENAME}"

	mkdir -p `dirname ${TMPFILE}`
cat > ${TMPFILE} <<EOF
<html>
<head><script>
function login() {
	// set first login, SLA accepted and no tutorial shown
	var d = {"email": "","firstLogin": false,"showTutorial": false,"slaAccepted": true,"username":"${USERNAME}"};
	var r = new XMLHttpRequest();
	r.open("PUT", "${PA}/pa-admin-api/v3/users/1", true, "${USERNAME}", "${PASSWD}");
	r.setRequestHeader("X-XSRF-Header", "PingAccess");
	r.onreadystatechange = function () {
    	if (r.readyState == 4) {
    		// login and get a PingAccess session
    		d = {"username":"${USERNAME}","password":"${PASSWD}"};
    		r = new XMLHttpRequest();
    		r.open("POST", "${PA}/pa-admin-api/v3/login");
    		r.setRequestHeader("X-XSRF-Header", "PingAccess");
    		r.onreadystatechange = function () {
    			if (r.readyState == 4) {
    				window.location = "${PA}/"
    			}
    		}
		}
		r.send(JSON.stringify(d));
	}
	r.send(JSON.stringify(d));
}
</script> </head>
<body onload="login()">
Logging in to the PingAccess Administration Console as ${USERNAME}...
</body></html>
EOF
	jar uf `find ${BASE}/lib/pingaccess-admin-ui* -print` ${TMPFILE}
	rm -rf com
}

pa_deploy_browser_open_admin_login_complete() {
	local BASE=$1
	
	local PA="https://localhost:9000"
	local FILENAME="autopost.html"
	local TMPFILE="com/pingidentity/pa/adminui/frontend/dist/${FILENAME}"

	pf_deploy_browser_open "${PA}/dist/${FILENAME}"
	pf_deploy_wait_for "PingAccess admin login" "${BASE}" "${BASE}/log/pingaccess_api_audit.log" "POST| /pa-admin-api/v3/login| 200"
	zip -q -d `find ${BASE}/lib/pingaccess-admin-ui* -print` ${TMPFILE}
}

pa_deploy_launch() {
	local BASE=$1
	local LOGFILE="logs/boot.log"
	if [ -z $2 ] ; then
		pa_deploy_browser_open_admin_login_prepare ${BASE} "Administrator" "2Access"
		pf_deploy_launch_terminal "${BASE}" "bin/run.sh" "PingAccess" "${LOGFILE}"
		pf_deploy_wait_for "PingAccess to startup" "${BASE}" "${BASE}/${LOGFILE}" "PingAccess running"
		pa_deploy_browser_open_admin_login_complete ${BASE}
	fi
}
