/* 
Cleaning Data in SQL querries
*/


-- looking at imported Data

SELECT *
FROM Data_Cleaning_Project..Nashville_Housing_data





-- Standardize Date Format

ALTER TABLE Data_Cleaning_Project..Nashville_Housing_data
ALTER COLUMN SaleDate date;

SELECT SaleDate
FROM Data_Cleaning_Project..Nashville_Housing_data








--Populate property Address Data
-- Add data where property address is null

SELECT *
FROM Data_Cleaning_Project..Nashville_Housing_data
WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Data_Cleaning_Project..Nashville_Housing_data a
	JOIN Data_Cleaning_Project..Nashville_Housing_data b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Data_Cleaning_Project..Nashville_Housing_data a
	JOIN Data_Cleaning_Project..Nashville_Housing_data b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null







--Breaking Out Property Address into Individual Columns(Address,City,State)

SELECT PropertyAddress
FROM Data_Cleaning_Project..Nashville_Housing_data


SELECT 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) As Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress)) AS City
FROM Data_Cleaning_Project..Nashville_Housing_data




ALTER TABLE Nashville_Housing_data
ADD Property_Split_Address Nvarchar(255);

UPDATE  Data_Cleaning_Project..Nashville_Housing_data
SET Property_Split_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1)




ALTER TABLE Nashville_Housing_data
ADD Property_Split_City Nvarchar(255);

UPDATE  Data_Cleaning_Project..Nashville_Housing_data
SET Property_Split_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress))



SELECT PropertyAddress,Property_Split_Address,Property_Split_City
FROM Data_Cleaning_Project..Nashville_Housing_data








--Breaking Out Owner Address into Individual Columns(Address,City,State)


SELECT OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM Data_Cleaning_Project..Nashville_Housing_data



ALTER TABLE Data_Cleaning_Project..Nashville_Housing_data
ADD Owner_Split_Address nvarchar(255);

UPDATE Data_Cleaning_Project..Nashville_Housing_data
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)




ALTER TABLE Data_Cleaning_Project..Nashville_Housing_data
ADD Owner_Split_City nvarchar(255);

UPDATE Data_Cleaning_Project..Nashville_Housing_data
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)




ALTER TABLE Data_Cleaning_Project..Nashville_Housing_data
ADD Owner_Split_State nvarchar(255);

UPDATE Data_Cleaning_Project..Nashville_Housing_data
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



SELECT OwnerAddress,Owner_Split_Address,Owner_Split_City,Owner_Split_State
FROM Data_Cleaning_Project..Nashville_Housing_data








--Change Y and N to yes and No is Sold as Vacant field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM Data_Cleaning_Project..Nashville_Housing_data
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
		CASE 
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		END
FROM Data_Cleaning_Project..Nashville_Housing_data

UPDATE Data_Cleaning_Project..Nashville_Housing_data
SET SoldAsVacant = CASE 
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		END






-- Remove Duplicates


WITH RowNumCTE AS
(
SELECT *,
ROW_NUMBER()
	OVER(PARTITION BY ParcelID,
					  PropertyAddress,
					  SaleDate,
					  LegalReference
			ORDER BY UniqueID) Row_Num
FROM Data_Cleaning_Project..Nashville_Housing_data
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress


SELECT *
FROM Data_Cleaning_Project..Nashville_Housing_data






-- Delete Unused Column

SELECT *
FROM Data_Cleaning_Project..Nashville_Housing_data

ALTER TABLE Data_Cleaning_Project..Nashville_Housing_data
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress

-- Data is Cleaned and ready for analysis