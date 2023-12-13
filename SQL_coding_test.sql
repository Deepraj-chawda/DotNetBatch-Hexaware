
--Coding Challenge SQL Crime Management 
--Submitted BY DEEPRAJ CHAWDA 

--Creating database
CREATE DATABASE CrimeManagement;

USE CrimeManagement;

--Creating tables

CREATE TABLE Crime (
    CrimeID INT PRIMARY KEY,
    IncidentType VARCHAR(255),
    IncidentDate DATE,
    Location VARCHAR(255),
    Description TEXT,
    Status VARCHAR(20)
);


CREATE TABLE Victim (
    VictimID INT PRIMARY KEY,
    CrimeID INT,
    Name VARCHAR(255),
    ContactInfo VARCHAR(255),
    Injuries VARCHAR(255),
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

CREATE TABLE Suspect (
    SuspectID INT PRIMARY KEY,
    CrimeID INT,
    Name VARCHAR(255),
    Description TEXT,
    CriminalHistory TEXT,
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

-- Insert sample data 
INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status) VALUES
    (1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
    (2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under Investigation'),
    (3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');

INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries) VALUES
    (1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'),
    (2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'),
    (3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None');

INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory) VALUES
    (1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'),
    (2, 2, 'Unknown', 'Investigation ongoing', NULL),
    (3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests');


--Query 1
--Select all open incidents

SELECT * FROM Crime WHERE Status = 'Open';


--Query 2
--Find the total number of incidents

SELECT COUNT(*) AS TotalNumberOfIncidents FROM Crime;


--Query 3
--List all unique incident types

SELECT DISTINCT IncidentType FROM Crime;


--Query 4
--Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'

SELECT * FROM Crime WHERE IncidentDate BETWEEN '2023-09-01' AND '2023-09-10';


--Query 5
-- Add Age column to Victim table
ALTER TABLE Victim ADD Age INT;

-- Add Age column to Suspect table
ALTER TABLE Suspect ADD Age INT;

-- Update sample data with Age information
UPDATE Victim SET Age = 25 WHERE VictimID = 1; 
UPDATE Victim SET Age = 30 WHERE VictimID = 2; 
UPDATE Victim SET Age = 22 WHERE VictimID = 3; 

UPDATE Suspect SET Age = 28 WHERE SuspectID = 1; 
UPDATE Suspect SET Age = 35 WHERE SuspectID = 2;
UPDATE Suspect SET Age = 40 WHERE SuspectID = 3; 

-- List persons involved in incidents in descending order of age
SELECT Name, Age, 'Victim' AS Role FROM Victim
UNION
SELECT Name, Age, 'Suspect' AS Role FROM Suspect
ORDER BY Age DESC;


--Query 6
-- average age of persons involved in incidents

SELECT AVG(Age) AS AverageAge
FROM (
    SELECT Age FROM Victim
    UNION
    SELECT Age FROM Suspect
) AS personAges;


--Query 7
--List incident types and their counts, only for open cases

SELECT IncidentType, COUNT(*) AS OpenCasesCount FROM Crime 
WHERE Status = 'Open' 
GROUP BY IncidentType;


--Query 8
-- persons with names containing 'Doe'

SELECT CrimeID, Name FROM Victim WHERE Name LIKE '%Doe%' 
UNION
SELECT CrimeID, Name FROM Suspect WHERE Name LIKE '%Doe%';


--Query 9
--Retrieve the names of persons involved in open cases and closed cases. 

SELECT Name FROM Victim WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status IN ('Open','Closed') )
UNION
SELECT Name FROM Suspect WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status IN ('Open','Closed'));


--Query 10
-- List incident types where persons aged 30 or 35 are involved

SELECT DISTINCT c.IncidentType FROM Crime c
LEFT JOIN Victim v ON c.CrimeID = v.CrimeID AND v.Age IN (30, 35)
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID AND s.Age IN (30, 35)
WHERE v.VictimID IS NOT NULL OR s.SuspectID IS NOT NULL;


--Query 11
-- Find persons involved in incidents of the same type as 'Robbery'

SELECT Name, CrimeID FROM Victim WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE IncidentType = 'Robbery')
UNION
SELECT Name, CrimeID FROM Suspect WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE IncidentType = 'Robbery');


--Query 12
--List incident types with more than one open case

SELECT IncidentType, COUNT(*) AS OpenCaseCount FROM Crime 
WHERE Status = 'Open' GROUP BY IncidentType HAVING COUNT(*) > 1;

--result of above query12 is empty because we have only 1 Open Case


--Query 13
-- List all incidents with suspects whose names also appear as victims in other incidents

SELECT * FROM Crime
WHERE CrimeID IN (
    SELECT DISTINCT c1.CrimeID FROM Suspect s1
    INNER JOIN Crime c1 ON s1.CrimeID = c1.CrimeID
    INNER JOIN Victim v1 ON s1.Name = v1.Name AND s1.CrimeID = v1.CrimeID );

--result of above query13 is empty because we do not have any suspects whose names also appear as victims in other incidents


--Query 14
-- Retrieve all incidents along with victim and suspect details

SELECT c.*, v.*, s.*
FROM Crime c
LEFT JOIN Victim v ON c.CrimeID = v.CrimeID
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID;


--Query 15
-- Find incidents where the suspect is older than any victim

SELECT c.CrimeID,c.IncidentType, s.Name AS SuspectName ,s.Age FROM Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.Age > ANY (SELECT v.Age FROM Victim v WHERE v.CrimeID = c.CrimeID);


--Query 16
--. Find suspects involved in multiple incidents

SELECT Name, COUNT(*) AS IncidentCount FROM Suspect 
GROUP BY Name HAVING COUNT(*) > 1;

--result of above query16 is empty because we do not have any suspects involved in multiple incidents


--Query 17
-- List incidents with no suspects involved

SELECT * FROM Crime WHERE CrimeID 
NOT IN (SELECT DISTINCT CrimeID FROM Suspect);

--result of above query17 is empty because we do not have any incidents with no suspects involved


--Query 18
-- List all cases where at least one incident is of type 'Homicide' and all others are 'Robbery'

SELECT c1.CrimeID, c1.IncidentType, c1.IncidentDate, c1.Location, c1.Description, c1.Status
FROM Crime c1
WHERE c1.IncidentType = 'Homicide'
AND NOT EXISTS (
    SELECT 1
    FROM Crime c2
    WHERE c2.CrimeID <> c1.CrimeID
    AND c2.IncidentType <> 'Robbery'
);

--result of above query18 is empty because we do not have such cases


--Query 19
--Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none. 

SELECT c.CrimeID, c.IncidentType, c.IncidentDate, COALESCE(s.Name, 'No Suspect') AS SuspectName
FROM Crime c
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID;


--Query 20
--List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault' 

SELECT s.*,c.IncidentType  FROM Suspect s
INNER JOIN Crime c ON s.CrimeID = c.CrimeID
WHERE c.IncidentType IN ('Robbery', 'Assault');



