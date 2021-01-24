'''
Created on Nov 21, 2020

@author: mballance
'''

import pybfms

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/wb_initiator_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/wb_initiator_bfm.v"),
    }, has_init=True)
class WbInitiatorBfm():


    def __init__(self):
        self.busy = pybfms.lock()
        self.ack_ev = pybfms.event()
        self.addr_width = 0
        self.data_width = 0
        self.reset_ev = pybfms.event()
        self.is_reset = False
        
    async def write(self, adr, dat, sel):
        """
        Write data according to the mask 'sel'.
        
        Note that this call will block until the first reset is received
        """
        await self.busy.acquire()

        if not self.is_reset:
            await self.reset_ev.wait()
            self.reset_ev.clear()

        self._access_req(adr, dat, 1, sel)
        
        await self.ack_ev.wait()
        self.ack_ev.clear()
        
        self.busy.release()
        
    async def read(self, adr):
        """
        Read data from the system.
        
        Note that this call will block until the first reset is received
        """
        await self.busy.acquire()
        
        if not self.is_reset:
            await self.reset_ev.wait()
            self.reset_ev.clear()
            
        self._access_req(adr, 0, 0, 0)
        
        await self.ack_ev.wait()
        self.ack_ev.clear()
        
        self.busy.release()
        
        return self.dat_i
    
    async def wait(self, cycles):
        """
        Wait for the specified number of interface-clock cycles.
        
        Note that this call does not wait for a reset
        """
        
        await self.busy.acquire()
        self._wait_req(cycles)
        await self.ack_ev.wait()
        self.busy.release()
        
        
    @pybfms.import_task(pybfms.uint64_t,pybfms.uint64_t,pybfms.uint8_t,pybfms.uint8_t)
    def _access_req(self, adr, dat, we, sel):
        pass
    
    @pybfms.export_task(pybfms.uint64_t)
    def _access_ack(self, dat_i):
        self.dat_i = dat_i
        self.ack_ev.set()
        
    @pybfms.import_task(pybfms.uint32_t)
    def _wait_req(self, cycles):
        pass
    
    @pybfms.export_task()
    def _wait_ack(self):
        self.ack_ev.set()
        
    @pybfms.export_task(pybfms.uint32_t,pybfms.uint32_t)
    def _set_parameters(self, addr_width, data_width):
        self.addr_width = addr_width
        self.data_width = data_width
        
    @pybfms.export_task()
    def _reset(self):
        self.is_reset = True
        self.reset_ev.set()
