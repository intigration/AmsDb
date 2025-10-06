CREATE TABLE [dbo].[BlockData] (
    [BlockKey]        INT            CONSTRAINT [df_BlockData_BlockKey] DEFAULT ((0)) NOT NULL,
    [EventIdDay]      INT            CONSTRAINT [df_BlockData_EventIdDay] DEFAULT ((0)) NOT NULL,
    [EventIdFraction] INT            CONSTRAINT [df_BlockData_EventIdFraction] DEFAULT ((0)) NOT NULL,
    [ParamKind]       NCHAR (1)      CONSTRAINT [df_BlockData_ParamKind] DEFAULT ('P') NOT NULL,
    [ParamName]       NVARCHAR (255) NOT NULL,
    [ValueMode]       NCHAR (1)      CONSTRAINT [df_BlockData_ValueMode] DEFAULT ('h') NOT NULL,
    [ParamDataType]   TINYINT        CONSTRAINT [df_BlockData_ParamDataType] DEFAULT ((0)) NOT NULL,
    [ParamDataSize]   INT            CONSTRAINT [df_BlockData_ParamDataSize] DEFAULT ((0)) NOT NULL,
    [ParamData]       VARCHAR (MAX)  NULL,
    [Archived]        BIT            CONSTRAINT [df_BlockData_Archived] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_BlockData] PRIMARY KEY CLUSTERED ([BlockKey] ASC, [EventIdDay] ASC, [EventIdFraction] ASC, [ParamKind] ASC, [ParamName] ASC),
    CONSTRAINT [fk_BlockData_BlockKey] FOREIGN KEY ([BlockKey]) REFERENCES [dbo].[Blocks] ([BlockKey]),
    CONSTRAINT [fk_BlockData_EventId] FOREIGN KEY ([EventIdDay], [EventIdFraction]) REFERENCES [dbo].[EventLog] ([EventIdDay], [EventIdFraction])
);


GO

CREATE NONCLUSTERED INDEX [IX_BlockData_EventId]
    ON [dbo].[BlockData]([EventIdDay] ASC, [EventIdFraction] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_BlockData_BlockKey]
    ON [dbo].[BlockData]([BlockKey] ASC);


GO

