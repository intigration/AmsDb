

-------------------------------------------------------------------------------
-- AmsUdf_CurrentSoftwareRevision 
--
-- Returns the current software revision for the given block key.
--
-- Inputs --
--	@nBlockKey - The block key for which to get the current software revision for.
--
-- Outputs --
--	SoftwareRevision as int
--
-- Author --
--	Corey Middendorf
--	10/21/04
--
CREATE FUNCTION AmsUdf_CurrentSoftwareRevision 
(@nBlockKey int)  
RETURNS int

AS  
BEGIN 


return (SELECT TOP 1 
		SoftwareRev = case ParamData
		when NULL then 0
			else
				dbo.AmsUdf_BinaryToInt(CONVERT(binary, dbo.BlockData.ParamData))
			end
	FROM	dbo.BlockData INNER JOIN
		dbo.EventLog ON dbo.BlockData.EventIdDay = dbo.EventLog.EventIdDay AND dbo.BlockData.EventIdFraction = dbo.EventLog.EventIdFraction
		AND dbo.BlockData.ParamName = N'software_revision.0000009E.0000.0000'
	WHERE	dbo.BlockData.BlockKey = @nBlockKey
	ORDER BY dbo.EventLog.EventTime desc)
END

GO

