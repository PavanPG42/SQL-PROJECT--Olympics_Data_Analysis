use zepto;
-- imported data through vizard
select * from Zepto_v2;

ALTER TABLE zepto_v2
ADD COLUMN sku_id INT AUTO_INCREMENT PRIMARY KEY;

SET SQL_SAFE_UPDATES = 0;
-- check weather mrp is 0
select mrp from Zepto_v2 
where mrp=0;


-- data cleaning
delete from zepto_v2
where mrp=0;

-- converting the datatype of the colunm
ALTER TABLE zepto_v2 
MODIFY COLUMN mrp NUMERIC(8,2),
MODIFY COLUMN discountedSellingPrice NUMERIC(8,2);
SET SQL_SAFE_UPDATES = 0;

-- convert prise to rupees
update zepto_v2
set discountedSellingPrice= discountedSellingPrice/100.0,
mrp=mrp/100.0;

select mrp, discountedSellingPrice from zepto_v2;


-- to check the data type of the data
DESCRIBE zepto_v2;


select * from Zepto_v2;

-- Q1.Find the top 10 best_value profucts based on the discount percentage 
 select name, discountPercent from Zepto_v2
 order by discountPercent desc limit 10;


-- Q2.What are the Products with High MRP but Out of Stock
select name,mrp from  Zepto_v2
where outOfStock="TRUE" and mrp>300
order by mrp desc;


-- Q3.Calculate Estimated Revenue for each category
select category, discountedSellingPrice as revenu from Zepto_v2
group by  category, discountedSellingPrice;

