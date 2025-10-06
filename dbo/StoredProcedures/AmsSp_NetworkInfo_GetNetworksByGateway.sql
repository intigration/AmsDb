
CREATE PROCEDURE AmsSp_NetworkInfo_GetNetworksByGateway
	@sGateway NVARCHAR(1024),
	@sNetworkKind NVARCHAR(1024)
AS
BEGIN
	DECLARE @sqlQuery NVARCHAR(2000)
	DECLARE @iResult INT

	SET NOCOUNT ON;
	SET @iResult = -1
	
	DECLARE @NetworkList TABLE
	(	AmsServerName NVARCHAR(255),
		NetworkId NVARCHAR(255),
		NetworkName NVARCHAR(1024),
		NetworkKind NVARCHAR(1024),
		Propertykey NVARCHAR(256),
		PropertyValue NVARCHAR(256),
		NetworkInfoKey INT
	)
	
	INSERT INTO @NetworkList
	EXECUTE AmsSp_NetworkInfo_GetNetworks_1 @sNetworkKind = @sNetworkKind
			
	SELECT AmsServerName, NetworkId, NetworkName, NetworkKind, Propertykey, PropertyValue
	FROM @NetworkList
	WHERE 
		NetworkInfoKey IN 
		(SELECT NetworkInfoKey 
		FROM @NetworkList
		WHERE
			PropertyKey = 'Configured Gateways' AND
			PropertyValue LIKE '%' + @sGateway + '%')

	IF(@@ROWCOUNT > 0)
		SET @iResult = 0

	RETURN @iResult
END

GO

