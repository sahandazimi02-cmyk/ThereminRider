"""Fake Max: sends the same OSC messages the Max patch sends, so you can test
the game without the theremin or the stationary bike. Python 3, no installs.

Examples
  python tools/osc_test_sender.py                      # sine steering + 85 RPM
  python tools/osc_test_sender.py --cadence 0          # stop pedalling (bike falls)
  python tools/osc_test_sender.py --steer 0.3          # constant steer right
  python tools/osc_test_sender.py --pedal-hz 1.5       # send /bike/pedal strokes instead of RPM
  python tools/osc_test_sender.py --absent-every 6     # hand leaves the theremin every 6 s
  python tools/osc_test_sender.py --host 192.168.1.20  # game on another PC
"""
import argparse
import math
import socket
import struct
import time


def osc_string(s: str) -> bytes:
    b = s.encode("utf-8") + b"\x00"
    return b + b"\x00" * ((4 - len(b) % 4) % 4)


def osc_message(address: str, *args) -> bytes:
    tags = ","
    payload = b""
    for a in args:
        if isinstance(a, bool) or isinstance(a, int):
            tags += "i"
            payload += struct.pack(">i", int(a))
        else:
            tags += "f"
            payload += struct.pack(">f", float(a))
    return osc_string(address) + osc_string(tags) + payload


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=9100)
    ap.add_argument("--rate", type=float, default=50.0, help="messages per second")
    ap.add_argument("--steer", type=float, default=None, help="constant steer -1..1 (default: slow sine)")
    ap.add_argument("--sine-amp", type=float, default=0.35)
    ap.add_argument("--sine-period", type=float, default=6.0)
    ap.add_argument("--cadence", type=float, default=85.0, help="RPM sent on /bike/cadence")
    ap.add_argument("--pedal-hz", type=float, default=0.0, help="send /bike/pedal strokes at this rate instead of RPM")
    ap.add_argument("--absent-every", type=float, default=0.0, help="hand leaves for 1.5 s every N seconds")
    ap.add_argument("--duration", type=float, default=0.0, help="seconds (0 = until Ctrl+C)")
    a = ap.parse_args()

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    dest = (a.host, a.port)
    t0 = time.time()
    next_stroke = t0
    print(f"Sending OSC to {a.host}:{a.port} at {a.rate:.0f}/s. Ctrl+C to stop.")
    try:
        while True:
            t = time.time() - t0
            if a.duration and t > a.duration:
                break
            steer = a.steer if a.steer is not None else a.sine_amp * math.sin(2 * math.pi * t / a.sine_period)
            present = 1
            if a.absent_every > 0 and (t % a.absent_every) > a.absent_every - 1.5:
                present = 0
            sock.sendto(osc_message("/bike/steer", steer), dest)
            sock.sendto(osc_message("/bike/steer/present", present), dest)
            if a.pedal_hz > 0:
                if time.time() >= next_stroke:
                    sock.sendto(osc_message("/bike/pedal", 1), dest)
                    next_stroke += 1.0 / a.pedal_hz
            else:
                sock.sendto(osc_message("/bike/cadence", a.cadence), dest)
            time.sleep(1.0 / a.rate)
    except KeyboardInterrupt:
        pass
    print("stopped")


if __name__ == "__main__":
    main()
