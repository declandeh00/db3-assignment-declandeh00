Use caugdi1_IN705Assignment1 

/* Creating getCategoryID Function*/

Go

Create or alter Function dbo.getCategoryID(@CatName Varchar (30))
Returns Int
As
Begin
	Return (Select Top 1 CategoryID
			From Category
			Where CategoryName = @CatName)
End

Go

/* Creating getAssemblySupplierID Function*/

Go
Create or alter Function dbo.getAssemblySupplierID()
Returns Int
As
Begin
	Return(Select Top 1 ContactID
			From Contact
			Where ContactName = 'BIT Manufacturing Ltd.')

End

Go

print dbo.getAssemblySupplierID()

/* Creating createAssembly Procedure */

Go

Create or alter Proc dbo.createAssembly
(@componentName Varchar (15),
@componentDescription Varchar (255))
As
set nocount on
Insert Component(ComponentName, ComponentDescription, TradePrice, ListPrice, TimeToFit, CategoryID, SupplierID)
Values(@componentName, @componentDescription, 0, 0, 0, dbo.getAssemblySupplierID(), dbo.getCategoryID('Assembly'))

Go


/* Creating addSubComponent Procedure */

Go

Create or alter Proc dbo.addSubComponent
(@assemblyName Varchar (15),
@subComponentName Varchar (15),
@quantity Int)
As
set nocount on
Insert Into AssemblySubcomponent(AssemblyID, SubcomponentID, Quantity)
Select C1.ComponentID, C2.ComponentID, @quantity
From Component C1, Component C2
Where @assemblyName = C1.ComponentName And @subComponentName = C2.ComponentName

Go


--create assemblies
exec createAssembly  'SmallCorner.15', '15mm small corner'
exec dbo.addSubComponent 'SmallCorner.15', 'BMS.5.15', 0.120
exec dbo.addSubComponent 'SmallCorner.15', 'APPLAB', 0.33333
exec dbo.addSubComponent 'SmallCorner.15', '43', 0.0833333

exec dbo.createAssembly 'SquareStrap.1000.15', '1000mm x 15mm square strap'
exec dbo.addSubComponent 'SquareStrap.1000.15', 'BMS.5.15', 4
exec dbo.addSubComponent 'SquareStrap.1000.15', 'SmallCorner.15', 4
exec dbo.addSubComponent 'SquareStrap.1000.15', 'APPLAB', 25
exec dbo.addSubComponent 'SquareStrap.1000.15', 'ARTLAB', 10
exec dbo.addSubComponent 'SquareStrap.1000.15', '43', 0.185
exec dbo.addSubComponent 'SquareStrap.1000.15', 'BMS10', 8

exec dbo.createAssembly 'CornerBrace.15', '15mm corner brace'
exec dbo.addSubComponent 'CornerBrace.15', 'BMS.5.15', 0.090
exec dbo.addSubComponent 'CornerBrace.15', 'BMS10', 2

/* Creating createCustomer Stored Procedure */

Go

Create or alter Proc dbo.createCustomer(@ContactName Varchar (255),
@ContactPhone Varchar (25),
@ContactPostalAdd Varchar (255),
@ContactFax Decimal (10, 0) = null,
@ContactMobilePhone Varchar (17) = null,
@ContactEmail Varchar (255) = null,
@ContactWWW Varchar (255) = null
)
As
set nocount on
Begin
	
	Declare @ContactID INT
	
	Insert Contact(ContactName, ContactPhone, ContactPostalAddress, ContactFax, ContactMobilePhone, ContactEmail, ContactWWW)
	Values(@ContactName, @ContactPhone, @ContactPostalAdd, @ContactFax, @ContactMobilePhone, @ContactEmail, @ContactWWW)

	Set @ContactID = @@Identity

	Select @ContactID AS ContactID
End

Go

/* Creating createQuote Stored Procedure */

Go

Create or alter Proc dbo.createQuote(@QuoteDescription Varchar (255),
@QuoteDate DateTime = Null,
@QuotePrice Money = Null,
@QuoteCompiler Varchar (255),
@CustomerID Int,
@QuoteID Int Output
)
As
Set Nocount On
Begin

	if @QuoteDate is null set @QuoteDate = getdate()


	Insert Quote(QuoteDescription, QuoteDate, QuotePrice, QuoteCompiler, CustomerID)
	Values(@QuoteDescription, @QuoteDate, @QuotePrice, @QuoteCompiler, @CustomerID)

	Set @QuoteID = @@Identity
	
End

Go

Declare @QuoteID Int
exec dbo.createQuote 'Craypot frame', Null, Null, 'Declan de Haas', 4, @QuoteID output
print @QuoteID


/* Creating addQuoteComponent Stored Procedure */


Go

Create or alter Proc dbo.addQuoteComponent(@QuoteID Int,
@ComponentID Int,
@Quantity Int,
@TradePrice Money,
@ListPrice Money,
@TimeToFit Decimal (2,2)
)
As
Set Nocount On
Begin
	Insert QuoteComponent(QuoteID, ComponentID, Quantity, TradePrice, ListPrice, TimeToFit)
	Values (@QuoteID, @ComponentID, @Quantity, @TradePrice, @ListPrice, @TimeToFit)
End

Go

/* Use the stored procedures createCustomer, createQuote and addQuoteComponent to populate the database */



/* Creating cascade update on constraints FK_Assembly_Component and FK_Subcomponent_Component Trigger */

Go

Create or alter Trigger dbo.trigComponentUpdate_AssemblyID
On Component
After Update
As
Set Nocount On
Begin
	If Update(ComponentID)
	Begin
		Set IDENTITY_INSERT AssemblySubcomponent on
		Update [as]
		Set [as].AssemblyID = i.ComponentID
		From AssemblySubcomponent [as]
		Inner Join inserted i on [as].AssemblyID = i.ComponentID
		Set IDENTITY_INSERT AssemblySubcomponent off
	End
End

Go

Go

Create or alter Trigger dbo.trigComponentUpdate_SubcomponentID
On Component
After Update
As
Set Nocount On
Begin
	If Update(ComponentID)
	Begin
		Set IDENTITY_INSERT AssemblySubcomponent on
		Update [as]
		Set [as].SubcomponentID = i.ComponentID
		From AssemblySubcomponent [as]
		Inner Join inserted i on [as].SubcomponentID = i.ComponentID
		Set IDENTITY_INSERT AssemblySubcomponent off
	End
End

Go


/* Creating trigSupplierDelete Trigger */

Go

Create or alter Trigger dbo.trigSupplierDelete
On Supplier
Instead Of Delete
As
Set Nocount On
Begin
	Declare @SupplierID Int;
	Declare @SupplierName Varchar (255);
	Declare @ComponentCount Int;

	Select @SupplierID = d.SupplierID
	From deleted d

	Select @SupplierName = c.ContactName
	From Contact c
	Where c.ContactID = @SupplierID

	Select @ComponentCount = Count(*)
	From Component
	Where SupplierID = @SupplierID

	If @ComponentCount > 0
	Begin
		Raiserror('You cannot delete this supplier. %s has %i relatedcomponents.', 11, 1, @SupplierName, @ComponentCount)
	End
	Else
	Begin
		Delete From Supplier
		Where SupplierID = @SupplierID
	End
End

Go

/* Creating updateAssemblyPrices Stored Procedure */

Go

Create or alter Proc dbo.updateAssemblyPrices
As
Set Nocount On
Begin
	Create Table #TempAssemPrices(
	AssmeblyID Int Primary Key,
	TotalTradePrice Money Not Null,
	TotalListPrice Money Not Null
	)

	Insert Into #TempAssemPrices (AssmeblyID, TotalTradePrice, TotalListPrice)
	Select a.AssemblyID, Sum(c.TradePrice * a.Quantity), Sum(c.ListPrice * a.Quantity)
	From AssemblySubcomponent a
	Inner Join Component c On a.SubcomponentID = c.ComponentID
	Group By a.AssemblyID

	Update c
	Set c.TradePrice = tap.TotalTradePrice,
	c.ListPrice = tap.TotalListPrice
	From Component c
	Inner Join #TempAssemPrices tap On c.ComponentID = tap.AssmeblyID

	Drop Table #TempAssemPrices
End

Go