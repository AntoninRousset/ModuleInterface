from libcpp cimport bool as bool_t
from libc.stdint cimport uint8_t, uint16_t, uint32_t

ctypedef int PJON_SERIAL_TYPE

ctypedef void* PJON_Receiver
ctypedef void* PJON_Error

cdef extern from "interfaces/LINUX/PJON_LINUX_Interface.h":
    int serialOpen (const char *device, const int baud)

cdef extern from "PJON.h":

    const uint8_t PJON_NOT_ASSIGNED
    const uint8_t  PJON_NO_HEADER
    const uint16_t GUDP_DEFAULT_PORT
    const uint16_t LUDP_DEFAULT_PORT

    # errors
    const uint8_t PJON_CONNECTION_LOST
    const uint8_t PJON_PACKETS_BUFFER_FULL
    const uint8_t PJON_CONTENT_TOO_LONG

    const uint16_t _PJON_ACK "PJON_ACK"
    const uint16_t _PJON_NAK "PJON_NAK"
    const uint16_t _PJON_BUSY "PJON_BUSY"
    const uint16_t _PJON_FAIL "PJON_FAIL"
    const uint16_t _PJON_BROADCAST "PJON_BROADCAST"
    const uint16_t _PJON_TO_BE_SENT "PJON_TO_BE_SENT"

    const uint16_t _PJON_MAX_PACKETS "PJON_MAX_PACKETS"
    const uint16_t _PJON_PACKET_MAX_LENGTH "PJON_PACKET_MAX_LENGTH"
    const uint32_t _LUDP_RESPONSE_TIMEOUT "LUDP_RESPONSE_TIMEOUT"

    cdef struct PJON_Packet_Info:
        uint8_t header
        uint16_t id
        uint8_t receiver_id
        uint8_t receiver_bus_id[4]
        uint8_t sender_id
        uint8_t sender_bus_id[4]
        uint16_t port
        void *custom_pointer

    cdef cppclass _localudp "LocalUDP":
        void set_port(uint16_t port)

    cdef cppclass _globaludp "GlobalUDP":
        uint16_t add_node(uint8_t remote_id, const uint8_t remote_ip[], uint16_t port_number)
        void set_port(uint16_t port)
        void set_autoregistration(bool_t enabled)

    cdef cppclass _throughserial "ThroughSerial":
        void set_serial(PJON_SERIAL_TYPE serial_port)
        void set_baud_rate(uint32_t baud)

    cdef cppclass _throughserialasync "ThroughSerialAsync":
        void set_serial(PJON_SERIAL_TYPE serial_port)
        void set_baud_rate(uint32_t baud)
        void set_flush_offset(uint16_t offset)

    cdef cppclass StrategyLinkBase:
        pass

    cdef cppclass _any "Any":
        pass

    cdef cppclass StrategyLink[T]:
        T strategy
        uint8_t get_max_attempts()
        void set_link(StrategyLinkBase *strategy_link)
        bool_t can_start()

    cdef cppclass PJON[T]:
        StrategyLink strategy 
        PJON() except +
        void set_id(uint8_t id)
        void set_packet_id(bool_t state)
        void set_crc_32(bool_t state)
        uint8_t device_id()
        uint8_t packet_overhead(uint8_t  header)
        void set_synchronous_acknowledge(bool_t state)
        void set_asynchronous_acknowledge(bool_t state)
        void include_sender_info(bool_t state)
        void begin()
        void set_error(PJON_Error e)
        void set_receiver(PJON_Receiver r)
        uint16_t update() except *
        uint16_t receive() except *
        uint16_t receive(uint32_t duration) except *
        void set_custom_pointer(void *pointer)
        uint16_t get_packets_count(uint8_t device_id)
        uint16_t send(uint8_t id, const char *string, uint16_t length, uint8_t  header, uint16_t p_id, uint16_t requested_port) except *
        uint16_t send_repeatedly(uint8_t id, const char *string, uint16_t length, uint32_t timing, uint8_t  header, uint16_t p_id, uint16_t requested_port) except *
        uint16_t reply(const char *packet, uint16_t length, uint8_t  header, uint16_t p_id, uint16_t requested_port) except *

PJON_BROADCAST = _PJON_BROADCAST
PJON_ACK = _PJON_ACK
PJON_NAK = _PJON_NAK
PJON_BUSY = _PJON_BUSY
PJON_FAIL = _PJON_FAIL
PJON_TO_BE_SENT = _PJON_TO_BE_SENT

PJON_MAX_PACKETS = _PJON_MAX_PACKETS
LUDP_RESPONSE_TIMEOUT = _LUDP_RESPONSE_TIMEOUT
PJON_PACKET_MAX_LENGTH = _PJON_PACKET_MAX_LENGTH

