
-----------------------------------------------------------------------
-- AmsSp_GetDeviceTypeTemplateInfo_1
--
-- Get the template information for this device type.
--
-- Inputs -
--	manufactuerName
--	protocolName
--	deviceTypeName
--	deviceRevisionName
--
-- Outputs -
--	Recordset --
--		ConfigName as nvarchar
--		ConfigType as nvarchar
--		ProtocolRevision as nvarchar
--		H275 as integer
--
-- Returns -
--	0 - success.
--	-1 - not found.
--
-- Joe Fisher, 4/8/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetDeviceTypeTemplateInfo_1
@sMfrName as nvarchar(255),
@sProtocolName as nvarchar(255),
@sDeviceTypeName as nvarchar(255),
@sDeviceRevisionName as nvarchar(255)
AS
declare @iReturnVal int
set @iReturnVal = 0

SELECT NamedConfigs.ConfigName, 
    NamedConfigs.ConfigType, 
    ProtocolRevision = 
	case
	    when NamedConfigs.UniversalId is NULL then '0'
	    else NamedConfigs.UniversalId
	end, 
    IsUserConfig =
	case
	    when NamedConfigs.H275 = 0 then 'No'
	    else 'Yes'
	end
FROM Manufacturers INNER JOIN
    MfrProtocols ON 
    Manufacturers.AmsMfrNameId = MfrProtocols.AmsMfrNameId
     INNER JOIN
    DeviceProtocols ON 
    MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId INNER
     JOIN
    DeviceTypes ON 
    MfrProtocols.MfrProtocolId = DeviceTypes.MfrProtocolId
     INNER JOIN
    DeviceRevisions ON 
    DeviceTypes.AmsDevTypeId = DeviceRevisions.AmsDevTypeId
     INNER JOIN
    NamedConfigs ON 
    DeviceRevisions.AmsDevRevId = NamedConfigs.AmsDevRevId
WHERE (Manufacturers.Name = @sMfrName) AND 
    (DeviceProtocols.Name = @sProtocolName) AND 
    (DeviceTypes.Name = @sDeviceTypeName) AND 
    (DeviceRevisions.Name = @sDeviceRevisionName)

if (@@ERROR <> 0)
    set @iReturnVal = -1

return @iReturnVal

GO

