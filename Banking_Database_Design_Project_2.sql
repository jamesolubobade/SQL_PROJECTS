use HAZELGREENBANK
--1. Create a view to get all customers with checking account from ON province?
create view VWState as
select CustomerFirstName, CustomerMiddleInitial, CustomerLastName, state, AccountTypeDescription
from Customer c
join Customer_Account ca
on c.CustomerID=ca.CustomerID
join Account a
on ca.AccountID=a.AccountID
join AccountType at
on a.AccountTypeID=at.AccountTypeID
where State= 'ny' And AccountTypeDescription= 'checkingsaccount'
go
select * from VWState
go
--2. Create a view to get all customers with total account balanc (including interest rate) greater than 5000?
create view VWCustomersAcct
as
select c.CustomerID,c.CustomerFirstName+' '+c.CustomerMiddleInitial+' '+c.CustomerLastName [Customer Name],
CurrentBalance,InterestRateValue
from Customer c
join Customer_Account ca
on c.CustomerID = ca.CustomerID
join Account a
on ca.AccountID = a.AccountID
join SavingsInterestRates sir
on a.InterestSavingsRateID=sir.InterestSavingsRateID
where CurrentBalance > 400
go
select * from VWCustomersAcct
go
--3. Create a view to get counts of checking and savings accounts by customer?
create view VWTotalAccountbyCustomer
as
select c.CustomerFirstName+' '+c.CustomerMiddleInitial+' '+c.CustomerLastName [Customer Name],
Count (c.CustomerID) as TotalAccounts 
from Customer c
join Customer_Account ca
on c.CustomerID = ca.CustomerID
join Account a
on ca.AccountID = a.AccountID
join AccountType at
on a.AccountTypeID=at.AccountTypeID
group by c.CustomerFirstName+' '+c.CustomerMiddleInitial+' '+c.CustomerLastName
go
select * from VWTotalAccountbyCustomer
--4. Create a view to get any particular user's login and password using AccountId?
create view VWLoginPassword
as
select distinct UserLogins.UserLogin,UserLogins.UserPassword
from UserLogins
join Login_Account
on UserLogins.UserLoginID = Login_Account.UserLoginID
join Account
on Account.AccountID = Login_Account.AccountID
where Login_Account.AccountID = '50'
go
select *from VWLoginPassword
go
---5. Create a view to get all customers' overdraft amount?
create view VWOverDraft
as
select c.CustomerID,c.CustomerFirstName+' '+c.CustomerMiddleInitial+' '+c.CustomerLastName [Customer Name],OverDraftAmount
from Customer c
join Customer_Account ca
on c.CustomerID = ca.CustomerID
join Account a
on ca.AccountID = a.AccountID
join OverDraftLog odl 
on a.AccountID = odl.AccountID
go
select *from VWOverDraft
--6 create a stored procedure to add "user_" as prefix to everyones login (username).
create proc SPUserPrefix
as
begin
update UserLogins
set UserLogin = 'user_'+ UserLogin
from UserLogins
end
go
exec SPUserPrefix
select *from UserLogins
go
--7 Create a stored procedure that accepts AccountId as a parameter and returns customer's full name?
if exists
(select * from sys.procedures
where Name='SPFullNameFromAccountID')
drop proc SPFullNameFromAccountID
go
create proc SPFullNameFromAccountID  --assigning a name for procedure
@AccountID int,                      --defining input parameter and its data type & dont forget to put "," btw them
@FullName nvarchar(100) output       --defining output parameter & its data type & specifying it as output
as
begin
	if (@AccountID in (select AccountID from Customer_Account))
		begin
			select @FullName=c.CustomerFirstName+' '+c.CustomerMiddleInitial+' '+c.CustomerLastName
			from Customer c
			join Customer_Account ca
			on ca.CustomerID=c.CustomerID
			where ca.AccountID=@AccountID;
		end
	else
		begin
			print 'there is no account with AccountID='+convert(nvarchar(12),@AccountID)
		end
end
go
									 --in my table i have 46 but i dont have 80
									 --executing for valid Account ID
declare @FullName nvarchar(100)
exec SPFullNameFromAccountID 46, @FullName out
print 'Full Name is '+replace (@FullName,'   ',' ')
go
									 --executing for invalid account id
declare @FullName nvarchar(100)
exec SPFullNameFromAccountID 80, @FullName out
print 'Full Name is '+replace (@FullName,'   ',' ')
go
--8. Create a stored procedure that returns error logs inserted in the last 24 hours?
create procedure SP_ErrorLogin
as
begin
select *from LoginErrorLog
where ErrorTime >=Dateadd (hh,-24, getdate())
end
exec SP_ErrorLogin
--9. Create a stored procedure that takes a deposit as a parameter and updates currentbalance value for that particular account
create procedure SPBalanceUpdate
@AccountID int,
@Deposit int
as
begin
select TotalBalance=(CurrentBalance+@deposit)
from Account
where AccountID=@AccountID
end
exec SPBalanceUpdate @AccountID = 46, @deposit = 400
exec SPBalanceUpdate @AccountID = 47, @deposit = 400
exec SPBalanceUpdate @AccountID = 48, @deposit = 400
exec SPBalanceUpdate @AccountID = 49, @deposit = 400
exec SPBalanceUpdate @AccountID = 50, @deposit = 400
--10. Create a stored procedure that takes a withdrawal amount as a parameter and updates?
create procedure SPBalance
@WithdrawalAmount int,
@AccountID int
as
begin
select NewBalance=(CurrentBalance-@WithdrawalAmount)
from Account
where AccountID=@AccountID
end
exec SPBalance @AccountID = 46, @WithdrawalAmount = 150
exec SPBalance @AccountID = 47, @WithdrawalAmount = 150
exec SPBalance @AccountID = 48, @WithdrawalAmount = 150
exec SPBalance @AccountID = 49, @WithdrawalAmount = 150
exec SPBalance @AccountID = 50, @WithdrawalAmount = 150



