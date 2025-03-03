EXECUTE AS USER = 'SystemUser';
SELECT USER_NAME() AS CurrentUser;

-- Register as a user
EXEC dbo.SP_InsertUsers 'JacobChew', 'jacobchew@gmail.com', '0288199889', 'IndividiualCustomer'
EXEC dbo.SP_InsertUsers 'AngelineTan', 'angeline@gmail.com', '013234567', 'IndividiualCustomer'

REVERT;