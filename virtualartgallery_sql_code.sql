--Coding Challenge SQL Virtual Art Gallery

--Submitted BY DEEPRAJ CHAWDA 

--Creating database
CREATE DATABASE VirtualArtGallery;

--use Database
USE VirtualArtGallery;

-- Creating the Artists table
CREATE TABLE Artists (
    ArtistID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Biography TEXT,
    Nationality VARCHAR(100)
);

-- Creating the Categories table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);

-- Creating the Artworks table
CREATE TABLE Artworks (
    ArtworkID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    ArtistID INT,
    CategoryID INT,
    Year INT,
    Description TEXT,
    ImageURL VARCHAR(255),
    FOREIGN KEY (ArtistID) REFERENCES Artists (ArtistID),
    FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID)
);

-- Creating the Exhibitions table
CREATE TABLE Exhibitions (
    ExhibitionID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    Description TEXT
);

-- Creating a table to associate artworks with exhibitions
CREATE TABLE ExhibitionArtworks (
    ExhibitionID INT,
    ArtworkID INT,
    PRIMARY KEY (ExhibitionID, ArtworkID),
    FOREIGN KEY (ExhibitionID) REFERENCES Exhibitions (ExhibitionID),
    FOREIGN KEY (ArtworkID) REFERENCES Artworks (ArtworkID)
);


-- Insert sample data into the Artists table
INSERT INTO Artists (ArtistID, Name, Biography, Nationality)
VALUES
    (1, 'Pablo Picasso', 'Renowned Spanish painter and sculptor.', 'Spanish'),
    (2, 'Vincent van Gogh', 'Dutch post-impressionist painter.', 'Dutch'),
    (3, 'Leonardo da Vinci', 'Italian polymath of the Renaissance.', 'Italian');

-- Insert sample data into the Categories table
INSERT INTO Categories (CategoryID, Name)
VALUES
    (1, 'Painting'),
    (2, 'Sculpture'),
    (3, 'Photography');

-- Insert sample data into the Artworks table
INSERT INTO Artworks (ArtworkID, Title, ArtistID, CategoryID, Year, Description, ImageURL)
VALUES
    (1, 'Starry Night', 2, 1, 1889, 'A famous painting by Vincent van Gogh.', 'starry_night.jpg'),
    (2, 'Mona Lisa', 3, 1, 1503, 'The iconic portrait by Leonardo da Vinci.', 'mona_lisa.jpg'),
    (3, 'Guernica', 1, 1, 1937, 'Pablo Picassos powerful anti-war mural.', 'guernica.jpg');

-- Insert sample data into the Exhibitions table
INSERT INTO Exhibitions (ExhibitionID, Title, StartDate, EndDate, Description)
VALUES
    (1, 'Modern Art Masterpieces', '2023-01-01', '2023-03-01', 'A collection of modern art masterpieces.'),
    (2, 'Renaissance Art', '2023-04-01', '2023-06-01', 'A showcase of Renaissance art treasures.');

-- Insert artworks into exhibitions
INSERT INTO ExhibitionArtworks (ExhibitionID, ArtworkID)
VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (2, 2);


--1 Retrieve the names of all artists along with the number of artworks they have in the gallery, 
-- and list them in descending order of the number of artworks

SELECT a.Name, COUNT(w.ArtworkID) AS NumberOfArtworks FROM Artists a
JOIN Artworks w ON a.ArtistID = w.ArtistID
GROUP BY a.Name
ORDER BY NumberOfArtworks DESC;


--2 List the titles of artworks created by artists from 'Spanish' and 'Dutch' nationalities, and order them by the year in ascending order

SELECT w.Title, w.Year FROM Artworks w
JOIN Artists a ON w.ArtistID = a.ArtistID
WHERE a.Nationality IN ('Spanish', 'Dutch')
ORDER BY w.Year ASC;


--3 Find the names of all artists who have artworks in the 'Painting' category, and the number of artworks they have in this category. 

SELECT a.Name, COUNT(w.ArtworkID) AS NumberOfArtworks FROM Artists a
JOIN Artworks w ON a.ArtistID = w.ArtistID
WHERE w.CategoryID = (SELECT CategoryID FROM Categories WHERE Name = 'Painting')
GROUP BY a.Name;

--or we can use join 
SELECT a.Name, COUNT(w.ArtworkID) AS NumberOfArtworks FROM Artists a
JOIN Artworks w ON a.ArtistID = w.ArtistID
JOIN Categories c ON w.CategoryID = c.CategoryID
WHERE c.Name = 'Painting' 
GROUP BY A.Name;


--4 List the names of artworks from the 'Modern Art Masterpieces' exhibition, along with their artists and categories

SELECT w.Title, a.Name , C.Name AS CategoryName, E.Title FROM Artworks w
JOIN Artists a ON w.ArtistID = a.ArtistID
JOIN Categories C ON w.CategoryID = C.CategoryID
JOIN ExhibitionArtworks EA ON w.ArtworkID = EA.ArtworkID
JOIN Exhibitions E ON EA.ExhibitionID = E.ExhibitionID
WHERE E.Title = 'Modern Art Masterpieces';


--5 Find the artists who have more than two artworks in the gallery. 

SELECT A.Name AS ArtistName, COUNT(W.ArtworkID) AS NumberOfArtworks FROM Artists A
JOIN Artworks W ON A.ArtistID = W.ArtistID
GROUP BY A.Name
HAVING COUNT(W.ArtistID) > 2;


--6 Find the titles of artworks that were exhibited in both 'Modern Art Masterpieces' and 'Renaissance Art' exhibitions 

SELECT W.Title FROM Artworks W
JOIN ExhibitionArtworks EA ON W.ArtworkID = EA.ArtworkID
JOIN Exhibitions E ON EA.ExhibitionID = E.ExhibitionID
WHERE E.Title IN ('Modern Art Masterpieces', 'Renaissance Art')
GROUP BY W.Title
HAVING COUNT(DISTINCT E.ExhibitionID) = 2;


--7 Find the total number of artworks in each category 

SELECT C.Name AS CategoryName, COUNT(W.ArtworkID) AS NumberOfArtworks FROM Categories C
JOIN Artworks W ON C.CategoryID = W.CategoryID
GROUP BY C.Name;


--8 List artists who have more than 3 artworks in the gallery. 

SELECT A.Name AS ArtistName, COUNT(W.ArtworkID) AS NumberOfArtworks FROM Artists A
JOIN Artworks W ON A.ArtistID = W.ArtistID
GROUP BY A.Name
HAVING COUNT(W.ArtworkID) > 3;


--9 Find the artworks created by artists from a specific nationality (e.g., Spanish). 

SELECT W.Title, A.Name FROM Artworks W
JOIN Artists A ON W.ArtistID = A.ArtistID
WHERE A.Nationality = 'Spanish'; --we can change nationality here

--or other way
Declare @nationalityInput Varchar(20) ='Spanish'; -- here we can set the nationality

SELECT W.Title, A.Name FROM Artworks W
JOIN Artists A ON W.ArtistID = A.ArtistID
WHERE A.Nationality = @nationalityInput;



--10  List exhibitions that feature artwork by both Vincent van Gogh and Leonardo da Vinci. 

SELECT e.Title FROM Exhibitions e 
JOIN ExhibitionArtworks ea ON e.ExhibitionID = ea.ExhibitionID
JOIN Artworks w ON ea.ArtworkID = w.ArtworkID
JOIN Artists a ON w.ArtistID = a.ArtistID
WHERE a.Name = 'Vincent van Gogh' OR a.Name = 'Leonardo da Vinci' --here we can use IN as well like: IN ('Vincent van Gogh', 'Leonardo da Vinci')
GROUP BY e.Title
HAVING COUNT(DISTINCT a.Name) = 2;


--11  Find all the artworks that have not been included in any exhibition. 

SELECT W.*  FROM Artworks W
LEFT JOIN ExhibitionArtworks EA ON W.ArtworkID = EA.ArtworkID
WHERE EA.ArtworkID IS NULL;


--12  List artists who have created artworks in all available categories.

SELECT A.Name AS ArtistName FROM Artists A
WHERE ( SELECT COUNT(DISTINCT W.CategoryID) FROM Artworks W WHERE W.ArtistID = A.ArtistID )
	 = (SELECT COUNT(*) FROM Categories);

--or using join

SELECT A.Name AS ArtistName FROM Artists A
join Artworks W on A.ArtistID=W.ArtistID
GROUP BY A.Name
HAVING COUNT(DISTINCT W.CategoryID)=(SELECT COUNT(*) FROM Categories);


--13  List the total number of artworks in each category

SELECT C.Name AS CategoryName, COUNT(W.ArtworkID) AS NumberOfArtworks FROM Categories C
JOIN Artworks W ON C.CategoryID = W.CategoryID
GROUP BY C.Name;


--14  Find the artists who have more than 2 artworks in the gallery. 

SELECT A.Name AS ArtistName, COUNT(W.ArtworkID) AS NumberOfArtworks FROM Artists A
JOIN Artworks W ON A.ArtistID = W.ArtistID
GROUP BY A.Name
HAVING COUNT(W.ArtworkID) > 2;


--15  List the categories with the average year of artworks they contain, only for categories with more than 1 artwork. 

SELECT C.Name AS CategoryName, AVG(W.Year) AS AverageYear FROM Categories C
JOIN Artworks W ON C.CategoryID = W.CategoryID
GROUP BY C.Name
HAVING COUNT(W.ArtworkID) > 1;


--16  Find the artworks that were exhibited in the 'Modern Art Masterpieces' exhibition

SELECT W.Title AS ArtworkTitle, E.Title FROM Artworks W
JOIN ExhibitionArtworks EA ON W.ArtworkID = EA.ArtworkID
JOIN Exhibitions E ON EA.ExhibitionID = E.ExhibitionID
WHERE E.Title = 'Modern Art Masterpieces';


--17 Find the categories where the average year of artworks is greater than the average year of all artworks. 

SELECT C.Name AS CategoryName, AVG(W.Year) AS AvgYear FROM Categories C
JOIN Artworks W ON C.CategoryID = W.CategoryID
GROUP BY C.Name
HAVING AVG(W.Year) > (SELECT AVG(Year) FROM Artworks);


--18 List the artworks that were not exhibited in any exhibition. 

SELECT W.Title FROM Artworks W
LEFT JOIN ExhibitionArtworks EA ON W.ArtworkID = EA.ArtworkID
WHERE EA.ArtworkID IS NULL;


--19  Show artists who have artworks in the same category as "Mona Lisa." 

SELECT DISTINCT A.Name AS ArtistName FROM Artists A
JOIN Artworks W ON A.ArtistID = W.ArtistID
WHERE W.CategoryID IN ( SELECT CategoryID FROM Artworks WHERE Title = 'Mona Lisa');

--if we donot include Mona Lisa
SELECT DISTINCT A.Name AS ArtistName FROM Artists A
JOIN Artworks W ON A.ArtistID = W.ArtistID
WHERE W.CategoryID IN ( SELECT CategoryID FROM Artworks WHERE Title = 'Mona Lisa')
	AND A.ArtistID != (SELECT ArtistID FROM Artworks WHERE Title = 'Mona Lisa');


--20 List the names of artists and the number of artworks they have in the gallery. 

SELECT A.Name, COUNT(W.ArtworkID) AS NumberOfArtworks FROM Artists A
LEFT JOIN Artworks W ON A.ArtistID = W.ArtistID
GROUP BY A.Name;
