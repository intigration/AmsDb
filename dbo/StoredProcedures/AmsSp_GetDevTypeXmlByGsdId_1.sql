-----------------------------------------------------------------------
-- AmsSp_GetDevTypeXmlByGsdId_1
--
-- Get device type info by GsdId.
--
-- Inputs -
--	@nGsdId      		int
--
-- Outputs -	Xml with the following format
--
--<AmsSp_GetDevTypeXmlByGsdId_1>
--  <Manufacturer MfrName="MyMfrName" MfrId="9999" GsdId="12345" Protocol="PROFIBUS-DP">
--    <DeviceType DevTypeName="MyDevTypeName" DevTypeCode="8888">
--      <DeviceRevision DevRevName="1" DevRevCode="1" />
--      <DeviceRevision DevRevName="2" DevRevCode="2" />
--    </DeviceType>
--    <DeviceType DevTypeName="MyDevTypeName2" DevTypeCode="88882">
--      <DeviceRevision DevRevName="1" DevRevCode="1" />
--    </DeviceType>
--  </Manufacturer>
--</AmsSp_GetDevTypeXmlByGsdId_1>
--
-- Returns -
--	-1 - general error.
--
-- Nghy Hong, 08/14/2009
-- Nghy Hong, 01/30/2012	- Added Protocol as attribute to Manufacturer section of the xml.
--
CREATE PROCEDURE AmsSp_GetDevTypeXmlByGsdId_1
@nGsdId int
AS
declare @Return_Value int;
set @Return_Value = 0;
set nocount on;

Begin Try;
	WITH Manufacturer
	as
	(
		select Manufacturer as MfrName, MfrId, ExtPropertyValue as GsdId, Protocol
		from   AmsVw_DeviceTypes INNER JOIN
			   DevRevExtProperty on AmsVw_DeviceTypes.AmsDevRevId = DevRevExtProperty.AmsDevRevId
		where (DevRevExtProperty.ExtPropertyName = N'GsdId') AND (DevRevExtProperty.ExtPropertyValue = @nGsdId)
	),
	DeviceType 
	as 
	(
		select distinct DeviceTypeName as DevTypeName, 
		                DeviceTypeCode as DevTypeCode, 
						MfrId,
						Protocol as ProtocolName
		from   AmsVw_DeviceTypes INNER JOIN
			   DevRevExtProperty on AmsVw_DeviceTypes.AmsDevRevId = DevRevExtProperty.AmsDevRevId
		where (DevRevExtProperty.ExtPropertyName = N'GsdId') AND (DevRevExtProperty.ExtPropertyValue = @nGsdId)
	),
	DeviceRevision 
	as 
	(
		select distinct DeviceRevisionName as DevRevName, DeviceRevisionCode as DevRevCode, DeviceTypeCode
		from   AmsVw_DeviceTypes INNER JOIN
			   DevRevExtProperty on AmsVw_DeviceTypes.AmsDevRevId = DevRevExtProperty.AmsDevRevId
		where (DevRevExtProperty.ExtPropertyName = N'GsdId') AND (DevRevExtProperty.ExtPropertyValue = @nGsdId)
	)
	select distinct MfrName, MfrId = Manufacturer.MfrId, GsdId, Protocol, 
					DevTypeName, DevTypeCode,
					DevRevName, DevRevCode, ProtocolName = DeviceType.ProtocolName
	from Manufacturer, DeviceType, DeviceRevision
	where Manufacturer.MfrId = DeviceType.MfrId
		and DeviceType.DevTypeCode = DeviceRevision.DeviceTypeCode
	for xml auto, type, root('AmsSp_GetDevTypeXmlByGsdId_1')

End Try
Begin Catch
	set @Return_Value = -1;
End Catch;

return @Return_Value;

GO

