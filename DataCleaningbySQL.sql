SELECT *
FROM `Nashville Housing Data for Data Cleaning`;

-- Standardize Date Format

SELECT SaleDate, STR_TO_DATE(SaleDate, '%Y-%m-%d') as date_convert
From `Nashville Housing Data for Data Cleaning` as N ;

ALTER TABLE `Nashville Housing Data for Data Cleaning`
ADD SaleDateConverted Date;

Update `Nashville Housing Data for Data Cleaning`
Set Sale_Date = STR_TO_DATE(SaleDate, '%Y-%m-%d');

-- Populate Property Address data

Select *
FROM `Nashville Housing Data for Data Cleaning`
WHERE PropertyAddress = '';

-- SET EMPTY VALUE BY NULL

Update `Nashville Housing Data for Data Cleaning`
Set OwnerAddress = NULL 
Where OwnerAddress = '';

Update `Nashville Housing Data for Data Cleaning`
Set PropertyAddress = NULL 
Where PropertyAddress = '';

-- DELETE DUPLICATE/NULL VALUE
Select * 
From `Nashville Housing Data for Data Cleaning`
Order by ParcelID;


Select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) 
From `Nashville Housing Data for Data Cleaning` a 
JOIN `Nashville Housing Data for Data Cleaning` b 
	on a.ParcelID=b.ParcelID
	and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

UPDATE `Nashville Housing Data for Data Cleaning` a
JOIN `Nashville Housing Data for Data Cleaning` b 
	on a.ParcelID=b.ParcelID
	and a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress) 
WHERE a.PropertyAddress is NULL;

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, STATE, CITY)

select PropertyAddress
From `Nashville Housing Data for Data Cleaning`;

SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress) - 1) as Address1,
	   SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1, LENGTH(PropertyAddress)) as Address2
FROM `Nashville Housing Data for Data Cleaning`;

ALTER TABLE `Nashville Housing Data for Data Cleaning`
ADD PropertySplitAddress TEXT;

UPDATE `Nashville Housing Data for Data Cleaning`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress) - 1);

ALTER TABLE `Nashville Housing Data for Data Cleaning`
ADD PropertySplitCity TEXT;

UPDATE `Nashville Housing Data for Data Cleaning`
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress) + 1, LENGTH(PropertyAddress));

Select PropertySplitAddress, PropertySplitCity, PropertyAddress
FROM `Nashville Housing Data for Data Cleaning`;

-- Populate Property Address data
SELECT OwnerAddress 
From `Nashville Housing Data for Data Cleaning`;

SELECT 
SUBSTRING_INDEX(OwnerAddress,',',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2), ',', -1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',3), ',', -1)
FROM `Nashville Housing Data for Data Cleaning`;

ALTER TABLE `Nashville Housing Data for Data Cleaning`
ADD OwnerSplitAddress TEXT;

UPDATE `Nashville Housing Data for Data Cleaning`
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress,',',1);

ALTER TABLE `Nashville Housing Data for Data Cleaning`
ADD OwnerSplitCity TEXT;

UPDATE `Nashville Housing Data for Data Cleaning`
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2), ',', -1);

ALTER TABLE `Nashville Housing Data for Data Cleaning`
ADD OwnerSplitState TEXT;

UPDATE `Nashville Housing Data for Data Cleaning`
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',3), ',', -1);

SELECT * 
FROM `Nashville Housing Data for Data Cleaning`;

-- Change Y and N to Yes and No in ''Sold as Vacant' Field

Select DISTINCT(SoldAsVacant), count(SoldAsVacant)
FROM `Nashville Housing Data for Data Cleaning`
GROUP BY 1;

SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
		 END 
FROM `Nashville Housing Data for Data Cleaning`;

UPDATE `Nashville Housing Data for Data Cleaning`
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
		 END;

-- Remove Duplicates

WITH ROW_NUM_CTE AS(
SELECT *, ROW_NUMBER() OVER (
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 Sale_Date,
						 LegalReference
						 ORDER BY 
						 	UniqueID
						 	) row_num 
FROM `Nashville Housing Data for Data Cleaning`)
SELECT * 
FROM ROW_NUM_CTE
WHERE row_num >1;

-- THE MYSQL DO NOT ALLOW ME TO DELETE VALUES FROM CTE SO LET'S USE THE SUBQUERY :D

DELETE FROM `Nashville Housing Data for Data Cleaning`
WHERE UniqueID NOT IN (
						SELECT UniqueID
						FROM(
							SELECT UniqueID, ROW_NUMBER() OVER (
									PARTITION BY ParcelID,
						 			PropertyAddress,
						 			SalePrice,
									Sale_Date,
						 			LegalReference
						 			ORDER BY 
						 				UniqueID
						 					) row_num
						 	FROM `Nashville Housing Data for Data Cleaning`) as ROW_NUM_SUBQUERY
						WHERE row_num = 1);

-- Delete Unsused Columns

SELECT *
FROM `Nashville Housing Data for Data Cleaning`;

ALTER TABLE `Nashville Housing Data for Data Cleaning`
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN SaleDate,
DROP COLUMN SaleDateConverted;
