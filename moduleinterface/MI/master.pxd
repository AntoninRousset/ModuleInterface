from libc.stdint cimport int32_t, uint8_t, uint32_t
from libcpp cimport bool

print('##########')

cdef extern from 'Chose.h':
    cdef cppclass Chose:
        int a;

cdef extern from 'ModuleInterface/src/MIMaster.h':
    cdef cppclass aaa:
        int a;

cdef extern from 'ModuleInterface/src/MI/ModuleInterface.h':
    cdef cppclass ModuleInterface:
        char module_name
        uint8_t status_bits
        #ModuleVariableSet settings, inputs, outputs
        uint32_t last_alive
        uint32_t up_time
        uint32_t last_uptime_millis
        #ifdef IS_MASTER
        char module_prefix
        bool out_of_memory
        #ModuleVariableSet *confirmed_settings
        #ModuleCommand last_incoming_cmd
        uint32_t before_status_requested_time
        uint32_t status_received_time
        #ifndef NO_TIME_SYNC
        #ifndef IS_MASTER
        uint32_t time_utc_s, time_utc_incremented_ms, time_utc_received_s, time_utc_statup_s
        #endif
        #endif
        ModuleInterface() except +
        #ifdef IS_MASTER
        ModuleInterface(const char*, const char*)
        #endif
        #ifndef IS_MASTER
        #ifdef MI_NO_DYNAMIC_MEM
        #void set_variables(uint8_t, ModuleVariable*, uint8_t, ModuleVariable*, uint8_t, ModuleVariable*)
        #else
        ModuleInterface(const char*, const char*, const char*, const char*)
        ModuleInterface(const char*, const bool, const char*, const char*, const char*)
        ModuleInterface(const char*, MVS_getContractChar, MVS_getContractChar, MVS_getContractChar)
        ModuleInterface(const uint8_t, const uint8_t, const uint8_t)
        #endif
        void set_contracts(const char*, const char*, const char*, const char*)
        void set_contracts_P(const char*, const char*, const char*)
        void set_contracts(const char*, MVS_getContractChar, MVS_getContractChar, MVS_getContractChar)
        #ifndef MI_NO_DYNAMIC_MEM
        bool preallocate_variables(const uint8_t, const uint8_t, const uint8_t)
        #endif
        #endif
        void init()
        void set_name(const char*)
        #ifdef DEBUG_PRINT
        void dname()
        #endif
        bool is_master()
        int32_t get_last_alive_age()
        #ifdef IS_MASTER
        void set_prefix(const char*)
        bool got_prefix()
        bool got_contract()
        #endif
        bool handle_input_message(const uint8_t*, const uint8_t)
        #bool handle_request_message(const uint8_t*, const uint8_t, BinaryBuffer&, uint8_t&)
        uint8_t get_status_bits() const
        #void set_notification_callback(notify_function)
        bool is_active()
        #ifndef IS_MASTER
        #ifndef NO_TIME_SYNC
        bool is_time_set()
        uint32_t get_time_utc_s()
        #endif
        #endif
        uint32_t get_uptime_s()
