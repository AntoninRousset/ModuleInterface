from os import close

from _pjon_cython cimport *

class PJON_Connection_Lost(BaseException):
    pass

class PJON_Packets_Buffer_Full(BaseException):
    pass

class PJON_Content_Too_Long(BaseException):
    pass

class PJON_Unable_To_Create_Bus(BaseException):
    pass


cdef void error_handler(uint8_t code, uint16_t data, void *custom_pointer):

    # raise Exception('Code: {} Data: {}'.format(code, data))
    cdef PJONBUS self = <object> custom_pointer

    if code == PJON_CONNECTION_LOST:
        self.exception = PJON_Connection_Lost

    elif code == PJON_PACKETS_BUFFER_FULL:
        self.exception = PJON_Packets_Buffer_Full

    elif code == PJON_CONTENT_TOO_LONG:
        self.exception = PJON_Content_Too_Long
    
    else:
        self.exception = Exception


cdef object make_packet_info_dict(const PJON_Packet_Info &_pi):
    return dict(
        header=_pi.header,
        id=_pi.id,
        receiver_id = _pi.receiver_id,
        receiver_bus_id =_pi.receiver_bus_id,
        sender_id = _pi.sender_id,
        sender_bus_id = _pi.sender_bus_id,
        port = _pi.port
    )

cdef void _pjon_receiver(uint8_t *payload, uint16_t length, const PJON_Packet_Info &_pi) except *:
    cdef PJONBUS self = <object> _pi.custom_pointer
    self.receive(<bytes>payload[:length], length, make_packet_info_dict(_pi))


cdef class PJONBUS:
    cdef PJON[_any] *bus

    def __cinit__(self):
        self.bus = new PJON[_any]()
        self.bus.set_custom_pointer(<void*> self)
        self.bus.set_receiver(&_pjon_receiver)
        self.bus.set_error(&error_handler)
        self.exception = None

    def __dealloc__(self):
        del self.bus

    def packet_overhead(self, header=PJON_NO_HEADER):
        return self.bus.packet_overhead(header)

    def set_synchronous_acknowledge(self, enabled):
        "Acknowledge receipt of packets"
        self.bus.set_synchronous_acknowledge(1 if enabled else 0)
        return self

    def set_asynchronous_acknowledge(self, enabled):
        "sync or async ack"
        self.bus.set_asynchronous_acknowledge(1 if enabled else 0)
        return self

    def include_sender_info(self, enabled):
        self.bus.include_sender_info(1 if enabled else 0)
        return self

    def set_crc_32(self, enabled):
        self.bus.set_crc_32(1 if enabled else 0)
        return self

    def set_packet_id(self, enabled):
        self.bus.set_packet_id(1 if enabled else 0)
        return self

    def can_start(self):
        return self.bus.strategy.can_start()

    def receive(self, payload, length, packet_info):
        raise NotImplementedError()

    def device_id(self):
        return self.bus.device_id()

    def get_max_attempts(self):
        return self.bus.strategy.get_max_attempts()

    def get_packets_count(self, device_id = PJON_NOT_ASSIGNED):
        return self.bus.get_packets_count(device_id)

    def loop(self, timeout_us=None):
        """
        :param self:
        :param timeout_us: optional parameter - timeout in uS on receive() call
        :return: (packets_to_be_sent, return from receive (one of PJON_FAIL, PJON_BUSY, PJON_NAK)
        """
        to_be_sent = self.bus.update()
        if timeout_us is not None:
            resa,resb = to_be_sent, self.bus.receive(timeout_us)
        else:
            resa,resb = to_be_sent, self.bus.receive()

        self.check_for_exc()
        return resa,resb

    def bus_receive(self, timeout_us=None):
        if timeout_us is None:
            res = self.bus.receive()
        else:
            res = self.bus.receive(timeout_us)
        self.check_for_exc()
        return res

    def bus_update(self):
        res = self.bus.update()
        self.check_for_exc()
        return res

    def send(self, device_id, data, port=_PJON_BROADCAST, packet_id=0):
        res = self.bus.send(device_id, data, len(data), PJON_NO_HEADER, packet_id, port)
        self.check_for_exc()
        return res

    def reply(self, data, port=_PJON_BROADCAST):
        res = self.bus.reply(data, len(data), PJON_NO_HEADER, 0, port)
        self.check_for_exc()
        return res

    def send_repeatedly(self, device_id, data, timing, port=_PJON_BROADCAST):
        res = self.bus.send_repeatedly(device_id, data, len(data), timing, PJON_NO_HEADER, 0, port)
        self.check_for_exc()
        return res

    def check_for_exc(self):
        if self.exception is not None:
            exc_to_raise = self.exception()
            self.exception = None
            raise exc_to_raise


cdef class GlobalUDP(PJONBUS):
    cdef StrategyLink[_globaludp] * link

    def __cinit__(self):
        self.link = new StrategyLink[_globaludp]()
        self.bus.strategy.set_link(<StrategyLinkBase *> self.link)

    def __del__(self):
        del self.link

    def __init__(self, device_id, port=GUDP_DEFAULT_PORT):
        self.bus.set_id(device_id)
        self.link.strategy.set_port(port)
        self.bus.begin()

    def can_start(self):
        return self.bus.strategy.can_start()

    def set_autoregistration(self, enabled):
        self.link.strategy.set_autoregistration(1 if enabled else 0)
        return self

    def add_node(self, device_id, ip, port = GUDP_DEFAULT_PORT):
        ip_ints = bytearray(map(lambda _:int(_),ip.split('.')))
        self.link.strategy.add_node(device_id, ip_ints, port)


cdef class LocalUDP(PJONBUS):
    cdef StrategyLink[_localudp] * link

    def __cinit__(self):
        self.link = new StrategyLink[_localudp]()
        self.bus.strategy.set_link(<StrategyLinkBase *> self.link)

    def __del__(self):
        del self.link

    def __init__(self, device_id, port=LUDP_DEFAULT_PORT):
        self.bus.set_id(device_id)
        self.link.strategy.set_port(port)
        self.bus.begin()
        if not self.link.can_start():
            raise PJON_Unable_To_Create_Bus()

cdef class ThroughSerial(PJONBUS):
    cdef StrategyLink[_throughserial] *link
    cdef int s

    def __cinit__(self):
        self.link = new StrategyLink[_throughserial]()
        self.bus.strategy.set_link(<StrategyLinkBase *> self.link)

    def __del__(self):
        if self.s > 0:
            try:
                close(self.s)
            except OSError:
                pass

    def _fd(self):
        return self.s

    def __init__(self, device_id, port, baud_rate):
        self.bus.set_id(device_id)

        if type(port) is int:
            self.s = port
        else:
            self.s = serialOpen(port, baud_rate)

            if(int(self.s) < 0):
                raise PJON_Unable_To_Create_Bus('Unable to open serial port')

        self.link.strategy.set_serial(self.s)
        self.link.strategy.set_baud_rate(baud_rate)
        self.bus.begin()

cdef class ThroughSerialAsync(PJONBUS):
    cdef StrategyLink[_throughserialasync] *link
    cdef int s

    def __cinit__(self):
        self.link = new StrategyLink[_throughserialasync]()
        self.bus.strategy.set_link(<StrategyLinkBase *> self.link)

    def __del__(self):
        if self.s > 0 :
            try:
                close(self.s)
            except OSError:
                pass

    def _fd(self):
        return self.s

    def set_flush_offset(self, offset):
        self.link.strategy.set_flush_offset(offset)

    def __init__(self, device_id, port, baud_rate):
        self.bus.set_id(device_id)

        if type(port) is int:
            self.s = port
        else:
            self.s = serialOpen(port, baud_rate)

            if(int(self.s) < 0):
                raise PJON_Unable_To_Create_Bus('Unable to open serial port')

        self.link.strategy.set_serial(self.s)
        self.link.strategy.set_baud_rate(baud_rate)
        self.bus.begin()

