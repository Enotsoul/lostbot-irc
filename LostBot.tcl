###################################################
#LostBot made by LostOne 
#LostBot v0.1 pre-alpha
#Last Mod 21-06-2009
#This bot uses the irc & logger tcllib packages.
#You need a proper sqlite library to run it(usually included..)
##################################################
#The following tags are self explaintory... You MUST change the [Required] ones
#[Required] change it or bot won't work well 
#[Recommended] Best values are default
#[Optional] Edit the bot however you want it
##################################################
#Load things
source logger-0.8.tm
source irc-0.6.1.tm

#change this to tclsqlite3.so if you use linux..
load tclsqlite3.dll
package require sqlite3

#database
sqlite3 lbd ./LostBot.sqlite

##################################################
# CONFIGURATION Most things are self explaintory
##################################################
global LostBot LostCon

#[Optional] fill the filename of the extensions...

set LostBot(extensions) ""
#[Required]
#The owner's nick you need to set this and then register:)
set LostBot(owner) "LostOne"
set LostBot(nick) "L"
set LostBot(name) "/msg $LostBot(nick) help basics"
set LostBot(server) "irc.FunIRC.info"
set LostBot(mainchannel) "#LostWorld"
set LostBot(nickservpass) "thelbot"
set LostBot(town) "LostHeaven"

#[Optional]
#IrcOperator status, set 0 if no ircop
set LostBot(operstatus) "1"
set LostBot(oper) "LostBot"
set LostBot(operpass) "wittlebot"
#[Recommended] How many minutes does a INGAME day take? Your energy gets fully revived every INGAME day.
#Once every WEEK you get your money:) from exhortion.. If you still own the place
#Default is 206 so you get 1 week in 1 normal day..
set LostBot(day) "206"

#[Recomended] Here you can change how many inventory spots a user may have. Best is 3 to 5
#This is used so you can add multiple inventory spots in a database and not having to worry
#about modifying the whole database.. CHANGE THIS at the beginning
set LostBot(inventory) "5"
#[Recomended] The maximum for the map, normally 20
#Use this settings with MakeNewMap $mapmaxX $mapmaxY or else...
set LostBot(mapmaxX) "20"
set LostBot(mapmaxY) "20"

##################################################
# END OF CONFIGURATION
##################################################
set LostBot(version) "0.1alpha"
#Create connection
set LostCon [::irc::connection]

##################################################
# Events
##################################################
#First we register the PING event so that we won't get kicked from the net:)
$LostCon registerevent PING {
network send "PONG [msg]"
set ::PING 1
}
$LostCon registerevent defaultcmd {
puts "[action] [msg]"
}
$LostCon registerevent defaultnumeric {
puts "[action] XXX [target] XXX [msg]"
}
$LostCon registerevent defaultevent {
puts "[who] does [action] on [target] [additional] and [msg]"
}   
$LostCon registerevent 353 {
puts "Channel: [additional] users: [msg]"
}
$LostCon registerevent MODE {
puts "[who] sets mode [additional] on [target]"
}
$LostCon registerevent KICK {
global LostBot LostCon
puts "[who address] has kicked [additional] on [target] reason [msg]"
	if {[additional] == $LostBot(nick) && [target] == $LostBot(mainchannel)} {
	$LostCon join $LostBot(mainchannel)
	$LostCon privmsg $LostBot(mainchannel) "\00304Stop kicking me from my channel you freak!"
	}
	if {[additional] == $LostBot(nick)} {
		$LostCon join [target]
		}
	
}
#Read the freakin README also, remove this..
puts stderr "You haven't read the readme.txt, haven't you?"; exit 1
#handle the privmsg..
$LostCon registerevent PRIVMSG {
global LostBot LostCon
	puts "[who] says to [target]  [msg]"
	if {[floodprotection [who]] == 1} { return }
	set msg [subst -nocommands [split [msg]]]
	NewDay $LostBot(day)
	#Private messages
	if {[target] == $LostBot(nick) && [who] != $LostBot(nick)} {
		if {[lindex {[msg]} 0] == "op"} { 
		$LostCon privmsg [who] "pardon me?"		
		}
		if {[lindex $msg 0] == "register"} { 
			if {[lindex [msg] 4] != ""} {	
			if {[string is integer [join "[lrange [msg] 2 4]" ""]] == 0} { $LostCon privmsg [who] "\00302Those numbers don't seem like valid integers to me" ; return}
			set password [lindex [msg] 1]
			set PointsChosen [expr [join [lrange [msg] 2 4] +]] 
			if {$PointsChosen != 10} { $LostCon privmsg [who] "\00302You need to use PRECISE 10 pickpoints!" ;return }
			set nick [who]
			set regip [GetAddress [who address] nick]
			set exists [lbd eval {SELECT nickname FROM users where nickname=$nick}]
			if {$exists == [who]} { $LostCon privmsg [who] "\00302You are already registered, try logging in:)" ; return } 
			set countip [lbd eval {select count(regip) from users where regip=$regip}]
			if {$countip > 1} { $LostCon privmsg [who] "\00302Sorry, you can only register 1 nickname from one ip:)" ;return}
			set hp [expr "[lindex [msg] 2]*20"]
			set aggressivity [lindex [msg] 3]
			set energy [expr "[lindex [msg] 4]*10"]
			set created [unixtime]
			set y [rnd 1 20];	set x [rnd 1 20]
			if {[who] == $LostBot(owner)} {
			for {set i 1} {$i <= $LostBot(inventory)} {incr i} {
			lbd eval {INSERT INTO inventory (nickname,item,invnr) VALUES ($nick,'Empty',$i)}
			}
		   lbd eval {INSERT INTO users (nickname,password,created,regip,hp,maxhp,aggressivity,energy,maxenergy,x,y,level) 
		   values ($nick,$password,$created,$regip,$hp,$hp,$aggressivity,$energy,$energy,$x,$y,'7')}
		  $LostCon privmsg [who] "\00304Godfather\00302, welcome! You are the OWNER of this BOT! LEVEL 7" ; return
			}			
		   lbd eval {INSERT INTO users (nickname,password,created,regip,hp,maxhp,aggressivity,energy,maxenergy,x,y) 
		   values ($nick,$password,$created,$regip,$hp,$hp,$aggressivity,$energy,$energy,$x,$y)}
		   	$LostCon privmsg [who] "\00302Welcome mafiozo\00304 [who] \00302Your HP is\00304 $hp \00302energy:\00304 $energy \00302and aggressivity:\00304 $aggressivity \00302you will start at the X,Y location\00304 $x,$y"
			  } else { $LostCon privmsg [who] "\00302Correct syntax: (!)register <pass> <Health> <Aggressivity> <Energy> type \037help register\037 for details" }
			} 
		if {[lindex $msg 0] == "login"} { 
			if {[lindex $msg 1] == ""} { $LostCon privmsg [who] "\00302Correct syntax: /msg $LostBot(nick) login <password>" ; return }
			set password [lindex [msg] 1]; set nick [who]
			set exists [lbd eval {SELECT nickname FROM users where password=$password}]
			set lastlogin [unixtime]
			if {$exists != [who]} { $LostCon privmsg [who] "\00302Either your character doesn't exist or you have provided an incorrect password, please try again:D" ; return } 
			lbd eval {UPDATE users set lastlogin=$lastlogin, logged='1' where nickname=$nick}
			$LostCon privmsg [who] "\00302You are back in\00304 $LostBot(town)."
		}
		if {[lindex $msg 0] == "logout"} { 
		set nick [who] ; set logged [lbd eval {SELECT logged FROM users where nickname=$nick}]
			if {$logged == 0 } { $LostCon privmsg [who] "\00302Well, you aren't really logged in anyway.." ; return } 
			lbd eval {UPDATE users set logged='0' where nickname=$nick}
			$LostCon privmsg [who] "\00302You have now left the Mafia war, at least for now.."
		}
		if {[lindex $msg 0] == "msg"} { 
		if {[VerifyLogin [who]] == 0} { return }
		if {[gotaccess [who address] 4] == 0} { return }
			if {[lindex $msg 1] != "" || [lrange [msg] 2 end] != ""} {
			$LostCon privmsg [lindex [msg] 1] "[lrange [msg] 2 end]"
			} else { $LostCon privmsg [who] "\00302Correct syntax: /msg $LostBot(nick) msg <#channel>/<user> <message>" }
		}
		if {[lindex $msg 0] == "do"} { 
			if {[VerifyLogin [who]] == 0} { return }
		if {[gotaccess [who address] 5] == 0} { return }
			if {[lrange $msg 1 end] != ""} {
			$LostCon send "[lrange [msg] 1 end]"
			} else { $LostCon privmsg [who] "\00302Correct syntax: /msg $LostBot(nick) do <text>" }
		}
		if {[lindex $msg 0] == "walk"} { 	
			if {[VerifyLogin [who]] == 0} { return }
			Walk [who] [lrange $msg 1 end] [who]
		}
		if {[lindex $msg 0] == "weapons"} {
			if {[VerifyLogin [who]] == 0} { return }
			Weapons [who] [lrange $msg 1 end] [who] 
		}
		if {[lindex $msg 0] == "attack"} {
			if {[VerifyLogin [who]] == 0} { return }
			Attack [who] [lrange $msg 1 end] [who]
		}
		if {[lindex $msg 0] == "help"} { Help:Msg [who] [lrange $msg 1 end] [who]	}
		if {[lindex $msg 0] == "stats"} { Stats [who] [lrange $msg 1 end] [who] }
		if {[lindex $msg 0] == "version"} { Version [who] }
	} 

	#Channel messages & stuff
	if {[target] != $LostBot(nick) && [who] != $LostBot(nick)} {
		if {[lindex $msg 0] == "!owner"} { 
		$LostCon privmsg [target] "\00302My owner is\00304 $LostBot(owner) \00302be nice or feel the mighty wang!"
		}
		if {[lindex $msg 0] == "!do"} { 
		if {[VerifyLogin [who]] == 0} { return }
		if {[gotaccess [who address] 5] == 0} { return }
			if {[lrange $msg 1 end] != ""} {
			$LostCon send "[lrange [msg] 1 end]"
			} else { $LostCon privmsg [who] "\00302Correct syntax: !do <text>" }
		}
		if {[lindex $msg 0] == "!version"} { Version [target] }
		if {[lindex $msg 0] == "!stats"} { Stats [who] [lrange $msg 1 end] [target] }
		if {[lindex $msg 0] == "!help"} { Help:Msg [who] [lrange $msg 1 end] [target] }
		if {[lindex $msg 0] == "!move"} { $LostCon privmsg [target] "\00302Use: (!)walk to <x> <y> instead" }
		if {[lindex $msg 0] == "!walk"} { 	
		if {[VerifyLogin [who]] == 0} { return }
		Walk [who] [lrange $msg 1 end] [target] 
		}
		if {[lindex $msg 0] == "!weapons"} {
			if {[VerifyLogin [who]] == 0} { return }
			Weapons [who] [lrange $msg 1 end] [target] 
		}
		if {[lindex $msg 0] == "!attack"} {
			if {[VerifyLogin [who]] == 0} { return }
			Attack [who] [lrange $msg 1 end] [target] 
		}
	}
}

##################################################
# Procedures That are commands used by the bot
##################################################

proc Help:Msg {who msg target} {
#ALWAYS DEFINE GLOBALS, otherwise the namespace won't work..
	global LostBot LostCon
	if {$msg == ""} { $LostCon privmsg $target "\00302Try: (!)help <command> <args> Commands: register login logout basics commands nickname" }
	switch -nocase [lindex $msg 0] {
		register {
		$LostCon privmsg $target "\00302At registration you get 10 PickPoints, each of them may be used on a trait. \002register <pass> <Health> <Aggressivity> <Energy>\002 1 PickPoint could mean +20 Health +10 Energy +1 Aggressivity"
			}
		login {	$LostCon privmsg $target "\00302Just type login <password> to login!" }
		logout { $LostCon privmsg $target "\00302Logging out is important, so others don't get access in your place:D." }
		admin { $LostCon privmsg $target "\00302Admin commands: (!)do (!)msg (!)admin" }
		basics {
		$LostCon privmsg $target "\00302Mafia Game is played in the town of $LostBot(town) where everyone starts off as an Outsider and wants to become a Don. (You can only give commands every 3 seconds.) "
		$LostCon privmsg $target "\00302You will run around the city in the need to exhort busineses for money. Bribing cops, buying weapons and killing other mobsters."
				$LostCon privmsg $target "\00302Type: help commands for a list of commands, and help register on how to register."
		$LostCon privmsg $target "\00302=-=Game created by LostOne=-="
		}
		nickname { 	$LostCon privmsg $target "\00302Be sure to have a nickname not containing the following \{\}\[\]. Use a polite nickname that's not ruining the spirit of Mafia:). " }
		commands { 	$LostCon privmsg $target "\00302Full commands list: (!)do (!)msg (!)stats (!)version (!)help (!)admin  (!)walk (!)weapons (!)attack login register logout " }

	}
}
proc Stats {who msg target} {
	global LostBot LostCon
	if {$msg == ""} { $LostCon privmsg $target "\00302Try: (!)stats <command> <args> Commands:  users admins online myprofile player location inventory newday" }
	switch -nocase [lindex $msg 0] {
		users {	$LostCon privmsg $target "\00302There currently are [lbd eval {Select count(*) from users}] users registered."		}
		admins { $LostCon privmsg $target "\00302My admins are: [lbd eval {select nickname from users where level>='4'}]."		}
		online { $LostCon privmsg $target "\00302There are [lbd eval {Select count(*) from users where logged='1'}] users online: [lbd eval {select nickname from users where logged='1'}]" }
		myprofile {
		if {[VerifyLogin $who] == 0} { return }
		lbd eval {select * from users where nickname=$who} stats { }
		set owns [lbd eval {select count(owner) from buildings where owner=$who}]
		#	level,created,money,respect,totalrespect,hp,maxhp,aggressivity,energy,maxenergy,rank,kills,x,y
		$LostCon privmsg $target "=-=\00302Statistics for: \00304$stats(nickname)\00302 Created: \00304[givetime $stats(created)]\00302 Location:\00304 $stats(x),$stats(y) \00302Respect: \00304$stats(respect)/$stats(totalrespect) \00302=-=-=\00302 Money: \00304$stats(money)\$ \00302 Bank: \00304$stats(bank)\$ \00302 Health:\00304 $stats(hp)/$stats(maxhp) \00302Aggressivity:\00304 $stats(aggressivity) \00302Energy:\00304 $stats(energy)/$stats(maxenergy) \00302Rank:\00304 $stats(rank) \00302Kills:\00304 $stats(kills) \00302You own\00304 $owns \00302businesses=-="
		}
		inventory {
		if {[VerifyLogin $who] == 0} { return }
		set items [lbd eval {select count(item) from inventory where nickname=$who and not item='Empty'}]
		set inventory [lbd eval {select invnr,item,quantity from inventory where nickname=$who and not item='Empty'}]
			$LostCon privmsg $target  "\00302You have the following items in your inventory:"
			foreach {invnr item quantity} $inventory {
			incr nr
			lappend itemslist "\00302Item Nr:\00304 $invnr \00302Item:\00304 $item\ \00302Quantity:\00304 ${quantity}"
			if {[expr {$nr%5}] == 0} { $LostCon privmsg $target "$itemslist" ; unset itemslist }
			}
			$LostCon privmsg $target $itemslist
		}
		player {
			if {[VerifyLogin $who] == 0} { return } 
			if {[lindex $msg 1] == ""} { $LostCon privmsg $target "\00302Syntax: !stats player <player> " ; return }
			set player [lindex $msg 1]
			if {[ExistsPlayer $player $target] == 0} { return }
			lbd eval {select * from users where nickname=$player} stats { }
		set owns [lbd eval {select count(owner) from buildings where owner=$player}]
		$LostCon privmsg $target "=-=\00302Statistics for: \00304$stats(nickname)\00302 Last Login: \00304[givetime $stats(lastlogin)]\00302  Created: \00304[givetime $stats(created)]\00302 Location:\00304 $stats(x),$stats(y) \00302Respect: \00304$stats(respect)/$stats(totalrespect) \00302=-=-=\00302 Money: \00304$stats(money)\$ \00302 Bank: \00304$stats(bank)\$ \00302 Health:\00304 $stats(hp)/$stats(maxhp) \00302Aggressivity:\00304 $stats(aggressivity) \00302Energy:\00304 $stats(energy)/$stats(maxenergy) \00302Rank:\00304 $stats(rank) \00302Kills:\00304 $stats(kills) \00302Owns\00304 $owns \00302businesses=-="
		}
		location {
		if {[VerifyLogin $who] == 0} { return } 
		lbd eval {select users.x,users.y,users.inbuilding,buildings.type from users,buildings where buildings.y=users.y and buildings.x=users.x and nickname=$who} {}
		set count [lbd eval {select count(*) from users where x=$x and y=$y}]
		$LostCon privmsg $target "\00302Your current location is $x,$y. You are [InBuilding $inbuilding] of the ${type}. There are currently $count users there."
		}
		newday {
		NextTurn $LostBot(day) $target
		}
	}
}
proc Exhort {who msg target} {
	global LostBot LostCon
	if {$msg == ""} { $LostCon privmsg $target "\00302Try: (!)exhort <command> <args> Commands: talk aggressive" }
	switch -nocase [lindex $msg 0] {
		talk { 
		}
		talk { 
		}
		talk { 
		}
	}
}
#Read the freakin README also, remove this..
puts stderr "You haven't read the readme.txt, haven't you?"; exit 1
proc Weapons {who msg target} {
	global LostBot LostCon
	if {$msg == ""} { $LostCon privmsg $target "\00302Try: (!)weapons <command> <args> Commands: list buy sell" }
	switch -nocase [lindex $msg 0] {
		list { 
		set weapons [lbd eval {select * from items where special=0} ]	
			foreach {n c dmg hit epb mb sp stack} $weapons {
			incr nr
			lappend weaponlist "\00302Nr:\00304 $nr \00302Name:\00304 $n \00302Costs:\00304 ${c}\$ \00302Damage:\00304 ${dmg} \00302Hit:\00304 ${hit}% \00302Energy:\00304 $epb \00302MaxBullets:\00304 $mb"
			if {[expr {$nr%2}] == 0} { $LostCon privmsg $target "$weaponlist" ; unset weaponlist }
			}
		$LostCon privmsg $target $weaponlist
		}
		buy { 
		 if {[lindex $msg 1] == ""} { $LostCon privmsg $target "\00302Correct syntax: (!)weapons buy <weapon number> <inventorynr> ?<quantity>? type: (!)weapons list"  ; return }
		set nr [lindex $msg 1] 
		set inv [lindex $msg 2]
		set qty [lindex $msg 3]
		if {[string is digit $nr] != 1 || $nr > 9 } { $LostCon privmsg $target "\00302You need to specify a number between 1 and 9"  ; return }
		if {$inv == "" || $inv > $LostBot(inventory) || $inv < 1} { $LostCon privmsg $target "\00302You have to chose an inventory place from 1 to $LostBot(inventory)."  ; return }
		lbd eval {select * from items where rowid=$nr} weapon { }
		lbd eval {select money from users where nickname=$who} user { }
		set shopname [lbd eval {select buildings.type from buildings,users where buildings.y=users.y and buildings.x=users.x and users.nickname=$who}]
		puts $shopname
		if {$shopname != "{Weapon Store}"} { $LostCon privmsg $target "\00302Are you talking to yourself? You need to be in a Weapon Store to buy weapons.." ; return }
		set inventory [lbd eval {select count(item) from inventory where nickname=$who and not item='Empty'}]
		if {$inventory >= 5} { $LostCon privmsg $target "\00302You can't buy anything while your inventory is full.. Please sell something"  ; return }
		if {$qty != "" && $weapon(stackable) != 1} { $LostCon privmsg $target "\00302You can't buy that weapon more than one time. Quantity is used only for bullets! Leave it empty otherwise:)." ; return }
		if {$qty == ""} {	set qty 1	}
		set itemtype [lbd eval {select item from inventory where nickname=$who and invnr=$inv}]
		if {$itemtype != "Empty"  && $qty == 1} { $LostCon privmsg $target "\00302You already have something on your inventory spot $inv. Sell if first."  ; return }
		if {$user(money) < [expr {$weapon(cost)*$qty}]} { $LostCon privmsg $target "\00302You don't have enough money to buy this weapon, DO something about it!" ; return }
		if {[expr {$weapon(cost)*$qty}] >= 100} {
		set ttlrespect [expr {int(ceil($weapon(cost)*$qty/250.))}]
		lbd eval {UPDATE users set money=money-$weapon(cost)*$qty,respect=respect+$ttlrespect where nickname=$who}
		} else {
		set ttlrespect 1
		lbd eval {UPDATE users set money=money-$weapon(cost)*$qty,respect=respect+$ttlrespect where nickname=$who}
		}
		lbd eval {UPDATE inventory set item=$weapon(item), quantity=quantity+$qty where nickname=$who and invnr=$inv}
		$LostCon privmsg $target "\00302You have bought\00304 $qty $weapon(item) \00302with\00304 [expr {$weapon(cost)*$qty}]\$. \00302People now have more respect for you! \00304(+${ttlrespect})"
		}
		sell {
		if {[lindex $msg 1] == ""} { $LostCon privmsg $target "\00302Correct syntax: (!)weapons sell <inventorynr>!"  ; return }
		set inv [lindex $msg 1]
		if {$inv == "" || $inv > $LostBot(inventory) || $inv < 1} { $LostCon privmsg $target "\00302You have to chose an inventory place from 1 to $LostBot(inventory)."  ; return }
		set empty [lbd eval {select item from inventory where invnr=$inv and nickname=$who}]
		if {$empty == "Empty"} { $LostCon privmsg $target "\00302Your inventory $inv is Empty.. Chose another one." ; return }
		lbd eval {select items.cost,inventory.item from items,inventory where inventory.nickname=$who and items.item=inventory.item and inventory.invnr=$inv} {} 
		set gain [expr {$cost*0.75} ]
		lbd eval {update users set money=money+$gain where nickname=$who}
		lbd eval {update inventory set item='Empty', quantity='0' where nickname=$who and invnr=$inv}
		$LostCon privmsg $target "\00302You have sold\00304 $item \00302for\00304 $gain\$"
		}
	}
}
proc Attack {who msg target} {
	global LostBot LostCon
	if {[lindex $msg 2] == ""} { $LostCon privmsg $target "\00302Try: (!)attack <player> <number of weapon from inventory> <how many times>" ; return}
	set player [lindex $msg 0]
	set inv [lindex $msg 1]
	set times [lindex $msg 2]
	if {[string is digit $inv] != 1 || [string is digit $times] != 1  && $times != 0} { $LostCon privmsg $target "\00302Invetory number and the times you want to attack have to be digits(numbers)." }
	if {[ExistsPlayer $player $target] == 0} { return }
	lbd eval {select x,y,energy,hp from users where nickname=$who} me {}
	lbd eval {select x,y,energy,hp from users where nickname=$player} enemy {}
	if {"$me(x),$me(y)" != "$enemy(x),$enemy(y)"} { $LostCon privmsg $target "\00302It seems you are not in the same place as $player." ; return  }
	if {$enemy(hp) == 0} { $LostCon privmsg $target "\00302You can't attack dead people!" ; return }
	#Your functions
	set empty [string trim [lbd eval {select item from inventory where invnr=$inv and nickname=$who}] "{}"]
	if {$empty == "Empty" || $empty == "Bullet"} { $LostCon privmsg $target "\00302Ups, you don't have any item on that inventory spot.. You'll have to use your fists" ; set myweapon(damage) 1 ; set myweapon(energyuse) 1 ; set myweapon(maxbullets) 1 ; set myweapon(hit) 99
	}	else { lbd eval {select * from items where item=$empty} myweapon { } }
	#set this here, so you don't use any bullets if it's 0
	puts "maxbullets : $myweapon(maxbullets)"
	set myusedbullets [expr {$myweapon(maxbullets)*$times}]
	if {$myweapon(maxbullets) == 0} { set mybulletts 1 } else { set mybullets  [lbd eval {select quantity from inventory where item='Bullet' and nickname=$who}]  	}
	if {$mybullets == ""} { set mybullets 1 }
	set myusedenergy [expr {$myweapon(energyuse)*$myweapon(maxbullets)*$times+$times}]
	if {$myweapon(maxbullets) == 1} { incr myusedenergy -$times }
	if {$me(energy) < $myusedenergy} {  $LostCon privmsg $target "\00302You need\00304 $myusedenergy \00302energy to attack but you only have\00304 $me(energy) \00302energy left. Try attacking him less times" ; return }
	if {$mybullets < $myusedbullets} { $LostCon privmsg $target "\00302You need\00304 $myusedbullets \00302to attack and you only have\00304 $mybullets." ; return }
	set mydamage 0
	for {set i 0} {$i<[expr {$times*$myweapon(maxbullets)}]} {incr i} {
	if {[rnd 1 100] <= $myweapon(hit)} {  incr mydamage $myweapon(damage) } 
	puts "$i and $mydamage damage & $myweapon(damage) myweapondamage"
	}
	#The enemy's functions, he has NO weapon we'll fake the things
	set empty [string trim [lbd eval {select * from items where item=(select item from inventory where nickname=$player and not item='Empty' and not item='Bullet')} enemyweapon {}] "{}"]
	if {$empty == ""} { set enemyweapon(damage) 1 ; set enemyweapon(energyuse) 1 ; set enemyweapon(maxbullets) 1 ; set enemyweapon(hit) 99 }
	#Calculate how many times you can attack..
	set enemytimes [expr {int($enemy(energy)/($enemyweapon(energyuse)*$enemyweapon(maxbullets)+1))}]
	if {$enemyweapon(maxbullets) == 1} { set enemyusedbullets 0 } else { set enemyusedbullets [expr {$enemyweapon(maxbullets)*$enemytimes}] }
	if {$enemyweapon(maxbullets) == 0} { set enemybullets 1 } else { set enemybullets  [lbd eval {select quantity from inventory where item='Bullet' and nickname=$player}]  }
	if {$enemybullets == ""} { set enemybullets 1 }
	#Don't attack more times than the one who attacks you..
	if {$times < $enemytimes} { set enemytimes $times }
	set enemyusedenergy [expr {$enemyweapon(energyuse)*$enemyweapon(maxbullets)*$enemytimes+$enemytimes}]
	if {$enemyweapon(maxbullets) == 1} { incr enemyusedenergy -$enemytimes }
	set enemydamage 0
	for {set i 0} {$i<[expr {$enemytimes*$enemyweapon(maxbullets)}]} {incr i} {
	if {[rnd 1 100] <= $enemyweapon(hit) && $enemybullets >= $enemyusedbullets } { 
		incr enemydamage $enemyweapon(damage)
		} else { incr enemydamage 1 }
	}

	#Calculate each user's remaining HP, save to database, give stats
	set enemyhp [expr {$enemy(hp) - $mydamage}]
	set myhp [expr {$me(hp) - $enemydamage}]
	set myrespect 0 ; set mykills 0
	set enemyrespect 0 ; set mydeaths 0
	if {$enemyhp < 0} { 
		set enemyhp 0 
		set myrespect [expr {5+$mydamage*0.25}] 
		set killenemy "He died. You get \00304 $myrespect \00302respect."
		set mykills 1
		} else { 
		set myrespect [expr {$mydamage*0.25}] 
		set killenemy "You gained\00304 $myrespect \00302 respect. "
		}
	if {$myhp < 0} { 
		set myhp 0 
		set enemyrespect [expr {5+$enemydamage*0.25}] 
		set killme "You also died."
		set mydeaths 1
	} else { 
		set enemyrespect [expr {$enemydamage*0.25}] 
		set killme ""
		}
	lbd eval {UPDATE users set hp=$enemyhp,respect=respect+$enemyrespect,energy=energy-$enemyusedenergy,kills=kills+$mydeaths,deaths=deaths+$mykills where nickname=$player}
	lbd eval {UPDATE users set hp=$myhp,respect=respect+$myrespect,energy=energy-$myusedenergy,kills=kills+$mykills,deaths=deaths+$mydeaths where nickname=$who}
	if {$myweapon(maxbullets) != 1} { lbd eval {UPDATE inventory set quantity=quantity-$myusedbullets where item='Bullet' and nickname=$who} } 
	if {$enemyweapon(maxbullets) != 1} { lbd eval {UPDATE inventory set quantity=quantity-$enemyusedbullets where item='Bullet' and nickname=$player} } 
    $LostCon privmsg $target "\00302You've attacked\00304 $player \00302with\00304 $mydamage \00302damage and used\00304 $myusedbullets \00302bullets. His HP went from\00304 $enemy(hp) \00302to\00304 $enemyhp \00302. He attacked you back with\00304 $enemydamage \00302damage and used\00304 $enemyusedbullets \00302bullets and your HP went from\00304 $me(hp) \00302to\00304 ${myhp}\00302. $killenemy $killme"
	set time [unixtime]
	if {$enemyhp == 0} {
	set msg "You hage been killed by $who."
	lbd eval {INSERT INTO notes VALUES($player,$who,$msg,$time,'0')}
	} else { set msg "You have been attacked by $who. Show him who's the real mobster!"	; lbd eval {INSERT INTO notes VALUES($player,$who,$msg,$time,'0')} }
}
proc Admin {who msg target} {
	global LostBot LostCon
	if {$msg == ""} { $LostCon privmsg $target "\00302Commands: modify" }
	switch -nocase [lindex $msg 0] {
	modify { $LostCon privmsg $target "Nothing yet.." }
	}
}
proc Walk {who msg target} {
	global LostBot LostCon
	if {$msg == ""} { $LostCon privmsg $target "\00302Try: (!)walk <command> <args> Commands: enter exit north south east west to" }
	switch -nocase [lindex $msg 0] {
	north { 
	if {[VerifyEnergy $who $target 1] == 0} { return }
	if {[IsInBuilding $who $target] == 0} { return }
	lbd eval {select users.x,users.y,buildings.type,buildings.open from users,buildings where buildings.x=users.x and buildings.y=users.y-1 and nickname=$who} {} 
	if {[Edge $LostBot(mapmaxX) $LostBot(mapmaxY) $x [expr {$y-1}] $target] == 0} { return }
	lbd eval {UPDATE users set x=x, y=y-1, energy=energy-1 where nickname=$who} {}
	$LostCon privmsg $target "\00302You have moved to the North. You now see the\00304 $type \00302and it's currently \00304[OpenBuilding $open]. " 
	}
	west { 
	if {[VerifyEnergy $who $target 1] == 0} { return }
	if {[IsInBuilding $who $target] == 0} { return }
	lbd eval {select users.x,users.y,buildings.type,buildings.open from users,buildings where buildings.x=users.x-1 and buildings.y=users.y and nickname=$who} {} 
	if {[Edge $LostBot(mapmaxX) $LostBot(mapmaxY) [expr {$x-1}] $y $target] == 0} { return }
	lbd eval {UPDATE users set x=x-1, y=y, energy=energy-1 where nickname=$who}
	$LostCon privmsg $target "\00302You have moved to the West. You now see the\00304 $type \00302and it's currently \00304[OpenBuilding $open]. " 	}
	south { 
	if {[VerifyEnergy $who $target 1] == 0} { return }
	if {[IsInBuilding $who $target] == 0} { return }
	lbd eval {select users.x,users.y,buildings.type,buildings.open from users,buildings where buildings.x=users.x and buildings.y=users.y+1 and nickname=$who} {} 
	if {[Edge $LostBot(mapmaxX) $LostBot(mapmaxY) $x [expr {$y+1}] $target] == 0} { return }
	lbd eval {UPDATE users set x=x, y=y+1, energy=energy-1 where nickname=$who}
	$LostCon privmsg $target "\00302You have moved to the South. You now see the\00304 $type \00302and it's currently \00304[OpenBuilding $open]. " 	}
	east { 
	if {[VerifyEnergy $who $target 1] == 0} { return }
	if {[IsInBuilding $who $target] == 0} { return }
	lbd eval {select users.x,users.y,buildings.type,buildings.open from users,buildings where buildings.x=users.x+1 and buildings.y=users.y and nickname=$who} {} 
	if {[Edge $LostBot(mapmaxX) $LostBot(mapmaxY) [expr {$x+1}] $y $target] == 0} { return }
	lbd eval {UPDATE users set x=x+1, y=y, energy=energy-1 where nickname=$who}
	$LostCon privmsg $target "\00302You have moved to the East. You now see the\00304 $type \00302and it's currently \00304[OpenBuilding $open]. " 	}
	to { 
	if {[IsInBuilding $who $target] == 0} { return }
	if {[lindex $msg 2] == ""} { $LostCon privmsg $target "\00302Correct syntax: (!)walk to <x> <y>"  ; return }
	set nextx [lindex $msg 1] ;set nexty [lindex $msg 2]
	if {[Edge $LostBot(mapmaxX) $LostBot(mapmaxY) $nextx $nexty $target] == 0} { return }
	lbd eval {select users.x,users.y,buildings.type,buildings.open from users,buildings where buildings.x=$nextx and buildings.y=$nexty and nickname=$who} {}
	#formula to calculate distance from one point to another...
	set energy [expr {int(ceil(sqrt(($x-$nextx)*($x-$nextx)+($y-$nexty)*($y-$nexty))))}]
	if {[VerifyEnergy $who $target $energy] == 0} { return }
	lbd eval {update users set x=$nextx,y=$nexty,energy=$energy where nickname=$who}
	$LostCon privmsg $target "\00302You are walking to\00304 $nextx,$nexty \00302... You are standing in front of the\00304 ${type}\00302. It is currently \00304[OpenBuilding $open]. " 
	}	
	enter {
	if {[VerifyEnergy $who $target 1] == 0} { return }
	set inbuilding [lbd eval {SELECT inbuilding from users where nickname=$who}]
	if {$inbuilding == 1} { $LostCon privmsg $target "\00302What? You're already in the building!" ; return } 
	lbd eval {select buildings.ownerusers.x,users.y,buildings.type,buildings.open from users,buildings where buildings.x=users.x and buildings.y=users.y and nickname=$who} {} 
	if  {$open != 1} { $LostCon privmsg $target "\00302This building seems to be closed" ; return }
	lbd eval {UPDATE users set inbuilding=1, energy=energy-1 where nickname=$who}
	$LostCon privmsg $target "\00302Welcome to the\00304 $type\00302. How may I help you\00304 ${who}\00302? This building is owned by\00302 $owner." 
	}
	exit { 
	if {[VerifyEnergy $who $target 1] == 0} { return }
	set inbuilding [lbd eval {SELECT inbuilding from users where nickname=$who}]
	if {$inbuilding == 0} { $LostCon privmsg $target "\00302You are not in a building." ; return } 
	lbd eval {UPDATE users set inbuilding=0, energy=energy-1 where nickname=$who}
	$LostCon privmsg $target "\00302You have exited the building." 
	}
	}
}
###################################################
# Procedures that are used by multiple commands..
###################################################
proc Version {who} { global LostBot LostCon ; $LostCon privmsg $who "\00302Lost Mafia Bot\00304 $LostBot(version)\00302 by LostOne Get it at \00304https://sourceforge.net/projects/lostbot/\0037"}
proc unixtime { } { return [clock seconds] }
proc givetime { time } { return [clock format $time -format {%Y-%m-%d %H:%M:%S}] }
proc rnd {min max} {
expr {int(($max - $min + 1) * rand()) + $min}
}
#Looks if user is in building or not..
proc IsInBuilding {who target} {
	global LostBot LostCon
	set inbuilding [lbd eval {SELECT inbuilding from users where nickname=$who}]
	if {$inbuilding == 1} { $LostCon privmsg $target "\00302You can't move around the city while you're in a building! Exit it first and then try again." ; return 0 } 
}
proc InBuilding { state } {
	if {$state == 1} { return "inside" }
	elseif {$state == 0} { return "outside" }
}
	#Look if player isn't near an edge or wouldn't exit the map..
proc Edge {maxx maxy nextx nexty target} {
	global LostBot LostCon
	if {$nextx > $maxx || $nexty > $maxy || $nexty < 1 || $nextx < 1} {
	$LostCon privmsg $target "\00302The location where you want to move does not exist. You can't move to $nextx,$nexty because it's off the map! Please restrain to a minimum of 1,1 and a maximum of $maxx,$maxy" 
	return 0
	}
}
proc OpenBuilding { state } {
	if {$state == 1} { return "open" }
	elseif {$state == 0} { return "closed" }
}
proc ExistsPlayer {player target} {
	global LostBot LostCon
	set exists [lbd eval {SELECT nickname FROM users where nickname=$player}]
	if {$exists == ""} { $LostCon privmsg $target "\00302I never heard about a mobster called\00304 $player \00302before..." ; return 0}
}
proc GetAddress {address type} {
	switch $type {
		nick {	return [lindex [split $address "!@"] 0] }
		ident { return [lindex [split $address "!@"] 1] }
		ip {return [lindex [split $address "!@"] 2] }
		default { return $address }
	}
}
proc VerifyLogin {nick} {
	global LostBot LostCon
	set logged [lbd eval {select logged from users where nickname=$nick}]
	set exists [lbd eval {SELECT nickname FROM users where nickname=$nick}]
		if {$logged == 0 || $exists != $nick} {
	$LostCon privmsg $nick "\00302Please login to be able to use this command!"
	return 0
	}
}
proc VerifyAlive {nick target} {
	global LostBot LostCon
	set health [lbd eval {select hp from users where nickname=$nick}]
	if {$health == 0} { 
	$LostCon privmsg $target "\00302You're dead, you can't do anything. Wait untill you get to a hospital."
	return 0
	}
}
proc VerifyEnergy {nick target energy} {
	global LostBot LostCon
	if {[VerifyAlive $nick $target] == 0} { return 0 }
	set leftenergy [lbd eval {select energy from users where nickname=$nick}]
	if {$energy > $leftenergy} { 
	$LostCon privmsg $target "\00302You don't have enough energy left to do that.. wait untill a new day starts"
	return 0
	}
}

#Read the freakin README also, remove this..
puts stderr "You haven't read the readme.txt, haven't you?"; exit 1
proc gotaccess {address reqlevel} {
	global LostBot LostCon
	set nick [GetAddress $address nick]
	set level [lbd eval {select level from users where nickname=$nick}]
	if {$level < $reqlevel} {
	$LostCon privmsg $nick "\00302Sorry you don't have access to this command:)"
	return 0
	}
}
proc NextTurn {day target} {
	global LostBot LostCon
	set lastday  [lbd eval {select time from notes where touser='System' and fromuser='SYSTEM'}]
	set read  [lbd eval {select read from notes where touser='System' and fromuser='SYSTEM'}]
	set newday [clock add $lastday $day minutes]
	set timenow [unixtime]
	set nextday [expr {($newday-$timenow)/60}]
	set nextweek [expr {(7-$read)*$day+($newday-$timenow)/60}] 
	set nextdayhours [expr {$nextday/60}]
	set nextdayminutes [expr {$nextday%60}]
	set nextweekhours [expr {$nextweek/60}]
	set nextweekminutes [expr {$nextweek%60}]
	$LostCon privmsg $target "\00309,01A new day starts in\00304 $nextdayhours \00309hours and\00304 $nextdayminutes \00309minutes. A new week starts in\00304 $nextweekhours \00309hours and\00304 $nextweekminutes \00309minutes."
}
proc NewDay {day} {
	global LostBot LostCon
	set lastday  [lbd eval {select time from notes where touser='System' and fromuser='SYSTEM'}]
	set read  [lbd eval {select read from notes where touser='System' and fromuser='SYSTEM'}]
	set newday [clock add $lastday $day minutes]
	set timenow [unixtime]
	if {$newday <= $timenow} {
	#This calculates the days passed since it last 
	set difference [expr {abs($newday-$timenow)/(60*$day)}]
	if {$difference == 0} { set $difference 1 }
	lbd eval {UPDATE users set energy=maxenergy}
	lbd eval {select x,y from buildings where type="Hospital"} {  }
	#put dead users in a hospital
	lbd eval {UPDATE users set x=$x,y=$y,inbuilding=1,hp=1 where hp='0'}
	lbd eval {UPDATE notes set time=$timenow,read=read+1 WHERE touser='System'}
		if {[expr {$read*$difference}] >= 7} { 
			#updates multiple things, since the SQL update only supports 1
			lbd eval {update users set money=money+(select sum(buildings.funds) from buildings where buildings.owner=users.nickname and buildings.weekly='1') WHERE EXISTS (select * from buildings where buildings.owner=users.nickname)}
			$LostCon privmsg $LostBot(mainchannel) "\00309,01A new week has started. Everyone recieves money from his racket business."
			lbd eval {UPDATE notes set read=1 where touser='System'}
		} else { $LostCon privmsg $LostBot(mainchannel) "\00309,01A new day has started. Energy is up!:)" }
	after [expr {1000*60*$day}] NewDay $LostBot(day)
	}
}
#Use this command only 1-2 times and don't use it with more than 50x50 or it may seem "blocked" for a few minutes
proc MakeNewMap {maxx maxy} {
#n0 means a maximum of 1-2 such buildings per city at a 5x5 distance from eachother! N1= 7 max, 3x3 distance N2= 15 max 2x2 n3= 25 max n4= kinda unlimited.. 
set TotalBuildings [lbd eval {SELECT max(rowid) from buildingtype}]
#Start putting buildings, starting from the left upper corner
	for {set miny 1} {$miny <= $maxy} {incr miny} {
		for {set minx 1} {$minx <= $maxx} {incr minx} {
	set random [rnd 1 $TotalBuildings]
	lbd eval {select * from buildingtype where rowid=$random} Building {}
	set count [lbd eval {select count(type) from buildings where type=$Building(necessity)}]
	switch $Building(necessity) {
		5 { set dx 5 ; set dy 5; set maxcity 30 }
		4 { set dx 4 ; set dy 4; set maxcity 70 }
		3 { set dx 3 ; set dy 3; set maxcity 130 }
		2 { set dx 2 ; set dy 2; set maxcity 170 }
		1 { set dx 1 ; set dy 1; set maxcity 300 }
	}
	set buildings [lbd eval {select type from buildings where (x between $minx-$dx and $minx) and (y between $miny-$dy and $miny)}]
	if {$count >= $maxcity || [string match "*$Building(type)*" $buildings] == 1} { 
	incr minx -1
		} else {
		set funds [rnd $Building(minincome) $Building(maxincome)]
		set endurance [rnd $Building(minendurance) $Building(maxendurance)]
		lbd eval {INSERT INTO buildings (type,owner,funds,endurance,payed,open,x,y,life,building) values ($Building(type),'Vito Corleone',$funds,$endurance,0,1,$minx,$miny,'20',$Building(building))}
		}
		}
	}
}

proc Buildings { } {

set random [rnd 1 $TotalBuildings]
	lbd eval {select * from buildingtype where rowid=$random} Building {}
	set funds [rnd $Building(minincome) $Building(maxincome)]
	set endurance [rnd $Building(minendurance) $Building(maxendurance)]
	lbd eval {INSERT INTO buildings (type,owner,funds,endurance,payed,open,x,y,life) values ($Building(type),'Vito Corleone',$funds,$endurance,0,1,$minx,$miny,'20')}

}
#Flood Protection
proc floodprotection {nick} {
global flood
	if {[info exists flood($nick)] == 0} { set flood($nick) 0  }
	if {$flood($nick) == 1} { return 1 
	} elseif {$flood($nick) == 0} {
		set flood($nick) 1
		after 3000 set flood($nick) 0
	}
}

###################################################
#Start LostBot
###################################################

$LostCon connect $LostBot(server) 6667
$LostCon user $LostBot(nick) "lost" "one" $LostBot(name) 
$LostCon nick $LostBot(nick)
if {$LostBot(operstatus) == "1" } {
$LostCon send "oper $LostBot(oper) $LostBot(operpass)"
$LostCon send "mode $LostBot(nick) +ixB-kcfvGqso"
$LostCon send "sethost Lost.Mafia.Bot.ro"
#after 5000 [$LostCon send "opmode $LostBot(mainchannel) +o $LostBot(nick)"]
}
if {$LostBot(nickservpass) != ""} {
$LostCon privmsg nickserv "identify $LostBot(nickservpass)"
}
$LostCon join $LostBot(mainchannel)
NewDay $LostBot(day)

