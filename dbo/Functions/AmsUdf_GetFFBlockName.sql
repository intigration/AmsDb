
-------------------------------------------------------------------------------
-- AmsUdf_GetFFBlockName 
--
-- Build the FF blockName from the blockType character ('R', 'T' or 'F') and the
--	blockindex.
--
-- Inputs --
--	blockType - The single character block type.
--	blockIndex - The blockIndex.
--
-- Outputs --
--	blockName - the blockName.
--
-- Author --
--	Joe Fisher
--	08/27/03
--
-- Source control keywords --
-- $Date: 2/22/05 3:48p $
-- $Revision: 34 $
--
CREATE FUNCTION AmsUdf_GetFFBlockName 
(@blockType nvarchar(1), @blockIndex int)  
RETURNS nvarchar(255) 
AS  
BEGIN 
Declare @blockName nvarchar(255)
set @blockName = N''

set @blockName = case @blockType
		when N'R' then N'RESOURCE'
		when N'T' then N'TRANSDUCER'
		when N'F' then N'FUNCTION'
	end
if (@blockType !='R')
begin
	set @blockName = @blockName + convert(nvarchar(200), @blockIndex)
end

Return (Select @blockName As BlockName)

END

GO

