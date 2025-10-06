-----------------------------------------------------------------------
-- AmsSp_Tag_Add_1
--
-- add a tag to ExtBlockTags table.
--
-- Inputs -
--	sAmsTagName nvarchar(255)
--
-- Outputs -
--	nExtBlockTagKey 
-- Returns -
--	0  - Succeeded
--	-1 - Error, unable to get information.
--
-- Jane Xiao, 7/3/2003
--
--
CREATE  PROCEDURE AmsSp_Tag_Add_1
@sAmsTagName nvarchar(255),
@nExtBlockTagKey int output
AS

declare @iReturnVal int
set @iReturnVal = 0

-- get the next ExtBlockTagKey
declare @NextKey int
select @NextKey = max(ExtBlockTagKey) + 1 from ExtBlockTags
--add the tag
insert ExtBlockTags (ExtBlockTagKey, ExtBlockTag, ExtBlockTagDesc, TestDefinitionId)
values (@NextKey, @sAmsTagName, '', -1)

if (@@ERROR <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = 0
	set @nExtBlockTagKey = @NextKey

return @iReturnVal

GO

