USE [WideWorldImporters]
GO

/****** Object:  Table [Sales].[ReportInvoices]    Script Date: 21.12.2022 16:34:35 ******/
DROP TABLE [Sales].[ReportInvoices]
GO

DROP SERVICE [//WWI/SB/TargetService]
GO

DROP SERVICE [//WWI/SB/InitiatorService]
GO

DROP QUEUE [dbo].[TargetQueueWWI]
GO 

DROP QUEUE [dbo].[InitiatorQueueWWI]
GO

DROP CONTRACT [//WWI/SB/Contract]
GO

DROP MESSAGE TYPE [//WWI/SB/RequestMessage]
GO

DROP MESSAGE TYPE [//WWI/SB/ReplyMessage]
GO

DROP PROCEDURE IF EXISTS  Sales.SendNewCustomer;

DROP PROCEDURE IF EXISTS  Sales.GetNewCustomer;

DROP PROCEDURE IF EXISTS  Sales.ConfirmCustomer;