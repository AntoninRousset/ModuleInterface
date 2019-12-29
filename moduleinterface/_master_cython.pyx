# distutils: define_macros = LINUX
# distutils: language = c++

cdef extern from 'MIMaster.h':
    pass

from _pjon_cython cimport _any, _throughserialasync
from _pjonlink_cython cimport MILink as cppMILink
from _pjonlink_cython cimport PJONLink as cppPJONLink
from _pjonmoduleinterfaceset_cython cimport PJONModuleInterfaceSet as cppPJONModuleInterfaceSet

cdef class MILink:
    #cdef cppMILink* link
    pass

cdef class PJONLink_ThroughSerialAsync(MILink):
    cdef cppPJONLink[_throughserialasync] link

    def __cinit__(self):
        self.link = cppPJONLink[_throughserialasync]()

cdef class PJONModuleInterfaceSet:

    cdef cppPJONModuleInterfaceSet* pjon_module_interface_set

    def __cinit__(self, PJONLink_ThroughSerialAsync bus, interface_list, prefix):
        self.pjon_module_interface_set = new cppPJONModuleInterfaceSet(bus.link, interface_list.encode(), prefix.encode())

    def update(self):
        self.pjon_module_interface_set.update()

