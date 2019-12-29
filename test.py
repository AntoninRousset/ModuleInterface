import moduleinterface.master as master

bus = master.PJONLink_ThroughSerialAsync()
interfaces = master.PJONModuleInterfaceSet(bus, "Blink:b1:4", "m1");

while True:
    interfaces.update()
    print('udpated')
