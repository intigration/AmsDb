CREATE PROCEDURE [dbo].[AmsSp_Ext_ConvertToEightCharacterHARTAlert]
@sHex NVARCHAR (256) NULL, @sEight NVARCHAR (256) NULL OUTPUT
AS EXTERNAL NAME [EmersonAmsDbSqlServerSProc].[Emerson.AMS.Private.AmsDb.SProc.SProcClass].[ConvertToEightCharacterHARTAlert]


GO

