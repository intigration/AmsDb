
CREATE PROCEDURE AmsSp_Diag_Analyze_1
as
set nocount on

-- place your analysis modules here.
exec AmsSp_DiagAnalysis_DeviceTypes_1

return

GO

