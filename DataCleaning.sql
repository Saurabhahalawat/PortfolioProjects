--look into nashvillehousing table
use Portfolio
select * from Nashvillehousing
sp_help Nashvillehousing

--standardizing date column
select Saledate from  Nashvillehousing

alter table Nashvillehousing
add Sale_date date

update Nashvillehousing
set Sale_date = CONVERT(date,SaleDate)

select * from Nashvillehousing

--Populate Property Address data
--finding null values through out the data

select *
from Nashvillehousing
where PropertyAddress is null

--29 observations have null values in property address column
--let's fill null values
--let's find refrence in data to fill these null values

select *
from Nashvillehousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashvillehousing a
join Nashvillehousing b
on a.ParcelID = b.ParcelID
and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashvillehousing a
join Nashvillehousing b
on a.ParcelID = b.ParcelID
and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--spliting Property address column into different columns

select PropertyAddress
from Nashvillehousing

alter table Nashvillehousing
add Street nvarchar(255)

update Nashvillehousing
set Street = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1)

alter table Nashvillehousing
add City nvarchar(255)

update Nashvillehousing
set City= SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

select PropertyAddress,street,city
from Nashvillehousing

--spliting Owners address to different column

select [UniqueID ], ParcelID, OwnerAddress
from Nashvillehousing

alter table Nashvillehousing
add owner_state nvarchar(255)

update Nashvillehousing
set owner_state = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

alter table Nashvillehousing
add owner_city nvarchar(255)

update Nashvillehousing
set owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table Nashvillehousing
add owner_street nvarchar(255)

update Nashvillehousing
set owner_street = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

select OwnerAddress, owner_city,owner_street, owner_state
from Nashvillehousing


-- converting Y and N to Tes and No in soldasvacant column

select distinct[SoldAsVacant], COUNT([SoldAsVacant])
from Nashvillehousing
group by SoldAsVacant
order by 2

select [SoldAsVacant],
	case when [SoldAsVacant]= 'Y' then 'Yes'
		 when [SoldAsVacant]= 'N' then 'No'
		 else [SoldAsVacant]
		 end
from Nashvillehousing

update Nashvillehousing
set [SoldAsVacant] = case when [SoldAsVacant]= 'Y' then 'Yes'
		 when [SoldAsVacant]= 'N' then 'No'
		 else [SoldAsVacant]
		 end
from Nashvillehousing

select distinct[SoldAsVacant], COUNT([SoldAsVacant])
from Nashvillehousing
group by SoldAsVacant
order by 2

--Remove Duplicates
with duplicates as (
select *,
	Row_Number() over (
	PARTITION by [ParcelID],
	[PropertyAddress],[SaleDate],
	[SalePrice],[LegalReference]
	order by [UniqueID ])
	row_num
from Nashvillehousing
)
delete 
from  duplicates
where row_num > 1

--delete unused columns

select * 
from Nashvillehousing

alter table Nashvillehousing
drop column [OwnerAddress],[SaleDate],[PropertyAddress],[TaxDistrict]

-----------------------------------------------------------------------

--Some data analysis

select * from Nashvillehousing

--which city has the highest sale value

select [City] , Avg(SalePrice) as salesPrice
from Nashvillehousing
group by [City]
order by salesPrice desc

-- land distribution according to diffrent type of homes

select LandUse, Avg(Acreage) as Area
from Nashvillehousing
group by LandUse
order by Area desc

select [LandUse], Avg(SalePrice) as salesPrice
from Nashvillehousing
group by [LandUse]
order by salesPrice desc
