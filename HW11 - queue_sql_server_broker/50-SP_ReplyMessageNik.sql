USE [WideWorldImporters]
GO

CREATE OR ALTER PROCEDURE Sales.GetNewCustomer
AS
BEGIN

    DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
            @InitDlgHandle UNIQUEIDENTIFIER,
            @Message NVARCHAR(4000),
            @MessageType Sysname,
            @ReplyMessage NVARCHAR(4000),
            @ReplyMessageName Sysname,
            @CustomerID INT,
            @DateBeg DATE,
            @DateEnd DATE,
            @xml XML; 

    BEGIN TRAN; 

        --Receive message from Initiator
        RECEIVE TOP(1)
            @TargetDlgHandle = Conversation_Handle,
            @Message = Message_Body,
            @MessageType = Message_Type_Name
        FROM dbo.TargetQueueWWI; 

        SELECT @Message; -- ��� �������, ����� ������

        SET @xml = CAST(@Message AS XML);

        SELECT
            @InitDlgHandle = R.Iv.value('@InitDlgHandle','UNIQUEIDENTIFIER'),
            @CustomerID = R.Iv.value('@CustomerID','INT'),
            @DateBeg = R.Iv.value('@DateBeg','DATE'),
            @DateEnd = R.Iv.value('@DateEnd','DATE')    
        FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

        SELECT InitDlgHandle = @InitDlgHandle, CustomerID = @CustomerID, DateBeg = @DateBeg, DateEnd = @DateEnd;  

        INSERT INTO [Sales].[ReportInvoices]
            SELECT 
                InitDlgHandle = @InitDlgHandle,
                CustomerID,
                DateBeg = @DateBeg,
                DateEnd = @DateEnd,
                NumberOrders = COUNT(OrderID)
            FROM [Sales].[Invoices] 
            WHERE CustomerID = @CustomerID AND InvoiceDate BETWEEN @DateBeg AND @DateEnd
            GROUP BY CustomerID; 

        --SELECT * FROM [WideWorldImporters].[Sales].[ReportInvoices];-- ��� �������, ����� ������
        --SELECT @Message AS ReceivedRequestMessage, @MessageType; -- ��� �������, ����� ������

        -- Confirm and Send a reply
        IF @MessageType=N'//WWI/SB/RequestMessage'
            BEGIN
                SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; -- ������� �����

                SEND ON CONVERSATION @TargetDlgHandle  -- ������������� �������
                MESSAGE TYPE
                [//WWI/SB/ReplyMessage]
                (@ReplyMessage);
                END CONVERSATION @TargetDlgHandle;

            END

        --SELECT @ReplyMessage AS SentReplyMessage;  -- ��� �������, ����� ������

    COMMIT TRAN;
END