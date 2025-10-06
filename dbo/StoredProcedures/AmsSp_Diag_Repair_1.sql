
CREATE PROCEDURE AmsSp_Diag_Repair_1
as
set nocount on

declare @nReturn int
set @nReturn = -1

-- place your repair modules here.
exec @nReturn = AmsSp_FixDupDevTypes_1

return @nReturn

GO

