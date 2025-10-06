-----------------------------------------------------------------------
-- AmsSp_GetDeviceCountsByProtocol_1
--
-- Get device counts for each of the protocols.
--
--
-- Inputs -
--	none
--
-- Outputs -
--	recordset with the following columns --
--		Protocol	nvarchar(256)
--		Count		int
--	
--
-- Joe Fisher - 08/15/2006
--

CREATE PROCEDURE AmsSp_GetDeviceCountsByProtocol_1
AS
set nocount on

SELECT     dbo.DeviceProtocols.Name AS Protocol, COUNT(*) AS Ct
FROM         dbo.MfrProtocols with (nolock) INNER JOIN
                      dbo.DeviceProtocols with (nolock) ON dbo.MfrProtocols.ProtocolId = dbo.DeviceProtocols.ProtocolId INNER JOIN
                      dbo.DeviceTypes with (nolock) ON dbo.MfrProtocols.MfrProtocolId = dbo.DeviceTypes.MfrProtocolId INNER JOIN
                      dbo.DeviceRevisions with (nolock) ON dbo.DeviceTypes.AmsDevTypeId = dbo.DeviceRevisions.AmsDevTypeId INNER JOIN
                      dbo.Devices with (nolock) ON dbo.DeviceRevisions.AmsDevRevId = dbo.Devices.AmsDevRevId
GROUP BY dbo.DeviceProtocols.Name
HAVING      (dbo.DeviceProtocols.Name <> 'Unknown')

GO

