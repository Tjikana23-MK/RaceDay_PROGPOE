/* =========================================================
   RaceDay Database
   PROG6212 - Programming 2B
   Part 1 - System Planning and Database
   ========================================================= */

-- Create database
IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

/* =========================================================
   Drop existing tables if they already exist
   This allows the script to be tested again.
   ========================================================= */

IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL
    DROP TABLE dbo.Results;

IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL
    DROP TABLE dbo.Enrolments;

IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL
    DROP TABLE dbo.Categories;

IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL
    DROP TABLE dbo.Events;

IF OBJECT_ID('dbo.EventTypes', 'U') IS NOT NULL
    DROP TABLE dbo.EventTypes;

IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL
    DROP TABLE dbo.Users;
GO

/* =========================================================
   1. USERS
   Stores Organiser and Participant accounts
   ========================================================= */

CREATE TABLE Users
(
    UserID INT IDENTITY(1,1) NOT NULL,

    FirstName VARCHAR(50) NOT NULL,

    LastName VARCHAR(50) NOT NULL,

    Email VARCHAR(100) NOT NULL,

    PasswordHash VARCHAR(255) NOT NULL,

    Role VARCHAR(20) NOT NULL,

    Phone VARCHAR(20) NULL,

    ProfilePictureUrl VARCHAR(500) NULL,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Users_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Users
        PRIMARY KEY (UserID),

    CONSTRAINT UQ_Users_Email
        UNIQUE (Email),

    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organiser', 'Participant'))
);
GO


/* =========================================================
   2. EVENT TYPES
   Stores the type of road event
   ========================================================= */

CREATE TABLE EventTypes
(
    EventTypeID INT IDENTITY(1,1) NOT NULL,

    TypeName VARCHAR(50) NOT NULL,

    Description VARCHAR(255) NULL,

    CONSTRAINT PK_EventTypes
        PRIMARY KEY (EventTypeID),

    CONSTRAINT UQ_EventTypes_TypeName
        UNIQUE (TypeName)
);
GO


/* =========================================================
   3. EVENTS
   Stores events created by organisers
   ========================================================= */

CREATE TABLE Events
(
    EventID INT IDENTITY(1,1) NOT NULL,

    OrganiserID INT NOT NULL,

    EventTypeID INT NOT NULL,

    Name VARCHAR(150) NOT NULL,

    Description VARCHAR(1000) NULL,

    EventDate DATE NOT NULL,

    Location VARCHAR(200) NOT NULL,

    DistanceKm DECIMAL(6,2) NOT NULL,

    BannerImageUrl VARCHAR(500) NULL,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Events_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Events
        PRIMARY KEY (EventID),

    CONSTRAINT FK_Events_Organiser
        FOREIGN KEY (OrganiserID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Events_EventType
        FOREIGN KEY (EventTypeID)
        REFERENCES EventTypes(EventTypeID),

    CONSTRAINT CK_Events_Distance
        CHECK (DistanceKm > 0)
);
GO


/* =========================================================
   4. CATEGORIES
   Stores categories belonging to each event
   ========================================================= */

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1,1) NOT NULL,

    EventID INT NOT NULL,

    CategoryName VARCHAR(100) NOT NULL,

    MinAge INT NULL,

    MaxAge INT NULL,

    CategoryDistanceKm DECIMAL(6,2) NOT NULL,

    CONSTRAINT PK_Categories
        PRIMARY KEY (CategoryID),

    CONSTRAINT FK_Categories_Event
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT UQ_Categories_Event_Category
        UNIQUE (EventID, CategoryName),

    CONSTRAINT CK_Categories_MinAge
        CHECK (MinAge IS NULL OR MinAge >= 0),

    CONSTRAINT CK_Categories_MaxAge
        CHECK (MaxAge IS NULL OR MaxAge >= 0),

    CONSTRAINT CK_Categories_AgeRange
        CHECK (
            MinAge IS NULL
            OR MaxAge IS NULL
            OR MinAge <= MaxAge
        ),

    CONSTRAINT CK_Categories_Distance
        CHECK (CategoryDistanceKm > 0)
);
GO


/* =========================================================
   5. ENROLMENTS
   Links participants to events and categories
   ========================================================= */

CREATE TABLE Enrolments
(
    EnrolmentID INT IDENTITY(1,1) NOT NULL,

    ParticipantID INT NOT NULL,

    EventID INT NOT NULL,

    CategoryID INT NOT NULL,

    EnrolmentDate DATETIME2 NOT NULL
        CONSTRAINT DF_Enrolments_EnrolmentDate
        DEFAULT SYSDATETIME(),

    Status VARCHAR(20) NOT NULL
        CONSTRAINT DF_Enrolments_Status
        DEFAULT 'Confirmed',

    CONSTRAINT PK_Enrolments
        PRIMARY KEY (EnrolmentID),

    CONSTRAINT FK_Enrolments_Participant
        FOREIGN KEY (ParticipantID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_Enrolments_Event
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT FK_Enrolments_Category
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT UQ_Enrolments_Participant_Event
        UNIQUE (ParticipantID, EventID),

    CONSTRAINT CK_Enrolments_Status
        CHECK (
            Status IN
            ('Pending', 'Confirmed', 'Cancelled')
        )
);
GO


/* =========================================================
   6. RESULTS
   Stores participant race results
   ========================================================= */

CREATE TABLE Results
(
    ResultID INT IDENTITY(1,1) NOT NULL,

    EnrolmentID INT NOT NULL,

    FinishTimeSeconds INT NOT NULL,

    FinishingPosition INT NOT NULL,

    PublishedAt DATETIME2 NULL,

    CONSTRAINT PK_Results
        PRIMARY KEY (ResultID),

    CONSTRAINT FK_Results_Enrolment
        FOREIGN KEY (EnrolmentID)
        REFERENCES Enrolments(EnrolmentID),

    CONSTRAINT UQ_Results_Enrolment
        UNIQUE (EnrolmentID),

    CONSTRAINT CK_Results_FinishTime
        CHECK (FinishTimeSeconds > 0),

    CONSTRAINT CK_Results_Position
        CHECK (FinishingPosition > 0)
);
GO


/* =========================================================
   SEED DATA
   ========================================================= */


/* ---------------------------------------------------------
   EVENT TYPES
   --------------------------------------------------------- */

INSERT INTO EventTypes
(
    TypeName,
    Description
)
VALUES
(
    'Run',
    'Road running events'
),
(
    'Walk',
    'Community and charity walking events'
),
(
    'Cycle',
    'Road cycling events'
);
GO


/* ---------------------------------------------------------
   USERS
   2 Organisers
   2 Participants
   --------------------------------------------------------- */

INSERT INTO Users
(
    FirstName,
    LastName,
    Email,
    PasswordHash,
    Role,
    Phone
)
VALUES
(
    'Naledi',
    'Mokoena',
    'naledi.mokoena@raceday.co.za',
    'PLACEHOLDER_HASH_1',
    'Organiser',
    '0712345678'
),
(
    'Johan',
    'van Wyk',
    'johan.vanwyk@raceday.co.za',
    'PLACEHOLDER_HASH_2',
    'Organiser',
    '0723456789'
),
(
    'Ayanda',
    'Dlamini',
    'ayanda.dlamini@example.com',
    'PLACEHOLDER_HASH_3',
    'Participant',
    '0734567890'
),
(
    'Liam',
    'Naidoo',
    'liam.naidoo@example.com',
    'PLACEHOLDER_HASH_4',
    'Participant',
    '0745678901'
);
GO


/* ---------------------------------------------------------
   EVENTS
   3 sample events
   --------------------------------------------------------- */

INSERT INTO Events
(
    OrganiserID,
    EventTypeID,
    Name,
    Description,
    EventDate,
    Location,
    DistanceKm
)
VALUES
(
    1,
    1,
    'Johannesburg Charity Run',
    'A community road running event supporting local charities.',
    '2026-10-10',
    'Johannesburg, Gauteng',
    10.00
),
(
    2,
    2,
    'Limpopo Community Walk',
    'A family-friendly community walking event.',
    '2026-10-24',
    'Polokwane, Limpopo',
    5.00
),
(
    1,
    3,
    'Polokwane Cycling Challenge',
    'A competitive road cycling challenge.',
    '2026-11-07',
    'Polokwane, Limpopo',
    50.00
);
GO


/* ---------------------------------------------------------
   CATEGORIES
   Categories for every event
   --------------------------------------------------------- */

INSERT INTO Categories
(
    EventID,
    CategoryName,
    MinAge,
    MaxAge,
    CategoryDistanceKm
)
VALUES
(
    1,
    '10km Open',
    18,
    NULL,
    10.00
),
(
    1,
    '10km Junior',
    13,
    17,
    10.00
),
(
    2,
    '5km Family Walk',
    10,
    NULL,
    5.00
),
(
    2,
    '5km Junior Walk',
    8,
    17,
    5.00
),
(
    3,
    '50km Open',
    18,
    NULL,
    50.00
),
(
    3,
    '50km Veteran',
    40,
    NULL,
    50.00
);
GO


/* ---------------------------------------------------------
   ENROLMENTS
   Sample participant enrolments
   --------------------------------------------------------- */

INSERT INTO Enrolments
(
    ParticipantID,
    EventID,
    CategoryID,
    Status
)
VALUES
(
    3,
    1,
    1,
    'Confirmed'
),
(
    4,
    1,
    1,
    'Confirmed'
),
(
    3,
    2,
    3,
    'Confirmed'
),
(
    4,
    3,
    5,
    'Pending'
);
GO


/* ---------------------------------------------------------
   RESULTS
   Sample results for completed enrolments
   --------------------------------------------------------- */

INSERT INTO Results
(
    EnrolmentID,
    FinishTimeSeconds,
    FinishingPosition,
    PublishedAt
)
VALUES
(
    1,
    3150,
    1,
    SYSDATETIME()
),
(
    2,
    3420,
    2,
    SYSDATETIME()
);
GO


/* =========================================================
   INDEXES
   ========================================================= */

CREATE INDEX IX_Events_OrganiserID
ON Events(OrganiserID);

CREATE INDEX IX_Events_EventTypeID
ON Events(EventTypeID);

CREATE INDEX IX_Categories_EventID
ON Categories(EventID);

CREATE INDEX IX_Enrolments_ParticipantID
ON Enrolments(ParticipantID);

CREATE INDEX IX_Enrolments_EventID
ON Enrolments(EventID);

CREATE INDEX IX_Enrolments_CategoryID
ON Enrolments(CategoryID);

CREATE INDEX IX_Results_EnrolmentID
ON Results(EnrolmentID);
GO


/* =========================================================
   VERIFICATION
   ========================================================= */

SELECT * FROM Users;

SELECT * FROM EventTypes;

SELECT * FROM Events;

SELECT * FROM Categories;

SELECT * FROM Enrolments;

SELECT * FROM Results;
GO


/* =========================================================
   SHOW TABLES
   ========================================================= */

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO

USE RaceDayDB;
GO

SELECT * FROM Users;
SELECT * FROM EventTypes;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM Enrolments;
SELECT * FROM Results;


SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ParentColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
ORDER BY ChildTable;


USE RaceDayDB;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

SELECT COUNT(*) AS UserCount FROM Users;
SELECT COUNT(*) AS EventTypeCount FROM EventTypes;
SELECT COUNT(*) AS EventCount FROM Events;
SELECT COUNT(*) AS CategoryCount FROM Categories;
SELECT COUNT(*) AS EnrolmentCount FROM Enrolments;
SELECT COUNT(*) AS ResultCount FROM Results;


USE RaceDayDB;
GO

SELECT COUNT(*) AS UserCount FROM Users;
SELECT COUNT(*) AS EventTypeCount FROM EventTypes;
SELECT COUNT(*) AS EventCount FROM Events;
SELECT COUNT(*) AS CategoryCount FROM Categories;
SELECT COUNT(*) AS EnrolmentCount FROM Enrolments;
SELECT COUNT(*) AS ResultCount FROM Results;

SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ParentColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
ORDER BY ChildTable;

USE RaceDayDB;
GO

SELECT
    Role,
    COUNT(*) AS NumberOfUsers
FROM Users
GROUP BY Role;

SELECT
    e.EventID,
    e.Name AS EventName,
    COUNT(c.CategoryID) AS NumberOfCategories
FROM Events e
LEFT JOIN Categories c
    ON e.EventID = c.EventID
GROUP BY
    e.EventID,
    e.Name
ORDER BY e.EventID;


SELECT
    en.EnrolmentID,
    u.FirstName + ' ' + u.LastName AS Participant,
    e.Name AS EventName,
    c.CategoryName,
    en.Status,
    en.EnrolmentDate
FROM Enrolments en
INNER JOIN Users u
    ON en.ParticipantID = u.UserID
INNER JOIN Events e
    ON en.EventID = e.EventID
INNER JOIN Categories c
    ON en.CategoryID = c.CategoryID
ORDER BY en.EnrolmentID;


SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME IN
(
    'Users',
    'EventTypes',
    'Events',
    'Categories',
    'Enrolments',
    'Results'
)
ORDER BY TABLE_NAME, CONSTRAINT_TYPE;


USE RaceDayDB;
GO

SELECT
    Role,
    COUNT(*) AS NumberOfUsers
FROM Users
GROUP BY Role;