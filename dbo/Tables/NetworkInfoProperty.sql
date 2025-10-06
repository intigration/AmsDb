CREATE TABLE [dbo].[NetworkInfoProperty] (
    [NetworkInfoPropKey]       INT            IDENTITY (0, 1) NOT NULL,
    [NetworkInfoKey]           INT            NOT NULL,
    [NetworkInfoPropertyKey]   NVARCHAR (256) NOT NULL,
    [NetworkInfoPropertyValue] NVARCHAR (256) NOT NULL,
    CONSTRAINT [NetworkInfoProperty_PK] PRIMARY KEY CLUSTERED ([NetworkInfoPropKey] ASC),
    CONSTRAINT [NetworkInfoProperty_FK] FOREIGN KEY ([NetworkInfoKey]) REFERENCES [dbo].[NetworkInfo] ([NetworkInfoKey]),
    CONSTRAINT [NetworkInfoProperty_U1] UNIQUE NONCLUSTERED ([NetworkInfoKey] ASC, [NetworkInfoPropertyKey] ASC)
);


GO

