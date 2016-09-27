ping-scripts-deploy
===================
This repository contains scripts that allow you to quickly deploy PingFederate, PingAccess,
Quickstart demo applications, Integration Kits and the OAuth 2.0 playground in various
combinations and versions.

It will save you from manually unzipping files, copying license files, starting the
server, accepting the license, flipping through default config screens, etc. Basically 
avoiding all of the manual steps required to get a working setup for a Ping Identity
product with sample applications.

How To Use It
-------------
Drop distribution files into a directory and call the appropriated deployment script from
that directory.

For example for the PingFederate Quickstart you'd need the PingFederate ZIP file,
the Quickstart distribution, a license file in your directory, as in:
    
    $ ls -1
    pingfederate-8.2.1.zip
    pingfederate.lic
    pf-quickstart-1-1.zip
    $~/ping-scripts-deploy/pf-deploy-quickstart.sh
    ...

The exact versions of these distributions don't matter, the scripts should be version agnostic
although they are most likely to work only with recent versions of the distributions.

Scripts
-------
There may be slightly more detailed instructions in the documentation at the top of each script.

- `pf-deploy-common.sh`  
This is a utility/helper script that is included from the other scripts, not meant to
be called directly from the command line.

- `pf-deploy-quickstart.sh`  
Deploys PingFederate (pingfederate-x.x.x.zip) and the Quickstart (pf-quickstart-x-x.zip) sample applications.  
*Depends on: `pf-deploy-common.sh`*
 
- `pf-deploy-oauth-playground.sh`  
Deploys PingFederate (pingfederate-x.x.x.zip) and the OAuth 2.0 Playground (OAuthPlayground-x.x.x.zip).  
*Depends on: `pf-deploy-common.sh`*

- `pf-deploy-agentless-ik.sh`  
Deploys PingFederate (pingfederate-x.x.x.zip), the Agentless Integration Kit and the
sample IDP/SP applications in there.  
*Depends on: `pf-deploy-common.sh`*

- `pf-deploy-java-ik.sh`  
Deploys PingFederate (pingfederate-x.x.x.zip), the Java Integration Kit (pf-Java-integration-kit-x.x.x.zip)
and the sample IDP/SP applications in there.  
*Depends on: `pf-deploy-common.sh`*
 
- `pa-deploy-quickstart.sh`  
Deploys PingAccess ((pingaccess-x.x.x.zip), PingFederate (pingfederate-x.x.x.zip) and
the PingAccess Quickstart applications (pingaccess-quickstart-x.x.x.zip).  
*Depends on: `pf-deploy-common.sh`*

Disclaimer
----------
    /***************************************************************************
     * Copyright (C) 2014-2016 Ping Identity Corporation
     * All rights reserved.
     *
     *      Ping Identity Corporation
     *      1099 18th St Suite 2950
     *      Denver, CO 80202
     *      303.468.2900
     *      http://www.pingidentity.com
     *
     * DISCLAIMER OF WARRANTIES:
     *
     * THE SOFTWARE PROVIDED HEREUNDER IS PROVIDED ON AN "AS IS" BASIS, WITHOUT
     * ANY WARRANTIES OR REPRESENTATIONS EXPRESS, IMPLIED OR STATUTORY; INCLUDING,
     * WITHOUT LIMITATION, WARRANTIES OF QUALITY, PERFORMANCE, NONINFRINGEMENT,
     * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  NOR ARE THERE ANY
     * WARRANTIES CREATED BY A COURSE OR DEALING, COURSE OF PERFORMANCE OR TRADE
     * USAGE.  FURTHERMORE, THERE ARE NO WARRANTIES THAT THE SOFTWARE WILL MEET
     * YOUR NEEDS OR BE FREE FROM ERRORS, OR THAT THE OPERATION OF THE SOFTWARE
     * WILL BE UNINTERRUPTED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
     * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
     * EXEMPLARY, OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF
     * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
     * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
     * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
     */
