/*
 *	mexcdf.h	Include-file for mexcdf53.c.
 *
 *	Dr. Charles R. Denham, U.S. Geological Survey.
 *
 */
 
# if !defined	MEXCDF_H
# define		MEXCDF_H

# define		calloc(A, B)	mxCalloc(A, B)
# define		free(A)			mxFree(A)

# if defined	__STDC__
# if !defined	HAS_VOID
# define		HAS_VOID
# endif
# endif

# if defined	HAS_VOID
# define		VOID	void
# define		VOIDP	void *
# define		VOIDPP	void **
# else
# define		VOID
# define		VOIDP	char *
# define		VOIDPP	char **
# endif

# if !defined	DOUBLE
# define		DOUBLE	double
# define		INT		int
# endif

# if !defined	VERBOSE
# define		VERBOSE		0	/*	Verbosity.	*/
# endif

# if !defined	MEXCDF_4
# define		MEXCDF_4				0
# define		MEXCDF_5				1
# define        Matrix                  mxArray
# define        COMPLEX                 mxCOMPLEX
# define        REAL                    mxREAL
# define        INT                     int
# define		mxCreateFull(A, B, C)	mxCreateDoubleMatrix(A, B, C)
# define		mxIsString(A)				mxIsChar(A)
# else
# define		MEXCDF_5				0
# endif

# define		MAX_BUFFER	32

/*	NetCDF Operations.	*/

typedef enum s_opcode	{
	USAGE = 1,
	CREATE,
	OPEN,
	REDEF,
	ENDEF,
	INQUIRE,
	CLOSE,
	SYNC,
	ABORT,
	DIMDEF,
	DIMID,
	DIMINQ,
	DIMRENAME,
	VARDEF,
	VARID,
	VARINQ,
	VARPUT1,
	VARGET1,
	VARPUT,
	VARGET,
	VARPUTG,
	VARGETG,
	VARRENAME,
	VARCOPY,
	ATTPUT,
	ATTINQ,
	ATTGET,
	ATTCOPY,
	ATTNAME,
	ATTRENAME,
	ATTDEL,
	RECPUT,
	RECGET,
	RECINQ,
	TYPELEN,
	SETFILL,
	SETOPTS,
	ERR,
	PARAMETER,
	NONE
	}	OPCODE;

typedef struct s_op	{
	OPCODE		opcode;
	char	*	opname;
	int			nrhs;		/*	Required nrhs.	*/
	int			nlhs;		/*	Maximum nlhs.	*/
	}	op;

op ops[] =	{
	USAGE, "usage", 1, 0,
	CREATE, "create", 2, 2,
	OPEN, "open", 2, 2,
	REDEF, "redef", 1, 1,
	ENDEF, "endef", 1, 1,
	INQUIRE, "inquire", 2, 5,
	CLOSE, "close", 2, 1,
	SYNC, "sync", 2, 1,
	ABORT, "abort", 2, 1,
	DIMDEF, "dimdef", 4, 1,
	DIMID, "dimid", 3, 1,
	DIMINQ, "diminq", 3, 3,
	DIMRENAME, "dimrename", 4, 1,
	VARDEF, "vardef", 6, 1,
	VARID, "varid", 3, 1,
	VARINQ, "varinq", 3, 5,
	VARPUT1, "varput1", 5, 1,
	VARGET1, "varget1", 4, 2,
	VARPUT, "varput", 6, 1,
	VARGET, "varget", 5, 2,
	VARPUTG, "varputg", 7, 1,
	VARGETG, "vargetg", 6, 2,
	VARRENAME, "varrename", 4, 1,
	VARCOPY, "varcopy", 3, 2,
	ATTPUT, "attput", 7, 1,
	ATTINQ, "attinq", 4, 3,
	ATTGET, "attget", 4, 2,
	ATTCOPY, "attcopy", 6, 1,
	ATTNAME, "attname", 4, 2,
	ATTRENAME, "attrename", 5, 1,
	ATTDEL, "attdel", 4, 1,
	RECPUT, "recput", 4, 1,
	RECGET, "recget", 3, 2,
	RECINQ, "recinq", 2, 3,
	TYPELEN, "typelen", 2, 2,
	SETFILL, "setfill", 3, 1,
	SETOPTS, "setopts", 2, 1,
	ERR, "err", 1, 1,
	PARAMETER, "parameter", 1, 1,
	NONE, "none", 0, 0
	};

/*	NetCDF Parameters.	*/

typedef struct s_parm	{
	int			code;
	char	*	name;
	int			len;		/*	Minimal unique length.	*/
	}	parm;
	
parm parms[] =	{
/*
	FILL_BYTE, "FILL_BYTE", 6,
	FILL_CHAR, "FILL_CHAR", 6,
	FILL_SHORT, "FILL_SHORT", 6,
	FILL_INT, "FILL_INT", 6,
	FILL_INT, "FILL_LONG", 6,
	FILL_FLOAT, "FILL_FLOAT", 6,
	FILL_DOUBLE, "FILL_DOUBLE", 6,
*/

#define MAX_NC_DIMS 100	 /* max dimensions per file */
#define MAX_NC_ATTRS 2000	 /* max global or per variable attributes */
#define MAX_NC_VARS 2000	 /* max variables per file */
#define MAX_NC_NAME 128	 /* max length of a name */
#define MAX_VAR_DIMS MAX_NC_DIMS /* max per variable dimensions */

	MAX_NC_NAME, "MAX_NC_NAME", 8,
	MAX_NC_DIMS, "MAX_NC_DIMS", 8,
	MAX_NC_VARS, "MAX_NC_VARS", 8,
	MAX_NC_ATTRS, "MAX_NC_ATTRS", 8,
	MAX_VAR_DIMS, "MAX_VAR_DIMS", 9,
	NC_BYTE, "BYTE", 1,
	NC_CHAR, "CHAR", 2,
	NC_CLOBBER, "CLOBBER", 2,
	NC_DOUBLE, "DOUBLE", 1,
	NC_FATAL, "FATAL", 2,
	NC_FILL, "FILL", 2,
	NC_FLOAT, "FLOAT", 2,
	NC_GLOBAL, "GLOBAL", 1,
	NC_LONG, "LONG", 3,
	NC_LOCK, "NC_LOCK", 3,
	NC_NOCLOBBER, "NOCLOBBER", 3,
	NC_NOFILL, "NOFILL", 3,
	NC_NOWRITE, "NOWRITE", 3,
	NC_SHARE, "SHARE", 3,
	NC_SHORT, "SHORT", 3,
	NC_UNLIMITED, "UNLIMITED", 1,
	NC_VERBOSE, "VERBOSE", 1,
	NC_WRITE, "WRITE", 1,
	0, "NONE", 0
	};

# endif
