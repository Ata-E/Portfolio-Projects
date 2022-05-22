/* 

Cleaning data in SQL queries

*/

SELECT * FROM HousingDataCleaning..NashvilleHousing

-- Standardize Date Format

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date

SELECT SaleDate FROM HousingDataCleaning..NashvilleHousing

-- Populate Property Address data

SELECT * FROM HousingDataCleaning..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingDataCleaning..NashvilleHousing a 
JOIN HousingDataCleaning..NashvilleHousing b
ON a.ParcelID=b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingDataCleaning..NashvilleHousing a 
JOIN HousingDataCleaning..NashvilleHousing b
ON a.ParcelID=b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

SELECT PropertyAddress FROM HousingDataCleaning..NashvilleHousing
WHERE PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress FROM HousingDataCleaning..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM HousingDataCleaning..NashvilleHousing

ALTER TABLE HousingDataCleaning..NashvilleHousing 
ADD PropertySplitAddress varchar(200)

UPDATE HousingDataCleaning..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE HousingDataCleaning..NashvilleHousing 
ADD PropertySplitCity varchar(200)

UPDATE HousingDataCleaning..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Doing it in a much easier way


SELECT OwnerAddress FROM HousingDataCleaning..NashvilleHousing


SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
FROM HousingDataCleaning..NashvilleHousing

ALTER TABLE HousingDataCleaning..NashvilleHousing
Add OwnerSplitAddress varchar(200);

Update HousingDataCleaning..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE HousingDataCleaning..NashvilleHousing
Add OwnerSplitCity varchar(200);

Update HousingDataCleaning..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE HousingDataCleaning..NashvilleHousing
Add OwnerSplitState varchar(200);

Update HousingDataCleaning..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From HousingDataCleaning..NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingDataCleaning..NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END
FROM HousingDataCleaning..NashvilleHousing

UPDATE HousingDataCleaning..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END



-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			   UniqueID) as row_num

FROM HousingDataCleaning..NashvilleHousing
)
-- DELETE FROM RowNumCTE
SELECT * FROM RowNumCTE
WHERE row_num>1


--Delete Unused Columns

SELECT *
FROM HousingDataCleaning..NashvilleHousing

ALTER TABLE HousingDataCleaning..NashvilleHousing
DROP COLUMN SaleDate