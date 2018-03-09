#Edit ONLY if you know what you're doing
#load tclsqlite3.dll
package require sqlite3
#database
sqlite3 lbd ./LostBot.sqlite
lbd eval {CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY AUTOINCREMENT, nickname COLLATE NOCASE, password TEXT, 
level INT DEFAULT 1, created INT, regip TEXT, lastlogin INT DEFAULT 0, logged int DEFAULT 0, suspendedreason TEXT, money INT DEFAULT 0, bank INT DEFAULT 0, respect INT DEFAULT 0, totalrespect int DEFAULT 0, hp 
int, maxhp int, aggressivity int, energy int, maxenergy int, rank text DEFAULT Outsider, kills INT DEFAULT 0, deaths int default 0, x int, y int, inbuilding INT DEFAULT 0)}
lbd eval {CREATE TABLE IF NOT EXISTS buildings(type TEXT, owner COLLATE NOCASE, funds INT, payed int, endurance int, open INT, x int, y int, life INT default 100, building int)}
lbd eval {CREATE TABLE IF NOT EXISTS buildingtype(type TEXT, weekly INT, minincome int, maxincome int, minendurance int, maxendurance int, respect int, necessity int, building INT)}
lbd eval {INSERT INTO buildingtype VALUES('City Hall','0','0','0','0','0','0','0','1')}
lbd eval {INSERT INTO buildingtype VALUES('Police station','0','0','0','0','0','0','1','1')}
lbd eval {INSERT INTO buildingtype VALUES('Hospital','0','0','0','0','0','0','1','1')}
lbd eval {INSERT INTO buildingtype VALUES('Weapon Store','0','0','0','0','0','0','1','1')}
lbd eval {INSERT INTO buildingtype VALUES('Bank','0','400','700','21','30','25','1','1')}
lbd eval {INSERT INTO buildingtype VALUES('Warehouse','1','100','250','14','23','20','1','1')}
lbd eval {INSERT INTO buildingtype VALUES('Hotel','1','80','170','9','15','10','2','1')}
lbd eval {INSERT INTO buildingtype VALUES('Brothel','1','70','150','8','16','10','2','1')}
lbd eval {INSERT INTO buildingtype VALUES('Cinema','1','50','110','7','13','10','2','1')}
lbd eval {INSERT INTO buildingtype VALUES('Nightclub','1','55','100','7','12','10','2','1')}
lbd eval {INSERT INTO buildingtype VALUES('Coffee House','1','40','90','5','9','5','3','1')}
lbd eval {INSERT INTO buildingtype VALUES('Butcher','1','30','70','5','5','5','3','1')}
lbd eval {INSERT INTO buildingtype VALUES('General Store','1','40','60','4','7','5','3','1')}
lbd eval {INSERT INTO buildingtype VALUES('Bakery','1','20','50','3','7','5','3','1')}
lbd eval {INSERT INTO buildingtype VALUES('Restaurant','1','55','100','7','12','10','2','1')}
lbd eval {INSERT INTO buildingtype VALUES('Casino','1','90','220','14','27','20','1','1')}
lbd eval {INSERT INTO buildingtype VALUES('Museum','1','50','130','9','13','5','2','1')}
lbd eval {INSERT INTO buildingtype VALUES('Art Gallery','1','60','120','8','13','5','2','1')}
lbd eval {INSERT INTO buildingtype VALUES('Theater','1','20','50','3','7','5','3','1')}
lbd eval {INSERT INTO buildingtype VALUES('Newspaper Office','1','25','60','4','8','5','3','1')}
lbd eval {INSERT INTO buildingtype VALUES('Clothes Store','1','50','80','5','9','5','2','1')}
lbd eval {INSERT INTO buildingtype VALUES('Church','0','0','0','0','0','0','1','1')}
lbd eval {INSERT INTO buildingtype VALUES('Park','0','0','0','0','0','0','4','0')}
lbd eval {INSERT INTO buildingtype VALUES('Street','0','0','0','0','0','0','4','0')}

lbd eval {CREATE TABLE IF NOT EXISTS items (item TEXT, cost INT, damage INT, hit INT, energyuse FLOAT, maxbullets INT, special INT, stackable INT)}
lbd eval {CREATE TABLE IF NOT EXISTS inventory(nickname TEXT COLLATE NOCASE, item TEXT, quantity INT, invnr INT default 1)}
lbd eval {INSERT INTO items VALUES('Bullet','1','0','0','0','0','0','1')}
lbd eval {INSERT INTO items VALUES('Knuckles','25','2','85','1','1','0','0')}
lbd eval {INSERT INTO items VALUES('Baseball','50','2','95','2','1','0','0')}
lbd eval {INSERT INTO items VALUES('Knife','80','3','90','2','1','0','0')}
lbd eval {INSERT INTO items VALUES('Axe','120','4','85','3','1','0','0')}
lbd eval {INSERT INTO items VALUES('Katana','170','3','90','3','1','0','0')}
lbd eval {INSERT INTO items VALUES('Colt 1911','250','1','85','0.25','6','0','0')}
lbd eval {INSERT INTO items VALUES('Winchester 1912','500','4','70','0.5','2','0','0')}
lbd eval {INSERT INTO items VALUES('ThompsonM1A1','1000','1','75','0.1','25','0','0')}
lbd eval {INSERT INTO items VALUES('Assasins Colt 1931','10000','2','90','1','12','1','0')}

lbd eval {CREATE TABLE IF NOT EXISTS notes(touser TEXT COLLATE NOCASE, fromuser TEXT COLLATE NOCASE, note TEXT, time int, read int DEFAULT 0)}
set time [clock seconds]
lbd eval {INSERT INTO notes VALUES('System','System','Time management',$time,'1')}
lbd eval {CREATE TABLE IF NOT EXISTS actions(nickname TEXT COLLATE NOCASE, what TEXT COLLATE NOCASE, action TEXT, time INT)}

puts "Database created..."
