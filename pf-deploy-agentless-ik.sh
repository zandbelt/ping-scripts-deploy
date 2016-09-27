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
# This script deploys PingFederate and the Agentless Integration Kit
# plus the included sample applications.
#
# Prerequisites:
# - The (MacPorts) utilities unzip and sed must be installed.
# - Download into the directory where you run this script from:
#   a) a pingfederate ZIP distribution (eg. pingfederate-8.2.1.zip)
#   b) a valid license file (pingfederate.lic)
#   c) the Agentless Integration Kit (eg. Agentless-Integration-Kit-1-2-1.zip)
#
##########################################################################

source "$(dirname "$0")/pf-deploy-common.sh"

pf_deploy_utility_check sed

pf_deploy_pingfederate $1
PFBASE=${BASE}
DIR=`pwd`
pf_deploy_secondary_port_patch ${PFBASE} 9032

AIK=pf-agentless-integration-kit
pf_deploy_unzip "Agentless-Integration-Kit" "Agentless Integration Kit ZIP"

echo " [${BASE}] deploy Agentless IK JAR files ... "
cp ${AIK}/dist/*.jar ${PFBASE}/pingfederate/server/default/deploy
echo " [${BASE}] deploy Agentless IK sample WARs ... "
cp -r ${AIK}/Samples/AgentlessIntegrationKitSample* ${PFBASE}/pingfederate/server/default/deploy
echo " [${BASE}] deploy Agentless IK sample certificates ... "
cp ${AIK}/Samples/certificates/* ${PFBASE}/pingfederate/server/default/deploy/AgentlessIntegrationKitSampleSP
cp ${AIK}/Samples/certificates/* ${PFBASE}/pingfederate/server/default/deploy/AgentlessIntegrationKitSampleIDP
echo " [${BASE}] patch Agentless IK sample SP configuration ... "
sed -i "" s#FULL/PATH/TO/CERTIFICATES#"${DIR}/${PFBASE}/pingfederate/server/default/deploy/AgentlessIntegrationKitSampleSP"#g ${PFBASE}/pingfederate/server/default/deploy/AgentlessIntegrationKitSampleSP/configuration.jsp
sed -i "" s#FULL/PATH/TO/CERTIFICATES#"${DIR}/${PFBASE}/pingfederate/server/default/deploy/AgentlessIntegrationKitSampleIDP"#g ${PFBASE}/pingfederate/server/default/deploy/AgentlessIntegrationKitSampleIDP/configuration.jsp
echo " [${BASE}] deploy Agentless IK data.zip ... "
cp ${AIK}/Samples/data.zip ${PFBASE}/pingfederate/server/default/data/drop-in-deployer/
rm -rf ${AIK}

echo " [${BASE}] patch SubmitToSP.jsp for Java 8 ... "
cat <<EOF | patch -s -p0 ${PFBASE}/pingfederate/server/default/deploy/AgentlessIntegrationKitSampleIdP/SubmitToSP.jsp
--- pingfederate/server/default/deploy/AgentlessIntegrationKitSampleIdP/SubmitToSP.jsp.orig
+++ pingfederate/server/default/deploy/AgentlessIntegrationKitSampleIdP/SubmitToSP.jsp
@@ -99,7 +99,7 @@
 	{
 		// 3A - Authenticate using HTTP Basic Authentication; values Base64 encoded
 		String basicAuth = REFID_USERNAME + ":" + REFID_PASSWORD;
-		urlConnection.setRequestProperty("Authorization", "Basic " + Base64.encodeBase64String(basicAuth.getBytes()));
+		urlConnection.setRequestProperty("Authorization", "Basic " + org.apache.commons.codec.binary.Base64.encodeBase64String(basicAuth.getBytes()));
 	}
 	else
 	{
EOF

echo " [${BASE}] patch ShowAttributes.jsp for Java 8 ... "
cat <<EOF | patch -s -p0 ${PFBASE}/pingfederate/server/default/deploy/AgentlessIntegrationKitSampleSP/ShowAttributes.jsp
--- pingfederate/server/default/deploy/AgentlessIntegrationKitSampleSP/ShowAttributes.jsp.orig
+++ pingfederate/server/default/deploy/AgentlessIntegrationKitSampleSP/ShowAttributes.jsp
@@ -139,7 +139,7 @@
 	{
 		// 3A - Authenticate using HTTP Basic Authentication; values Base64 encoded
 		String basicAuth = REFID_USERNAME + ":" + REFID_PASSWORD;
-		urlConnection.setRequestProperty("Authorization", "Basic " + Base64.encodeBase64String(basicAuth.getBytes()));
+		urlConnection.setRequestProperty("Authorization", "Basic " + org.apache.commons.codec.binary.Base64.encodeBase64String(basicAuth.getBytes()));
 	}
 	else
 	{
EOF

pf_deploy_launch ${PFBASE} $1
pf_deploy_browser_open https://localhost:9031/AgentlessIntegrationKitSampleSP
