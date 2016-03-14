#!/bin/bash
###########################################################################
# Copyright (C) 2013-2015 Ping Identity Corporation
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
# This script deploys PingFederate and the Java Integration Kit.
#
# Prerequisites:
# - The (MacPorts) utility unzip must be installed.
# - Download into the directory where you run this script from:
#   a) a pingfederate ZIP distribution (eg. pingfederate-7.1.1.zip)
#   b) a valid license file (pingfederate.lic)
#   c) the Java Integration Kit (eg. pf-Java-integration-kit-2.5.1.zip)
#
##########################################################################

source "$(dirname "$0")/pf-deploy-common.sh"

pf_deploy_pingfederate $1
PFBASE=${BASE}

JIK=pf-Java-integration-kit
pf_deploy_unzip ${JIK} "Java Integration Kit ZIP"

echo " [${BASE}] deploy Java IK JAR files ... "
cp ${JIK}/dist/*.jar ${PFBASE}/pingfederate/server/default/deploy
echo " [${BASE}] deploy Java IK sample WARs ... "
cp -r ${JIK}/sample/*.war ${PFBASE}/pingfederate/server/default/deploy
echo " [${BASE}] deploy Java IK data.zip ... "
cp ${JIK}/sample/data.zip ${PFBASE}/pingfederate/server/default/data/drop-in-deployer/
chmod a+rw ${PFBASE}/pingfederate/server/default/data/drop-in-deployer/data.zip
rm -rf ${JIK}

pf_deploy_launch ${PFBASE} $1
