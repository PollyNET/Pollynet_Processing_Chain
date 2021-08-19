========
Overview
========

Lidar is a key instrument for the characterization of aerosols and their impact on the Earth's environment, as they are able to provide vertically resolved information of aerosols. With multiwavelength Raman polarization lidar, aerosol layers can be characterized in terms of types, size distribution, and concentration (`Ansmann and Müller, 2005`_; `Müller., et al., 2007`_; `Ansmann et al., 2012`_).

Motivated by the urgent need for robust multiwavelength Raman polarization lidars that are easy to operate and allow aerosol typing, a portable lidar system, called Polly (or Polly\*XT* for the updated version), has been developed at the Leibniz Institute for Tropospheric Research (`TROPOS`_) with international partners during the past two decades. As the number of Polly systems and measurement sites increasing with time, an independent, voluntary, international network of cooperating institutes, the so-called PollyNET, has evolved as an additional contribution to the world wide aerosol observational efforts. Namely the Finnish Meteorological Institute (FMI), the National Institute of Environmental Research (NIER) in Korea, the Évora University in Portugal (UE-ICT), the University of Warsaw (UW) in Poland, The German Meteorological Service (DWD) and the National Observatory of Athens (NOA) in Greece contribute actively to the network by hosting Polly systems. Each group contributes with its expertise and knowledge to the network and to joint scientific projects.

What is Picasso?
----------------

Picasso is an automatic processing tool for analyzing data of a multiwavelength Raman polarization lidar. It takes sophisticated lidar processing algorithms to produce physical results from lidar backscatter measurements, which are suitable for aerosol classification, climatological analysis, model evaluation aerosol radiative transfer calculations. With Picasso, any users with no lidar background can quickly set up lidar data processing routines to analyze data from Polly\*XT* and generate lidar quicklooks without writing any code. The outputs from Picasso are netCDF4 files following climatic format and can be opened and by many third party viewers, i.e., Panoply_.

So far, Picasso is dedicated for handling with lidar data from PollyNET_, which is a worldwide lidar network with more than 10 active lidar stations. After nearly 20 years development, the capabilities of current lidars have been substantially improved, compared with the first version Polly. System details can be found in `Althausen., et al (2009)`_ and `Engelmann., et al (2016)`_. For the latest version of Polly, it can measure :math:`3\beta+2\alpha+2\delta+WV`, simultaneously. By introducing a third small telescope, the latest Polly can measure volume depolarization ratio at 532 nm under two field-of-views (FOV) (`Jimenez., et al., 2020`_). This feature enables the retrieval of cloud microphysics at liquid cloud base. The dynamic and evolving characteristics of PollyNET shape Picasso into a continuously integrated and developed processing platform. Therefore, we kindly invite people to test their ideas on this platform and give us feedback and pull-request to make the platform more robust and powerful.

Structure of Picasso?
---------------------

.. figure:: _static/PollyNET-processing-chain-flowchart.jpg
       :width: 400 px
       :align: center

       Flowchart of the PollyNET processing chain. (Optional parts mean the modules are dependent on the available AERONET sites nearby).

Publication
-----------

Yin., et al, "Deriving high temporal and spatial resolved aerosol optical properties for aerosol target classification with Raman lidar calibration", Atmospheric Measurement Techniques, 2021 (in preparation)

.. _Althausen., et al (2009): https://doi.org/10.1175/2009JTECHA1304.1
.. _Engelmann., et al (2016): https://amt.copernicus.org/articles/9/1767/2016/
.. _Ansmann and Müller, 2005: https://doi.org/10.1007/0-387-25101-4_4
.. _Müller., et al., 2007: https://doi.org/10.1029/2006jd008292
.. _Ansmann et al., 2012: https://doi.org/10.5194/acp-12-9399-2012
.. _TROPOS: https://www.tropos.de/
.. _Jimenez., et al., 2020: https://doi.org/10.5194/acp-20-15265-2020
.. _Panoply: https://www.giss.nasa.gov/tools/panoply/
.. _PollyNET: https://polly.tropos.de/