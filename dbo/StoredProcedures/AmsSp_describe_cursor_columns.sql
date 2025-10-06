
-----------------------------------------------------------------------
-- AmsSp_describe_cursor_columns
-- (see text describing SqlServer sp_describe_cursor_columns)
-- this returns limited number of columns.
--
-- Joe Fisher, 03/27/2001
--
-- Source control keywords --
-- $Date: 2/17/05 3:47p $
-- $Revision: 121 $
--
Create Procedure AmsSp_describe_cursor_columns 
(  @cursor_return CURSOR VARYING OUTPUT,
   @cursor_source nvarchar (30),
   @cursor_identity nvarchar (128)
)
AS

declare @scope int

/* Check if the cursor exists by name or handle. */
If cursor_status ( @cursor_source, @cursor_identity ) >= -1
begin
	if lower(convert(nvarchar(30), @cursor_source)) = 'local' OR 
		lower(convert(nvarchar(128), @cursor_source)) = 'variable'
		select @scope = 1
	else
	if lower(convert(nvarchar(30), @cursor_source)) = 'global'
		select @scope = 2

	set @cursor_return =  	CURSOR LOCAL SCROLL DYNAMIC FOR 
				SELECT column_name, ordinal_position
				FROM master.dbo.syscursorrefs scr, master.dbo.syscursorcolumns scc
				WHERE 	scr.cursor_scope = @scope and 
					scr.reference_name = @cursor_identity and 
					scr.cursor_handl = scc.cursor_handle
				ORDER BY 2
				FOR READ ONLY
	open @cursor_return		
		
end

GO

