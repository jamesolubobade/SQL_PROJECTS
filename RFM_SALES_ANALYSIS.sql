--INSPECTING DATASET

select * from [dbo].[sales_dataset]

--CHECKING UNIQUE VALUES

select distinct STATUS from [dbo].[sales_dataset]
select distinct YEAR_ID from [dbo].[sales_dataset]
select distinct PRODUCTLINE from [dbo].[sales_dataset]
select distinct COUNTRY from [dbo].[sales_dataset]
select distinct DEALSIZE from [dbo].[sales_dataset]
select distinct TERRITORY from [dbo].[sales_dataset]

--ANALYSIS

--1. SALES BY PRODUCTLINE

select PRODUCTLINE, sum(sales) as REVENUE
from [dbo].[sales_dataset]
group by PRODUCTLINE
order by 2 desc 

--Based on the output Classic Cars had the highest revenue

--2. SALAES BY YEAR_ID

select YEAR_ID, sum(sales) as REVENUE
from [dbo].[sales_dataset]
group by YEAR_ID
order by 2 desc

--Based on the output the year 2004 recorded the highest revenue.

--Lets check monthly operations:

select distinct MONTH_ID from [dbo].[sales_dataset]
where YEAR_ID = 2003

--Based on the output it show they were in operations through out the year 2003.

select distinct MONTH_ID from [dbo].[sales_dataset]
where YEAR_ID = 2004

--Based on the output it show they were in operations through out the year 2004.

select distinct MONTH_ID from [dbo].[sales_dataset]
where YEAR_ID = 2005

--Based on the output it show they were in operations for only 5 months through out the year 2005.

--3. SALES BY DEALSIZE

select DEALSIZE, sum(sales) as REVENUE
from [dbo].[sales_dataset]
group by DEALSIZE
order by 2 desC

--Based on the output the medium size deals generated the highest revenue.

--4. WHAT WAS THE BEST MONTH FOR SALES IN A SPECIFIC YEAR? HOW MUCH WAS EARNED THAT MONTH?

select MONTH_ID, sum(sales) as REVENUE, count(ORDERNUMBER) Frequency
from [dbo].[sales_dataset]
where YEAR_ID = 2003
group by MONTH_ID
order by 2 desc

--Based on the output November was the best month, with the highest revenue.

select MONTH_ID, sum(sales) as REVENUE, count(ORDERNUMBER) Frequency
from [dbo].[sales_dataset]
where YEAR_ID = 2004
group by MONTH_ID
order by 2 desc

--Based on the output November was also the best month, with the highest revenue.

select MONTH_ID, sum(sales) as REVENUE, count(ORDERNUMBER) Frequency
from [dbo].[sales_dataset]
where YEAR_ID = 2005
group by MONTH_ID
order by 2 desc

--Based on the output May was the best month, with the highest revenue.

--5. WHAT PRODUCT LINE SELLS MOST IN BEST MONTH

select MONTH_ID, PRODUCTLINE, sum(sales) as REVENUE, count(ORDERNUMBER) 
from [dbo].[sales_dataset]
where YEAR_ID = 2003 and MONTH_ID = 11
group by MONTH_ID, PRODUCTLINE
order by 3 desc

--Based on the output Classic Cars sold the most in the month of November.

select MONTH_ID, PRODUCTLINE, sum(sales) as REVENUE, count(ORDERNUMBER) 
from [dbo].[sales_dataset]
where YEAR_ID = 2004 and MONTH_ID = 11
group by MONTH_ID, PRODUCTLINE
order by 3 desc

--Based on the output Classic Cars also sold the most in the month of November.

select MONTH_ID, PRODUCTLINE, sum(sales) as REVENUE, count(ORDERNUMBER) 
from [dbo].[sales_dataset]
where YEAR_ID = 2005 and MONTH_ID = 5
group by MONTH_ID, PRODUCTLINE
order by 3 desc

--Based on the output Classic Cars also sold the most in the month of May.

--6. WHO IS OUR BEST CUSTOMER? (THIS COULD BE BEST ANSWERED WITH RFM)

--RFM ANALYSIS: 
--Recency-Frequency-Monetary (RFM)
--It is an indexing technique that uses past purchase behavior to segment customers.
-- An RFM report is a way of segmenting customers using three key metrics;
    --1. RECENCY: How long ago was their last purchase was?
	--2. FREQUENCY: How often do they purchase?
	--3. MONETARY VALUE: How much do they spend?

--DATA POINTS USED IN RFM ANALYSIS
    --1. RECENCY: Last order date
	--2. FREQUENCY: Count of total orders
	--3. MONETARY VALUE: Total spent

select 
	CUSTOMERNAME,
	sum(sales) MonetaryValue,
	avg(sales) AvgMonetaryValue,
	count(ORDERNUMBER) Frequency,
	max(ORDERDATE) last_order_date
from [dbo].[sales_dataset]
group by CUSTOMERNAME

--Including the Recency
select 
	CUSTOMERNAME,
	sum(sales) MonetaryValue,
	avg(sales) AvgMonetaryValue,
	count(ORDERNUMBER) Frequency,
	max(ORDERDATE) last_order_date,
	(select max(ORDERDATE) from [dbo].[sales_dataset]) max_order_date,
	DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from [dbo].[sales_dataset])) Recency
from [dbo].[sales_dataset]
group by CUSTOMERNAME

--Creating a bucket

;with rfm as
(
	select 
		CUSTOMERNAME,
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from [dbo].[sales_dataset]) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from [dbo].[sales_dataset])) Recency
	from [dbo].[sales_dataset]
	group by CUSTOMERNAME
),
rfm_calc as 
(

select r. *,
	NTILE(4) OVER (order by Recency desc) rfm_recency,
	NTILE(4) OVER (order by Frequency) rfm_frequency,
	NTILE(4) OVER (order by AvgMonetaryValue) rfm_monetary
from rfm r
)
select c. *, rfm_recency + rfm_frequency + rfm_monetary as rfm_cell, --cocatenation
cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary as varchar)rfm_cell_string
from rfm_calc c

--Creating a view

drop table if exists #rfm
;with rfm as
(
	select 
		CUSTOMERNAME,
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from [dbo].[sales_dataset]) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from [dbo].[sales_dataset])) Recency
	from [dbo].[sales_dataset]
	group by CUSTOMERNAME
),
rfm_calc as 
(

select r. *,
	NTILE(4) OVER (order by Recency desc) rfm_recency,
	NTILE(4) OVER (order by Frequency) rfm_frequency,
	NTILE(4) OVER (order by MonetaryValue) rfm_monetary
from rfm r
)
select c. *, rfm_recency + rfm_frequency + rfm_monetary as rfm_cell, --cocatenation
cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary as varchar)rfm_cell_string
into #rfm
from rfm_calc c

select * from #rfm

--Creating a CASE Statement

select CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,
	case
		when rfm_cell_string in (111, 112, 121, 122, 123, 132, 211, 114, 141) then 'lost_customers' --lost customer
		when rfm_cell_string in (133, 134, 143, 144, 244, 334, 343, 344) then 'slipping away, reach out' --Big spenders who haven't purchased lately; slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers' 
		when rfm_cell_string in (222, 223, 322) then 'potential churners' 
		when rfm_cell_string in (323, 333, 321, 422, 332, 432) then 'active' --customers who buy often and recently, but as low points
		when rfm_cell_string in (433, 434, 443) then 'loyal' 
	end rfm_segment

from #rfm

--Based on the above analysis marketing campaign can be used to reach out to the different groups.

--7. WHAT PRODUCT ARE MOST OFTEN SOLD TOGETHER?

select ORDERNUMBER, count(*) rn
from [dbo].[sales_dataset]
where STATUS = 'Shipped'
group by ORDERNUMBER

--select * from [dbo].[sales_dataset] where ORDERNUMBER = 10411
------------------------------------------------------
--Checking for unique values

	select ORDERNUMBER 
	from (
		select ORDERNUMBER, count(*) rn
		from [dbo].[sales_dataset]
		where STATUS = 'Shipped'
		group by ORDERNUMBER
	)m
	where rn = 2

----------------------------------------------------------
--Checking for the product code

select PRODUCTCODE
from [dbo].[sales_dataset]
where ORDERNUMBER in
	(

select ORDERNUMBER 
	from (
		select ORDERNUMBER, count(*) rn
		from [dbo].[sales_dataset]
		where STATUS = 'Shipped'
		group by ORDERNUMBER
	)m
	where rn = 2
	)
-----------------------------------------------------
--Trying to append using xml path

select ',' + PRODUCTCODE
from [dbo].[sales_dataset]
where ORDERNUMBER in
	(

select ORDERNUMBER 
	from (
		select ORDERNUMBER, count(*) rn
		from [dbo].[sales_dataset]
		where STATUS = 'Shipped'
		group by ORDERNUMBER
	)m
	where rn = 2
	)
	for xml path ('')

-------------------------------------------------------------------------
--Convert from xml to a string

select stuff(

(select ',' + PRODUCTCODE
from [dbo].[sales_dataset]
where ORDERNUMBER in
	(

select ORDERNUMBER 
	from (
		select ORDERNUMBER, count(*) rn
		from [dbo].[sales_dataset]
		where STATUS = 'Shipped'
		group by ORDERNUMBER
	)m
	where rn = 2
	)
	for xml path (''))
	, 1, 1, '')

-------------------------------------------------------------------


select OrderNumber, stuff(

(select ',' + PRODUCTCODE
from [dbo].[sales_dataset] p
where ORDERNUMBER in
	(

select ORDERNUMBER 
	from (
		select ORDERNUMBER, count(*) rn
		from [dbo].[sales_dataset]
		where STATUS = 'Shipped'
		group by ORDERNUMBER
	)m
	where rn = 2
	)
	for xml path (''))
	, 1, 1, '')
from [dbo].[sales_dataset] s
-----------------------------------------------------------


select distinct OrderNumber, stuff(

(select ',' + PRODUCTCODE
from [dbo].[sales_dataset] p
where ORDERNUMBER in
	(

select ORDERNUMBER 
	from (
		select ORDERNUMBER, count(*) rn
		from [dbo].[sales_dataset]
		where STATUS = 'Shipped'
		group by ORDERNUMBER
	)m
	where rn = 2
	)
	and p.ORDERNUMBER = s.ORDERNUMBER
	for xml path (''))
	, 1, 1, '') as ProductCodes

from [dbo].[sales_dataset] s
order by 2 desc
-----------------------------------------------------------
--Check if rn is = 3

select distinct OrderNumber, stuff(

(select ',' + PRODUCTCODE
from [dbo].[sales_dataset] p
where ORDERNUMBER in
	(

select ORDERNUMBER 
	from (
		select ORDERNUMBER, count(*) rn
		from [dbo].[sales_dataset]
		where STATUS = 'Shipped'
		group by ORDERNUMBER
	)m
	where rn = 3
	)
	and p.ORDERNUMBER = s.ORDERNUMBER
	for xml path (''))
	, 1, 1, '') as ProductCodes

from [dbo].[sales_dataset] s
order by 2 desc

