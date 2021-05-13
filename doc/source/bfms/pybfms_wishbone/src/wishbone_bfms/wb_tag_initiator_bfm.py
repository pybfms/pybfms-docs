'''
Created on May 11, 2021

@author: mballance
'''

import pybfms
from wishbone_bfms.wb_initiator_bfm import WbInitiatorBfm

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/wb_tag_initiator_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/wb_tag_initiator_bfm.v"),
    }, has_init=True)
class WbTagInitiatorBfm(object):
    
    def __init__(self):
        self.adr_width = 0
        self.dat_width = 0
        self.tga_width = 0
        self.tgd_width = 0
        self.tgc_width = 0
        self.dat_i = 0
        self.tgd_i = 0
        self.busy = pybfms.lock()
        self.ack_ev = pybfms.event()
        self.addr_width = 0
        self.data_width = 0
        self.reset_ev = pybfms.event()
        self.is_reset = False

    async def write_tagged(self, adr, tga, dat, tgd, sel, tgc):
        await self.busy.acquire()

        if not self.is_reset:
            await self.reset_ev.wait()
            self.reset_ev.clear()

        self._access_req(adr, tga, dat, tgd, 1, sel, tgc)
        
        await self.ack_ev.wait()
        self.ack_ev.clear()
        
        self.busy.release()
        
        return (self.dat_i,self.tgd_i)
    
    async def write(self, adr, dat, sel):
        await self.write_tagged(adr, 0, dat, 0, sel, 0)
        
    async def read_tagged(self, adr, tga, tgc):
        """Returns (data,tag)"""
        await self.busy.acquire()
        
        if not self.is_reset:
            await self.reset_ev.wait()
            self.reset_ev.clear()
            
        self._access_req(adr, tga, 0, 0, 0, 0, tgc)
        
        await self.ack_ev.wait()
        self.ack_ev.clear()
        
        self.busy.release()
        
        return (self.dat_i,self.tgd_i)
    
    async def read(self, adr):
        ret = await self.read_tagged(adr, 0, 0)
        return ret[0]

    @pybfms.import_task(
        pybfms.uint64_t,
        pybfms.uint64_t,
        pybfms.uint64_t,
        pybfms.uint64_t,
        pybfms.uint8_t,
        pybfms.uint8_t,
        pybfms.uint64_t)
    def _access_req(self, adr, tga, dat, tgd, we, sel, tgc):
        pass
    
    @pybfms.export_task(pybfms.uint64_t, pybfms.uint64_t)
    def _access_ack(self, dat_i, tgd_i):
        self.dat_i = dat_i
        self.tgd_i = tgd_i
        self.ack_ev.set()
        
    @pybfms.import_task(pybfms.uint32_t)
    def _wait_req(self, cycles):
        pass
    
    @pybfms.export_task()
    def _wait_ack(self):
        self.ack_ev.set()
        
    @pybfms.export_task(
        pybfms.uint32_t,
        pybfms.uint32_t,
        pybfms.uint32_t,
        pybfms.uint32_t,
        pybfms.uint32_t)
    def _set_parameters(self, 
                        adr_width, 
                        dat_width, 
                        tga_width, 
                        tgd_width, 
                        tgc_width):
        self.adr_width = adr_width
        self.dat_width = dat_width
        self.tga_width = tga_width
        self.tgd_width = tgd_width
        self.tgc_width = tgc_width
        
    @pybfms.export_task()
    def _reset(self):
        self.is_reset = True
        self.reset_ev.set()

        