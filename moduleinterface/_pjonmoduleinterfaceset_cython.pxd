#distutils language_level = 3

from libc.stdint cimport uint8_t, uint16_t, uint32_t
from libcpp cimport bool

from _pjon_cython cimport PJON, PJON_Packet_Info, PJON_Receiver
from _pjonlink_cython cimport MILink

cdef extern from 'MI/MITransferBase.h':

    cdef cppclass MITransferBase:
        pass

cdef extern from 'MI/ModuleVariableSet.h':

    cdef cppclass ModuleVariableSet:
        pass
        
cdef extern from 'MI/ModuleVariable.h':

    cdef cppclass ModuleVariable:
        pass

cdef extern from 'MI/ModuleInterface.h':
    
    cdef cppclass ModuleInterface:

        char *module_name
        uint8_t status_bits
        ModuleVariableSet settings, inputs, outputs
        uint32_t last_alive
        uint32_t last_uptime_millis

        char *module_prefix
        uint8_t comm_failures
        bool out_of_memory
        ModuleVariableSet *confirmed_settings
        #ModuleCommand last_incoming_cmd
        uint32_t before_status_requested_time
        uint32_t status_received_time

        uint32_t time_utc_s, time_utc_incremented_ms, time_utc_received_s, time_utc_startup_s

        ModuleInterface() except +

        ModuleInterface(const char*, const char*) except +

        void set_variables(uint8_t, ModuleVariable*, uint8_t, ModuleVariable*, uint8_t, ModuleVariable*)

        ModuleInterface(const char*, const char*, const char*, const char*)
    
        ModuleInterface(const char*, const bool, const char*, const char*, const char*)
        #ModuleInterface(cons char*, MVS_getContractChar, MVS_getContractChar, MVS_getContractChar)
        ModuleInterface(const uint8_t, const uint8_t, const uint8_t)

        void set_contracts(const char*, const char*, const char*, const char*)
        void set_contracts_P(const char*, const char*, const char*, const char*)
        #void set_contracts(const char*, MVS_getContractChar, MVS_getContractChar, MVS_getContractChar)

        #etc...

cdef extern from 'MI/ModuleInterfaceSet.h':
    
    cdef cppclass ModuleInterfaceSet:

        uint8_t num_interfaces
        ModuleInterface **interfaces
        uint32_t last_total_usage_ms
        ModuleInterfaceSet(const char*) except +
        ModuleInterfaceSet(const uint8_t, const char*) except +
        #~ModuleInterfaceSet()
        void set_prefix(const char*)
        const char *get_prefix() const
        void assign_names(const char*)
        ModuleInterface *operator [] (const uint8_t)
        void update_intermodule_dependencies()
        void transfer_outputs_to_inputs()
        void transfer_events_from_outputs_to_inputs()
        uint16_t count_active_contracts()
        bool got_all_contracts()
        uint8_t get_inactive_module_count()
        #void set_notification_callback(notify_function)
        uint8_t find_interface_by_prefix(const char*) const
        ModuleVariableSet *find_settings_by_prefix(const char*)
        ModuleVariableSet *find_inputs_by_prefix(const char*)
        ModuleVariableSet *find_outputs_by_prefix(const char*)
        bool find_output_by_name(const char*, uint8_t&, uint8_t&) const
        bool find_setting_by_name(const char*, uint8_t&, uint8_t&) const

        #etc...
        void update(MITransferBase* =None)

cdef extern from 'MI_PJON/PJONModuleInterfaceSet.h':

    cdef cppclass PJONModuleInterfaceSet(ModuleInterfaceSet):
        
        PJONModuleInterfaceSet(const char*) except +
        #PJONModuleInterfaceSet(MILink&, const uint8_t, const char*) except +
        PJONModuleInterfaceSet(MILink&, const char*, const char*) except +

