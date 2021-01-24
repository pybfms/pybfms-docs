'''
Created on Nov 21, 2020

@author: mballance
'''

import pybfms

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/wb_target_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/wb_target_bfm.v"),
    }, has_init=True)
class WbTargetBfm():


    def __init__(self):
        self.busy = pybfms.lock()
        self.ack_ev = pybfms.event()
        self.addr_width = 0
        self.data_width = 0
        self.reset_ev = pybfms.event()
        self.is_reset = False
        self.responder = None
        
    def set_responder(self, responder):
        self.responder = responder
        
    @pybfms.import_task(pybfms.uint64_t,pybfms.uint8_t)
    def access_ack(self, dat, err):
        pass
    
    @pybfms.export_task(pybfms.uint64_t, pybfms.uint8_t, pybfms.uint8_t, pybfms.uint64_t)
    def _access_req(self, adr, we, sel, dat_w):
        if self.is_reset:
            if self.responder is not None:
                self.responder(self, adr, we, sel, dat_w)
            else:
                # Acknowledge as an error
                print("Note: no responder")
                self.access_ack(0xDEADBEEF, 1)
        else:
            print("Ignore request in reset")
            pass
        
    @pybfms.export_task(pybfms.uint32_t,pybfms.uint32_t)
    def _set_parameters(self, addr_width, data_width):
        self.addr_width = addr_width
        self.data_width = data_width
        
    @pybfms.export_task()
    def _reset(self):
        print("--> _reset")
        self.is_reset = True
        self.reset_ev.set()
        print("<-- _reset")
