
-----------------------------------------------------------------------
-- AmsSp_GetDeviceTypes_1
--
-- Get list of device types with the following information (see output section.)
-- Note: this filters out the standard default.
--
-- Inputs -
--	none.
--
-- Outputs -
--	Recordset with the following --
--		Manufacturer
--		Protocol
--		MfrId
--		DeviceTypeCode
--		DeviceTypeName
--		DeviceRevisionCode
--		DeviceRevisionName
--		ProtocolRevision
--
-- Returns -
--	returns number of records in recordset.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 12/27/2000
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetDeviceTypes_1
AS

declare @iReturnVal int
set @iReturnVal = 0

SELECT DISTINCT  Manufacturers.Name AS Manufacturer, 
    DeviceProtocols.Name AS Protocol, MfrProtocols.MfrId, 
    DeviceTypes.DeviceType as DeviceTypeCode, 
    DeviceTypes.Name AS DeviceTypeName, 
    DeviceRevisions.DeviceRevision as DeviceRevisionCode, 
    DeviceRevisions.Name AS DevRevisionName, 
    ProtocolRevision = 
	case
	    when NamedConfigs.UniversalId is NULL then '0'
	    else NamedConfigs.UniversalId
	end
FROM Manufacturers INNER JOIN
    MfrProtocols ON 
    Manufacturers.AmsMfrNameId = MfrProtocols.AmsMfrNameId INNER
     JOIN
    DeviceProtocols ON 
    MfrProtocols.ProtocolId = DeviceProtocols.ProtocolId INNER JOIN
    DeviceTypes ON 
    MfrProtocols.MfrProtocolId = DeviceTypes.MfrProtocolId INNER JOIN
    DeviceRevisions ON 
    DeviceTypes.AmsDevTypeId = DeviceRevisions.AmsDevTypeId
     LEFT OUTER JOIN
    NamedConfigs ON 
    DeviceRevisions.AmsDevRevId = NamedConfigs.AmsDevRevId
WHERE (Manufacturers.Name <> 'Default')
order by Manufacturers.name,
	MfrProtocols.MfrId,
	deviceProtocols.name, 
	deviceTypes.DeviceType,
	deviceTypes.name,
	deviceRevisions.deviceRevision,
	deviceRevisions.name

declare @Err int, @Rcount int
select @Err = @@ERROR, @Rcount = @@ROWCOUNT

if (@Err <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = @Rcount

return @iReturnVal

GO

