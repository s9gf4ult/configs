import gobject, os
import dbus, dbus.glib

OBJ_PATH = '/org/gajim/dbus/RemoteObject'
INTERFACE = 'org.gajim.dbus.RemoteInterface'
SERVICE = 'org.gajim.dbus'

def new_message(details):
    print 'new message'
    os.system('notify-send -t 10000 "You have a new message."')

def init(service, arg1, arg2):
    if service == 'org.gajim.dbus':
        bus = dbus.SessionBus()
        try:
            bus.add_signal_receiver(new_message, 'NewMessage', INTERFACE, SERVICE, OBJ_PATH)
            print 'added gajim signal receivers'
        except:
            print 'oops, no gajim'


def main():
    bus = dbus.SessionBus()
    bus.add_signal_receiver(init, 'NameOwnerChanged',
                            'org.freedesktop.DBus',
                            'org.freedesktop.DBus',
                            '/org/freedesktop/DBus',
                            arg0='org.gajim.dbus')

    init('org.gajim.dbus', '', '')
   
    print 'listening to dbus...'
    mainloop = gobject.MainLoop()
    mainloop.run()
               
if __name__ == '__main__':
    import sys
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
