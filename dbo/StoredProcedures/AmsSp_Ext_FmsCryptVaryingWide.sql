CREATE PROCEDURE [dbo].[AmsSp_Ext_FmsCryptVaryingWide]
@sInputString NVARCHAR (MAX) NULL, @sOutputString NVARCHAR (MAX) NULL OUTPUT
AS EXTERNAL NAME [EmersonAmsDbSqlServerSProc].[Emerson.AMS.Private.AmsDb.SProc.SProcClass].[FmsCryptVaryingWide]


GO

