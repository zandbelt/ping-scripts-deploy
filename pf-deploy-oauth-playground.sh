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
# This script deploys PingFederate and the OAuth 2.0 Playground.
#
# Prerequisites:
# - The (MacPorts) utility unzip must be installed.
# - Download into the directory where you run this script from:
#   a) a pingfederate ZIP distribution (eg. pingfederate-9.2.0.zip)
#   b) a valid license file (pingfederate.lic)
#   c) the OAuth 2.0 Playground (eg. OAuthPlayground-4.1.0.zip)
#
##########################################################################

source "$(dirname "$0")/pf-deploy-common.sh"

# PingFederate

pf_deploy_pingfederate $1
PFBASE=${BASE}

# OAuth 2.0 Playground

pf_deploy_unzip OAuthPlayground "OAuth 2.0 Playground ZIP"
PGBASE=${BASE}
echo " [${PGBASE}] deploy OAuth Playground files ... "
cp -r ${PGBASE}/dist/* ${PFBASE}/pingfederate/server/default/deploy
echo " [${PGBASE}] deploy OAuth Playground data.zip ... "
cp ${PGBASE}/data.zip ${PFBASE}/pingfederate/server/default/data/drop-in-deployer/
rm -rf ${PGBASE}

pf_deploy_ciphers_patch ${PFBASE}

pf_deploy_launch ${PFBASE} $1
pf_deploy_browser_open https://localhost:9031/OAuthPlayground

pf_deploy_ognl_patch ${PFBASE}
