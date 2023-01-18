--Populate (missing) Property Address Data 

SELECT uniqueid
FROM nashvillehousing
--WHERE propertyaddress IS NULL
ORDER BY parcelid;

SELECT a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress, COALESCE(a.propertyaddress,b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b
	ON a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

UPDATE nashvillehousing a
SET propertyaddress = b.propertyaddress
FROM nashvillehousing b
WHERE a.parcelid = b.parcelid
  AND a.uniqueid <> b.uniqueid
  AND a.propertyaddress IS NULL;
  
SELECT *
FROM nashvillehousing;

--Breaking out address into individual columns (Address, City, State)

SELECT propertyaddress
FROM nashvillehousing;

SELECT 
SUBSTRING(propertyaddress, 1, strpos(propertyaddress, ',')-1)AS address,
split_part(propertyaddress,',', 2) AS city
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD propertysplitaddress varchar(255);

UPDATE nashvillehousing
SET propertysplitaddress = SUBSTRING(propertyaddress, 1, strpos(propertyaddress, ',')-1);

ALTER TABLE nashvillehousing
ADD propertysplitcity varchar(255);

UPDATE nashvillehousing
SET propertysplitcity = split_part(propertyaddress,',', 2);


SELECT owneraddress
FROM nashvillehousing;

SELECT 
SUBSTRING(owneraddress, 1, strpos(owneraddress, ',')-1)AS address,
split_part(owneraddress,',', 2) AS city,
split_part(owneraddress,',', 3) AS state
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD ownersplitaddress varchar(255);

UPDATE nashvillehousing
SET ownersplitaddress = SUBSTRING(owneraddress, 1, strpos(owneraddress, ',')-1);

ALTER TABLE nashvillehousing
ADD ownersplitcity varchar(255);

UPDATE nashvillehousing
SET ownersplitcity = split_part(owneraddress,',', 2);

ALTER TABLE nashvillehousing
ADD ownersplitstate varchar(255);

UPDATE nashvillehousing
SET ownersplitstate = split_part(owneraddress,',', 3)  ;


--Change Y and N to Yes and No in "Sold as Vacant" field 

SELECT DISTINCT(soldasvacant),COUNT(soldasvacant) 
FROM nashvillehousing 
GROUP BY soldasvacant
ORDER BY 2

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 WHEN soldasvacant = 'N' THEN 'No'
	 ELSE soldasvacant
	 END
FROM nashvillehousing; 


UPDATE nashvillehousing
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	 WHEN soldasvacant = 'N' THEN 'No'
	 ELSE soldasvacant
	 END;
	 
-- Delete Unused Columns 

SELECT *
FROM nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN owneraddress, 
DROP COLUMN	taxdistrict, 
DROP COLUMN	propertyaddress

	 
