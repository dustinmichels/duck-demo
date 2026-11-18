SELECT ReportID, ReportDate, LocationID
FROM PotholeReports
WHERE Status = 'Open'
ORDER BY ReportDate ASC;
