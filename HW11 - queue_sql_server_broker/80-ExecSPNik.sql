
USE [WideWorldImporters]
GO

DECLARE @CustomerID INT = 832,
        @DateBeg DATE = '2013-02-01',
        @DateEnd DATE = '2013-12-30';

--SELECT CustomerID, DateBeg = @DateBeg, DateEnd = @DateEnd, NumberOrders = COUNT(*)
--            FROM [Sales].[Invoices] 
--            WHERE CustomerID = @CustomerID AND InvoiceDate BETWEEN @DateBeg AND @DateEnd
--            GROUP BY CustomerID;

-- Send message
EXEC Sales.SendNewCustomer @CustomerID, @DateBeg, @DateEnd;
-----------------------------------------------------------
SELECT CAST(message_body AS XML),* FROM dbo.TargetQueueWWI;
SELECT CAST(message_body AS XML),* FROM dbo.InitiatorQueueWWI;
-----------------------------------------------------------

-- Target
EXEC Sales.GetNewCustomer;
-- Initiator
EXEC Sales.ConfirmCustomer;

--- проверим, что запись добавилась --------------------------------------
SELECT * FROM [WideWorldImporters].[Sales].[ReportInvoices];
