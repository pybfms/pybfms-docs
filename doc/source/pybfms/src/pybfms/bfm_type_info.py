'''
Created on Feb 11, 2020

@author: ballance
'''

class BfmTypeInfo():

    def __init__(
            self, 
            T, 
            hdl, 
            has_init,
            import_info, 
            export_info):
        self.T = T
        self.hdl = hdl
        self.has_init = has_init
        self.import_info = import_info
        self.export_info = export_info
