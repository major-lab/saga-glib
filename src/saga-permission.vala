[Flags]
enum Saga.Permission
{
	NONE  = 0,
	QUERY = 1,
	READ  = 2,
	WRITE = 4,
	EXEC  = 8,
	OWNER = 16,
	ALL   = 31
}
