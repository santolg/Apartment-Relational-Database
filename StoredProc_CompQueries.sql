USE jllApartments

-- STORED PROCEDURES

-- creating stored procedure to insert new row into tblBUILDING

GO
CREATE PROCEDURE GetLocID
@Cit varchar(20),
@Sta varchar(20),
@L_ID INT OUTPUT
AS
SET @L_ID = (SELECT LocationID FROM tblLOCATION WHERE City = @Cit AND [State] = @Sta)
GO

CREATE PROCEDURE GetMgmtID
@Nm varchar(100)
AS
SET @M_ID = (SELECT ManagementID FROM tblMANAGEMENT WHERE ManagementName = @Nm)
GO

CREATE PROCEDURE INSERT_BLDG
@City varchar(20),
@State varchar(20),
@BuildingID INT,
@Name varchar(100),
@BldgName INT,
@YrOpened INT
AS
DECLARE @LOCATION INT, @MANAGEMENT INT

EXEC GetLocID
@Cit = @City,
@Sta = @State,
@L_ID = @LOCATION OUTPUT

IF @LOCATION IS NULL
	BEGIN
		PRINT '@BTID is NULL and will fail during the INSERT transaction; check spelling of all parameters';
		THROW 56676, '@BTID cannot be NULL; statement is terminating', 1;
	END

EXEC GetMgmtID
@Nm = @Name,
@M_ID = @MANAGEMENT OUTPUT

IF @MANAGEMENT IS NULL
	BEGIN
		PRINT '@BTID is NULL and will fail during the INSERT transaction; check spelling of all parameters';
		THROW 56676, '@BTID cannot be NULL; statement is terminating', 1;
	END

BEGIN TRAN T1
INSERT INTO tblBUILDING (LocationID, ManagementID, BuildingName, YearOpened)
VALUES (@LOCATION, @MANAGEMENT, @BldgName, @YrOpened)
COMMIT TRAN T1
GO 


-- creating stored procedure to insert new row into tblLEASE

CREATE PROCEDURE GetFeeID
@Fee varchar(50),
@F_ID INT OUTPUT
AS
SET @F_ID = (SELECT FeeID FROM tblLEASE_FEES WHERE FeeName = @Fee)
GO

CREATE PROCEDURE GetTenantId
@Fname varchar(20),
@Lname varchar(20),
@Bday DATE,
@T_ID INT OUTPUT
AS 
SET @T_ID = (SELECT TenantID FROM tblTENANT_INFO WHERE TenantFname = @Fname AND TenantLname = @Lname AND TenantBirthdate = @Bday)
GO 

CREATE PROCEDURE GetUnitID
@UCap INT,
@U_ID INT OUTPUT
AS 
SET @U_ID = (SELECT UnitID FROM tblUNIT WHERE UnitCapacity = @UCap)
GO

CREATE PROCEDURE INSERT_LEASE
@FeeName varchar(50),
@LeaseID INT,
@First varchar(20),
@Last varchar(20),
@DOB DATE,
@Capacity INT,
@Months NUMERIC(10,2),
@Rent INT
AS
DECLARE @FEE INT, @TENANT INT, @UNIT INT

EXEC GetFeeID
@Fee = @FeeName,
@F_ID = @FEE

IF @FEE IS NULL
	BEGIN
		PRINT '@BTID is NULL and will fail during the INSERT transaction; check spelling of all parameters';
		THROW 56676, '@BTID cannot be NULL; statement is terminating', 1;
	END

EXEC GetTenantId
@Fname = @First,
@Lname = @Last,
@Bday = @DOB,
@T_ID = @TENANT

IF @TENANT IS NULL
	BEGIN
		PRINT '@BTID is NULL and will fail during the INSERT transaction; check spelling of all parameters';
		THROW 56676, '@BTID cannot be NULL; statement is terminating', 1;
	END

EXEC GetUnitID
@UCap = @Capacity,
@U_ID = @UNIT

IF @UNIT IS NULL
	BEGIN
		PRINT '@BTID is NULL and will fail during the INSERT transaction; check spelling of all parameters';
		THROW 56676, '@BTID cannot be NULL; statement is terminating', 1;
	END

BEGIN TRAN T1
INSERT INTO tblLEASE (FeeID, TenantID, UnitID, LeaseMonths, MonthlyRent)
VALUES (@FEE, @TENANT, @UNIT, @Months, @Rent)
COMMIT TRAN T1
GO 


-- COMPUTED COLUMNS

--adding yearly rent values off MonthlyRent column in tblLEASE
ALTER TABLE tblLEASE ADD YearlyRent AS (MonthlyRent *  12);

--adding current age values based off TenantBirthDate in tblTENANT_INFO
ALTER TABLE tblTENANT_INFO ADD CurrentAge AS CONVERT(INT, ROUND(DATEDIFF(HOUR, TenantBirthDate, GETDATE()) / 8766.0, 0));


-- BUSINESS RULES


---Only tenants who are over the age of 18 can sign a lease. This rule is to help mangage lease laws and alert if a co-signer is needed. 
--User defined function
GO
CREATE FUNCTION fn_notenantunder18lease()
RETURNS INT
AS
BEGIN

DECLARE @RET INT = 0
IF EXISTS (SELECT *
			FROM tblTENANT_INFO T
			JOIN tblLEASE L ON T.TenantID = L.TenantID
			WHERE T.CurrentAge >= '18')
			BEGIN
				SET @RET = 1
			END
RETURN @RET
END
GO

ALTER TABLE tblTENANT_INFO
ADD CONSTRAINT CK_notenantunder18lease
CHECK (dbo.fn_notenantunder18lease()=0)
GO



---Only unit type one bedroom, two bedroom, or three bedroom can have a unit capacity greater than 3. 
---This rule would help manage occupancy in the buildings. 
--User defined function

CREATE FUNCTION fn_unitcapacityforunittype()
RETURNS INT
AS
BEGIN

DECLARE @RET INT = 0
IF EXISTS (SELECT *
			FROM tblUNIT U
			JOIN tblUNIT_TYPE UT ON U.UnitTypeID = UT.UnitTypeID
			WHERE UT.UnitTypeName IN ('Studio', 'Loft')
				AND U.UnitCapacity > '2')
			BEGIN
				SET @RET = 1
			END
RETURN @RET
END
GO

ALTER TABLE tblUNIT
ADD CONSTRAINT unitcapacityforunittype
CHECK (dbo.fn_unitcapacityforunittype()=0)
GO

---DELETING DUPLICATES FROM THE TABLES

---Removing Duplicates in tables using the SQL MAX function
SELECT * FROM tblLOCATION --- Three times

DELETE FROM tblLOCATION
    WHERE LocationID NOT IN
    (SELECT MAX(LocationID) AS MaxRecordID
        FROM tblLOCATION
        GROUP BY [City],[State],[Zip]);

SELECT * FROM tblLOCATION

---Deleting duplicates from the table using CTE
SELECT * FROM tblFEATURE_TYPE

GO
WITH cte AS (
    SELECT FeatureTypeName, FeatureTypeDesc, 
        ROW_NUMBER() OVER (
            PARTITION BY FeatureTypeName, FeatureTypeDesc
            ORDER BY FeatureTypeName, FeatureTypeDesc
        ) row_num
     FROM tblFEATURE_TYPE 
)
DELETE FROM cte
WHERE row_num > 1;
GO

---Deleting duplicates from the table using CTE
SELECT * FROM tblAMENITY_TYPE 
GO
WITH cte AS (
    SELECT AmenityTypeName, AmenityTypeDesc, 
        ROW_NUMBER() OVER (
            PARTITION BY AmenityTypeName, AmenityTypeDesc
            ORDER BY AmenityTypeName, AmenityTypeDesc
        ) row_num
     FROM tblAMENITY_TYPE 
)
DELETE FROM cte
WHERE row_num > 1;
GO
SELECT * FROM tblAMENITY_TYPE 

---Deleting duplicates from the table using CTE
GO
WITH cte AS (
    SELECT FeeTypeName, FeeTypeDesc, 
        ROW_NUMBER() OVER (
            PARTITION BY FeeTypeName, FeeTypeDesc
            ORDER BY FeeTypeName, FeeTypeDesc
        ) row_num
     FROM tblFEE_TYPE 
)
DELETE FROM cte
WHERE row_num > 1;
GO
SELECT * FROM tblFEE_TYPE 


---Deleting duplicates from the table using CTE
GO
WITH cte AS (
    SELECT SpecialNeedName, SpecialNeedDesc, 
        ROW_NUMBER() OVER (
            PARTITION BY SpecialNeedName, SpecialNeedDesc
            ORDER BY SpecialNeedName, SpecialNeedDesc
        ) row_num
     FROM tblSPECIAL_NEED
)
DELETE FROM cte
WHERE row_num > 1;
GO

---COMPLEX QUERIES

/*Write the SQL to determine the buildings that have held more than 50 tenants born in the month of November that have also collected the most money in rent in 2006
*/

SELECT A.BuildingID, A.NumTenants, B.TotalYearlyRent
FROM
(SELECT B.BuildingID, B.BuildingName, COUNT(T.TenantID) AS NumTenants
FROM tblLEASE L
		JOIN tblTENANT_INFO T  ON L.TenantID = T.TenantID
		JOIN tblUNIT U ON L.UnitID = U.UnitID
		JOIN tblBUILDING B ON U.BuildingID = B.BuildingID
		JOIN tblLOCATION LO ON B.LocationID = LO.LocationID
WHERE LO.City = 'Kirkland'
	AND MONTH(T.TenantBirthdate) = 11
GROUP BY B.BuildingID, B.BuildingName
HAVING COUNT(T.TenantID) > 50) A,

(SELECT B.BuildingID, B.BuildingName, SUM(L.YearlyRent) AS TotalYearlyRent
	FROM tblLEASE L
		JOIN tblTENANT_INFO T  ON L.TenantID = T.TenantID
		JOIN tblLEASE_FEES LF ON L.FeeID = LF.FeeID
		JOIN tblFEE_TYPE FT ON LF.FeeTypeID = FT.FeeTypeID
		JOIN tblUNIT U ON L.UnitID = U.UnitID
		JOIN tblBUILDING B ON U.BuildingID = B.BuildingID
WHERE L.LeaseEndDate = '2006'
GROUP BY B.BuildingID, B.BuildingName) B

WHERE A.BuildingID = B.BuildingID


/*Write the SQL to determine the tenants that started a lease during the 2019 year that also had a service animal
*/

SELECT A.TenantID, A.TenantFname, A.TenantFname, B.SpecialNeedID
FROM
(SELECT T.TenantID, T.TenantFname, T.TenantLname
FROM tblTENANT_INFO T
	JOIN tblLEASE L ON T.TenantID = L.TenantID
WHERE L.LeaseStartDate = '2019') A,

(SELECT T.TenantID, T.TenantFname, T.TenantLname, SN.SpecialNeedID
FROM tblTENANT_INFO T
	JOIN tblTENANT_SPECIAL_NEED S ON T.TenantID = S.TenantID
	JOIN tblSPECIAL_NEED SN ON S.SpecialNeedID = SN.SpecialNeedID
WHERE SN.SpecialNeedName = 'Service Animal') B 

WHERE A.TenantID = B.TenantID

