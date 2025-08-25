## OPA -  Lattice Design Code 

The main purpose of the OPA code is to support the development of electron (positron) storage rings. Emphasis is on visualization and interactivity rather than on elaborate beam dynamics models.
OPA is in particular useful for designing high brightness light source lattices, but may be used for transfer lines and other types of lattices as well.
Storage ring design with OPA starts from scratch and ends at a bare (i.e. error free) lattice with optimized dynamic apertures, to be passed on to other codes like `TRACY`, `MAD` or `ELEGANT`, which use more complete models.

**History and Acknowledgements**

OPA is based on the code OPTIK from Klaus Wille, who started in the 80’s already to work on a design tool for electron rings.
In 1993 he kindly passed it on to the author, who developed it further and used it for the design of the Swiss Light Source, SLS, and the upgrade, SLS-2.  
Algorithms for sextupole optimization and signal processing were kindly contributed by Johan Bengtsson.  
Simon Leemann did a lot of tests and suggested many extensions and changes during the design of MAX-IV.  
Michael Borland and Chun-xi Wang tested the module for non-linear optimization for consistency with the `ELEGANT` code and helped to find several bugs.  
Volker Ziemann helped with implementation of coupling and calculation of radiation integrals.  
Bernard Riemann implemented the flood fill algorithm.  

**Licence**

This software is licensed under the MIT License (see LICENSE file for details).
Attribution:
- Original author: Andreas STREUN ([@opa-andreas](https://github.com/opa-andreas))
- Copyright (c) 2025 Paul Scherrer Institut PSI and Andreas Streun
- Additional contributions and stewardship as mentioned in the acknowledgements.
