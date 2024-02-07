/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT (Date, SaleDate) 
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate) 


-- If it doesn't Update properly


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate) 


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null


--property address missed in some rows although sharing same id. Goal now is to copy existing info into missing property address cells if id is the same
--use function ISNULL(woher, wohin)


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

-- result: unnamed column  with he copied address, which it'll replace the first propertyaddress first, a.

-- when using update in join, we must write the table alias (a) and not full name (nashville):


UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
--Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID]<> b.[UniqueID]
Where a.PropertyAddress is null

--run query, then to check that there are not null values:

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) / Substring + CHARINDEX (last looks for words, signs, spicific values) 
--How? CHARINDEX ('word', which table) [easier than SUBSTRING->PARSENAME]


Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

--delimiter in address is a comma, separating address, city and we need to get rid of it. next query means: 
--looks in (PropertyAddress, begins count from value 1 and stops at the comma).

Select
SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing


-- Result includes the comma, we need to avoid this. We change this though. 
--1st, in which value is the comma:

Select
SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress)) as Address,
  CHARINDEX(',',PropertyAddress)
From PortfolioProject..NashvilleHousing

--without COMMA:

Select
SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
From PortfolioProject..NashvilleHousing

--now separate address from city and no comma:

Select
SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

-- we add -1 for it to read it BEFORE the comma, and +1, AFTER the comma..

--now we create two collums with last query's info, meaning, address (SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) )
--and city (PropertyAddress, CHARINDEX(',',PropertyAddress)+1)

--add address to table:
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

--adding results to table:
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

--add city to table:
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

--adding results to table:
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


--check:

Select *
From PortfolioProject.dbo.NashvilleHousing


--let's try another way. We'll use OwnerAddress (address, city y state):

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


--Parsename: goo when delimiter is a full stop

Select
PARSENAME (OwnerAddress,1)
From PortfolioProject.dbo.NashvilleHousing

--here delimiter is a comma though. In this case, we replace coma for a full stop and THEN run parsename query:

Select
PARSENAME (REPLACE(OwnerAddress,',', '.') ,1) --looks for state (reads from back to forth)
, PARSENAME (REPLACE(OwnerAddress,',', '.') ,2) --looks for city
, PARSENAME (REPLACE(OwnerAddress,',', '.') ,3) --looks for address
From PortfolioProject.dbo.NashvilleHousing

--we want the opposite thought (address, city , state):

Select
PARSENAME (REPLACE(OwnerAddress,',', '.') ,3) 
, PARSENAME (REPLACE(OwnerAddress,',', '.') ,2) 
, PARSENAME (REPLACE(OwnerAddress,',', '.') ,1) 
From PortfolioProject.dbo.NashvilleHousing


-- we create columns and then add the new values separated:


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

--adding results to table:
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',', '.') ,3) 

--we add the city table:
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

--adding results to table:
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',', '.') ,2) 


--we add the state table:
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

--adding results to table:
Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',', '.') ,1)




--check:

Select *
From PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

--change the remaining Y and N to yes and no:

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

--we add results to table:

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- check:

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
Order By ParcelID

--this query results in almost all 1, with some exceptions. z.B. row 18043+18044, excetp unique id, all info is identical:

Select *
From PortfolioProject.dbo.NashvilleHousing

--we want to locate the duplicated ones:

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
Order By ParcelID
Where row_num > 1

--but this last query does not work. For it to work, we need to create a temporary CTE table:

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE



WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProject.DBO.NashvilleHousing

--Let's delete duplicates:

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject.DBO.NashvilleHousing

ALTER TABLE PortfolioProject.DBO.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject.DBO.NashvilleHousing
DROP COLUMN SaleDate