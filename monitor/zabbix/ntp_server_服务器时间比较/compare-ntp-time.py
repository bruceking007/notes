#!/usr/bin/python

import struct, sys, time, argparse
from socket import socket, AF_INET, SOCK_DGRAM

error_margin = 5

def get_time(host):
    sock = socket(AF_INET, SOCK_DGRAM)
    sock.settimeout(2)
    sock.sendto('\x1b' + 47 * '\0', (host, 123))
    data, address = sock.recvfrom( 1024 )
    sock.close()
    if data:
        t = struct.unpack( '!12I', data )[10]
        t -= 2208988800L # Time 1970
        return t
    else:
        return False

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('time_server', help='specify the ntp server you want to check')
    parser.add_argument('time_reference', help='specify the time reference (another ntp server)')
    parser.add_argument('-v', '--verbose', help='talk a lot more', action='store_true')
    args = parser.parse_args()

    time_server = get_time(args.time_server)
    #print "%s" % time_server
    time_reference = get_time(args.time_reference)
    #print "%s" % time_reference
    if time_server and time_reference:
        if args.verbose:
            print 'Time received from %s = %s (%s)' % (args.time_server, time_server, time.ctime(time_server))
            print 'Time received from %s = %s (%s)' % (args.time_reference, time_reference, time.ctime(time_reference))

        #  if s2 <= s1 + err and s2 >= s1 - err
        if time_server <= time_reference + error_margin and time_server >= time_reference - error_margin:
	    times= time_server - time_reference
	    print "%s" % times
            print '0'
        else:
            print '1'

if __name__ == "__main__":
    main()
