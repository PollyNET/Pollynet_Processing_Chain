/*
 *	mexcdf53.c -- For Matlab Version 5 and NetCDF Version 3.
 *
 *	******************** NOTICE ********************
 *
 *	MEXCDF53 -- USGS Preliminary Computer Software For
 *		Interaction Between Matlab-5 and NetCDF-3.
 *
 *	Begun:		Tuesday, July 14, 1992 6:59:54 PM.
 *	Version:	Tuesday, March 4, 1997 3:54:00 PM.
 *	Version:	Wednesday, December 16, 1998 4:43:00 PM.
 *					byte ==> (signed char) Jim Mansbridge.
 *	Version:	Monday, January 24, 2000 19:11:50 PM.
 *					varget1, vargetg, attget: plhs[0]
 *  Version:    Tuesday, September 17, 2002.
 *                  MacOSX version built with this.
 *
 *	Written, Maintained, and Supported By:
 *		Dr. Charles R. Denham
 *		U.S. Geological Survey
 *		Woods Hole, Massachusetts 02543
 *		e-mail: cdenham@usgs.gov
 *
 *	Computer Programming Language:
 *		The C-Language.
 *
 *	Computer System:
 *		This software has been successfully linked with
 *		the NetCDF-3 library and executed from Matlab-5
 *		on Power Macintosh and DEC Alpha hardware.  The
 *		software is intended to be compatible with all
 *		installations of Matlab-4, Matlab-5, NetCDF-2,
 *		and NetCDF-3.
 *
 *	Source Code Available From:
 *		Author.
 *
 *	Disclaimer:
 *		Although this software has been used by the USGS, no
 *		warranty, expressed or implied, is made by the USGS
 *		or the United States Government as to the accuracy
 *		and functioning of the software and related software
 *		material, nor shall the fact of distribution constitute
 *		any such warranty or publication, and no responsibility
 *		is assumed by the USGS in connection therewith.
 *
 *	Fair Use:
 *		This software, named "mexcdf53", may be used freely on
 *		condition that this NOTICE be displayed prominantly and
 *		in its entirety on all copies of the software, as well
 *		as on all copies of software that has been derived from
 *		this software.  Furthermore, this software requires the
 *		UCAR/Unidata NetCDF library, whose conditions on proper
 *		credit, distribution, and use must be acknowledged and
 *		honored fully.
 *
 *	******************** END OF NOTICE ********************
 *
 *	Use mexcdf53.c and mexcdf.h, plus a valid NetCDF library,
 *	to build mexcdf53.mex, a mex-file function that is intended
 *	to be executed from Matlab.
 *
 *	This source-code uses MATLAB Version 5 mex-file syntax,
 *	but it still requires that the -V4 compiler-flag be
 *	specified when building with the "mex" script supplied
 *	by MathWorks.  (V4 not relevant with Matlab 6.)
 *
 *	The strictly two-dimensional assumption of Matlab-4 can
 *	be recreated by specifying the MEXCDF_4 compiler-flag,
 *	in addition to the -V4 flag mentioned above.
 *  (V4 not relevant with Matlab 6.)
 *
 *	To build mexcdf53 for use with MATLAB Version 4, specify
 *	the MEXCDF_4 flag, as well as other flags required by
 *	the "cmex" script supplied previously by MathWorks.
 *
 *	This Mex-file invokes the high-level C-Language NetCDF-2
 *	interface of the NetCDF Users Guide.  All of the specified
 *	NetCDF input arguments are required.  All output arguments
 *	are optional.
 *
 *	Matlab Syntax:
 *
 *		[out1, out2, ...] = mexcdf53('operation', in1, in2, ...)
 *
 *	Extensions:
 *
 *		1.	Dimensions and variables accessible by id or name.
 *		2.	Attributes accessible by name or number.
 *		3.	Parameters accessible by number or name.
 *		4.	Prepended "nc" not necessary for operation names.
 *		5.	Prepended "NC_" not necessary for specifying parameters.
 *		6.	Parameter names not case-sensitive.
 *		7.	Required lengths default to actual lengths via -1.
 *		8.	Scaling via "scale_factor" and "add_offset" attributes.
 *		9.	SETOPTS to set NetCDF options.  NC_FATAL is disabled.
 *		10.	ERR to get and auto-reset the most recent error-code.
 *		11.	PARAMETER to access parameters by name.
 *		12.	USAGE to list mexcdf53 syntax.
 *
 */

# include <ctype.h>
# include <errno.h>
# include <stdio.h>
# include <stdlib.h>
# include <string.h>

# include "netcdf.h"

# include "mex.h"

# include "mexcdf.h"

static	VOID			Usage			(VOID);

static	Matrix		*	SetNum			(Matrix *);
static	Matrix		*	SetStr			(Matrix *);

static	char		*	Mat2Str			(Matrix *);
static	Matrix		*	Str2Mat			(char *);

static	int			*	Mat2Int			(Matrix *);
static	Matrix		*	Int2Mat			(int *, int, int);

static	long		*	Mat2Long		(Matrix *);
static	Matrix		*	Long2Mat		(long *, int, int);

static	int				Scalar2Int		(Matrix *);
static	Matrix		*	Int2Scalar		(int);

static	long			Scalar2Long		(Matrix *);
static	Matrix		*	Long2Scalar		(long);

static	int				Count			(Matrix *);

static	int				Parameter		(Matrix *);

static	VOID			Free			(VOIDPP);

static	DOUBLE			Scale_Factor	(int, int);
static	DOUBLE			Add_Offset		(int, int);

static	int				Convert			(OPCODE, nc_type, int, VOIDP,
											DOUBLE, DOUBLE, DOUBLE *);

static	nc_type			RepairBadDataType	(nc_type);


/*	MexFunction(): Mex-file entry point.	*/

void
mexFunction	(
	INT			nlhs,
	Matrix	*	plhs[],
	INT			nrhs,
	const Matrix	*	prhs[]
	)

{
	char		*	opname;
	OPCODE			opcode;
	
	Matrix		*	mat;
	
	int				status;
	char		*	path;
	int				cmode;
	int				mode;
	int				cdfid;
	int				ndims;
	int				nvars;
	int				natts;
	int				recdim;
	char		*	name;
	long			length;
	int				dimid;
	nc_type			datatype;
	int			*	dim;
	int				varid;
	long		*	coords;
	VOIDP			value;
	long		*	start;
	long		*	count;
	int			*	intcount;
	long		*	stride;
	long		*	imap;
	long			recnum;
	int				nrecvars;
	int			*	recvarids;
	long		*	recsizes;
	VOIDPP			datap;		/*	pointers for record access.	*/
	int				len;
	int				incdf;
	int				invar;
	int				outcdf;
	int				outvar;
	int				attnum;
	char		*	attname;
	char		*	newname;
	int				fillmode;
	
	int				i;
	int				m;
	int				n;
	char		*	p;
	char			buffer[MAX_BUFFER];
	
	DOUBLE		*	pr;
	DOUBLE			addoffset;
	DOUBLE			scalefactor;
	int				autoscale;		/*	do auto-scaling if this flag is non-zero.	*/
	
	/*	Disable the NC_FATAL option from ncopts.	*/
	
	if (ncopts & NC_FATAL)	{
		ncopts -= NC_FATAL;
	}
	
	/*	Display usage if less than one input argument.	*/
	
	if (nrhs < 1)	{
	
		Usage();
		
		return;
	}
	
	/*	Convert the operation name to its opcode.	*/
	
	opname = Mat2Str(prhs[0]);
	for (i = 0; i < strlen(opname); i++)	{
		opname[i] = (char) tolower((int) opname[i]);
	}
	p = opname;
	if (strncmp(p, "nc", 2) == 0)	{	/*	Trim away "nc".	*/
		p += 2;
	}
	
	i = 0;
	opcode = NONE;
	while (ops[i].opcode != NONE)	{
		if (!strcmp(p, ops[i].opname))	{
			opcode = ops[i].opcode;
			if (ops[i].nrhs > nrhs)	{
				mexPrintf("MEXCDF: opname = %s\n", opname);
				mexErrMsgTxt("MEXCDF: Too few input arguments.\n");
			}
			else if (0 && ops[i].nlhs > nlhs)	{	/*	Disabled.	*/
				mexPrintf("MEXCDF: opname = %s\n", opname);
				mexErrMsgTxt("MEXCDF: Too few output arguments.\n");
			}
			break;
		}
		else	{
			i++;
		}
	}
	
	if (opcode == NONE)	{
		mexPrintf("MEXCDF: opname = %s\n", opname);
		mexErrMsgTxt("MEXCDF: No such operation.\n");
	}
	
	Free((VOIDPP) & opname);
	
	/*	Extract the cdfid by number.	*/
	
	switch (opcode)	{
	
	case USAGE:
	case CREATE:
	case OPEN:
	case TYPELEN:
	case SETOPTS:
	case ERR:
	case PARAMETER:
	
		break;
	
	default:

		cdfid = Scalar2Int(prhs[1]);
	
		break;
	}
	
	/*	Extract the dimid by number or name.	*/
	
	switch (opcode)	{

	case DIMINQ:
	case DIMRENAME:
	
		if (mxIsNumeric(prhs[2]))	{
			dimid = Scalar2Int(prhs[2]);
		}
		else	{
			name = Mat2Str(prhs[2]);
			dimid = ncdimid(cdfid, name);
			Free((VOIDPP) & name);
		}
		break;
	
	default:
	
		break;
	}
	
	/*	Extract the varid by number or name.	*/
	
	switch (opcode)	{

	case VARINQ:
	case VARPUT1:
	case VARGET1:
	case VARPUT:
	case VARGET:
	case VARPUTG:
	case VARGETG:
	case VARRENAME:
	case VARCOPY:
	case ATTPUT:
	case ATTINQ:
	case ATTGET:
	case ATTCOPY:
	case ATTNAME:
	case ATTRENAME:
	case ATTDEL:
	
		if (mxIsNumeric(prhs[2]))	{
			varid = Scalar2Int(prhs[2]);
		}
		else	{
			name = Mat2Str(prhs[2]);
			varid = ncvarid(cdfid, name);
			Free((VOIDPP) & name);
			if (varid == -1)	{
				varid = Parameter(prhs[2]);
			}
		}
		break;
	
	default:
	
		break;
	}
	
	/*	Extract the attname by name or number.	*/
	
	switch (opcode)	{
	
	case ATTPUT:
	case ATTINQ:
	case ATTGET:
	case ATTCOPY:
	case ATTRENAME:
	case ATTDEL:
	
		if (mxIsNumeric(prhs[3]))	{
			attnum = Scalar2Int(prhs[3]);
			attname = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
			status = ncattname(cdfid, varid, attnum, attname);
		}
		else	{
			attname = Mat2Str(prhs[3]);
		}
		break;
	
	default:
	
		break;
	}
	
	/*	Extract the "add_offset" and "scale_factor" attributes.	*/
	
	switch (opcode)	{
	
	case VARPUT1:
	case VARGET1:
	case VARPUT:
	case VARGET:
	case VARPUTG:
	case VARGETG:

		addoffset = Add_Offset(cdfid, varid);
		scalefactor = Scale_Factor(cdfid, varid);
		if (scalefactor == 0.0)	{
			scalefactor = 1.0;
		}
		
		break;
	
	default:
	
		break;
	}
	
	/*	Perform the NetCDF operation.	*/
	
	switch (opcode)	{
		
	case USAGE:
	
		Usage();
		
		break;
	
	case CREATE:
		
		path = Mat2Str(prhs[1]);
		
		if (nrhs > 2)	{
			cmode = Parameter(prhs[2]);
		}
		else	{
			cmode = NC_NOCLOBBER;	/*	Default.	*/
		}
		
		cdfid = nccreate(path, cmode);
		
		plhs[0] = Int2Scalar(cdfid);
		plhs[1] = Int2Scalar((cdfid >= 0) ? 0 : -1);
		
		Free((VOIDPP) & path);
		
		break;
		
	case OPEN:
		
		path = Mat2Str(prhs[1]);
		
		if (nrhs > 2)	{
			mode = Parameter(prhs[2]);
		}
		else	{
			mode = NC_NOWRITE;	/*	Default.	*/
		}
		
		cdfid = ncopen(path, mode);
		
		plhs[0] = Int2Scalar(cdfid);
		plhs[1] = Int2Scalar((cdfid >= 0) ? 0 : -1);
		
		Free((VOIDPP) & path);
		
		break;
		
	case REDEF:
		
		status = ncredef(cdfid);
		
		plhs[0] = Int2Scalar(status);
		
		break;
		
	case ENDEF:
		
		status = ncendef(cdfid);
		
		plhs[0] = Int2Scalar(status);
		
		break;
		
	case CLOSE:
		
		status = ncclose(cdfid);
		
		plhs[0] = Int2Scalar(status);
		
		break;
		
	case INQUIRE:
	
		status = ncinquire(cdfid, & ndims, & nvars, & natts, & recdim);
		
		if (nlhs > 1)	{
			plhs[0] = Int2Scalar(ndims);
			plhs[1] = Int2Scalar(nvars);
			plhs[2] = Int2Scalar(natts);
			plhs[3] = Int2Scalar(recdim);
			plhs[4] = Int2Scalar(status);
		}
		else	{	/*	Default to 1 x 5 row vector.	*/
			plhs[0] = mxCreateFull(1, 5, REAL);
			pr = mxGetPr(plhs[0]);
			if (status == 0)	{
				pr[0] = (DOUBLE) ndims;
				pr[1] = (DOUBLE) nvars;
				pr[2] = (DOUBLE) natts;
				pr[3] = (DOUBLE) recdim;
			}
			pr[4] = (DOUBLE) status;
		}
		
		break;
		
	case SYNC:
	
		status = ncsync(cdfid);
		
		plhs[0] = Int2Scalar(status);
		
		break;
		
	case ABORT:
	
		status = ncabort(cdfid);
		
		plhs[0] = Int2Scalar(status);
		
		break;
		
	case DIMDEF:
	
		name = Mat2Str(prhs[2]);
		length = Parameter(prhs[3]);
		
		dimid = ncdimdef(cdfid, name, length);
		
		plhs[0] = Int2Scalar(dimid);
		plhs[1] = Int2Scalar((dimid >= 0) ? 0 : dimid);
		
		Free((VOIDPP) & name);
		
		break;
		
	case DIMID:
	
		name = Mat2Str(prhs[2]);
		
		dimid = ncdimid(cdfid, name);
		
		plhs[0] = Int2Scalar(dimid);
		plhs[1] = Int2Scalar((dimid >= 0) ? 0 : dimid);
		
		Free((VOIDPP) & name);
		
		break;
		
	case DIMINQ:
		
		name = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
		
		status = ncdiminq(cdfid, dimid, name, & length);
		
		plhs[0] = Str2Mat(name);
		plhs[1] = Long2Scalar(length);
		plhs[2] = Int2Scalar(status);
		
		Free((VOIDPP) & name);
		
		break;
		
	case DIMRENAME:
		
		name = Mat2Str(prhs[3]);
		
		status = ncdimrename(cdfid, dimid, name);
		
		plhs[0] = Int2Scalar(status);
		
		Free((VOIDPP) & name);
		
		break;
		
	case VARDEF:
	
		name = Mat2Str(prhs[2]);
		datatype = (nc_type) Parameter(prhs[3]);
		ndims = Scalar2Int(prhs[4]);
		if (ndims == -1)	{
			ndims = Count(prhs[5]);
		}
		dim = Mat2Int(prhs[5]);
		
		varid = ncvardef(cdfid, name, datatype, ndims, dim);
		
		Free((VOIDPP) & name);
		
		plhs[0] = Int2Scalar(varid);
		plhs[1] = Int2Scalar((varid >= 0) ? 0 : varid);
		
		break;
		
	case VARID:
	
		name = Mat2Str(prhs[2]);
		
		varid = ncvarid(cdfid, name);
		
		Free((VOIDPP) & name);
		
		plhs[0] = Int2Scalar(varid);
		plhs[1] = Int2Scalar((varid >= 0) ? 0 : varid);
		
		break;
		
	case VARINQ:
	
		name = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
		dim = (int *) mxCalloc(MAX_VAR_DIMS, sizeof(int));
		
		status = ncvarinq(cdfid, varid, name, & datatype, & ndims, dim, & natts);
		
		datatype = RepairBadDataType(datatype);
		
		plhs[0] = Str2Mat(name);
		plhs[1] = Int2Scalar(datatype);
		plhs[2] = Int2Scalar(ndims);
		plhs[3] = Int2Mat(dim, 1, ndims);
		plhs[4] = Int2Scalar(natts);
		plhs[5] = Int2Scalar(status);
		
		Free((VOIDPP) & name);
		Free((VOIDPP) & dim);
		
		break;
		
	case VARPUT1:
		
		coords = Mat2Long(prhs[3]);
		
		name = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
		dim = (int *) mxCalloc(MAX_NC_DIMS, sizeof(int));
		
		status = ncvarinq(cdfid, varid, name, & datatype, & ndims, dim, & natts);
		
		datatype = RepairBadDataType(datatype);
		
		Free((VOIDPP) & name);
		Free((VOIDPP) & dim);
		
		if (datatype == NC_CHAR)	{
			mat = SetNum(prhs[4]);
		}
		else	{
			mat = prhs[4];
		}
		if (mat == NULL)	{
			mat = prhs[4];
		}
		
		pr = mxGetPr(mat);
		
		autoscale = (nrhs > 5 && Scalar2Int(prhs[5]) != 0);
		
		if (!autoscale)	{
			scalefactor = 1.0;
			addoffset = 0.0;
		}
		
		status = Convert(opcode, datatype, 1, buffer, scalefactor, addoffset, pr);
		status = ncvarput1(cdfid, varid, coords, buffer);
		
		plhs[0] = Int2Scalar(status);
		
		Free((VOIDPP) & coords);
		
		break;
		
	case VARGET1:
		
		coords = Mat2Long(prhs[3]);
		
		autoscale = (nrhs > 4 && Scalar2Int(prhs[4]) != 0);
		
		if (!autoscale)	{
			scalefactor = 1.0;
			addoffset = 0.0;
		}
		
		name = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
		dim = (int *) mxCalloc(MAX_NC_DIMS, sizeof(int));
		
		status = ncvarinq(cdfid, varid, name, & datatype, & ndims, dim, & natts);
		
		datatype = RepairBadDataType(datatype);
		
		Free((VOIDPP) & name);
		Free((VOIDPP) & dim);
		
		mat = Int2Scalar(0);
		
		pr = mxGetPr(mat);
		
		status = ncvarget1(cdfid, varid, coords, buffer);
		status = Convert(opcode, datatype, 1, buffer, scalefactor, addoffset, pr);
		
		if (datatype == NC_CHAR)	{
			plhs[0] = SetStr(mat);
		}
		else	{
			plhs[0] = mat;
		}
		if (plhs[0] == NULL)	{
/*			prhs[0] = mat;		*/
			plhs[0] = mat;		/*	ZYDECO 24Jan2000	*/
		}
		
		plhs[1] = Int2Scalar(status);
		
		Free((VOIDPP) & coords);
		
		break;
		
	case VARPUT:
		
		start = Mat2Long(prhs[3]);
		count = Mat2Long(prhs[4]);
		
		autoscale = (nrhs > 6 && Scalar2Int(prhs[6]) != 0);
		
		if (!autoscale)	{
			scalefactor = 1.0;
			addoffset = 0.0;
		}
		
		name = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
		dim = (int *) mxCalloc(MAX_NC_DIMS, sizeof(int));
		
		status = ncvarinq(cdfid, varid, name, & datatype, & ndims, dim, & natts);
		
		datatype = RepairBadDataType(datatype);
		
		if (datatype == NC_CHAR)	{
			mat = SetNum(prhs[5]);
		}
		else	{
			mat = prhs[5];
		}
		if (mat == NULL)	{
			mat = prhs[5];
		}
		
		pr = mxGetPr(mat);
		
		for (i = 0; i < ndims; i++)	{
			if (count[i] == -1)	{
				status = ncdiminq(cdfid, dim[i], name, & count[i]);
				count[i] -= start[i];
			}
		}
		
		Free((VOIDPP) & name);
		Free((VOIDPP) & dim);
		
		len = 0;
		if (ndims > 0)	{
			len = 1;
			for (i = 0; i < ndims; i++)	{
				len *= count[i];
			}
		}
		
		value = (VOIDP) mxCalloc(len, nctypelen(datatype));
		status = Convert(opcode, datatype, len, value, scalefactor, addoffset, pr);
		status = ncvarput(cdfid, varid, start, count, value);
		Free((VOIDPP) & value);
		
		plhs[0] = Int2Scalar(status);
		
		Free((VOIDPP) & start);
		Free((VOIDPP) & count);
		
		break;
		
	case VARGET:
		
		start = Mat2Long(prhs[3]);
		count = Mat2Long(prhs[4]);
        intcount = Mat2Int(prhs[4]);
		
		autoscale = (nrhs > 5 && Scalar2Int(prhs[5]) != 0);
		
		if (!autoscale)	{
			scalefactor = 1.0;
			addoffset = 0.0;
		}
		
		name = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
		dim = (int *) mxCalloc(MAX_NC_DIMS, sizeof(int));
		
		status = ncvarinq(cdfid, varid, name, & datatype, & ndims, dim, & natts);
		
		datatype = RepairBadDataType(datatype);
		
		for (i = 0; i < ndims; i++)	{
			if (count[i] == -1)	{
				status = ncdiminq(cdfid, dim[i], name, & count[i]);
				count[i] -= start[i];
			}
		}
		
		Free((VOIDPP) & name);
		Free((VOIDPP) & dim);
		
		m = 0;
		n = 0;
		if (ndims > 0)	{
			m = count[0];
			n = count[0];
			for (i = 1; i < ndims; i++)	{
				n *= count[i];
				if (count[i] > 1)	{
					m = count[i];
				}
			}
			n /= m;
		}
		len = m * n;
		if (ndims < 2)	{
			m = 1;
			n = len;
		}
		
		for (i = 0; i < ndims; i++)	{
			intcount[i] = count[ndims-i-1];   /*	Reverse order.	*/
		}
		
		if (MEXCDF_4 || ndims < 2)	{
			mat = mxCreateFull(m, n, mxREAL);	/*	mxCreateDoubleMatrix	*/
		}
# if MEXCDF_5
		else	{
			mat = mxCreateNumericArray(ndims, intcount, mxDOUBLE_CLASS, mxREAL);
		}
# endif
		
		pr = mxGetPr(mat);
		
		value = (VOIDP) mxCalloc(len, nctypelen(datatype));
		status = ncvarget(cdfid, varid, start, count, value);
		status = Convert(opcode, datatype, len, value, scalefactor, addoffset, pr);
		Free((VOIDPP) & value);
		
		if (datatype == NC_CHAR)	{
			plhs[0] = SetStr(mat);
		}
		else	{
			plhs[0] = mat;
		}
		if (plhs[0] == NULL)	{
			plhs[0] = mat;
		}
		
		plhs[1] = Int2Scalar(status);
		
		Free((VOIDPP) & intcount);
		Free((VOIDPP) & count);
		Free((VOIDPP) & start);
		
		break;
		
	case VARPUTG:
		
		name = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
		dim = (int *) mxCalloc(MAX_NC_DIMS, sizeof(int));
		
		status = ncvarinq(cdfid, varid, name, & datatype, & ndims, dim, & natts);
		
		datatype = RepairBadDataType(datatype);
		
		if (nrhs > 7)	{
			if (datatype == NC_CHAR)	{
				mat = SetStr(prhs[7]);
			}
			else	{
				mat = prhs[7];
			}
			if (mat == NULL)	{
				mat = prhs[7];
			}
		}
		else	{
			if (datatype == NC_CHAR)	{
				mat = SetStr(prhs[6]);
			}
			else	{
				mat = prhs[6];
			}
			if (mat == NULL)	{
				mat = prhs[6];
			}
		}
		pr = mxGetPr(mat);
		
		start = Mat2Long(prhs[3]);
		count = Mat2Long(prhs[4]);
		stride = Mat2Long(prhs[5]);
		imap = NULL;
		
		for (i = 0; i < ndims; i++)	{
			if (count[i] == -1)	{
				status = ncdiminq(cdfid, dim[i], name, & count[i]);
				count[i] -= start[i];
			}
		}
		
		Free((VOIDPP) & name);
		Free((VOIDPP) & dim);
		
		len = 0;
		if (ndims > 0)	{
			len = 1;
			for (i = 0; i < ndims; i++)	{
				len *= count[i];
			}
		}
		
		autoscale = (nrhs > 8 && Scalar2Int(prhs[8]) != 0);
		
		if (!autoscale)	{
			scalefactor = 1.0;
			addoffset = 0.0;
		}
		
		value = (VOIDP) mxCalloc(len, nctypelen(datatype));
		status = Convert(opcode, datatype, len, value, scalefactor, addoffset, pr);
		status = ncvarputg(cdfid, varid, start, count, stride, imap, value);
		Free((VOIDPP) & value);
		
		plhs[0] = Int2Scalar(status);
		
		Free((VOIDPP) & stride);
		Free((VOIDPP) & count);
		Free((VOIDPP) & start);
		
		break;
		
	case VARGETG:
		
		start = Mat2Long(prhs[3]);
		count = Mat2Long(prhs[4]);
        intcount = Mat2Int(prhs[4]);
		stride = Mat2Long(prhs[5]);
		imap = NULL;
		
		autoscale = (nrhs > 7 && Scalar2Int(prhs[7]) != 0);
		
		if (!autoscale)	{
			scalefactor = 1.0;
			addoffset = 0.0;
		}
		
		name = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
		dim = (int *) mxCalloc(MAX_NC_DIMS, sizeof(int));
		
		status = ncvarinq(cdfid, varid, name, & datatype, & ndims, dim, & natts);
		
		datatype = RepairBadDataType(datatype);
		
		for (i = 0; i < ndims; i++)	{
			if (count[i] == -1)	{
				status = ncdiminq(cdfid, dim[i], name, & count[i]);
				count[i] -= start[i];
			}
		}
		
		Free((VOIDPP) & name);
		Free((VOIDPP) & dim);
		
		m = 0;
		n = 0;
		if (ndims > 0)	{
			m = count[0];
			n = count[0];
			for (i = 1; i < ndims; i++)	{
				n *= count[i];
				if (count[i] > 1)	{
					m = count[i];
				}
			}
			n /= m;
		}
		len = m * n;
		if (ndims < 2)	{
			m = 1;
			n = len;
		}
		
		for (i = 0; i < ndims; i++)	{
			intcount[i] = count[ndims-i-1];   /*	Reverse order.	*/
		}
		
		if (MEXCDF_4 || ndims < 2)	{
			mat = mxCreateFull(m, n, mxREAL);	/*	mxCreateDoubleMatrix	*/
		}
# if MEXCDF_5
		else	{
			mat = mxCreateNumericArray(ndims, intcount, mxDOUBLE_CLASS, mxREAL);
		}
# endif
		
		pr = mxGetPr(mat);
		
		value = (VOIDP) mxCalloc(len, nctypelen(datatype));
		status = ncvargetg(cdfid, varid, start, count, stride, imap, value);
		status = Convert(opcode, datatype, len, value, scalefactor, addoffset, pr);
		Free((VOIDPP) & value);
		
		if (datatype == NC_CHAR)	{
			plhs[0] = SetStr(mat);
		}
		else	{
			plhs[0] = mat;
		}
		if (plhs[0] == NULL)	{
/*			prhs[0] = mat;		*/
			plhs[0] = mat;		/*	ZYDECO 24Jan2000	*/
		}
		
		plhs[1] = Int2Scalar(status);
		
		Free((VOIDPP) & stride);
		Free((VOIDPP) & intcount);
		Free((VOIDPP) & count);
		Free((VOIDPP) & start);
		
		break;

	case VARRENAME:
		
		name = Mat2Str(prhs[3]);
		
		status = ncvarrename(cdfid, varid, name);
		
		plhs[0] = Int2Scalar(status);
		
		Free((VOIDPP) & name);
		
		break;
		
	case VARCOPY:
	
		incdf = cdfid;
		
		invar = varid;
		
		outcdf = Scalar2Int(prhs[3]);
	
		outvar = -1;
/*		outvar = ncvarcopy(incdf, invar, outcdf);	*/
		
		plhs[0] = Int2Scalar(outvar);
		plhs[1] = Int2Scalar((outvar >= 0) ? 0 : outvar);
		
		break;
		
	case ATTPUT:
		
		datatype = (nc_type) Parameter(prhs[4]);
		
		datatype = RepairBadDataType(datatype);
		
		if (datatype == NC_CHAR)	{
			mat = SetNum(prhs[6]);
		}
		else	{
			mat = prhs[6];
		}
		if (mat == NULL)	{
			mat = prhs[6];
		}
		
		len = Scalar2Int(prhs[5]);
		if (len == -1)	{
			len = Count(mat);
		}
		
		pr = mxGetPr(mat);
		value = (VOIDP) mxCalloc(len, nctypelen(datatype));
		status = Convert(opcode, datatype, len, value, (DOUBLE) 1.0, (DOUBLE) 0.0, pr);
		
		status = ncattput(cdfid, varid, attname, datatype, len, value);
		
		if (value != NULL)	{
			Free((VOIDPP) & value);
		}
		
		plhs[0] = Int2Scalar(status);
		
		Free((VOIDPP) & attname);
		
		break;
		
	case ATTINQ:
		
		status = ncattinq(cdfid, varid, attname, & datatype, & len);
		
		datatype = RepairBadDataType(datatype);
		
		plhs[0] = Int2Scalar((int) datatype);
		plhs[1] = Int2Scalar(len);
		plhs[2] = Int2Scalar(status);
		
		Free((VOIDPP) & attname);
		
		break;
		
	case ATTGET:
		
		status = ncattinq(cdfid, varid, attname, & datatype, & len);
		
		datatype = RepairBadDataType(datatype);
		
		value = (VOIDP) mxCalloc(len, nctypelen(datatype));
		status = ncattget(cdfid, varid, attname, value);
		
		mat = mxCreateDoubleMatrix(1, len, mxREAL);
		
		pr = mxGetPr(mat);
		
		status = Convert(opcode, datatype, len, value, (DOUBLE) 1.0, (DOUBLE) 0.0, pr);
		
		if (value != NULL)	{
			Free((VOIDPP) & value);
		}
		
		if (datatype == NC_CHAR)	{
			plhs[0] = SetStr(mat);
		}
		else	{
			plhs[0] = mat;
		}
		if (plhs[0] == NULL)	{
/*			prhs[4] = mat;		*/
			plhs[0] = mat;		/*	ZYDECO 24Jan2000	*/
		}
		
		plhs[1] = Int2Scalar(status);
		
		Free((VOIDPP) & attname);
		
		break;
		
	case ATTCOPY:
	
		incdf = cdfid;
		
		invar = varid;
		
		outcdf = Scalar2Int(prhs[4]);
	
		if (mxIsNumeric(prhs[5]))	{
			outvar = Scalar2Int(prhs[2]);
		}
		else	{
			name = Mat2Str(prhs[5]);
			outvar = ncvarid(cdfid, name);
			Free((VOIDPP) & name);
		}
	
		status = ncattcopy(incdf, invar, attname, outcdf, outvar);
		
		plhs[0] = Int2Scalar(status);
		
		Free((VOIDPP) & attname);
		
		break;
		
	case ATTNAME:
		
		attnum = Scalar2Int(prhs[3]);
		attname = (char *) mxCalloc(MAX_NC_NAME, sizeof(char));
		
		status = ncattname(cdfid, varid, attnum, attname);
		
		plhs[0] = Str2Mat(attname);
		plhs[1] = Int2Scalar(status);
		
		Free((VOIDPP) & attname);
		
		break;
		
	case ATTRENAME:
	
		newname = Mat2Str(prhs[4]);
		
		status = ncattrename(cdfid, varid, attname, newname);
		
		plhs[0] = Int2Scalar(status);
		
		Free((VOIDPP) & attname);
		Free((VOIDPP) & newname);
		
		break;
		
	case ATTDEL:
		
		status = ncattdel(cdfid, varid, attname);
		
		plhs[0] = Int2Scalar(status);
		
		Free((VOIDPP) & attname);
		
		break;
		
	case RECPUT:
		
		recnum = Scalar2Long(prhs[2]);
		pr = mxGetPr(prhs[3]);
		
		autoscale = (nrhs > 4 && Scalar2Int(prhs[4]) != 0);
		
		if (!autoscale)	{
			scalefactor = 1.0;
			addoffset = 0.0;
		}
		
		recvarids = (int *) mxCalloc(MAX_VAR_DIMS, sizeof(int));
		recsizes = (long *) mxCalloc(MAX_VAR_DIMS, sizeof(long));
		datap = (VOIDPP) mxCalloc(MAX_VAR_DIMS, sizeof(VOIDP));
		
		status = ncrecinq(cdfid, & nrecvars, recvarids, recsizes);
		
		if (status == -1)	{
			plhs[0] = Int2Scalar(status);
			break;
		}
		
		length = 0;
		n = 0;
		for (i = 0; i < nrecvars; i++)	{
			ncvarinq(cdfid, recvarids[i], NULL, & datatype, NULL, NULL, NULL);
		
			datatype = RepairBadDataType(datatype);
			
			length += recsizes[i];
			n += (recsizes[i] / nctypelen(datatype));
		}
		
		if (Count(prhs[3]) < n)	{
			status = -1;
			plhs[0] = Int2Scalar(status);
			break;
		}
		
		if ((value = (VOIDP) mxCalloc((int) length, sizeof(char))) == NULL)	{
			status = -1;
			plhs[0] = Int2Scalar(status);
			break;
		}
		
		length = 0;
		p = value;
		for (i = 0; i < nrecvars; i++)	{
			datap[i] = p;
			p += recsizes[i];
		}
		
		p = (char *) value;
		pr = mxGetPr(prhs[3]);
		
		for (i = 0; i < nrecvars; i++)	{
			ncvarinq(cdfid, recvarids[i], NULL, & datatype, NULL, NULL, NULL);
		
			datatype = RepairBadDataType(datatype);
		
			length = recsizes[i] / nctypelen(datatype);
			if (autoscale)	{
				addoffset = Add_Offset(cdfid, recvarids[i]);
				scalefactor = Scale_Factor(cdfid, recvarids[i]);
				if (scalefactor == 0.0)	{
					scalefactor = 1.0;
				}
			}
			Convert(opcode, datatype, length, (VOIDP) p,  scalefactor, addoffset, pr);
			pr += length;
			p += recsizes[i];
		}
		
		status = ncrecput(cdfid, recnum, datap);
		
		plhs[0] = Int2Scalar(status);
		
		Free ((VOIDPP) & value);
		Free ((VOIDPP) & datap);
		Free ((VOIDPP) & recsizes);
		Free ((VOIDPP) & recvarids);
		
		break;
		
	case RECGET:
		
		recnum = Scalar2Long(prhs[2]);
		
		autoscale = (nrhs > 3 && Scalar2Int(prhs[3]) != 0);
		
		if (!autoscale)	{
			scalefactor = 1.0;
			addoffset = 0.0;
		}
		
		recvarids = (int *) mxCalloc(MAX_VAR_DIMS, sizeof(int));
		recsizes = (long *) mxCalloc(MAX_VAR_DIMS, sizeof(long));
		datap = (VOIDPP) mxCalloc(MAX_VAR_DIMS, sizeof(VOIDP));
		
		status = ncrecinq(cdfid, & nrecvars, recvarids, recsizes);
		
		if (status == -1)	{
			Free ((VOIDPP) & recsizes);
			Free ((VOIDPP) & recvarids);
			plhs[1] = Int2Scalar(status);
			break;
		}
		
		if (nrecvars == 0)	{
			Free ((VOIDPP) & recsizes);
			Free ((VOIDPP) & recvarids);
			plhs[0] = mxCreateFull(0, 0, REAL);
			break;
		}
		
		length = 0;
		n = 0;
		for (i = 0; i < nrecvars; i++)	{
			ncvarinq(cdfid, recvarids[i], NULL, & datatype, NULL, NULL, NULL);
		
			datatype = RepairBadDataType(datatype);
			
			length += recsizes[i];
			n += (recsizes[i] / nctypelen(datatype));
		}
		
		if ((value = (VOIDP) mxCalloc((int) length, sizeof(char))) == NULL)	{
			status = -1;
			plhs[1] = Int2Scalar(status);
			break;
		}
		
		if (value == NULL)	{
			status = -1;
			plhs[1] = Int2Scalar(status);
			break;
		}
		
		length = 0;
		p = value;
		for (i = 0; i < nrecvars; i++)	{
			datap[i] = p;
			p += recsizes[i];
		}
		
		if ((status = ncrecget(cdfid, recnum, datap)) == -1)	{
			plhs[1] = Int2Scalar(status);
			break;
		}
		
		m = 1;
		
		plhs[0] = mxCreateFull(m, n, REAL);
		
		if (plhs[0] == NULL)	{
			status = -1;
			plhs[1] = Int2Scalar(status);
			break;
		}
		
		pr = mxGetPr(plhs[0]);
		p = (char *) value;
		
		for (i = 0; i < nrecvars; i++)	{
			status = ncvarinq(cdfid, recvarids[i], NULL, & datatype, NULL, NULL, NULL);
		
			datatype = RepairBadDataType(datatype);
			
			if (status == -1)	{
				plhs[1] = Int2Scalar(status);
				break;
			}
			length = recsizes[i] / nctypelen(datatype);
			if (autoscale)	{
				addoffset = Add_Offset(cdfid, recvarids[i]);
				scalefactor = Scale_Factor(cdfid, recvarids[i]);
				if (scalefactor == 0.0)	{
					scalefactor = 1.0;
				}
			}
			Convert(opcode, datatype, length, (VOIDP) p,  scalefactor, addoffset, pr);
			pr += length;
			p += recsizes[i];
		}
		
		plhs[1] = Int2Scalar(status);
		
		Free ((VOIDPP) & value);
		Free ((VOIDPP) & datap);
		Free ((VOIDPP) & recsizes);
		Free ((VOIDPP) & recvarids);
		
		break;

	case RECINQ:
		
		recvarids = (int *) mxCalloc(MAX_VAR_DIMS, sizeof(int));
		recsizes = (long *) mxCalloc(MAX_VAR_DIMS, sizeof(long));
		
		status = ncrecinq(cdfid, & nrecvars, recvarids, recsizes);
		
		if (status != -1)	{
			for (i = 0; i < nrecvars; i++)	{
				ncvarinq(cdfid, recvarids[i], NULL, & datatype, NULL, NULL, NULL);
		
				datatype = RepairBadDataType(datatype);
			
				recsizes[i] /= nctypelen(datatype);
			}
			m = 1;
			n = nrecvars;
			plhs[0] = Int2Mat(recvarids, m, n);
			plhs[1] = Long2Mat(recsizes, m, n);
		}
		
		plhs[2] = Int2Scalar(status);
		
		Free ((VOIDPP) & recsizes);
		Free ((VOIDPP) & recvarids);
		
		break;
		
	case TYPELEN:
	
		datatype = (nc_type) Parameter(prhs[1]);
		
		len = nctypelen(datatype);
		
		plhs[0] = Int2Scalar(len);
		plhs[1] = Int2Scalar((len >= 0) ? 0 : 1);
		
		break;
		
	case SETFILL:
	
		fillmode = Scalar2Int(prhs[1]);
		
		status = ncsetfill(cdfid, fillmode);
		
		plhs[0] = Int2Scalar(status);
		plhs[1] = Int2Scalar(0);
		
		break;

	case SETOPTS:
		
		plhs[0] = Int2Scalar(ncopts);
		plhs[1] = Int2Scalar(0);
		ncopts = Scalar2Int(prhs[1]);
		
		break;
		
	case ERR:
	
		plhs[0] = Int2Scalar(ncerr);
		ncerr = 0;
		plhs[1] = Int2Scalar(0);
		
		break;
		
	case PARAMETER:
	
		if (nrhs > 1)	{
			plhs[0] = Int2Scalar(Parameter(prhs[1]));
			plhs[1] = Int2Scalar(0);
		}
		else	{
			i = 0;
			while (strcmp(parms[i].name, "NONE") != 0)	{
				mexPrintf("%12d %s\n", parms[i].code, parms[i].name);
				i++;
			}
			plhs[0] = Int2Scalar(0);
			plhs[1] = Int2Scalar(-1);
		}
		
		break;
		
	default:
	
		break;
	}
	
	return;
}


/*	Convert(): Convert between DOUBLE and NetCDF numeric types.	*/

static int
Convert	(
	OPCODE		opcode,
	nc_type		datatype,
	int			len,
	VOIDP		value,
	DOUBLE		scalefactor,
	DOUBLE		addoffset,
	DOUBLE	*	pr
	)

{
	signed char	*	pbyte;
	char		*	pchar;
	short		*	pshort;
	nclong		*	plong;	/*	Note use of nclong.	*/
	float		*	pfloat;
	double		*	pdouble;
	
	int				i;
	int				status;
	
	status = 0;
	
	switch (opcode)	{
	
	case VARPUT:
	case VARPUT1:
	case ATTPUT:
	
		switch	(datatype)	{
		case NC_BYTE:
			pbyte = (signed char *) value;
			for (i = 0; i < len; i++)	{
				*pbyte++ = (signed char) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_CHAR:
			pchar = (char *) value;
			for (i = 0; i < len; i++)	{
				*pchar++ = (char) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_SHORT:
			pshort = (short *) value;
			for (i = 0; i < len; i++)	{
				*pshort++ = (short) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_LONG:
			plong = (nclong *) value;
			for (i = 0; i < len; i++)	{
				*plong++ = (nclong) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_FLOAT:
			pfloat = (float *) value;
			for (i = 0; i < len; i++)	{
				*pfloat++ = (float) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_DOUBLE:
			pdouble = (double *) value;
			for (i = 0; i < len; i++)	{
				*pdouble++ = (double) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		default:
			status = -1;
			break;
		}
		break;
		
	case VARGET:
	case VARGET1:
	case ATTGET:
	
		switch	(datatype)	{
		case NC_BYTE:
			pbyte = (signed char *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pbyte++;
			}
			break;
		case NC_CHAR:
			pchar = (char *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pchar++;
			}
			break;
		case NC_SHORT:
			pshort = (short *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pshort++;
			}
			break;
		case NC_LONG:
			plong = (nclong *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *plong++;
			}
			break;
		case NC_FLOAT:
			pfloat = (float *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pfloat++;
			}
			break;
		case NC_DOUBLE:
			pdouble = (double *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pdouble++;
			}
			break;
		default:
			status = -1;
			break;
		}
		break;
	
	case VARPUTG:
	case RECPUT:
	
		switch	(datatype)	{
		case NC_BYTE:
			pbyte = (signed char *) value;
			for (i = 0; i < len; i++)	{
				*pbyte++ = (signed char) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_CHAR:
			pchar = (char *) value;
			for (i = 0; i < len; i++)	{
				*pchar++ = (char) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_SHORT:
			pshort = (short *) value;
			for (i = 0; i < len; i++)	{
				*pshort++ = (short) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_LONG:
			plong = (nclong *) value;
			for (i = 0; i < len; i++)	{
				*plong++ = (nclong) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_FLOAT:
			pfloat = (float *) value;
			for (i = 0; i < len; i++)	{
				*pfloat++ = (float) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		case NC_DOUBLE:
			pdouble = (double *) value;
			for (i = 0; i < len; i++)	{
				*pdouble++ = (double) ((*pr++ - addoffset) / scalefactor);
			}
			break;
		default:
			status = -1;
			break;
		}
		break;
		
	case VARGETG:
	case RECGET:
	
		switch	(datatype)	{
		case NC_BYTE:
			pbyte = (signed char *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pbyte++;
			}
			break;
		case NC_CHAR:
			pchar = (char *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pchar++;
			}
			break;
		case NC_SHORT:
			pshort = (short *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pshort++;
			}
			break;
		case NC_LONG:
			plong = (nclong *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *plong++;
			}
			break;
		case NC_FLOAT:
			pfloat = (float *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pfloat++;
			}
			break;
		case NC_DOUBLE:
			pdouble = (double *) value;
			for (i = 0; i < len; i++)	{
				*pr++ = addoffset + scalefactor * (DOUBLE) *pdouble++;
			}
			break;
		default:
			status = -1;
			break;
		}
		break;
	
	default:
		status = -1;
		break;
	}
	
	return (status);
}


/*	Usage(): Print information on NCMEX usage.	*/

static VOID
Usage	(
	)

{
	int		i;
	int		j;
		
# if defined __DATE__
# if defined __TIME__

# if !defined __FILE__
# define	__FILE__	"mexcdf53.c"
# endif

	mexPrintf("Program %s Version %s %s\n", __FILE__, __DATE__, __TIME__);
	
# endif
# endif
	
	if (VERBOSE)	{
		mexPrintf("\n");
		mexPrintf("mexcdf53(\'USAGE\')\n");
		mexPrintf("\n");
		mexPrintf("mexcdf53(\'CREATE\', \'path\', cmode) ==> [cdfid, status]\n");
		mexPrintf("mexcdf53(\'OPEN\', \'path\', mode) ==> [cdfid, status]\n");
		mexPrintf("mexcdf53(\'REDEF\', cdfid) ==> status\n");
		mexPrintf("mexcdf53(\'ENDEF\', cdfid) ==> status\n");
		mexPrintf("mexcdf53(\'INQUIRE\', cdfid) ==> [ndims, nvars, natts, recdim, status]\n");
		mexPrintf("mexcdf53(\'SYNC\', cdfid) ==> status\n");
		mexPrintf("mexcdf53(\'ABORT\', cdfid) ==> status\n");
		mexPrintf("mexcdf53(\'CLOSE\', cdfid) ==> status\n");
		mexPrintf("\n");
		mexPrintf("mexcdf53(\'DIMDEF\', cdfid, \'name\', length) ==> [dimid, status]\n");
		mexPrintf("mexcdf53(\'DIMID\', cdfid, \'name\') ==> [dimid, status]\n");
		mexPrintf("mexcdf53(\'DIMINQ\', cdfid, dimid) ==> [\'name\', length, status]\n");
		mexPrintf("mexcdf53(\'DIMRENAME\', cdfid, \'name\') ==> status\n");
		mexPrintf("\n");
		mexPrintf("mexcdf53(\'VARDEF\', cdfid, \'name\', datatype, ndims, [dim]) ==> [varid, status]\n");
		mexPrintf("mexcdf53(\'VARID\', cdfid, \'name\') ==> [varid, status]\n");
		mexPrintf("mexcdf53(\'VARINQ\', cdfid, varid) ==> [\'name\', datatype, ndims, [dim], natts, status]\n");
		mexPrintf("mexcdf53(\'VARPUT1\', cdfid, varid, [coords], value, autoscale) ==> status\n");
		mexPrintf("mexcdf53(\'VARGET1\', cdfid, varid, [coords], flag) ==> [value, status]\n");
		mexPrintf("mexcdf53(\'VARPUT\', cdfid, varid, [start], [count], [value], autoscale) ==> status\n");
		mexPrintf("mexcdf53(\'VARGET\', cdfid, varid, [start], [count], autoscale) ==> [[value], status]\n");
		mexPrintf("mexcdf53(\'VARPUTG\', cdfid, varid, [start], [count], [stride], [imap], [value], autoscale) ==> status\n");
		mexPrintf("mexcdf53(\'VARGETG\', cdfid, varid, [start], [count], [stride], [imap], autoscale) ==> [[value], status]\n");
		mexPrintf("mexcdf53(\'VARRENAME\', cdfid, varid, \'name\') ==> status\n");
		mexPrintf("\n");
		mexPrintf("mexcdf53(\'ATTPUT\', cdfid, varid, \'name\', datatype, len, [value]) ==> status\n");
		mexPrintf("mexcdf53(\'ATTINQ\', cdfid, varid, \'name\') ==> [datatype, len, status]\n");
		mexPrintf("mexcdf53(\'ATTGET\', cdfid, varid, \'name\') ==> [[value], len, status]\n");
		mexPrintf("mexcdf53(\'ATTCOPY\', incdf, invar, \'name\', outcdf, outvar) ==> status\n");
		mexPrintf("mexcdf53(\'ATTNAME\', cdfid, varid, attnum) ==> [\'name\', status]\n");
		mexPrintf("mexcdf53(\'ATTRENAME\', cdfid, varid, \'name\', \'newname\') ==> status\n");
		mexPrintf("mexcdf53(\'ATTDEL\', cdfid, varid, \'name\') ==> status\n");
		mexPrintf("\n");
		mexPrintf("mexcdf53(\'TYPELEN\', datatype) ==> [len, status]\n");
		mexPrintf("mexcdf53(\'SETFILL\', cdfid, fillmode) ==> [old_fillmode, status]\n");
		mexPrintf("mexcdf53(\'SETOPTS\', ncopts) ==> [old_ncopts, status]\n");
		mexPrintf("mexcdf53(\'ERR\') ==> [ncerr, status]\n");
		mexPrintf("mexcdf53(\'PARAMETER\', \'NC_...\') ==> [code, status]\n");
	}
	
	else	{
	
		i = 0;
		while (ops[i].opcode != NONE)	{
		
			mexPrintf("mexcdf53(\'%s\'", ops[i].opname);
			for (j = 1; j < ops[i].nrhs; j++)	{
				mexPrintf(", in%d", j);
			}
			mexPrintf(")");
			if (ops[i].nlhs > 0)	{
				mexPrintf(" ==> [");
				for (j = 1; j <= ops[i].nlhs; j++)	{
					mexPrintf("out%d", j);
					if (j < ops[i].nlhs)	{
						mexPrintf(", ");
					}
				}
				mexPrintf("]");
			}
			mexPrintf("\n");
			
			i++;
		}
	}
	
	return;
}


/*	Parameter(): Get NetCDF parameter by name.	*/

static int
Parameter	(
	Matrix	*	mat
	)

{
	int			parameter;
	char	*	p;
	char	*	q;
	int			i;
	
	parameter = -1;
	
	if (mxIsNumeric(mat))	{
		parameter = Scalar2Int(mat);
	}
	else	{
		p = Mat2Str(mat);
		q = p;
		for (i = 0; i < strlen(p); i++)	{
			*q = (char) toupper((int) *q);
			q++;
		}
		if (strncmp(p, "NC_", 3) == 0)	{	/*	Trim away "NC_".	*/
			q = p + 3;
		}
		else	{
			q = p;
		}
		
		i = 0;
		while (strcmp(parms[i].name, "NONE") != 0)	{
			if (strncmp(q, parms[i].name, parms[i].len) == 0)	{
				parameter = parms[i].code;
				break;
			}
			else	{
				i++;
			}
		}
		
		Free ((VOIDPP) & p);
	}
	
	return (parameter);
}


/*	Scale_Factor: Return "scale_factor" attribute as DOUBLE.	*/

static DOUBLE
Scale_Factor	(
	int	cdfid,
	int	varid
	)

{
	int			status;
	nc_type		datatype;
	int			len;
	char		value[32];
	DOUBLE		d;
	
	d = 1.0;
	
	if ((status = ncattinq(cdfid, varid, "scale_factor", &datatype, &len)) == -1)	{
	}
	else if ((status = ncattget(cdfid, varid, "scale_factor", value)) == -1)	{
	}
	else	{
		switch (RepairBadDataType(datatype))	{
			case NC_BYTE:
				d = (DOUBLE) *((signed char *) value);
				break;
			case NC_CHAR:
				d = (DOUBLE) *((char *) value);
				break;
			case NC_SHORT:
				d = (DOUBLE) *((short *) value);
				break;
			case NC_LONG:
				d = (DOUBLE) *((nclong *) value);
				break;
			case NC_FLOAT:
				d = (DOUBLE) *((float *) value);
				break;
			case NC_DOUBLE:
				d = (DOUBLE) *((double *) value);
				break;
			default:
				break;
		}
	}
	
	return (d);
}


/*	Add_Offset: Return "add_offset" attribute as DOUBLE.	*/

static DOUBLE
Add_Offset	(
	int	cdfid,
	int	varid
	)

{
	int			status;
	nc_type		datatype;
	int			len;
	char		value[32];
	DOUBLE		d;
	
	d = 0.0;
	
	if ((status = ncattinq(cdfid, varid, "add_offset", &datatype, &len)) == -1)	{
	}
	else if ((status = ncattget(cdfid, varid, "add_offset", value)) == -1)	{
	}
	else	{
		switch (RepairBadDataType(datatype))	{
			case NC_BYTE:
				d = (DOUBLE) *((signed char *) value);
				break;
			case NC_CHAR:
				d = (DOUBLE) *((char *) value);
				break;
			case NC_SHORT:
				d = (DOUBLE) *((short *) value);
				break;
			case NC_LONG:
				d = (DOUBLE) *((nclong *) value);
				break;
			case NC_FLOAT:
				d = (DOUBLE) *((float *) value);
				break;
			case NC_DOUBLE:
				d = (DOUBLE) *((double *) value);
				break;
			default:
				break;
		}
	}
	
	return (d);
}


/*	SetNum(): Convert matrix to numeric matrix.	*/

static Matrix *
SetNum	(
	Matrix	*	mat
	)

{
	Matrix	*	result = NULL;
	int			status;
	
	if (mxIsString(mat))	{
		mexSetTrapFlag(1);
		status = mexCallMATLAB(1, & result, 1, & mat, "abs");
		if (status == 1)	{
			result = NULL;
		}
		mexSetTrapFlag(0);
	}
	
	return (result);
}


/*	SetStr(): Convert matrix to string matrix.	*/

static Matrix *
SetStr	(
	Matrix	*	mat
	)

{
	Matrix	*	result = NULL;
	int			status;
	
	if (mxIsNumeric(mat))	{
		mexSetTrapFlag(1);
		status = mexCallMATLAB(1, & result, 1, & mat, "setstr");
		if (status == 1)	{
			result = NULL;
		}
		mexSetTrapFlag(0);
	}
	
	return (result);
}


/*	Mat2Str(): Return string from a string-matrix.	*/

static char	*
Mat2Str	(
	Matrix	*	mat
	)

{
	DOUBLE	*	pr;
	char	*	p;
	char	*	str;
	int			len;
	int			i;

	len = mxGetM(mat) * mxGetN(mat);
	
	str = (char *) mxCalloc(len + 1, sizeof(char));
	
	mxGetString(mat, str, len + 1);
	
	return (str);
}


/*	Str2Mat():	Convert string into a string-matrix.	*/

static Matrix *
Str2Mat	(
	char	*	str
	)

{
	Matrix	*	mat;

	mat = mxCreateString(str);
	
	return (mat);
}


/*	Mat2Long(): Return matrix values as a long integer array.	*/

static long *
Mat2Long	(
	Matrix	*	mat
	)

{
	DOUBLE	*	pr;
	long	*	plong;
	long	*	p;
	int			len;
	int			i;

	len = mxGetM(mat) * mxGetN(mat);
	
	plong = (long *) mxCalloc(len, sizeof(long));
	p = plong;
	pr = mxGetPr(mat);
	
	for (i = 0; i < len; i++)	{
		*p++ = (long) *pr++;
	}
	
	return (plong);
}


/*	Long2Mat(): Convert long integer array to a matrix.	*/

static Matrix *
Long2Mat	(
	long	*	plong,
	int			m,
	int			n
	)

{
	Matrix	*	mat;
	DOUBLE	*	pr;
	long	*	p;
	int			len;
	int			i;

	mat = mxCreateFull(m, n, REAL);
	
	pr = mxGetPr(mat);
	p = plong;
	
	len = m * n;
	for (i = 0; i < len; i++)	{
		*pr++ = (long) *p++;
	}
	
	return (mat);
}


/*	Mat2Int(): Return matrix values as an integer array.	*/

static int *
Mat2Int	(
	Matrix	*	mat
	)

{
	DOUBLE	*	pr;
	int		*	pint;
	int		*	p;
	int			len;
	int			i;

	len = mxGetM(mat) * mxGetN(mat);
	
	pint = (int *) mxCalloc(len, sizeof(int));
	p = pint;
	pr = mxGetPr(mat);
	
	for (i = 0; i < len; i++)	{
		*p++ = (int) *pr++;
	}
	
	return (pint);
}


/*	Int2Mat(): Convert integer array to a matrix.	*/

static Matrix *
Int2Mat	(
	int		*	pint,
	int			m,
	int			n
	)

{
	Matrix	*	mat;
	DOUBLE	*	pr;
	int	*	p;
	int			len;
	int			i;

	mat = mxCreateFull(m, n, REAL);
	
	pr = mxGetPr(mat);
	p = pint;
	
	len = m * n;
	for (i = 0; i < len; i++)	{
		*pr++ = (int) *p++;
	}
	
	return (mat);
}


/*	Int2Scalar(): Convert integer value to a scalar matrix.	*/

static Matrix *
Int2Scalar	(
	int		i
	)

{
	Matrix	*	scalar;
	
	scalar = mxCreateFull(1, 1, REAL);
	
	*(mxGetPr(scalar)) = (DOUBLE) i;
	
	return (scalar);
}


/*	Scalar2Int(): Return integer value of a scalar matrix.*/

static int
Scalar2Int	(
	Matrix	*	scalar
	)

{
	return ((int) *(mxGetPr(scalar)));
}


/*	Long2Scalar(): Convert long integer value to a scalar matrix.	*/

static Matrix *
Long2Scalar	(
	long		along
	)

{
	Matrix	*	scalar;
	
	scalar = mxCreateFull(1, 1, REAL);
	
	*(mxGetPr(scalar)) = (DOUBLE) along;
	
	return (scalar);
}


/*	Scalar2Long(): Return long integer value of a scalar matrix.	*/

static long
Scalar2Long	(
	Matrix	*	scalar
	)

{
	return ((long) *(mxGetPr(scalar)));
}


/*	Count(): Element count of a matrix.	*/

static int
Count	(
	Matrix	*	mat
	)

{
	return ((int) (mxGetM(mat) * mxGetN(mat)));
}


/*	Free(): De-allocate memory by address of pointer.	*/

static VOID
Free	(
	VOIDPP		p
	)

{
	if (*p)	{
		if (1)	{
			mxFree(*p);
			*p = (VOIDP) 0;
		}
	}
	else if (VERBOSE)	{
		mexPrintf(" ## MexCDF53/Free(): Attempt to free null-pointer.\n");
	}
}


/*	RepairBadDataType(): Repair bad datatype.	*/

static nc_type
RepairBadDataType	(
	nc_type		theDataType
	)
	
{
	if (theDataType < NC_BYTE || theDataType > NC_DOUBLE)	{
		if (VERBOSE)	{
			mexPrintf(" ## MexCDF53/RepairBadDataType: %d", theDataType);
		}
		if (theDataType < NC_BYTE)	{
			theDataType = -1;
		}
		else if	(theDataType > NC_DOUBLE)	{
			while (theDataType > 255)	{
				theDataType /= 256;
			}
			while (theDataType > NC_DOUBLE)	{
				theDataType /= 2;
			}
		}
		if (VERBOSE)	{
			mexPrintf(" Converted To %d.\n", theDataType);
		}
	}
	
	return (theDataType);
}
