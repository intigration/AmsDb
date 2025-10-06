
-----------------------------------------------------------------------
-- AmsSp_GetDeviceTypeProtocolRev_1
--
-- Get the protocolRevision for the specified deviceType.
--
-- Inputs -
--	manufactuerName
--	protocolName
--	deviceTypeName
--	deviceRevisionName
--
-- Outputs -
--	protocolRev
--
-- Returns -
--	0 - success.
--	-1 - not found.
--	-2 - error.
--
-- Joe Fisher, 1/5/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetDeviceTypeProtocolRev_1
@sMfrName as nvarchar(255),
@sProtocolName as nvarchar(255),
@sDeviceTypeName as nvarchar(255),
@sDeviceRevisionName as nvarchar(255),
@sProtocolRev as nvarchar(255) OUTPUT
AS
declare @iReturnVal int
set @iReturnVal = 0

SELECT TOP 1 @sProtocolRev = NamedConfigs.UniversalId
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
     INNER JOIN
    NamedConfigs ON 
    DeviceRevisions.AmsDevRevId = NamedConfigs.AmsDevRevId
WHERE (Manufacturers.Name = @sMfrName) AND 
    (DeviceProtocols.Name = @sProtocolName) AND 
    (DeviceTypes.Name = @sDeviceTypeName) AND 
    (DeviceRevisions.Name = @sDeviceRevisionName)

if (@sProtocolRev is NULL)
begin
    -- data not found.
    set @iReturnVal = -1
end

if (@@ERROR <> 0)
    set @iReturnVal = -2

return @iReturnVal

GO

