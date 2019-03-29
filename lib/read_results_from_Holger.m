function [data] = read_results_from_Holger(file)
%READ_RESULTS_FROM_HOLGER read the retrieving results from the Labview Program.
%	Example:
%		[data] = read_results_from_Holger(file)
%	Inputs:
%		file: char
%			filename of the output file by the Labview Program.
%	Outputs:
%		data: matrix
%			1: Height(km)
%			2: Beta355 (Mm^-1 sr^-1)
%			3: error beta355 (Mm^-1 sr^-1)	
%			4: Beta532 (Mm^-1 sr^-1)
%			5: error beta532 (Mm^-1 sr^-1)	
%			6: Beta1064 (Mm^-1 sr^-1)
%			7: error beta1064 (Mm^-1 sr^-1)	
%			8: alpha355 (Mm^-1 sr^-1)
%			9: error alpha355 (Mm^-1)	
%			10: alpha532 (Mm^-1 sr^-1)
%			11: error alpha532 (Mm^-1)	
%			12: S355 (sr^-1)
%			13: errorS355
%			14: S532 (sr^-1)
%			15: error S532
%			16: Angstrom ext
%			17: error Angstrom ext
%			18: Angstrom b355/532
%			19: error Angstrom b355/532
%			20: Angstrom b532/1064
%			21: error Angstrom b532/1064 
%			22: voldepol höhe
%			23: vol.depol 532
%			24: error vol.depol 
%			25: partdepolhöhe
%			26: part. depol 532
%			27: error part. depol
%			28: sounding height (km)
%			29: Temperature (K)
%			30: Pressure (Pa)
%			31: voltdepol height
%			32: vol. depol 355
%			33: error
%			34: partdepol height
%			35: part. depol 355
%			36: error
%			37: Mixing ratio height (km)
%			38: Water vapour mixing ratio (g/kg)
%			39: Height NF (km)
%			40: Beta532 NF (Mm^-1 sr^-1)
%			41: error beta532 NF (Mm^-1 sr^-1)	
%			42: alpha 532 NF (Mm^-1 sr^-1)
%			43: error alpha532 NF (Mm^-1)	
%			44: Spar 532 NF (sr)
%			45: error Spar532 NF (sr)	
%			46: Height HSRL (km)
%			47: BetaHSRL (Mm^-1 sr^-1)
%			48: error betaHSRL (Mm^-1 sr^-1)	
%			49: alpha HSRL (Mm^-1 sr^-1)
%			50: error alphaHSRL (Mm^-1)	
%			51: Spar HSRL (sr)	
%			52: error Spar HSRL (sr)	
%			53: vol. depol 1064	
%			54: error	
%			55: part. depol 1064	
%			56: error	
%			57: water_vapour_error	
%			58: Sounding height	
%			59: water_vapor_mix_sonde	
%			60: Height NF 355 (km)
%			61: Beta355 NF (Mm^-1 sr^-1)
%			62: error beta355 NF (Mm^-1 sr^-1)	
%			63: alpha 355 NF (Mm^-1 sr^-1)
%			64: error alpha355 NF (Mm^-1)	
%			65: Spar 355 NF (sr)
%			66: error Spar 355 NF (sr)	
%			67: BetaMOL 355 (m^-1 sr^-1)	
%			68: BetaMOL 532 (m^-1 sr^-1)	
%			69: BetaMOL 1064 (m^-1 sr^-1)	
%			70: Ang b355/532 NF	
%			71: Error Ang b355/532 NF	
%			72: Ang Ext NF	
%			73: Error Ang Ext NF
%	History:
%		2018-06-27. First edition by Zhenping.
%	Contact:
%		zhenping@tropos.de

if ~ exist(file, 'file')
	warning('The input file does not exist.\n');
	data = [];
	return;
end

data = dlmread(file, '	', 1, 0);

end