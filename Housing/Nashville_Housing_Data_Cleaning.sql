/*
================================================================================
  Portfolio Project: Nashville Housing Data Cleaning
  Platform: Google Cloud Platform (BigQuery Standard SQL)
================================================================================
*/


-- Step 1: Initial Inspection
Select * From Housing.nashHousing 
Limit 5;


-- Step 2: Standardize / Inspect Sale Date
Select SaleDate From Housing.nashHousing Limit 10;



-- Step 3: Populate Missing Property Address Data
-- Using a Self-Join on ParcelID to populate NULL addresses from duplicate property records 
CREATE OR REPLACE TABLE `Housing.nashHousing` AS
SELECT 
  a.`UniqueID `,
  a.ParcelID,
  IFNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress,
  a.LandUse,
  a.SaleDate,
  a.SalePrice,
  a.LegalReference,
  a.SoldAsVacant,
  a.OwnerName,
  a.OwnerAddress,
  a.Acreage,
  a.TaxDistrict,
  a.LandValue,
  a.BuildingValue,
  a.TotalValue,
  a.YearBuilt,
  a.Bedrooms,
  a.FullBath,
  a.HalfBath
FROM `Housing.nashHousing` AS a
LEFT JOIN `Housing.nashHousing` AS b
  ON a.ParcelID = b.ParcelID
  AND a.`UniqueID ` != b.`UniqueID `
  AND b.PropertyAddress IS NOT NULL;




-- Step 4: Breaking Down PropertyAddress into Individual Columns (Address, City)
Create or Replace Table `Housing.nashHousing` as 
Select
    * Except(PropertyAddress),
    PropertyAddress,
    Trim(SPLIT(PropertyAddress, ',')[SAFE_OFFSET(0)]) as PropretyAdress,
    Trim(SPLIT(PropertyAddress, ',')[SAFE_OFFSET(1)]) as PropretyCity
From `Housing.nashHousing`;



Select OwnerAddress 
From `Housing.nashHousing`
limit 5;


-- Step 5: Breaking Down OwnerAddress into Individual Columns (Address, City, State)
Create or Replace Table `Housing.nashHousing` as 

SELECT 
  * Except(OwnerAddress),
  OwnerAddress,
  TRIM(SPLIT(OwnerAddress, ',')[SAFE_OFFSET(0)]) AS OwnerSplitAddress,
  TRIM(SPLIT(OwnerAddress, ',')[SAFE_OFFSET(1)]) AS OwnerSplitCity,
  TRIM(SPLIT(OwnerAddress, ',')[SAFE_OFFSET(2)]) AS OwnerSplitState
FROM `Housing.nashHousing`;




-- Step 6: Seeing duplicates before removing it 
WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
      ORDER BY `UniqueID `
    ) AS row_num
  FROM `Housing.nashHousing`
)
SELECT *
FROM RowNumCTE
where row_num > 1
ORDER BY PropertyAddress;




-- Step 6: Remove Duplicate Records Using CTE and ROW_NUMBER()

CREATE OR REPLACE TABLE `Housing.nashHousing` AS
WITH RowNumCTE AS (
  SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY ParcelID,
                   PropertyAddress,
                   SalePrice,
                   SaleDate,
                   LegalReference
      ORDER BY `UniqueID `
    ) AS row_num
  FROM `Housing.nashHousing`
)
SELECT 
  * EXCEPT(row_num) -- Excludes the temporary row_num column from the final table
FROM RowNumCTE
WHERE row_num = 1;



-- Step 7: Remove Redundant and Unused Columns
CREATE OR REPLACE TABLE `Housing.nashHousing` AS
SELECT 
  * EXCEPT(PropertyAddress, OwnerAddress, TaxDistrict)
FROM `Housing.nashHousing`;
