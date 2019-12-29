from libc.stdint cimport uint8_t, uint16_t, uint32_t
from libcpp cimport bool

from _pjon_cython cimport PJON, PJON_Packet_Info, PJON_Receiver

cdef extern from 'MI_PJON/MILink.h':

      cdef cppclass MILink:
          #virtual uint16_t receive()
          #virtual uint16_t receive(uint32_t duration)

          #virtual uint8_t update()
          #virtual uint16_t send_packet(uint8_t, const uint8_t*, const char*, uint16_t, uint32_t)

          #virtual const PJON_Packet_Info &get_last_packet_info() const

          #virtual uint8_t get_id() const
          #virtual const uint8_t *get_bus_id() const

          #virtual void set_id(uint8_t)
          #virtual void set_bus_id(const uint8_t*)

          #virtual void set_receiver(PJON_Receiver, void*)
          pass

cdef extern from 'MI_PJON/PJONLink.h':

    cdef cppclass PJONLink[Strategy](MILink):
        PJON[Strategy] bus

        PJONLink() except +
        PJONLink(uint8_t) except +
        PJONLink(uint8_t*, uint8_t) except +

        uint16_t receive()
        uint16_t receive(uint32_t)

        uint8_t update()
        uint16_t send_packet(uint8_t, const uint8_t*, const char*, uint16_t, uint32_t)
        const PJON_Packet_Info &get_last_packet_info() const

        uint8_t get_id() const
        const uint8_t *get_bus_id() const

        void set_id(uint8_t)
        void set_bus_id(const uint8_t*)

        void set_receiver(PJON_Receiver, void*)

