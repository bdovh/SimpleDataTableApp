buildVersion=$(cat sfdx-project.json | jq '.packageAliases | to_entries | length+1')
install=$(cat template/classes/InstallHandler.cls)
install1=${install/<BuildVersion>/$buildVersion}
install2=${install1//<PackageName>/Test App: $3}
install3=${install2/InstallHandler/InstallHandler$4}
install4=${install3/MailUtils/MailUtils$4}
echo "${install4/<PostInstallCode>/$5}" > $4/classes/InstallHandler$4.cls
uninstall=$(cat template/classes/UninstallHandler.cls)
uninstall1=${uninstall/<BuildVersion>/$buildVersion}
uninstall2=${uninstall1//<PackageName>/Test App: $3}
uninstall3=${uninstall2/UninstallHandler/UninstallHandler$4}
uninstall3=${uninstall2/UninstallHandler/UninstallHandler$4}
uninstall4=${uninstall3/MailUtils/MailUtils$4}
echo "${uninstall4/<PostUninstallCode>/$6}" > $4/classes/UninstallHandler$4.cls
mailUtils=$(cat template/classes/MailUtils.cls)
mailUtils1=${mailUtils/MailUtils/MailUtils$4}
echo "${mailUtils1/<email>/$7}" > $4/classes/MailUtils$4.cls
cp template/classes/MailUtils.cls-meta.xml $4/classes/MailUtils$4.cls-meta.xml
cp template/classes/InstallHandler.cls-meta.xml $4/classes/InstallHandler$4.cls-meta.xml
cp template/classes/UninstallHandler.cls-meta.xml $4/classes/UninstallHandler$4.cls-meta.xml

pid=$(sfdx force:package:version:create -v $1 -p "Test App: $3" -x -w 60 --skipvalidation --postinstallscript InstallHandler$4 --uninstallscript UninstallHandler$4 | awk '$1 ~ /Successfully/ { print $11 }')
echo "Hi client. Created a new Beta test version of installable package https://login.salesforce.com/packaging/installPackage.apexp?p0=$pid

This version includes the following updates:" > message$4beta$pid.txt

hub=$(sfdx config:get defaultdevhubusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx config:set defaultdevhubusername=$1 

default=$(sfdx config:get defaultusername | awk '/^==|^──|^Name/ {next}{print $2}')
sfdx force:config:set defaultusername=$2

./uninstall.sh "$3"
sfdx force:package:install -p $pid -r -b 20 -w 600

sfdx force:org:open -p "0A3?setupid=ImportedPackage"

sfdx config:set defaultusername=$default
sfdx config:set defaultdevhubusername=$hub