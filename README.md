ping-scripts-deploy
===================
This repository contains scripts that allow you to quickly deploy PingFederate, PingAccess,
Quickstart demo applications, Integration Kits and the OAuth 2.0 Playground in various
combinations and versions.

It will save you from manually unzipping files, copying license files, starting the
server, accepting the license, flipping through default config screens, etc. Basically 
avoiding all of the manual steps required to get a working setup for a Ping Identity
product with sample applications.

How To Use It
-------------
Drop distribution files into a directory and call the appropriate deployment script from
that directory.

For example for the PingFederate Quickstart you'd need the PingFederate ZIP file,
the Quickstart distribution, a license file in your directory, as in:
    
    $ ls -1
    pingfederate-9.3.0.zip
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

- `pf-deploy-java-ik.sh`  
Deploys PingFederate (pingfederate-x.x.x.zip), the Java Integration Kit (pf-Java-integration-kit-x.x.x.zip)
and the sample IDP/SP applications in there.  
*Depends on: `pf-deploy-common.sh`*
 
- `pa-deploy-quickstart.sh`  
Deploys PingAccess ((pingaccess-x.x.x.zip), PingFederate (pingfederate-x.x.x.zip) and
the PingAccess Quickstart applications (pingaccess-quickstart-x.x.x.zip).  
*Depends on: `pf-deploy-common.sh`*
