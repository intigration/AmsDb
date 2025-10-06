----------------------------------------------------------------------
-- AmsSp_Device_GetFFAlarmInfo_1
--
-- Get the FFAlarmInfo recordset for the given FF device.
--
-- Inputs -
--	@sFFDeviceId nvarchar(255) - the FF device id.
--
-- Outputs -
--	@nMfrId int  - the manufacturer id.
--	@nDeviceTypeCode int - the device type code.
--	@nDeviceRevisionCode int - the device revision code.
--	@nAlarmBlockIndex int - the block designated as the normal alarmBlock.
--
-- Recordset -
--	(see select statement)
--
-- Returns -
--	0 - successful.
--  -1 - device not in database.
--	-2 - Error, general error.
--
-- Joe Fisher 11/03/2004
--
CREATE PROCEDURE AmsSp_Device_GetFFAlarmInfo_1
@sFFDeviceId nvarchar(255),
@nMfrId int output,
@nDeviceTypeCode int output,
@nDeviceRevisionCode int output,
@nAlarmBlockIndex int output
AS
declare @nReturn int
set @nReturn = 0

set @nMfrId = -99
set @nDeviceTypeCode = -1
set @nDeviceRevisionCode = -1
set @nAlarmBlockIndex = -1

--print '@sFFDeviceId= ' + @sFFDeviceId

-- need to get the device's devRevId.
declare @nDevRevDbKey int
set @nDevRevDbKey = -99
select top 1 @nDevRevDbKey = AmsDevRevId from Devices where Identifier = @sFFDeviceId
--print '@nDevRevDbKey= ' + cast(@nDevRevDbKey as nvarchar(20))
if @nDevRevDbKey = -99
	return -1	-- device not found.

-- now get the deviceType info.
select top 1 @nMfrId = MfrId,
			 @nDeviceTypeCode = DeviceTypeCode,
			 @nDeviceRevisionCode = DeviceRevisionCode
		from AmsVw_DeviceTypes
		where AmsDevRevId = @nDevRevDbKey
if @nMfrId = -99
	return -2	-- we should absolutely not get here!!

-- get the device's alarmBlockIndex.
SELECT @nAlarmBlockIndex = dbo.AmsUdf_BinaryToInt(cast(dbo.NamedConfigData.ParamData as varbinary(4)))
FROM  dbo.NamedConfigData INNER JOIN dbo.NamedConfigs ON dbo.NamedConfigData.ConfigKey = dbo.NamedConfigs.ConfigKey
WHERE (dbo.NamedConfigData.ParamName = 'frsi.AlarmBlockIndex') AND (dbo.NamedConfigs.AmsDevRevId = @nDevRevDbKey)

-- now get the alarmInfo recordset.
SELECT     dbo.AmsUdf_AlertTypeUidFromParamName(dbo.NamedConfigData.ParamName) as AlertTypeUid,
		   case 
				when ((cast(dbo.NamedConfigData.ParamData as int) - @nAlarmBlockIndex) > 0)
					then (cast(dbo.NamedConfigData.ParamData as int) - @nAlarmBlockIndex)
					else cast(dbo.NamedConfigData.ParamData as int)
		   end [RelativeIndex]
FROM  dbo.NamedConfigData INNER JOIN dbo.NamedConfigs ON dbo.NamedConfigData.ConfigKey = dbo.NamedConfigs.ConfigKey
WHERE     (dbo.NamedConfigData.ParamName LIKE 'frsi.DeviceAlarm.%') AND (dbo.NamedConfigs.AmsDevRevId = @nDevRevDbKey)

return @nReturn

GO

