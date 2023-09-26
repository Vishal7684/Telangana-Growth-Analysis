use telangana;
show tables;

#Q1. How does the revenue generated from document registration vary across districts in Telangana?
# List down the top 5 districts that showed the highest document registration revenue growth between FY 2019 and 2022.
with fy19 as
(SELECT district,sum(documents_registered_rev) d1 
FROM fact_stamps join dim_date using (month) join dim_districts using (dist_code) 
where fiscal_year=2019 group by district), 
fy22 as
(SELECT district,sum(documents_registered_rev) d2
FROM fact_stamps join dim_date using (month) join dim_districts using (dist_code) 
where fiscal_year=2022 group by district)
select district,growth_rate from
(select (district),concat(round((pow((d2/d1),0.25)-1)*100,2),"%") growth_rate,round((pow((d2/d1),0.25)-1)*100,2) ord
from fy19 join fy22 using (district) order by ord desc) a limit 5




#2. How does the money from e-stamp challans compare to document registration money in districts? List the top 5 districts where e-stamp revenue is 
#significant in 2022.
SELECT 
    d.district AS Districs,
    SUM(f.documents_registered_rev) AS Total_Documents_Revenue, SUM(f.estamps_challans_rev) as Total_eStamps_Revenue, 
    SUM(f.estamps_challans_rev) - sum(f.documents_registered_rev) as Revenue_Diffrence
FROM
    dim_districts d
        JOIN
    fact_stamps f ON d.dist_code = f.dist_code
WHERE
    YEAR(f.month) = 2022
GROUP BY d.district
ORDER BY Total_eStamps_Revenue DESC
LIMIT 5;

SELECT 
    d.district AS District,
    SUM(f.documents_registered_rev) AS Total_Document_Revenue,
    SUM(f.estamps_challans_rev) AS Total_Estamp_Revenue
FROM
    dim_districts d
        JOIN
    fact_stamps f ON d.dist_code = f.dist_code
WHERE
    f.estamps_challans_rev > f.documents_registered_rev
        AND YEAR(f.month) = 2022
GROUP BY District
ORDER BY Total_Estamp_Revenue DESC
LIMIT 5;
 

SELECT 
    YEAR(month) AS Year,
    SUM(documents_registered_cnt) AS Total_Document_Registration_cnt
FROM
    fact_stamps
WHERE
    YEAR(month) != 2019
        AND YEAR(month) != 2023
        AND YEAR(month) != 2020
GROUP BY YEAR(month)
ORDER BY YEAR(month);
SELECT 
    *
FROM
    fact_stamps;




#4. Divide districts into three groups based on stamp registration revenue from 2021 to 2022
WITH Category AS (
    SELECT
        d.district AS Districts,
        SUM(f.documents_registered_rev) AS Revenue,
        NTILE(3) OVER (ORDER BY SUM(f.documents_registered_rev) DESC) AS Categories
    FROM fact_stamps f
    JOIN dim_date USING (month)
    JOIN dim_districts d USING (dist_code)
    WHERE fiscal_year BETWEEN 2021 AND 2022
    GROUP BY Districts
)
SELECT
    Districts,
    Revenue,
    MAX(CASE WHEN Categories = 1 THEN Districts END) AS High_Revenue_Group,
    MAX(CASE WHEN Categories = 2 THEN Districts END) AS Moderate_Revenue_Group,
    MAX(CASE WHEN Categories = 3 THEN Districts END) AS Low_Revenue_Group
FROM Category
GROUP BY Districts, Revenue, Categories;



SELECT 
    d.district AS Districts,
    SUM(t.vehicleClass_MotorCycle) AS Two_wheeler,
    SUM(t.vehicleClass_MotorCar) AS Four_wheeler,
    SUM(t.vehicleClass_AutoRickshaw) AS Three_wheeler,
    SUM(t.vehicleClass_Agriculture) AS Agriculture_vehicles,
    SUM(t.vehicleClass_others) AS Other
FROM
    fact_transport t
        JOIN
    dim_districts d ON t.dist_code = d.dist_code
GROUP BY Districts;



#7. List down the top 3 and bottom 3 districts that have shown the highest and lowest vehicle sales growth during FY 2022 compared to FY 2021? 
#(Consider and compare categories: Petrol, Diesel and Electric) 
WITH fy2021 AS (
    SELECT
        SUM(t.fuel_type_petrol + t.fuel_type_diesel + t.fuel_type_electric) as Total_Sales_2021,
        d.district as Districts,
        EXTRACT(YEAR FROM t.month) as Year
    FROM
        fact_transport t
    JOIN
        dim_districts d
    USING (dist_code)
    WHERE
        EXTRACT(YEAR FROM t.month) = 2021
    GROUP BY
        d.district, Year
),

-- Create CTE for FY 2022
fy2022 AS (
    SELECT
        SUM(t.fuel_type_petrol + t.fuel_type_diesel + t.fuel_type_electric) as Total_Sales_2022,
        d.district as Districts,
        EXTRACT(YEAR FROM t.month) as Year
    FROM
        fact_transport t
    JOIN
        dim_districts d
    USING (dist_code)
    WHERE
        EXTRACT(YEAR FROM t.month) = 2022
    GROUP BY
        d.district, Year
)

-- Main Query to Compare FY 2021 and FY 2022 Sales
SELECT
    fy2021.Districts,
    fy2021.Total_Sales_2021,
    fy2022.Total_Sales_2022,
    ROUND(((fy2022.Total_Sales_2022 - fy2021.Total_Sales_2021) / fy2021.Total_Sales_2021) * 100, 2) AS Sales_Growth
FROM
    fy2021
JOIN
    fy2022
ON
    fy2021.Districts = fy2022.Districts
ORDER BY
    Sales_Growth DESC
LIMIT 3;

#10. Is there any relationship between district investments, vehicles sales and stamps revenue within the same district between FY 2021 and 2022?
With Investment(
SELECT
    d.district AS District,
    d2.fiscal_year AS Year,
    SUM(`investment in cr`) AS Investment_in_rupees
FROM
    fact_ts_ipass f
JOIN
    dim_districts d
USING
    (dist_code)
Join dim_date d2
Using(month)
WHERE
    d2.fiscal_year BETWEEN 2021 AND 2022
GROUP BY
    Year, District
ORDER BY
    Investment_in_rupees desc
LIMIT 5;

#11. Are there any particular sectors that have shown substantial
#investment in multiple districts between FY 2021 and 2022?
SELECT
    sector,
    district,
    SUM(`investment in cr`) AS Total_Investment
FROM
    fact_TS_iPASS
WHERE
    fiscal_year BETWEEN 2021 AND 2022
GROUP BY
    sector, district
ORDER BY
    sector, Total_Investment DESC;

SELECT 
    d.district AS Districts,
    SUM(f.documents_registered_rev) AS Revenue
FROM
    dim_districts d
        JOIN
    fact_stamps f ON d.dist_code = f.dist_code
GROUP BY Districts
ORDER BY Revenue DESC;



WITH Category AS (
    SELECT
        d.district AS Districts,
        SUM(f.documents_registered_rev) AS Revenue,
        NTILE(3) OVER (ORDER BY SUM(f.documents_registered_rev) DESC) AS Categories
    FROM fact_stamps f
    JOIN dim_date USING (month)
    JOIN dim_districts d USING (dist_code)
    WHERE fiscal_year BETWEEN 2021 AND 2022
    GROUP BY Districts
)
SELECT
    Districts,
    Revenue,
    MAX(CASE WHEN Categories = 1 THEN Districts END) AS High_Revenue_Group,
    MAX(CASE WHEN Categories = 2 THEN Districts END) AS Moderate_Revenue_Group,
    MAX(CASE WHEN Categories = 3 THEN Districts END) AS Low_Revenue_Group
FROM Category
GROUP BY Districts, Revenue, Categories;





