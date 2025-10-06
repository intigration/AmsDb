CREATE FUNCTION [dbo].[AmsUdf_Ext_IsHexadecimal]
(@sHex NVARCHAR (256) NULL)
RETURNS INT
AS
 EXTERNAL NAME [EmersonAmsDbSqlServerUdf].[Emerson.AMS.Private.AmsDb.Udf.UdfClass].[IsHexadecimal]


GO

