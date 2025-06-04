SELECT s.sampleID,CAST(RIGHT(s.sampleID, 6) AS UNSIGNED) FROM NeonSample s
LEFT JOIN omoccurrences o
ON s.occid=o.occid
LEFT JOIN NeonShipment h
ON s.shipmentPK=h.shipmentPK
WHERE o.availability=1
AND CAST(RIGHT(s.sampleID, 6) AS UNSIGNED) BETWEEN 1 AND 1000000 
AND h.shipmentID LIKE 'D%' # update
AND s.sampleClass LIKE 'bet%pin%'
AND o.year = 2019 # update
AND s.sampleID LIKE '%D01%' # update
AND o.collid=39;
