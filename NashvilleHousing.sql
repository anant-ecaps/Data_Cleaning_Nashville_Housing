 -- Cleaning Data

SELECT * 
FROM NashvilleHousingProject.dbo.NashvilleHousingData

--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousingProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingProject.dbo.NashvilleHousingData
SET SaleDate=CONVERT(Date,SaleDate)


-- ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousingData
-- Add SaleDateConverted Date;

-- Update NashvilleHousingProject.dbo.NashvilleHousingData
-- SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

SELECT *
FROM NashvilleHousingProject.dbo.NashvilleHousingData
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingProject.dbo.NashvilleHousingData a
JOIN NashvilleHousingProject.dbo.NashvilleHousingData b
ON a.ParcelID=b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingProject.dbo.NashvilleHousingData a
JOIN NashvilleHousingProject.dbo.NashvilleHousingData b
ON a.ParcelID=b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousingProject.dbo.NashvilleHousingData

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousingProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousingData
ADD PropertySplitAddress NVARCHAR(255);

Update NashvilleHousingProject.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousingData
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousingProject.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM NashvilleHousingProject.dbo.NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousingProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousingData
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousingProject.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousingData
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousingProject.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousingData
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousingProject.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingProject.dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
WHEN SoldAsVacant= 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousingProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingProject.dbo.NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
WHEN SoldAsVacant= 'N' THEN 'No'
ELSE SoldAsVacant
END

--------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates (If records have same ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference then they are duplicate)

WITH RowNumCTE
AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num
FROM NashvilleHousingProject.dbo.NashvilleHousingData
)
DELETE
FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress

--------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
FROM NashvilleHousingProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict