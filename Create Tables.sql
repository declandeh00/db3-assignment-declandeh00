Drop Database caugdi1_IN705Assignment1

Create Database caugdi1_IN705Assignment1

go

Use caugdi1_IN705Assignment1

go

Create Table Category (
	CategoryID Int Identity(1,1) PRIMARY KEY,
	CategoryName Varchar (30) Not NULL
	)

go

Create Table Contact(
	ContactID Int Identity(1,1) PRIMARY KEY,
	ContactName Varchar (255) Not NULL,
	ContactPhone Varchar (25) Not NULL,
	ContactFax Decimal (10, 0),
	ContactMobilePhone Varchar (17),
	ContactEmail Varchar (255),
	ContactWWW Varchar (255),
	ContactPostalAddress Varchar (255) Not NULL
)

go

Create Table Supplier(
	SupplierID Int Primary Key,
	SupplierGST Decimal default 0.15 Not NULL
	Foreign Key (SupplierID) References Contact (ContactID) On Delete No Action On Update No Action
)

go

Create Table Component(
	ComponentID Int Identity(1,1) PRIMARY KEY ,
	ComponentName Varchar (15) Not NULL,
	ComponentDescription Varchar (255) Not NULL,
	TradePrice Money Not NULL CHECK (TradePrice >= 0),
	ListPrice Money Not NULL CHECK (ListPrice >= 0),
	TimeToFit Decimal (2,2) Not NULL CHECK (TimeToFit >= 0),
	CategoryID Int Not NULL,
	SupplierID Int Not NULL,
	Foreign Key (CategoryID) References Category (CategoryID) On Delete No Action On Update No Action,
	Foreign Key (SupplierID) References Supplier (SupplierID)
)

go


Create Table Customer(
	CustomerID Int PRIMARY KEY,
	Foreign Key (CustomerID) References Contact (ContactID) On Delete Cascade On Update Cascade
)

go

Create Table Quote(
	QuoteID Int Identity(1,1) PRIMARY KEY,
	QuoteDescription Varchar (255) Not NULL,
	QuoteDate DateTime Not NULL,
	QuotePrice Money CHECK (QuotePrice >= 0),
	QuoteCompiler Varchar (255) Not NULL,
	CustomerID Int Not NULL,
	Foreign Key (CustomerID) References Customer (CustomerID) On Delete No Action On Update Cascade
)

go

Create Table QuoteComponent(
	ComponentID Int,
	QuoteID Int,
	Quantity Int Not NULL,
	TradePrice Money Not NULL CHECK (TradePrice >= 0),
	ListPrice Money Not NULL CHECK (ListPrice >= 0),
	TimeToFit Decimal (2, 2) Not NULL CHECK (TimeToFit >= 0),
	Primary Key (ComponentID, QuoteID),
	Foreign Key (ComponentID) References Component (ComponentID) On Delete No Action,
	Foreign Key (QuoteID) References Quote (QuoteID) On Delete Cascade On Update Cascade

)

go

Create Table AssemblySubcomponent(
	AssemblyID Int Not NULL ,
	SubcomponentID Int Not NULL,
	Quantity Int Not NULL,
	Primary Key (AssemblyID, SubcomponentID),
	Foreign Key (AssemblyID) References Component (ComponentID) On Delete No Action,
	Foreign Key (SubcomponentID) References Component (ComponentID) On Delete No Action
)

go