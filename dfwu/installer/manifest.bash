#----- REQUIRE ROOT
if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root.  Try again with sudo."
	exit 1
fi
#-----/REQUIRE ROOT

#----- ENVIRONMENT VARIABLES
myeditor=${FCEDIT:-${VISUAL:-${EDITOR:-nano}}}
rootdir=~root
mydir=$( cd "$(dirname "$BASH_SOURCE")" ; pwd -P )
#-----/ENVIRONMENT VARIABLES

#----- DEFAULT SETTINGS I
TMPALLOWFILE='/etc/csf/csf.allow'
TMPINCLUDESTR='Include /etc/csf/csf-ddns.allow'
TMPLOC=`mktemp $mydir/csf-allow.XXXXXXXXX`
TMPCRONSTR="* * * * * /usr/local/bin/ddns-fwu.py $rootdir/etc/dfwu.ini"
TMPCRON=`mktemp $mydir/crontab.XXXXXXXXX`
#-----/DEFAULT SETTINGS I

#----- INSTALL SETTINGS
echo;
read -p "Which firewall file? [$TMPALLOWFILE] " INPALLOWFILE
if [ -z "$INPALLOWFILE" ]; then
	INPALLOWFILE=$TMPALLOWFILE
fi

read -p "What firewall line? [$TMPINCLUDESTR] " INPINCLUDESTR
if [ -z "$INPINCLUDESTR" ]; then
	INPINCLUDESTR=$TMPINCLUDESTR
fi
#-----/INSTALL SETTINGS

#----- MOVE MAIN APPLICATION
mv $mydir/../ddns-fwu.py /usr/local/bin/
chmod 755 /usr/local/bin/ddns-fwu.py
#-----/MOVE MAIN APPLICATION

#----- MOVE DFWU INI TO root's ~/etc (usually /root/etc) IF DOESN'T EXIST (otherwise, assume an upgrade)
if [ -f $rootdir/etc/dfwu.ini ]; then
	echo "$rootdir/etc/dfwu.ini exists, not replacing."
else
	mkdir -p $rootdir/etc
	mv $mydir/../dfwu.ini $rootdir/etc/dfwu.ini
fi
#-----/MOVE DFWU INI

#----- INSERT (or skip if exists) FIREWALL INCLUDE LINE
grep -q -F "$INPINCLUDESTR" $INPALLOWFILE || echo "$INPINCLUDESTR" >> $INPALLOWFILE
#-----/INSERT (or skip if exists) FIREWALL INCLUDE LINE

#----- INSERT ENTRY (or skip if exists) INTO CRONTAB
CRONTAB_NOHEADER='N'
crontab -l > $TMPCRON
grep -q -F "$TMPCRONSTR" $TMPCRON || echo "$TMPCRONSTR" >> $TMPCRON
( cat $TMPCRON ) | crontab -
#-----/INSERT ENTRY (or skip if exists) INTO CRONTAB

#----- DELETE TEMPORARY FILES
rm -rfv $TMPLOC
rm -rfv $TMPCRON
rm -rfv $mydir/../../ddns-utils/
#-----/DELETE TEMPORARY FILES

#----- GARBAGE COLLECTION
unset TMPALLOWFILE INPALLOWFILE
unset TMPINCLUDESTR INPINCLUDESTR
unset TMPLOC TMPCRONSTR
#-----/GARBAGE COLLECTION

#----- NOTICE: FINISH
echo "DFWU (DDNS Firewall Update) has been installed.";
echo "www.GotGetLLC.com | www.opensour.cc/dfwu";
echo;
#-----/NOTICE: FINISH

#----- NOTICE: EDIT
echo "Opening $rootdir/etc/dfwu.ini with your editor ($myeditor) for you to make appropriate changes.";
read -n1 -r -p "Press q to quit or any other key to continue..." quitCatch;
#-----/NOTICE: EDIT

#----- EDITOR
if [ "$quitCatch" == 'q' ]; then
	exit
else
	eval $myeditor $rootdir/etc/dfwu.ini
fi
#-----/EDITOR

#----- REFRESH
/usr/local/bin/ddns-fwu.py $rootdir/etc/dfwu.ini
#-----/REFRESH
