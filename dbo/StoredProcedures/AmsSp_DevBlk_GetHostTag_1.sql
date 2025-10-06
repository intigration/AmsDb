-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetHostTag_1
--
-- Get the HostTag for the device-block.
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
--
-- Outputs -
--	@sValue nvarchar(1024)	HostTag
--	
--
-- Returns -
--	0 - successful.
--	-1 - warning- deviceBlockKey not found
--  -2 - error- we had an error while trying to get data.
--
-- Nghy Hong - 10/17/2008
--

CREATE PROCEDURE AmsSp_DevBlk_GetHostTag_1
@nDevLevelBlockKey int,
@sValue nvarchar(1024) output
AS
declare @iReturnVal int
set @iReturnVal = 0
set @sValue = ''

declare @sHostTag nvarchar(1024)

set nocount on

Begin Try
	select top 1 @sHostTag = HostTag from DeviceLocation with (nolock) where BlockKey = @nDevLevelBlockKey

	if @@rowcount = 1
	begin
		set @sValue = @sHostTag
	end
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

