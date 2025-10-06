----------------------------------------------------------------------
-- AmsSp_NotifyQ_PushRenameDevice_1
--
-- Update the AAL based on a rename device operation.
-- Note: it should have been verified that the device was in the scanList
-- prior to this call and the associated plantServerKey is supplied.
--
-- Inputs -
--  @nPlantServerKey - the plantServer the device is associated with.
--	@nBlockKey - the device that is being renamed.
--
-- Outputs -
--  none.
--
-- Returns -
--	0 - successful.
--	-1 - Error.
--
-- Joe Fisher 10/27/2004
--
CREATE PROCEDURE AmsSp_NotifyQ_PushRenameDevice_1
@nPlantServerKey int,
@nBlockKey int
AS

set nocount on

declare @nReturn int
set @nReturn = 0

declare @nNotifyType int
declare @sNotifyData nvarchar(max)
exec @nReturn = AmsSp_NotifyData_BuildRenameDevice_1 @nBlockKey,
													 @nPlantServerKey,
														@nNotifyType output,
														@sNotifyData output

-- push the notification onto the queue.
exec @nReturn = AmsSp_NotifyQ_Push_1 @nNotifyType, @sNotifyData
if (@nReturn <> 0) 
begin
	return -1
end

return @nReturn

GO

