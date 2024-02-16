-- Modify by : Doug DeGenaro
-- Modify Date : 08/15/2019
-- Description :  removed Crim id in the select and group by as it is causing duplicates in Q-Report
CREATE PROCEDURE [dbo].[Iris_GetOrderQueueCount]
AS
SET NOCOUNT ON   
--Declare variables
declare @jurLabel varchar(25), @crimLabel varchar(25), @countOnline int, @countCallin int, @countFax int, @countFaxChk int,@mailchk int,@countMail int,@countEmail int,
	@countInhouse int,@countDps int,@countWebService int, @countIntegration int, @countMisc int, @jurTotal int, @crimTotal int

--Set labels
set @jurLabel = 'Total Jurisdictions'; 
set @crimLabel = 'Total Crims'; 

--Create tables for all Order Management queues
create table #tmpcnt_online(ID INT IDENTITY(1, 1) primary key, r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,
	vendorid int,r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10))

create table #tmpcnt_callin(ID INT IDENTITY(1, 1) primary key,r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,
	vendorid int,r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10))

create table #tmpcnt_fax(ID INT IDENTITY(1, 1) primary key,r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),R_State_Province varchar(100),
	readytosend bit,vendorid int,r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10))

create table #tmpcnt_faxchk(ID INT IDENTITY(1, 1) primary key,r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,
	vendorid int,r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10))

create table #tmpcnt_mailchk(ID INT IDENTITY(1, 1) primary key,r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,
	vendorid int,r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10))

create table #tmpcnt_mail(ID INT IDENTITY(1, 1) primary key,r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,
	vendorid int,r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10))

create table #tmpcnt_email(ID INT IDENTITY(1, 1) primary key,r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,vendorid int,
	r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10),InUse bit)

create table #tmpcnt_inhouse(ID INT IDENTITY(1, 1) primary key,r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,
	vendorid int,r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10))

create table #tmpcnt_dps(ID INT IDENTITY(1, 1) primary key,r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,
	vendorid int,r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10))

create table #tmpcnt_webservice(ID INT IDENTITY(1, 1) primary key, r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,vendorid int,
	r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10),Clear varchar(10))

create table #tmpcnt_integration(ID INT IDENTITY(1, 1) primary key,r_name varchar(100),r_firstname varchar(100),b_rule varchar(100),r_lastname varchar(100),readytosend bit,
	vendorid int,r_Delivery varchar(100),CNTY_NO int,crim_time datetime,county varchar(40),state varchar(40),IRIS_REC varchar(10))


create table #tmpcnt_misc(ID INT IDENTITY(1, 1) primary key,AppNo int,b_rule varchar(10),vendor varchar(100),Crimenteredtime datetime,CNTY_NO int,r_firstname varchar(100),
	r_lastname varchar(100),vendorid int,r_Delivery varchar(100),IRIS_REC varchar(10),county varchar(40))
	
create table #tmpcntall(Queue varchar(25), Online int,Callin int,Fax int,FaxCheck int,MailCheck int,Mail int,Email int,
	InHouse int,DPS_InHouse int, WebService int, IntegratedVendor int, Misc int, TOTAL int)

create table #tmpcnt_crims(ID INT IDENTITY(1, 1) primary key, crimId int, deliverymethod varchar(25), vendorid int)

--Inserting all records into temp tables per queue
insert into #tmpcnt_online EXEC [dbo].[Iris_Onlinedb_orders_pending] SET @countOnline=@@ROWCOUNT

insert into #tmpcnt_callin EXEC [dbo].[Iris_Callin_orders_pending] SET @countCallin=@@ROWCOUNT

insert into #tmpcnt_fax EXEC [dbo].[Iris_Fax_orders_pending] SET @countFax=@@ROWCOUNT

insert into #tmpcnt_faxchk EXEC Iris_Orders_By_DeliveryMethod 'fax-copyofcheck' SET @countFaxChk=@@ROWCOUNT

insert into #tmpcnt_mailchk EXEC Iris_Orders_By_DeliveryMethod 'Mail-copyofcheck' SET @mailchk=@@ROWCOUNT

insert into #tmpcnt_mail EXEC Iris_Orders_By_DeliveryMethod 'mail' SET @countMail=@@ROWCOUNT

insert into #tmpcnt_email EXEC Iris_email_orders_pending SET @countEmail=@@ROWCOUNT

insert into #tmpcnt_inhouse EXEC Iris_Inhouse_orders_pending SET @countInhouse=@@ROWCOUNT

insert into #tmpcnt_dps EXEC Iris_DPS_Inhouse_orders_pending SET @countDps=@@ROWCOUNT

insert into #tmpcnt_webservice EXEC iris_ws_orders SET @countWebService=@@ROWCOUNT

insert into #tmpcnt_integration EXEC Iris_IntegratedVendor_orders_pending SET @countIntegration=@@ROWCOUNT

insert into #tmpcnt_misc EXEC iris_no_default_pending SET @countMisc=@@ROWCOUNT

--Inserting total counts per queue into table
set @jurTotal = @countOnline + @countCallin + @countFax + @countFaxChk + @mailchk + @countMail + @countEmail + @countInhouse + @countDps + @countWebService + @countIntegration + @countMisc;

insert into #tmpcntall (Queue,Online,Callin,Fax,FaxCheck,MailCheck,Mail,Email,InHouse,DPS_InHouse,WebService,IntegratedVendor,Misc,TOTAL)

select @jurLabel, @countOnline,@countCallin,@countFax,@countFaxChk,@mailchk,@countMail,@countEmail,@countInhouse,@countDps,@countWebService, @countIntegration, @countMisc, @jurTotal;

declare @Id int, @vendorid INT, @delivery VARCHAR(25), @cntyno INT

--Insert crim with deliverymethod = OnlineDB
while (Select count(*) from #tmpcnt_online) > 0
begin
select Top 1 @Id = ID, @vendorid = vendorid, @delivery = r_Delivery, @cntyno = CNTY_NO from #tmpcnt_online
insert into #tmpcnt_crims exec [dbo].[iris_outgoing_min] @vendorid, @delivery, @cntyno 
delete from #tmpcnt_online where ID = @Id;
end

--Insert crim with deliverymethod = Call_in
while (Select count(*) from #tmpcnt_callin) > 0
begin
select Top 1 @Id = ID, @vendorid = vendorid, @delivery = r_Delivery, @cntyno = CNTY_NO from #tmpcnt_callin
insert into #tmpcnt_crims exec [dbo].[iris_outgoing_min] @vendorid, @delivery, @cntyno 
delete from #tmpcnt_callin where ID = @Id;
end

--Insert crim with deliverymethod = fax
while (Select count(*) from #tmpcnt_fax) > 0
begin
select Top 1 @Id = ID, @vendorid = vendorid, @delivery = r_Delivery, @cntyno = CNTY_NO from #tmpcnt_fax
insert into #tmpcnt_crims exec [dbo].[iris_outgoing_min] @vendorid, @delivery, @cntyno 
delete from #tmpcnt_fax where ID = @Id;
end

--Insert crim with deliverymethod = mail
while (Select count(*) from #tmpcnt_mail) > 0
begin
select Top 1 @Id = ID, @vendorid = vendorid, @delivery = r_Delivery, @cntyno = CNTY_NO from #tmpcnt_mail
insert into #tmpcnt_crims exec [dbo].[iris_outgoing_min] @vendorid, @delivery, @cntyno 
delete from #tmpcnt_mail where ID = @Id;
end

--Insert crim with deliverymethod = email
while (Select count(*) from #tmpcnt_email) > 0
begin
select Top 1 @Id = ID, @vendorid = vendorid, @delivery = r_Delivery, @cntyno = CNTY_NO from #tmpcnt_email
insert into #tmpcnt_crims exec [dbo].[iris_outgoing_min] @vendorid, @delivery, @cntyno 
delete from #tmpcnt_email where ID = @Id;
end

--Insert crim with deliverymethod = webservice
while (Select count(*) from #tmpcnt_webservice) > 0
begin
select Top 1 @Id = ID, @vendorid = vendorid, @delivery = r_Delivery, @cntyno = CNTY_NO from #tmpcnt_webservice
insert into #tmpcnt_crims exec [dbo].[iris_outgoing_min] @vendorid, @delivery, @cntyno 
delete from #tmpcnt_webservice where ID = @Id;
end

--Insert crim with deliverymethod = integration
while (Select count(*) from #tmpcnt_integration) > 0
begin
select Top 1 @Id = ID, @vendorid = vendorid, @delivery = r_Delivery, @cntyno = CNTY_NO from #tmpcnt_integration
insert into #tmpcnt_crims exec [dbo].[iris_outgoing_min] @vendorid, @delivery, @cntyno 
delete from #tmpcnt_integration where ID = @Id;
end


set @crimTotal = (select count(*) from #tmpcnt_crims) + @countFaxChk + @mailchk + @countEmail + @countMisc

insert into #tmpcntall (Queue,Online,Callin,Fax,FaxCheck,MailCheck,Mail,Email,InHouse,DPS_InHouse,WebService, IntegratedVendor,Misc,TOTAL)

select @crimLabel, 
(select count(*) from #tmpcnt_crims where deliverymethod like 'Online%'),
(select count(*) from #tmpcnt_crims where deliverymethod = 'Call_In'),
(select count(*) from #tmpcnt_crims where deliverymethod = 'Fax'),
@countFaxChk,
@mailchk,
(select count(*) from #tmpcnt_crims where deliverymethod = 'Mail'),
(select count(*) from #tmpcnt_crims where deliverymethod = 'E-Mail'),
@countInhouse,
@countDps,
(select count(*) from #tmpcnt_crims where deliverymethod = 'WEB SERVICE'),
(select count(*) from #tmpcnt_crims where deliverymethod = 'Integration'),
@countMisc,
@crimTotal;

select * from #tmpcntall

drop table #tmpcnt_online, #tmpcnt_callin, #tmpcnt_fax, #tmpcnt_faxchk, #tmpcnt_mailchk, #tmpcnt_mail, #tmpcnt_email, #tmpcnt_inhouse, #tmpcnt_dps, #tmpcnt_webservice, #tmpcnt_integration, #tmpcnt_misc
drop table #tmpcntall
drop table #tmpcnt_crims



