UPDATE omoccurrences o
RIGHT JOIN omoccurdeterminations d
ON o.occid=d.occid
SET o.family=d.family,
o.scientificName=d.sciname,
o.sciname=d.sciname,
o.tidInterpreted=d.tidInterpreted,
o.scientificNameAuthorship=d.scientificNameAuthorship,
o.genus=d.genus,
o.specificEpithet=d.specificEpithet,
o.identifiedBy=d.identifiedBy,
o.dateIdentified=d.dateIdentified,
o.identificationReferences=d.identificationReferences,
o.identificationRemarks=d.identificationRemarks,
o.taxonRemarks=d.taxonRemarks,
o.identificationQualifier=d.identificationQualifier,
o.taxonRank=d.taxonRank
WHERE d.isCurrent=1;
