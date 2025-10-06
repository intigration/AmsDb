
-------------------------------------------------------------------------------
-- AmsUdf_IsAlertDisplayable 
--
-- Inputs --
--  @nBlockKey - Block identifier of device.
--	@sAlertId  - The alertId.
--
-- Outputs --
--	True (<>0) if this Alert is enabled else false (=0)
--
-- Author --
--	James Kramer 11/26/2007
--
--
CREATE FUNCTION AmsUdf_IsAlertDisplayable 
(@nBlockKey int,  @sAlertId nvarchar(256))  
RETURNS bit 
AS  
BEGIN 

declare @bReturn bit
set @bReturn = 0

declare @nEnabled int
set @nEnabled = 2

SELECT @nEnabled = Enabled 
FROM AlertFilterForDevice INNER JOIN
	 DeviceAlertDesc ON	AlertFilterForDevice.AlertDescId = DeviceAlertDesc.AlertDescId
WHERE AlertFilterForDevice.BlockKey = @nBlockKey AND DeviceAlertDesc.AlertId = @sAlertId

if (@nEnabled = 1)
begin
	set @bReturn = 1
end

Return @bReturn

END

GO

