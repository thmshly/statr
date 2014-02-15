#!/usr/bin/perl -w
use strict;

my $enabled = 1;
my $interval = "5";
my $spacer = "|";
my $ipAddr = "-";
my $count = 0;
my ($tcpCount, $udpCount, $sshCount, $date, $freeSpace);

sub resetVars {
	($tcpCount, $sshCount, $udpCount) = (0,0,0,0);
}

sub setIp {
	my $ipcmd = "ip addr show";
	#my $interface = "eth0";
	my $interface = "wlp0s2f2u3";

	my @lines = qx/$ipcmd $interface/ or die("can't read ip addr $!");
	foreach(@lines){
	if(/inet ([\d.]+)/){
			$ipAddr = $1;	
		}
	}
	return $ipAddr;
}

sub setNetCounts {
	($tcpCount,$udpCount,$sshCount) = (0,0,0);
	my $lsofcmd = "sudo lsof";
	my $swtch = "-i";
	my @lines = qx/$lsofcmd $swtch/; #or print("Can't run lsof $!");
	foreach(@lines){
		unless(/^COMMAND PID/){
			if(/TCP/){
				$tcpCount++;
			} elsif (/UDP/) {
				$udpCount++;	
			}
			if(/ssh/){
				$sshCount++;
			}
		}
	}
	1;
}

sub setFreeSpace {
	$freeSpace = 0;
	my $cmd = "df -h /";
	my @lines = qx/$cmd/ or die("Couldn't run $cmd $!");
	my $line = pop @lines;
	$line =~ /([\d.]+%)/; 
	$freeSpace = $1;
}

sub setDate {
	$date = qx/date +"%d %b"/;
	#$date = "prune juice! \n";
}

sub setVars() {
	setNetCounts();
	if ($count == 0) {
		setDate();
		setIp();
		setFreeSpace();
		$count++;
		return 1;
	} else {
		if ($count == 4) { 
			$count = 0; 
		}
		if ($count == 3){
			setFreeSpace();			
			setIp();
			#print "moomin";
		}
	}
}

while($enabled){
	setVars();
	print STDOUT  "/" . $freeSpace .
		   " t" . $tcpCount .  
		   " u" . $udpCount .
		   " s" . $sshCount .
  		    " " . $ipAddr .
 		    " " . $date;
	resetVars();
	if(defined($ARGV[0]) && $ARGV[0] eq 'GNUscreen'){
		exit();
	}
	sleep($interval);
}
