
---CREATE DATABASE jllApartments

USE jllApartments


CREATE TABLE tblLOCATION
(LocationID INTEGER IDENTITY (1,1) PRIMARY KEY, 
City varchar (20) not null,
State varchar(20) not null,
Zip INT not null)
GO

CREATE TABLE tblMANAGEMENT_TYPE
(ManagementTypeID INTEGER IDENTITY (1,1) PRIMARY KEY, 
ManagementTypeName varchar(50) not null, 
ManagementTypeDesc varchar(100) not null)
GO

CREATE TABLE tblMANAGEMENT
(ManagementID INTEGER IDENTITY (1,1) PRIMARY KEY, 
ManagementName varchar(100) not null, 
ManagementTypeID INT FOREIGN KEY REFERENCES tblMANAGEMENT_TYPE (ManagementTypeID) not null)
GO

CREATE TABLE tblFEATURE_TYPE
(FeatureTypeID INTEGER IDENTITY (1,1) PRIMARY KEY, 
FeatureTypeName varchar(50) not null, 
FeatureTypeDesc varchar(100) null)
GO

CREATE TABLE tblFEATURE
(FeatureID INTEGER IDENTITY (1,1) PRIMARY KEY, 
FeatureTypeID INT FOREIGN KEY REFERENCES tblFEATURE_TYPE (FeatureTypeID) not null, 
FeatureName varchar(50) not null, 
FeatureNameDesc varchar(100) null)
GO

CREATE TABLE tblUNIT_TYPE
(UnitTypeID INTEGER IDENTITY (1,1) PRIMARY KEY, 
UnitTypeName varchar(50) not null, 
UnitTypeDesc varchar(100) null)
GO

CREATE TABLE tblAMENITY_TYPE
(AmenityTypeID INTEGER IDENTITY (1,1) PRIMARY KEY, 
AmenityTypeName varchar(50) not null, 
AmenityTypeDesc varchar(100) null)
GO

CREATE TABLE tblAMENITY
(AmenityID INTEGER IDENTITY (1,1) PRIMARY KEY, 
AmenityTypeID INT FOREIGN KEY REFERENCES tblAMENITY_TYPE not null, 
AmenityName varchar(50) not null,
AmenityNameDesc varchar(100) null)
GO

CREATE TABLE tblFEE_TYPE
(FeeTypeID INTEGER IDENTITY (1,1) PRIMARY KEY, 
FeeTypeName varchar(50) not null, 
FeeTypeDesc varchar(100) null)
GO

CREATE TABLE tblLEASE_FEES
(FeeID INTEGER IDENTITY (1,1) PRIMARY KEY, 
FeeTypeID INT FOREIGN KEY REFERENCES tblFEE_TYPE (FeeTypeID) not null, 
FeeName varchar(50) not null,
FeeDesc varchar(100) null)
GO

CREATE TABLE tblSPECIAL_NEED
(SpecialNeedID INTEGER IDENTITY (1,1) PRIMARY KEY, 
SpecialNeedName varchar(50) not null, 
SpecialNeedDesc varchar(100) null)
GO

CREATE TABLE tblTENANT_INFO
(TenantID INTEGER IDENTITY (1,1) PRIMARY KEY, 
TenantFname varchar(20) not null, 
TenantLname varchar(20) not null,
TenantPhone varchar (10) not null, 
TenantEmail varchar(100) null, 
TenantBirthdate DATE not null)
GO

CREATE TABLE tblTENANT_SPECIAL_NEED
(TenantSpecialNeedID INTEGER IDENTITY (1,1) PRIMARY KEY, 
TenantID INT FOREIGN KEY REFERENCES tblTENANT_INFO (TenantID) not null, 
SpecialNeedID INT FOREIGN KEY REFERENCES tblSPECIAL_NEED (SpecialNeedID) not null)
GO

CREATE TABLE tblBUILDING
(BuildingID INTEGER IDENTITY (1,1) PRIMARY KEY, 
BuildingName varchar(50) not null,
BuildingStreetAddress varchar(100) not null,
LocationID INT FOREIGN KEY REFERENCES tblLOCATION (LocationID) not null, 
YearOpened INT, 
TotalUnits INTEGER, 
ManagementID INT FOREIGN KEY REFERENCES tblMANAGEMENT (ManagementID) not null)
GO

CREATE TABLE tblUNIT
(UnitID INTEGER IDENTITY (1,1) PRIMARY KEY, 
UnitTypeID INT FOREIGN KEY REFERENCES tblUNIT_TYPE (UnitTypeID) not null, 
BuildingID INT FOREIGN KEY REFERENCES tblBUILDING (BuildingID) not null, 
UnitCapacity INT not null)
GO

CREATE TABLE tblLEASE
(LeaseID INTEGER IDENTITY (1,1) PRIMARY KEY, 
FeeID INT FOREIGN KEY REFERENCES tblLEASE_FEES (FeeID) not null, 
TenantID INT FOREIGN KEY REFERENCES tblTENANT_INFO (TenantID) not null, 
UnitID INT FOREIGN KEY REFERENCES tblUNIT (UnitID) not null, 
LeaseMonths INT not null,
MonthlyRent NUMERIC (10,2) not null, 
Insurance varchar(50) not null, 
LeaseStartDate DATE not null, 
LeaseEndDate DATE not null)
GO

CREATE TABLE tblUNIT_AMENITY
(AmenityID INT FOREIGN KEY REFERENCES tblAMENITY (AmenityID) not null,
UnitID INT FOREIGN KEY REFERENCES tblUNIT (UnitID) not null) 
GO

CREATE TABLE tblBUILDING_FEATURES
(BuildingFeatureID INTEGER IDENTITY (1,1) PRIMARY KEY, 
FeatureID INT FOREIGN KEY REFERENCES tblFEATURE (FeatureID) not null, 
BuildingID INT FOREIGN KEY REFERENCES tblBUILDING (BuildingID) not null)
GO


INSERT INTO tblLOCATION
(City, [State], Zip)
Values ('Seattle', 'Washington', 98101),
('Kirkland', 'Washington', 98033),
('Tacoma', 'Washington', 98402),
('Bellevue', 'Washington', 98004),
('Renton', 'Washington', 98058);
GO
 
INSERT INTO tblMANAGEMENT_TYPE
(ManagementTypeName, ManagementTypeDesc)
Values ('Residential', 'Property zoned for living or dwelling'),
('Commercial', 'Property zoned for commercial use'),
('Special Purpose', 'Property zone for other purpose');
GO
 
 INSERT INTO tblFEATURE_TYPE
(FeatureTypeName, FeatureTypeDesc)
Values ('Indoor', 'Indoor feature'),
('Outdoor', 'Outdoor feature');
GO
 
INSERT INTO tblUNIT_TYPE
(UnitTypeName, UnitTypeDesc) 
Values ('Studio', 'Open floor plan'),
('Loft', 'Large open room with high ceilings'),
('One bedroom', 'Apartment with one bedroom'),
('Two Bedroom', 'Apartment with 2 bedrooms'),
('Three Bedroom', 'Apartment with 3 bedrooms');
GO
 
INSERT INTO tblAMENITY_TYPE
(AmenityTypeName, AmenityTypeDesc)
Values ('Indoor', 'Indoor feature'),
('Outdoor', 'Outdoor feature');
GO

INSERT INTO tblFEE_TYPE
(FeeTypeName, FeeTypeDesc)
Values ('Application Fee', 'Fee for submitting apartment application'),
 ('Security Deposit', 'Deposit for apartment damages'),
 ('Late fee', 'Fee for rent paid past due date'),
 ('Cleaning fee', 'Fee for apartment cleaning and sanitation');
GO
 
INSERT INTO tblSPECIAL_NEED
(SpecialNeedName, SpecialNeedDesc)
Values ('Quiet hours', 'Quiet time 10pm-7am'),
  ('Package delivery', 'Package delivery to door'),
  ('Service animal', 'Service dog');
GO

