
--CLEANING DATA IN SQL

select * 
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

--STANDARDIZED DATA FORMAT

select SaleDate, convert(date,SaleDate)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

Update NASHVILLE_HOUSING
set SaleDate = convert(date,SaleDate)

--Then check if it worked by running this code again: 

select SaleDate, convert(date,SaleDate)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

--NOTE: It did not work so I'm going to try this code below:

alter table NASHVILLE_HOUSING
add SaleDatrConverted Date;

Update NASHVILLE_HOUSING
SET SaleDatrConverted = CONVERT(Date,SaleDate)

select SaleDatrConverted, convert(date,SaleDate)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

----------------------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA

select PropertyAddress
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

--Check for NULL

select PropertyAddress
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING
where PropertyAddress is null


select *
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a .PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING a
join PORTFOLIO_PROJECT..NASHVILLE_HOUSING b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING a
join PORTFOLIO_PROJECT..NASHVILLE_HOUSING b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select a.ParcelID, a .PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING a
join PORTFOLIO_PROJECT..NASHVILLE_HOUSING b
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

select PropertyAddress
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING
--where PropertyAddress is null
--order by ParcelID

--This is how to remove the comma's:
select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
From PORTFOLIO_PROJECT..NASHVILLE_HOUSING

--Creating 2 more column:

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) +1 , len(PropertyAddress)) as Address
From PORTFOLIO_PROJECT..NASHVILLE_HOUSING

alter table NASHVILLE_HOUSING
add PropertySplitAddress Nvarchar(255);

Update NASHVILLE_HOUSING
SET  PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table NASHVILLE_HOUSING
add PropertySplitCity Nvarchar(255);

Update NASHVILLE_HOUSING
SET  PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) 

--Checking the new 2 colums:
select *
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

-------------------------------------------------------------------------------------------------------------------

--SPLITTING THE OWNERS ADDRESS

select OwnerAddress
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING


--Include periods instead of comma's
select 
parsename(replace(OwnerAddress, ',', '.') ,1)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING


select
parsename(replace(OwnerAddress, ',', '.') , 3)
,parsename(replace(OwnerAddress, ',', '.') , 2)
,parsename(replace(OwnerAddress, ',', '.') , 1)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

-- Adding new columns

alter table NASHVILLE_HOUSING
add OwnerSplitAddress Nvarchar(255);

Update NASHVILLE_HOUSING
SET  OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') , 3)

alter table NASHVILLE_HOUSING
add OwnerSplitCity Nvarchar(255);

Update NASHVILLE_HOUSING
SET  OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') , 2) 

alter table NASHVILLE_HOUSING
add OwnerSplitState Nvarchar(255);

Update NASHVILLE_HOUSING
SET  OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') , 1) 

select *
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

-----------------------------------------------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD:

--First check the column;

select Distinct(SoldAsVacant)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

--OR

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING
Group by SoldAsVacant
--Order by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING

Update NASHVILLE_HOUSING
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PORTFOLIO_PROJECT..NASHVILLE_HOUSING
Group by SoldAsVacant
Order by 2

---------------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES

with RowNumCTE AS (
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				  UniqueID
				  ) row_num

from PORTFOLIO_PROJECT..NASHVILLE_HOUSING
--order by ParcelID
)
--Select * 
--from RowNumCTE

-----------------------------------------------------------
select *
from RowNumCTE
Where row_num > 1
order by PropertyAddress


----------------------------------------------
--removing duplicates

with RowNumCTE AS (
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				  UniqueID
				  ) row_num

from PORTFOLIO_PROJECT..NASHVILLE_HOUSING
--order by ParcelID
)
delete
from RowNumCTE
Where row_num > 1
--order by PropertyAddress

---------------------------------------------------
--checking if there is any duplicate;

with RowNumCTE AS (
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				  UniqueID
				  ) row_num

from PORTFOLIO_PROJECT..NASHVILLE_HOUSING
--order by ParcelID
)
select *
from RowNumCTE
Where row_num > 1
Order by PropertyAddress

----------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

Select *
From PORTFOLIO_PROJECT..NASHVILLE_HOUSING

--dropping columns

alter table PORTFOLIO_PROJECT..NASHVILLE_HOUSING
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

alter table PORTFOLIO_PROJECT..NASHVILLE_HOUSING
DROP COLUMN SaleDate

--check if the columns were dropped

Select *
From PORTFOLIO_PROJECT..NASHVILLE_HOUSING



