-----------------------------------------------------------------------
-- AmsSp_DevManufacturer_GetAddId_1
--
-- Get device manufacture Id. if not found, then add it.
--
-- Inputs -
--	@sMfrName nvarchar(255)
--		Manufacturer name
--	@sDescription nvarchar(255)
--		Manufacturer Description
--
-- Outputs -
--	nMfrId
--
-- Returns -
--	0 - successful.
--	-1 - Error, unable to get mfr id.
--
-- Jane Xiao (6/23/2003)
--

CREATE PROCEDURE AmsSp_DevManufacturer_GetAddId_1
@sMfrName nvarchar(255),
@sDescription nvarchar(255),
@nMfrNameId int OUTPUT
AS

declare @iReturnVal int
set @iReturnVal = 0

-- get ManufacturerID if present.
select @nMfrNameId = AmsMfrNameId
from Manufacturers
where Name = @sMfrName

if @@rowcount = 0 
--mfr name not found, add it
begin
	-- get the next AmsMfrNameId
	declare @NextMfrId int
	select @NextMfrId = max(AmsMfrNameId) + 1 from Manufacturers
	-- add mfr to db
	insert Manufacturers (AmsMfrNameId, Name, Description)
	values (@NextMfrId, @sMfrName, @sDescription)
	if (@@ERROR <> 0)
	begin
		set @iReturnVal = -1
	end
	else --get new ID
	begin
		set @nMfrNameId = @NextMfrId
	end
end

return @iReturnVal

GO

