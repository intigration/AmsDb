CREATE PROCEDURE [dbo].[AmsSp_Ext_FmsCryptVaryingNarrow]
@sInputString NVARCHAR (MAX) NULL, @sOutputString NVARCHAR (MAX) NULL OUTPUT
AS EXTERNAL NAME [EmersonAmsDbSqlServerSProc].[Emerson.AMS.Private.AmsDb.SProc.SProcClass].[FmsCryptVaryingNarrow]


GO

