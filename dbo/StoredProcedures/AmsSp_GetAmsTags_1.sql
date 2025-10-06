
-----------------------------------------------------------------------
-- AmsSp_GetAmsTags_1
--
-- Get list of AmsTags with the following information (see output section.)
-- Obtain both tags assigned to devices and tags that are used as template names.
--
-- Inputs -
--	none.
--
-- Outputs -
--	Recordset with the following --
--		AmsTag
--		TagType	-- either 'placeholder' or 'template'
--
-- Returns -
--	returns number of records in recordset.
--	-1 - Error, unable to get information.
--
-- Joe Fisher, 05/07/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
CREATE PROCEDURE AmsSp_GetAmsTags_1
AS

declare @iReturnVal int
set @iReturnVal = 0
declare @Err int, @nRow int

select ExtBlockTag as AmsTag, 'placeholder' as TagType from ExtBlockTags
union
select ConfigName as AmsTag, 'template' as TagType from NamedConfigs

select @Err = @@ERROR, @nRow = @@ROWCOUNT

if (@Err <> 0)
	set @iReturnVal = -1
else
	set @iReturnVal = @nRow

return @iReturnVal

GO

