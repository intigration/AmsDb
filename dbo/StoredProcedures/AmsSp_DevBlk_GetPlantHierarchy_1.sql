-----------------------------------------------------------------------
-- AmsSp_DevBlk_GetPlantHierarchy_1
--
-- Get the device-block Plant Hierarchy information as a single text output parameter.
-- Reason for expressing this information as one variable is to provide single property value
-- pattern for other deviceBlock type properties frameworks.
--
--
-- Inputs -
--	@nDeviceLevelBlockKey	int
--
-- Outputs -
--	@sValue	nvarchar(1024)
--  Note: format of @sValue is --
--		<isAssigned><a=<area>><u=<unit>><e=<equipment>><c=<control>>
--	  where <isAssigned> = <0> if device not assigned (or not found)
--						 = <1> if device is assigned
--					Note: if <isAssigned> = 0 then no further information is put in @sValue.
--	
--
-- Returns -
--	0 - successful.
--	-2 - Error, unable to get plant hierarchy information.
--
-- Joe Fisher - 6/18/2007
--

CREATE PROCEDURE AmsSp_DevBlk_GetPlantHierarchy_1
@nDeviceLevelBlockKey	int,
@sValue nvarchar(1024) output
AS
declare @iReturnVal int
set @iReturnVal = 0
set @sValue = '<0>'	-- indicates either not found or not assigned
declare @sPH nvarchar(1024)

set nocount on

SELECT     @sPH = '<a=' + Area + '><u=' + Unit + '><e=' + Equipment + '><c=' + Control + '>'
FROM         dbo.AmsVw_BlockTagLocation_2
WHERE     (dbo.AmsVw_BlockTagLocation_2.BlockKey = @nDeviceLevelBlockKey)

if @@error <> 0
begin
	set @iReturnVal = -2
	set @sValue = '<0>'	-- indicates either not found or not assigned
end

if (@sPH is not null)
begin
	set @sValue = '<1>' + @sPH
end

return @iReturnVal

GO

