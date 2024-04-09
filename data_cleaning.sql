
select * from data_cleaning.nh n ;

update data_cleaning.nh
set "PropertyAddress" = a1."PropertyAddress"
from 
(select 
	distinct uniqueid,
	"ParcelID",
	"PropertyAddress"  
from data_cleaning.nh
where trim("PropertyAddress")<> '') a1
where data_cleaning.nh.uniqueid = a1.uniqueid
and data_cleaning.nh."ParcelID" = a1."ParcelID";

select * from

-- i have 10/04/2014 to 2014-04-10
select "SaleDate" saledate ,"SaleDate"::date from data_cleaning.nh n ;
update data_cleaning.nh 
set "SaleDate"  = "SaleDate"::date;


-- populate property address data

-- in this case i have some records that have unique_id is unique but parcell_id are same so on record have have property
-- address but other records that have same parcell_id have propertyaddress = null or blank 
-- so we have to update this 

					
UPDATE data_cleaning.nh a
SET "PropertyAddress" = b."PropertyAddress"
						FROM data_cleaning.nh b 
						WHERE a."ParcelID" = b."ParcelID" AND a.uniqueid <> b.uniqueid 
    					AND TRIM(a."PropertyAddress") = '';

   
    				
-- breaking out address into  individual columns (address,city,state)

select  split_part("PropertyAddress",',',1),
split_part("PropertyAddress",',',2) 
from data_cleaning.nh;

alter table data_cleaning.nh 
add propertysplitaddress varchar(255);
-- update
update data_cleaning.nh 
set propertysplitaddress = split_part("PropertyAddress",',',1);


alter table data_cleaning.nh 
add propertysplitcity varchar(255);

update data_cleaning.nh 
set propertysplitcity = split_part("PropertyAddress",',',2);



select  uniqueid,split_part("OwnerAddress",',',1),
		split_part("OwnerAddress",',',2),
		split_part("OwnerAddress",',',3) 
		from data_cleaning.nh n ;



alter table data_cleaning.nh 
add ownersplitaddress varchar(255);
-- update
update data_cleaning.nh 
set ownersplitaddress = split_part("OwnerAddress",',',1);


alter table data_cleaning.nh 
add ownersplitcity varchar(255);

update data_cleaning.nh 
set ownersplitcity = split_part("OwnerAddress",',',2);

alter table data_cleaning.nh 
add ownersplitstate varchar(255);

update data_cleaning.nh 
set ownersplitstate = split_part("OwnerAddress",',',3);

select * from data_cleaning.nh n ;




-- change Y and N to Yes and No in "Sold ad Vaacant" field

--select distinct("SoldAsVacant"),count(*) from data_cleaning.nh n 
--group by 1;

update data_cleaning.nh 
set "SoldAsVacant" = case
when "SoldAsVacant" ='N' then 'No'
when "SoldAsVacant"= 'Y' then 'Yes'
else "SoldAsVacant" end



-- Remove Duplicates

delete from data_cleaning.nh 
where uniqueid in (
select 
	uniqueid 
	from 
	(select * ,
		row_number() over(
		partition by "ParcelID",
				 	"PropertyAddress" ,
				 	"SaleDate" ,
				 	"SalePrice" ,
				 	"LegalReference" 
				 )row_num
from data_cleaning.nh n 
)a
where row_num>1)




-- Delete unused columns

alter table data_cleaning.nh 
	drop column "PropertyAddress",
	drop column "TaxDistrict",
	drop column "OwnerAddress";



