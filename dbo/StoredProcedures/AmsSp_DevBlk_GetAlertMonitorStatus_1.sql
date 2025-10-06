-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetAlertMonitorStatus_1
--
-- Get the AlertMonitorStatus for the device-block.
--
-- Inputs -
--	@nDevLevelBlockKey	int		device level blockKey.
--
-- Outputs -
--	@sValue nvarchar(1024)	string value of state --
--		'0' = unknown staus (i.e. error)
--		'1' = device is not in DeviceMonitorList.
--		'2' = device is in DeviceMonitorList and polling is enabled.
--		'3' = device is in scanlist but polling is disabled.
--
-- Returns -
--	0 - successful.
--	-1 - warning- deviceBlockKey not found
--  -2 - error- we had an error while trying to get data.
--
-- James Kramer 11/27/2007
--

CREATE PROCEDURE AmsSp_DevBlk_GetAlertMonitorStatus_1
@nDevLevelBlockKey int,
@sValue nvarchar(1024) output
AS
declare @iReturnVal int
set @iReturnVal = 0
set @sValue = '0' -- unknown

set nocount on
declare @nDMLItem int
declare @nAlertMonitorEnabled bit
select @nDMLItem = DeviceMonitorList.BlockKey,
	   @nAlertMonitorEnabled = PlantServer.AlertMonitorEnabled
	from DeviceMonitorList with (nolock) inner join
		 AmsVw_DeviceTagLocation on AmsVw_DeviceTagLocation.BlockKey = DeviceMonitorList.BlockKey inner join
		 PlantServer on PlantServer.PlantServerKey = AmsVw_DeviceTagLocation.PlantServerKey
	where DeviceMonitorList.BlockKey = @nDevLevelBlockKey

if @@rowcount = 1
begin
	if (@nAlertMonitorEnabled = 1)
	begin
		set @sValue = '2'  -- device is in DeviceMonitorList and polling is enabled.
	end
	else
	begin
		set @sValue = '3'  -- device is in DeviceMonitorList but alertMonitor is disabled for the plantServer.
	end
end
if @@rowcount = 0
begin
	set @sValue = '1' -- device is not in DeviceMonitorList
end
if @@error <> 0
begin
	set @iReturnVal = -2
end

return @iReturnVal

GO

