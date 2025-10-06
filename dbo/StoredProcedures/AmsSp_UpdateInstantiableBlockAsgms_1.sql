----------------------------------------------------------------------------
-- AmsSp_UpdateInstantiableBlockAsgms_1
--
--  Adding new instantiable function block assignments 
--  or updating the existing instantiable function blockassignments.
--  
-- 
-- Input:
--  @InstantiableBlockKey - key referencing the device's function block
--  @DDItemId - function block item identifier.
--
---- Output: -
--	@Error - Error message to be sent up the chain
--
-- Returns -
--	0 - successful.
--	-1 - error.
--
-- Nghy Hong - 06/01/2011
CREATE PROCEDURE AmsSp_UpdateInstantiableBlockAsgms_1
@InstantiableBlockKey int,
@DDItemId nvarchar(255),
@Error nvarchar(max) output
AS
declare @nReturn int;
set @nReturn = 0;
set @Error = N'';

BEGIN TRY
	declare @BlocKKey_Fetch int;
	declare @DDItemId_Fetch nvarchar(255);
	declare @UtcOut_Fetch datetime2, @UtcIn_Fetch datetime2;
	declare @CurrentUtcDateTime datetime2;
	declare @MaxDateTimeRange datetime2;
	set @BlocKKey_Fetch = -1;
	set @DDItemId_Fetch = N'';
	
	set @CurrentUtcDateTime = SYSUTCDATETIME();
	set @MaxDateTimeRange = N'9999-12-31';

	--Fetch the BlockKey and DDItemId for the given Block-Index.
	select top(1) @BlocKKey_Fetch = InstantiableBlockKey, @DDItemId_Fetch = DDItemId, 
	@UtcIn_Fetch = UtcDateTimeIn, @UtcOut_Fetch = UtcDateTimeOut
	from InstantiableBlockAsgms
	where InstantiableBlockKey = @InstantiableBlockKey
	order by UtcDateTimeOut desc;  
	
	if ( @BlocKKey_Fetch != @InstantiableBlockKey )
	begin
		--Case 1 (Block-Index does not exist)
		--Insert a new record.
		--Note:  UtcDateTimeOut is automaticlly defaulted to '9999-12-31 00:00:00.0000000' (max DateTime range).
		Insert into InstantiableBlockAsgms
		(InstantiableBlockKey, DDItemId, UtcDateTimeIn)
		values(@InstantiableBlockKey, @DDItemId, @CurrentUtcDateTime);
	end
	else if ( @DDItemId_Fetch != @DDItemId ) or ( @UtcOut_Fetch != @MaxDateTimeRange)
	begin
		--Case 2 (Block-Index does exist but DDItemId is different)
		--and case 3 (Block-Index and DDItemId pair does exist but not currently applicable to the device)
		--1.  Update the UtcDateTimeOut of the current DDItemId to the current datetime 
		Update InstantiableBlockAsgms
		set UtcDateTimeOut = @CurrentUtcDateTime
		where InstantiableBlockKey = @BlocKKey_Fetch and DDItemId = @DDItemId_Fetch 
		and UtcDateTimeIn = @UtcIn_Fetch and UtcDateTimeOut = @UtcOut_Fetch;
		
		--2.  Insert a new record for the new DDItemId.
		Insert into InstantiableBlockAsgms
		(InstantiableBlockKey, DDItemId, UtcDateTimeIn)
		values(@InstantiableBlockKey, @DDItemId, @CurrentUtcDateTime);
		
	end

	--If the BlockKey and DDItemId do not fall in the above cases,
	--then do nothing since this particular Block-Index and DDItemId pair already exists 
	--and is currently applicable to the device.

END TRY
BEGIN CATCH
	set @nReturn = -1;
	set @Error = ERROR_MESSAGE();
END CATCH

return @nReturn;

GO

