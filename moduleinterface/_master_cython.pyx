# distutils: define_macros = LINUX

cdef extern from 'MIMaster.h':
    pass

from _pjon_cython cimport _any, _throughserialasync

from _pjonlink_cython cimport PJONLink as cpp_PJONLink

cdef class PJONLink_ThroughSerialAsync:

    cdef cpp_PJONLink[_throughserialasync] link

    def _cinit_(self):
        print('PJONLink!!')
        self.link = cpp_PJONLink[_throughserialasync]()

    def get_id(self):
        return self.link.get_id()

