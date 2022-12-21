USE [WideWorldImporters]
GO

-- создаем таблицу для хранения отчетов ----------------------------------------
--DROP TABLE IF EXISTS [Sales].[ReportInvoices];

CREATE TABLE [Sales].[ReportInvoices] (
	[InitDlgHandle] [uniqueidentifier], -- NOT NULL,
	[CustomerID] [int] NOT NULL,
	[DateBeg] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[NumberOrders] [int] NOT NULL
);

--ALTER DATABASE [WideWorldImporters] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--ALTER DATABASE [WideWorldImporters] SET MULTI_USER ;

USE [master]
GO
ALTER DATABASE [WideWorldImporters] SET  ENABLE_BROKER WITH NO_WAIT
GO

GO

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

ALTER AUTHORIZATION
   ON DATABASE::WideWorldImporters TO [sa];

--SELECT name, database_id, is_trustworthy_on FROM sys.databases
--An exception occurred while enqueueing a message in the target queue. Error: 33009, State: 2. 
--The database owner SID recorded in the master database differs from the database owner SID recorded in database 'WideWorldImporters'. 
--You should correct this situation by resetting the owner of database 'WideWorldImporters' using the ALTER AUTHORIZATION statement.
