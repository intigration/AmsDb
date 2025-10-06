CREATE TABLE [dbo].[ServiceReasons] (
    [ServiceId]   INT           CONSTRAINT [df_ServiceReasons_ServiceId] DEFAULT ((0)) NOT NULL,
    [ServiceDesc] NVARCHAR (50) NOT NULL,
    CONSTRAINT [pk_ServiceReasons] PRIMARY KEY CLUSTERED ([ServiceId] ASC)
);


GO

