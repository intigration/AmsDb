CREATE TABLE [dbo].[InstantiableConfigData] (
    [InstantiableBlockKey] INT            NOT NULL,
    [EventIdDay]           INT            NOT NULL,
    [EventIdFraction]      INT            NOT NULL,
    [ParamKind]            NCHAR (1)      NOT NULL,
    [ParamName]            NVARCHAR (255) NOT NULL,
    [ParamDataType]        SMALLINT       NOT NULL,
    [ParamDataSize]        INT            NOT NULL,
    [ParamData]            VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_InstantiableConfigData] PRIMARY KEY CLUSTERED ([InstantiableBlockKey] ASC, [EventIdDay] ASC, [EventIdFraction] ASC, [ParamKind] ASC, [ParamName] ASC),
    CONSTRAINT [fk_InstantiableConfigData_BlockKey] FOREIGN KEY ([InstantiableBlockKey]) REFERENCES [dbo].[InstantiableConfigBlocks] ([InstantiableBlockKey]),
    CONSTRAINT [fk_InstantiableConfigData_EventId] FOREIGN KEY ([EventIdDay], [EventIdFraction]) REFERENCES [dbo].[EventLog] ([EventIdDay], [EventIdFraction])
);


GO

