CREATE DATABASE HAZELGREENBANK
USE HAZELGREENBANK
CREATE TABLE UserLogins
(UserLoginID int primary key,
UserLogin nvarchar(15),
UserPassword nvarchar(20))
go
insert into UserLogins values
(1,'oyo','ibadan'),
(2,'lagos','ikeja'),
(3,'abuja','fct'),
(4,'ph','rivers'),
(5,'enugu','gra')
go
CREATE TABLE UserSecurityQuestions
(UserSecurityQuestionID int primary key,
UserSecurityQuestion nvarchar(50))
go
insert into UserSecurityQuestions values
(6,'how old are you'),
(7,'where were you born'),
(8,'how many siblings do you have'),
(9,'what is your dads middle name'),
(10,'what is your moms maiden name')
go
CREATE TABLE AccountType
(AcoountTypeID int primary key,
AccountTypeDescription nvarchar(30))
go
insert into AccountType values
(11,'savingsaccount'),
(12,'checkingsaccount'),
(13,'savingsaccount'),
(14,'checkingaccount'),
(15,'savingsaccount')
go
CREATE TABLE SavingsInterestRates
(InterestSavingsRateID int primary key,
InterestRateValue numeric (9,2),
InterestRateDescription nvarchar(50))

go
insert into SavingsInterestRates values
(41,0.99,'annually'),
(42,1.2,'annually'),
(43, 1.4,'annually'),
(44, 1.6,'annually'),
(45, 1.8,'annually')
go
CREATE TABLE AccountStatusTypes
(AccountStatusTypeID int primary key,
AccountStatusDescription nvarchar(30))
go

insert into AccountStatusType values
(16,'active'),
(17,'dormant'),
(18,'active'),
(19,'dormant'),
(20,'active')
go
CREATE TABLE Employee
(EmployeeID int primary key,
EmployeeFirstName nvarchar(30),
EmployeeMiddleInitial nvarchar(1),
EmployeeLastName nvarchar(30),
EmployeeManager bit)
go
insert into Employee values
(21,'james','a','lekejr',1),
(22,'adegboyega','j','olubobade',2),
(23,'adeola','o','anifowose',3),
(24,'adejiire','b','jaden',4),
(25,'oluwatoni','c','joanna',5)
go
select * from Employee
CREATE TABLE TransactionTypes
(TransactionTypeID int primary key,
TransactionTypeName nvarchar(10),
TransactionTypeDescription nvarchar(50),
TransactionFeeAmount smallmoney)
go
insert into TransactionType values
(26,'atm','deposit or withdraw of funds using atm',2.00),
(27,'charge','record a purchase on a credit card',3.00),
(28,'check','withdraw funds by writing a paper check',4.00),
(29,'deposit','add funds to an account by any method',5.00),
(30,'transfer','moving funds within or out of an account',6.00)
go
CREATE TABLE LoginErrorLog
(ErrorLogID int primary key,
ErrorTime datetime,
FailedTransactionXML xml)
go
insert into LoginErrorLog values
(31,'2022-01-01 08:00:00','insufficientfunds'),
(32,'2022-01-02 09:00:02','timeout'),
(33,'2022-01-03 10:00:04','usernameerror'),
(34,'2022-01-04 11:00:06','forgotpassword'),
(35,'2022-01-05 12:00:08','depositamounterror')
go
CREATE TABLE FailedTransactionErrorType
(FailedTransactionErrorTypeID int primary key,
FailedTransactionDescription nvarchar(50))
go
insert into FailedTransactionErrorType values
(36,'expired card'),
(37,'limit exceeded'),
(38,'do not honor'),
(39,'invalid credit card number'),
(40,'invalid expiration date')
go
create table Account
(AccountID int primary key,
CurrentBalance int,
AccountTypeID int,
AccountStatusTypeID int,
InterestSavingsRateID int,
CONSTRAINT FK4_Account_AccountType foreign key (AccountTypeID)
references AccountType (AcoountTypeID),
constraint FK5_Account_AccountStatusType foreign key (AccountStatusTypeID)
references AccountStatusType (AccountStatusTypeID),
constraint FK6_Account_InsterestSavingsRateID foreign key (InterestSavingsRateID)
references SavingsInterestRates (InterestSavingsRateID),)
go
insert into Account values
(46,200.00,11,16,41),
(47,400.00,12,17,42),
(48,600.00,13,18,43),
(49,800.00,14,19,44),
(50,1000.00,15,20,45)
go
create table Customer
(CustomerID int primary key,
CustomerAddress1 nvarchar(30),
CustomerAddress2 nvarchar(30),
CustomerFirstName nvarchar(30),
CustomerMiddleInitial nvarchar(1),
CustomerLastName nvarchar(30),
City nvarchar(20),
State char(2),
ZipCode char(10),
EmailAddress nvarchar(40),
HomePhone char(10), 
CellPhone char(10),
WorkPhone char(10),
SSN char(9),
UserLoginID int,
CONSTRAINT FK2_Customer_UserLogin Foreign Key (UserLoginID)
references UserLogins (UserLoginID),)
go
insert into Customer values
(51,'55 smooth rose court','unit 10','bob','a','john','dallas','tx','2345','bob@gmail.com','4376222925','4384569889','4392345678','123456789',1),
(52,'66 audelia street','unit 20','amy','b','tan','syracuse','ny','5432','amy@yahoo.com','5246292945','5244567885','5342347678','987654321',2),
(53,'24 park avenue','number 30','jack','c','anderson','detroit','mc','5678','jack@gmail.com','9466227692','9464569327','9462378678','246897531',3),
(54,'47 morningside drive','unit 40','susan','d','summers','atlanta','ga','9080','susan@hotmail.com','4167892345','4160985612','4163241918','563789243',4),
(55,'92 don valley way','number 50','david','e','bond','san jose','ca','5632','david@yahoo.com','7034567890','7030988765','7032345678','879456234',5)
go
create table Login_Account
(UserLoginID int,
AccountID int,
CONSTRAINT FK1_Login_Account_UserLogins foreign key (UserLoginID)
references UserLogins (UserLoginID),
constraint FK2_Login_Account_Account foreign key (AccountID)
references Account (AccountID),)
go
insert Login_Account values
(1,46),
(2,47),
(3,48),
(4,49),
(5,50)
go
create table Customer_Account
(AccountID int,
CustomerID int,
CONSTRAINT FK1_Customer_Account_Account foreign key (AccountID)
references Account (AccountID),
constraint FK2_Login_Customer_Account_Customer foreign key (CustomerID)
references Customer (CustomerID),)
go
INSERT into Customer_Account values
(46,51),
(47,52),
(48,53),
(49,54),
(50,55)
go
create table TransactionLog
(TransactionID int primary key,
TransactionDate datetime,
TransactionTypeID int,
TransactionAmount money,
NewBalance money,
AccountID int,
CustomerID int,
EmployeeID int,
UserLoginID int,
CONSTRAINT FK7_TransactionLog_TransactionType foreign key (TransactionTypeID)
references TransactionType (TransactionTypeID),
constraint FK6_TransactionLog_Account foreign key (AccountID)
references Account (AccountID),
constraint FK3_TransactionLog_Customer foreign key (CustomerID)
references Customer (CustomerID),
CONSTRAINT FK4_TransactionLog_Employee foreign key (EmployeeID)
references Employee (EmployeeID),
constraint FK5_TransactionLog_UserLogin foreign key (UserLoginID)
references UserLogins (UserLoginID),)
go
insert into TransactionLog values
(56,'2022-01-06 12:01:00',26,100.00,90.00,46,51,21,1),
(57,'2022-01-07 12:30:01',27,200.00,80.00,47,52,22,2),
(58,'2022-01-08 13:01:02',28,300.00,70.00,48,53,23,3),
(59,'2022-01-09 13:30:03',29,400.00,60.00,49,54,24,4),
(60,'2022-01-10 14:01:04',30,500.00,50.00,50,55,25,5)
go
CREATE table FailedTransactionLog
(FailedTransactionID int primary key,
FailedTransactionErrorTypeID int,
FailedTransactionErrorTime datetime,
FailedTransactionXML xml,
CONSTRAINT FK1_FailedTransactionLog_FailedTransactionErrorType foreign key (FailedTransactionErrorTypeID)
references FailedTransactionErrorType (FailedTransactionErrorTypeID),)
go
insert into FailedTransactionLog values
(61,36,'2022-01-11 05:10:01','depositamounterror'),
(62,37,'2022-01-12 06:20:02','forgotpassword'),
(63,38,'2022-01-13 07:30:03','usernameerror'),
(64,39,'2022-01-14 08:40:04','timeout'),
(65,40,'2022-01-15 09:50:05','insufficientfunds')
go
CREATE TABLE UserSecurityAnswers
(UserLoginID int primary key,
UserSecurityAnswer nvarchar (25),
UserSecurityQuestionID int,
CONSTRAINT FK2_UserSecurityAnswers_UserLogin foreign key (UserLoginID)
references UserLogins (UserLoginID),
constraint FK4_UserSecurityAnswers_UserSecurityQuestion foreign key (UserSecurityQuestionID)
references UserSecurityQuestions (UserSecurityQuestionID),)
go
insert into UserSecurityAnswers values
(1,'forty',6),
(2,'nigeria',7),
(3,'three',8),
(4,'james',9),
(5,'olugbod',10)
go
CREATE TABLE OverDraftLog
(AccountID int primary key,
UserSecurityAnswer nvarchar (25),
OverDraftDate datetime,
OverDraftAmount money,
OverDraftTransactionXML xml,
CONSTRAINT FK1_OverDraftLog_Account foreign key (AccountID)
references Account (AccountID),)
go
insert into OverDraftLog values
(46,'forty','2022-01-15 10:05:05',10.00,'insufficientfunds'),
(47,'nigeria','2022-01-16 11:04:04',20.00,'limitexceeded'),
(48,'three','2022-01-17 12:03:03',30.00,'seefinancialinstitution'),
(49,'james','2022-01-18 13:02:02',40.00,'unabletowithdraw'),
(50,'olugbode','2022-01-19 14:01:01',50.00,'withdrawallimitreached')
go











