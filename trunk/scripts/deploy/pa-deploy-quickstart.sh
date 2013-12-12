#!/bin/sh
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
#   a) a pingfederate ZIP distribution (eg. pingfederate-7.1.2.zip)
#   b) a PingAccess ZIP distribution (eg. pingaccess-2.0.1.zip)
#   c) valid license files for PingFederate and PingAccess (pingfederate.lic and pingaccess.lic)
#   d) the PingAccess Quickstart distribution (eg. pingaccess-quickstart-2.0.0.zip)
#
##########################################################################

source "$(dirname "$0")/pf-deploy-common.sh"

pf_deploy_utility_check python

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

pf_deploy_launch_macos ${PFBASE} $1
pa_deploy_launch_macos ${PABASE} $1

echo " [${QSBASE}] running PingAccess configuration script ... "
python ${QSBASE}/paconfig.py

rm -rf ${QSBASE}

pf_deploy_browser_open https://localhost:3000/headers
