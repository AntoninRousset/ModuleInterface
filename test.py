import moduleinterface.master as master

link = master.PJONLink_ThroughSerialAsync()
print(link.get_id())
