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
# This script deploys PingFederate, PingAccess and the PingAccess Quickstart demo.
#
# Prerequisites:
# - The (MacPorts) utilities unzip and python must be installed.
# - Download into the directory where you run this script from:
#   a) a pingfederate ZIP distribution (eg. pingfederate-7.1.0R2.zip)
#   b) a PingAccess ZIP distribution (eg. pingaccess-2.1.0.zip)
#   c) valid license files for PingFederate and PingAccess (pingfederate.lic and pingaccess.lic)
#   d) the PingAccess Quickstart distribution (eg. pingaccess-quickstart-2.1.0.zip)
#
##########################################################################

source "$(dirname "$0")/pf-deploy-common.sh"

pf_deploy_utility_check python curl

pf_deploy_pingfederate $1
PFBASE=${BASE}

pa_deploy_pingaccess $1
PABASE=${BASE}

QS=pingaccess-quickstart
pf_deploy_unzip ${QS} "PingAccess Quickstart ZIP" mksubdir
QSBASE=${BASE}

echo " [${QSBASE}] deploy PingFederate Quickstart JAR files ... "
cp ${QSBASE}/pf-dist/*.jar ${PFBASE}/pingfederate/server/default/deploy
echo " [${QSBASE}] deploy PingFederate Quickstart WAR files ... "
cp -r ${QSBASE}/pf-dist/*.war ${PFBASE}/pingfederate/server/default/deploy
echo " [${QSBASE}] deploy PingFederate Quickstart data.zip ... "
unzip -q -o ${QSBASE}/pf-data/data.zip -d ${PFBASE}/pingfederate/server/default/data

pf_deploy_launch ${PFBASE} $1
pa_deploy_launch ${PABASE} $1

echo " [${QSBASE}] running PingAccess configuration script ... "
python ${QSBASE}/paconfig.py

rm -rf ${QSBASE}

WAM_URL=https://localhost:3000/PingAccessQuickStart/
API_URL=https://localhost:3000/PingAccessQuickStart/api/headers

MAJOR=`echo ${QSBASE} | cut -d"-" -f3 | cut -d"." -f 1`
MINOR=`echo ${QSBASE} | cut -d"-" -f3 | cut -d"." -f 2`
if [[ ${MAJOR} -lt "2" || ( ${MAJOR} -eq "2" && ${MINOR} -lt "1" ) ]] ; then
	WAM_URL=https://localhost:3000/headers
	API_URL=https://localhost:3000/api/headers
fi

pf_deploy_browser_open ${WAM_URL}

echo
echo " # Unauthorized access, should fail:"
curl -k ${URL}
echo

RESPONSE=`curl -k -s -X POST -d "client_id=api_client&grant_type=password&username=joe&password=2Access&scope=edit" -k https://localhost:9031/as/token.oauth2`
echo " # get token response:"
echo ${RESPONSE}
echo

TOKEN=`expr "${RESPONSE}" : '.*\"access_token\":"\(.*\)"'`
echo " # token:"
echo ${TOKEN}
echo

echo " # Authorized access, should return JSON with headers:"
curl -k -s -H "Authorization: Bearer ${TOKEN}" ${API_URL}
echo
echo
