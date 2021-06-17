

SELECT * FROM
PortfolioProject.dbo.NashvilleHousing

-- Extracting just the date

SELECT SaleDateConverted,CONVERT(date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing 
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date

Update PortfolioProject.dbo.NashvilleHousing 
SET SaleDateConverted = CONVERT(date,SaleDate)	

--Checking for Null values in PropertyAddress column
SELECT * --ParcelId,PropertyAddress 
from PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null    -- Contains Null Values

-- Populating address with Null Values in Property Address -  By checking the repeated ParcelId's with the ParcelId's with Null values.

SELECT a.ParcelId,a.propertyaddress,b.parcelid,b.propertyaddress,ISNULL(a.propertyaddress,b.propertyaddress)  -- 
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.parcelid  = b.parcelid
	AND a.[uniqueid] <> b.[uniqueid]
WHERE a.propertyaddress is null                         -- The PracelId's with null values have the same PracelId's with the propertyaddress.

-- Populating the values
Update a
SET PropertyAddress = ISNULL(a.propertyaddress,b.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.parcelid  = b.parcelid
	AND a.[uniqueid] <> b.[uniqueid]
WHERE a.propertyaddress is null

-- Breaking Address into Individual Columns( Address, City)
SELECT PropertyAddress 
FROM PortfolioProject.dbo.NashvilleHousing 

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.NashvilleHousing

-- Creating tables to store the address and city data

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- Doing the same thing as above with OwnerAddress but with PARSENAME (city,address,state)

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1) 
FROM PortfolioProject.dbo.NashvilleHousing  -- PARSENAME considers . as the delimiator, REPLACE was used to change , to . -- PARSENAME excecutes from right to left 
											-- thats why 3,2,1.
											
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

Update PortfolioProject.dbo.NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
From PortfolioProject.dbo.NashvilleHousing 

-- Investigate SoldAsVact column
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) 
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant                           -- There are some values as Y and N

-- Changing Y and N to Yes and No respectively

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' then 'No'
	WHEN SoldAsVacant = 'Y' then 'Yes'
	ELSE SoldAsVacant 
	END
FROM PortfolioProject.dbo.NashVilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'N' then 'No'
	WHEN SoldAsVacant = 'Y' then 'Yes'
	ELSE SoldAsVacant 
	END

-- Removing Duplicate Values

WITH abc AS (
SELECT *,
ROW_NUMBER() 
OVER ( PARTITION BY ParcelID,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY UniqueId)
					as row_num
FROM PortfolioProject.dbo.NashvilleHousing
)															-- Query returns row numbers(Eg- 1,2) If more than 1 then there is a duplicate value
--ORDER BY ParcelId)

SELECT * FROM abc
WHERE row_num > 1
Order BY propertyAddress     -- Returns rows with row number more than 1 that are dulplicate values.

-- Drop Unused Columns
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress

SELECT * FROM PortfolioProject.dbo.NashvilleHousing

