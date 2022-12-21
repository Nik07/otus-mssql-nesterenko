USE [WideWorldImporters]
GO
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
CREATE OR ALTER PROCEDURE Sales.SendNewCustomer
	@CustomerID INT,
	@DateBeg DATE,
	@DateEnd DATE
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);

	BEGIN TRAN 

	    --Determine the Initiator Service, Target Service and the Contract 
	    BEGIN DIALOG @InitDlgHandle
	    FROM SERVICE
	    [//WWI/SB/InitiatorService]
	    TO SERVICE
	    '//WWI/SB/TargetService'
	    ON CONTRACT
	    [//WWI/SB/Contract]
	    WITH ENCRYPTION=OFF; 

        --Prepare the Message
	    SELECT @RequestMessage = (
                SELECT InitDlgHandle = @InitDlgHandle, CustomerID, DateBeg = @DateBeg, DateEnd = @DateEnd
			    FROM Sales.Customers Inv
			    WHERE CustomerID = @CustomerID
			    FOR XML AUTO, root('RequestMessage'));

       --Send the Message
	    SEND ON CONVERSATION @InitDlgHandle 
	    MESSAGE TYPE
	    [//WWI/SB/RequestMessage]
	    (@RequestMessage);

        SELECT @RequestMessage AS SentRequestMessage;

    COMMIT TRAN
END
GO
