#!/usr/bin/env python3

import sys
import time
import serial


CHUNK = 256


def progress(done, total, start, width=40):
    frac = done / total if total else 1.0
    filled = int(width * frac)
    bar = '=' * filled + '-' * (width - filled)
    elapsed = time.time() - start
    rate = done / elapsed if elapsed > 0 else 0
    eta = (total - done) / rate if rate > 0 else 0
    sys.stdout.write('\r[{0}] {1:6.1f}% {2}/{3} B {4:7.0f} B/s ETA {5:3.0f}s'.format(
        bar, frac * 100, done, total, rate, eta))
    sys.stdout.flush()


if __name__ == '__main__':

    if len(sys.argv) < 4:
        print('Expected usage: {0} <port> <filename> <size>'.format(sys.argv[0]))
        sys.exit(1)

    fb = open(sys.argv[2], 'rb')
    ba = bytearray(fb.read())
    size = int(sys.argv[3], 16)

    if size > len(ba):
        size = len(ba)

    ser = serial.Serial(
        port=sys.argv[1],
        baudrate=115200,
        parity='N',
        stopbits=1,
        bytesize=8,
        timeout=120,
        xonxoff=0,
        rtscts=0
    )

    if ser.isOpen():
        ser.close()

    ser.open()
    ser.isOpen()

    start = time.time()
    sent = 0

    progress(sent, size, start)

    while sent < size:
        end = min(sent + CHUNK, size)
        ser.write(ba[sent:end])
        ser.flush()
        sent = end
        progress(sent, size, start)

    print()

    while(1):
        line = ser.readline()
        if line == b'':
            break
        print(line.decode("ascii"),end='')

    ser.close()

    sys.exit(0)
