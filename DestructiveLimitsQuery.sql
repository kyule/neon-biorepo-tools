SELECT
    *,
    count - reserve AS destructiveLimit
FROM (
    SELECT
        sciName,
        SUBSTRING(locationID,1,4) AS site,
        CASE
            WHEN year <= 2018 THEN 'legacy'
            WHEN year BETWEEN 2019 AND 2021 THEN '1'
            WHEN year BETWEEN 2022 AND 2024 THEN '2'
            WHEN year BETWEEN 2025 AND 2027 THEN '3'
            WHEN year BETWEEN 2028 AND 2030 THEN '4'
            WHEN year BETWEEN 2031 AND 2033 THEN '5'
            WHEN year BETWEEN 2034 AND 2036 THEN '6'
            WHEN year BETWEEN 2037 AND 2039 THEN '7'
            WHEN year BETWEEN 2040 AND 2042 THEN '8'
            WHEN year BETWEEN 2043 AND 2045 THEN '9'
            WHEN year BETWEEN 2046 AND 2048 THEN '10'
            WHEN year >= 2049 THEN 'post'
        END AS cycle,
        COUNT(occid) AS count,
        LEAST(CEILING(COUNT(occid) / 3.0), 5) AS reserve
    FROM omoccurrences
    WHERE collid = 48
    GROUP BY sciName, site, cycle
) x;




