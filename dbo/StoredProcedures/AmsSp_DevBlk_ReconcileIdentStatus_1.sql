-----------------------------------------------------------------------
-- AmsSp_DevBlk_ReconcileIdentStatus_1
--
-- Reconcile the identStatus for the device-block based on deviceLocation.HostPath.
--
-- Algorithm --
--	If the supplied hostPath is different from what is currently in the database, the identStatus will NOT
--  be changed; else, the identStatus will be set to 'unknown or (0)'.
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
--  @sHostPath			nvarchar(1024)	the hosePath to reconcile with what is in the database.
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
-- Joe Fisher - 08/23/2004
--

CREATE PROCEDURE AmsSp_DevBlk_ReconcileIdentStatus_1
@nDevLevelBlockKey int,
@sHostPath nvarchar(1024)
AS
declare @iReturnVal int
set @iReturnVal = 0
declare @sDbHostPath nvarchar(1024)
set @sDbHostPath = ''

set nocount on

select top 1 @sDbHostPath = HostPath from DeviceLocation with (nolock) where BlockKey = @nDevLevelBlockKey

if @@rowcount = 1
begin
	if @sDbHostPath = @sHostPath
	begin
		-- we have the same hostPath; set the identStatus to 'unknown'
		exec AmsSp_DevBlk_PutIdentStatus_1 @nDevLevelBlockKey, '0'
	end
	set @iReturnVal = 0
end
else
begin
	set @iReturnVal = -1 -- did not find device in deviceLocation table.
end

if @@error <> 0
begin
	set @iReturnVal = -2 -- general error.
end

return @iReturnVal

GO

