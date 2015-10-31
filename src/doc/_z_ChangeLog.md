# Changes

- separated in *.bi and *.bas files (for usage in build management systems)

- fully documented in Doxygen style

- code reviewed and reduced to the essentials

  - GetErrr functions removed, error message is a public ZSTRING PTR now (zero in case of no error)
  - `CanPut` and `CanGet` functions removed, features integrated in GetData and PutData now
  - GetData returns a STRING now
  - method `GetConnection` renamed by `OpenSock`

- `bnConnectionFactory` collects a list of open connections, automaticaly closing them in the destructor

- new method `CloseSock` for manual closing a connection.

