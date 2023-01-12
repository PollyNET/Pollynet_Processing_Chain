=========================
Download and Installation
=========================

Picasso can be installed and used in Windows 10 and Linux (tested on `Centos 5`_). Since Picasso is developed in **Matlab (r2014a)**, it's required to have Matlab with compatible version installed in your machine.

Download
--------

Picasso project is hosted in `GitHub`_. The source code can be easily downloaded by running the command below, if `Git`_ was installed in your local machine.

.. note::

    Git is a very handy tool for code management and version control.

.. code-block:: console

    $ git clone https://github.com/PollyNET/Pollynet_Processing_Chain/

Dependencies
------------

Since `Picasso`_ is a very powerful lidar data processing platform, including data pre-processing, lidar calibration and data visualization, etc. It relies on many dependencies for realizing these features. Below are the list of Picasso **dependencies**:

- Python 3.6
- curl

It's recommended to use `Anaconda`_ for managing Python. Meanwhile, `matplotlib`_ is required for data visualization, but it's pre-installed in `Anaconda`_. And some additional Python packages are necessary for calculations and `Sphinx`_ docs. Below is the list of required Python packages:

.. code-block:: yaml

  alabaster==0.7.12
  Babel==2.9.1
  certifi==2021.5.30
  charset-normalizer==2.0.4
  colorama==0.4.4
  commonmark==0.9.1
  cycler==0.10.0
  docutils==0.16
  future==0.18.2
  idna==3.2
  imagesize==1.2.0
  Jinja2==3.0.1
  kiwisolver==1.3.1
  MarkupSafe==2.0.1
  matplotlib==3.3.4
  numpy==1.19.5
  packaging==21.0
  Pillow==8.2.0
  pycodestyle==2.7.0
  Pygments==2.9.0
  pyparsing==2.4.7
  python-dateutil==2.8.1
  pytz==2021.1
  recommonmark==0.7.1
  requests==2.26.0
  rstcheck==3.3.1
  scipy==1.5.4
  six==1.16.0
  snowballstemmer==2.1.0
  Sphinx==4.1.2
  sphinx-rtd-theme==0.5.2
  sphinxcontrib-applehelp==1.0.2
  sphinxcontrib-devhelp==1.0.2
  sphinxcontrib-htmlhelp==2.0.0
  sphinxcontrib-jsmath==1.0.1
  sphinxcontrib-matlabdomain==0.12.0
  sphinxcontrib-qthelp==1.0.3
  sphinxcontrib-serializinghtml==1.1.5
  urllib3==1.26.6
  wincertstore==0.2

SQLite is necessary for saving lidar calibration results. The `Java`_ connector has been provided in the folder of **./include**. But it needs to restart Matlab to activate this `Java`_ connector.

NOTE: one has to run **addSQLiteJDBC('path_to\sqlite-jdbc-3.30.1.jar')** once!


.. _Java: https://www.sqlitetutorial.net/sqlite-java/sqlite-jdbc-driver/
.. _Anaconda: https://www.anaconda.com/products/individual
.. _CentOS 5: https://www.centos.org/
.. _Github: https://github.com/
.. _Git: https://git-scm.com/
.. _Picasso: https://github.com/PollyNET/Pollynet_Processing_Chain/
.. _Sphinx: https://www.sphinx-doc.org/
.. _matplotlib: https://matplotlib.org/