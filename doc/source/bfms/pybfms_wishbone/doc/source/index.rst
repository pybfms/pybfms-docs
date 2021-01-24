#######################
PyBfms Wishbone Library
#######################

The PyBfms Wishbone library provides Bus Functional Models (BFMs)
to allow Python testbench environments to use the Wishbone bus protocol.

*************
Installation
*************

The Wishbone BFMs library can be installed via PyPi.org or directly from
GitHub. 

Installing from PyPi::

% pip install pybfms_wishbone


Installing from GitHub::

% pip install https://github.com/pybfms/pybfms_wishbone


**********************
Provided BFMs
**********************
The Wishbone BFM library provides three BFMS:

- Inititor BFM -- Initiates accesses on a Wishbone interface
- Target BFM -- Receives and responds to accesses on Wishbone interface
- Monitor BFM -- Passively monitors traffic on a Wishbone interface

Initiator BFM
=============


Signal-level Interface
----------------------

.. code-block:: sv

  module wb_initiator_bfm #(
        parameter ADDR_WIDTH = 32,
        parameter DATA_WIDTH = 32
        ) (
        input                            clock,
        input                            reset,
        output reg[ADDR_WIDTH-1:0]       adr,
        output reg[DATA_WIDTH-1:0]       dat_w,
        input[DATA_WIDTH-1:0]            dat_r,
        output reg                       cyc,
        input                            err,
        output reg[(DATA_WIDTH/8)-1:0]   sel,
        output reg                       stb,
        input                            ack,
        output reg                       we
        );

Python API
----------
.. automodule:: wishbone_bfms.wb_initiator_bfm
    :members:
    :member-order: bysource
    :undoc-members:

Target BFM
==========


Signal-level Interface
----------------------

.. code-block:: sv

  module wb_target_bfm #(
        parameter ADDR_WIDTH = 32,
        parameter DATA_WIDTH = 32
        ) (
        input                        clock,
        input                        reset,
        input[ADDR_WIDTH-1:0]        adr,
        input[DATA_WIDTH-1:0]        dat_w,
        output reg[DATA_WIDTH-1:0]   dat_r,
        input                        cyc,
        output reg                   err,
        input[(DATA_WIDTH/8)-1:0]    sel,
        input                        stb,
        output reg                   ack,
        input                        we
        );
		

Python API
----------
    
.. automodule:: wishbone_bfms.wb_target_bfm
    :members:
    :member-order: bysource
    :undoc-members:

    