-----------------------------------------------------------------------
-- AmsSp_DevBlk_PutHostTag_1
--
-- Set the HostTag for the device-block.
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
--	@sValue	nvarchar(1024)		HostTag
--
-- Outputs -
--	none
--	
--
-- Returns -
--	0 - successful.
--	-1 - warning- zero records affected- ie. deviceBlockKey not found
--  -2 - error- we had an error while trying to update
--
-- Nghy Hong - 10/17/2008
--

CREATE PROCEDURE AmsSp_DevBlk_PutHostTag_1
@nDevLevelBlockKey int,
@sValue nvarchar(1024)
AS
declare @iReturnVal int
set @iReturnVal = 0

set nocount on

Begin Try
	UPDATE DeviceLocation with (rowlock) set HostTag = @sValue where BlockKey = @nDevLevelBlockKey
	if @@rowcount = 0
	begin
		set @iReturnVal = -1
	end
End Try
Begin Catch
	set @iReturnVal = -2
End Catch

return @iReturnVal

GO

