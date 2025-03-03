USE AP_Arena

SELECT USER_NAME() AS CurrentUser;
-- Views
CREATE VIEW view_own_details AS
SELECT U.UserID, U.UFullName, U.UEmail, U.UPhone, U.UType, U.UCreatedAt, U.UUpdatedAt 
FROM dbo.Users U
INNER JOIN dbo.UserLoginDetails UL ON U.UserID = UL.UserID
WHERE UL.LoginName = USER_NAME()

CREATE VIEW view_participants AS
SELECT P.ParticipantsID, P.BookingID, P.PFullName, P.PPhone, P.PCreatedAt, P.PUpdatedAt
FROM Participants P
INNER JOIN Bookings B ON P.BookingID = B.BookingID 
WHERE B.UserID = (SELECT U.UserID FROM UserLoginDetails U WHERE U.LoginName = USER_NAME()) 

CREATE VIEW view_tournament_current_user AS
SELECT * FROM Tournaments T
WHERE T.UserID = (SELECT U.UserID FROM UserLoginDetails U WHERE LoginName = USER_NAME())

CREATE VIEW view_transactions AS
SELECT 
    T.TransactionID,
    T.BookingID,
    CONVERT(NVARCHAR(100), DecryptByKey(T.PaymentCard)) AS PaymentCard, -- Decrypted PaymentCard
    T.TransStatus,
    T.TotalAmount,
	T.PaymentTimestamp
FROM 
    Transactions T
INNER JOIN 
    Bookings B ON T.BookingID = B.BookingID
WHERE 
    B.UserID = (
        SELECT U.UserID
        FROM UserLoginDetails U
        WHERE U.LoginName = USER_NAME()
    );

CREATE VIEW view_booking AS
SELECT * FROM Bookings B
WHERE B.UserID = (SELECT U.UserID FROM UserLoginDetails U WHERE LoginName = USER_NAME())

CREATE VIEW view_unpaid_transactions AS
SELECT 
    T.TransactionID,
    B.BookingID,
    B.TournamentID,
    B.BookType,
    B.BookApprStatus,
    B.BCreatedAt,
    T.TransStatus,
    T.TotalAmount
FROM 
    Bookings B
LEFT JOIN 
    Transactions T
ON 
    B.BookingID = T.BookingID
WHERE 
    B.UserID = (SELECT U.UserID 
                FROM UserLoginDetails U 
                WHERE U.LoginName = USER_NAME())
    AND 
    (T.TransStatus = 'Pending'); 

