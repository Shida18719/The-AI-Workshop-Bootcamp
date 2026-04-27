-- Calculate the number of admissions for each combination of admission type and diagnosis, 
-- then return only the unique admission types with their overall admission counts.

SELECT AdmissionType, COUNT (*) AS total_admission
FROM Admissions
GROUP BY AdmissionType;