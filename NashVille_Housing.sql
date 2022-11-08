SELECT *
FROM PortfolioProject..Nashvillehousing

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..Nashvillehousing

ALTER TABLE Nashvillehousing
ADD SaleDateConverted DATE;

UPDATE Nashvillehousing
SET SaleDateConverted=CONVERT(Date,SaleDate)

--Populate Property Address data

SELECT *
FROM PortfolioProject..Nashvillehousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..Nashvillehousing a
JOIN PortfolioProject..Nashvillehousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..Nashvillehousing a
JOIN PortfolioProject..Nashvillehousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address,City,State)

SELECT PropertyAddress
FROM PortfolioProject..Nashvillehousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address

FROM PortfolioProject..Nashvillehousing


ALTER TABLE Nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashvillehousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE Nashvillehousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashvillehousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..Nashvillehousing



SELECT OwnerAddress
FROM PortfolioProject..Nashvillehousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..Nashvillehousing



ALTER TABLE Nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashvillehousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashvillehousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashvillehousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashvillehousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashvillehousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject..Nashvillehousing

--Change Y and N to Yes and No in "SoldAsVacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant='Y' THEN 'Yes'
       WHEN SoldAsVacant='N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..Nashvillehousing

UPDATE Nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
       WHEN SoldAsVacant='N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				   UniqueID
				   )row_num
FROM PortfolioProject..Nashvillehousing
--ORDER BY ParcelID
)
SELECT * FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress

--Delete Unused Columns

SELECT *
FROM PortfolioProject..Nashvillehousing

ALTER TABLE PortfolioProject..Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject..Nashvillehousing
DROP COLUMN SaleDate


