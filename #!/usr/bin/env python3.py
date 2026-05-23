#!/usr/bin/env python3
import struct, hashlib, os, sys

INFILE = "auth_docs.bin"

def read_exact(f, n):
    b = f.read(n)
    if len(b) != n:
        raise EOFError("Unexpected EOF")
    return b

def sha256_hex(b):
    return hashlib.sha256(b).hexdigest()

with open(INFILE, "rb") as f:
    # Read entire file
    data = f.read()

# File must be at least header + digest
if len(data) < 8 + 8 + 32:
    print("File too small or corrupted", file=sys.stderr)
    sys.exit(1)

# Separate appended digest (last 32 bytes)
body = data[:-32]
appended_digest = data[-32:]

calc_digest = hashlib.sha256(body).digest()
if calc_digest != appended_digest:
    print("Integrity check FAILED: appended digest does not match computed digest", file=sys.stderr)
    sys.exit(1)
print("Integrity check passed: file body matches appended SHA-256 digest")

# Parse header
# Bytes 0-7: magic
magic = body[0:8]
if magic != b'DOCBINv1':
    print("Unexpected magic:", magic, file=sys.stderr)
    sys.exit(1)

# Bytes 8-15: header length (big-endian uint64)
header_len = struct.unpack('>Q', body[8:16])[0]
if header_len > len(body):
    print("Invalid header length", file=sys.stderr)
    sys.exit(1)

header = body[:header_len]
# Extract fields from header according to spec
timestamp = header[16:48].rstrip(b' ').decode('utf-8', errors='replace')
creator = header[48:80].rstrip(b' ').decode('utf-8', errors='replace')
num_docs_str = header[80:112].rstrip(b' ').decode('ascii', errors='replace')
try:
    num_docs = int(num_docs_str)
except:
    num_docs = None

print(f"Header: timestamp={timestamp}, creator={creator}, declared_num_docs={num_docs}")

# Index starts at header_len and continues until payloads start
idx_offset = header_len
# We'll iterate index entries until we've read num_docs entries or run out
entries = []
ptr = idx_offset
for i in range(num_docs if num_docs is not None else 1000000):
    if ptr + 2 > len(body):
        break
    name_len = struct.unpack('>H', body[ptr:ptr+2])[0]
    ptr += 2
    if ptr + name_len + 1 + 8 + 8 > len(body):
        print("Index truncated", file=sys.stderr)
        sys.exit(1)
    name = body[ptr:ptr+name_len].decode('utf-8', errors='replace')
    ptr += name_len
    dtype = body[ptr]
    ptr += 1
    payload_offset = struct.unpack('>Q', body[ptr:ptr+8])[0]
    ptr += 8
    payload_length = struct.unpack('>Q', body[ptr:ptr+8])[0]
    ptr += 8
    entries.append({
        "name": name,
        "dtype": dtype,
        "offset": payload_offset,
        "length": payload_length
    })
    if len(entries) == num_docs:
        break

print(f"Parsed {len(entries)} index entries")

# Extract each payload
for e in entries:
    name = e["name"]
    offset = e["offset"]
    length = e["length"]
    if offset + 8 + length > len(body):
        print(f"Payload for {name} out of bounds", file=sys.stderr)
        sys.exit(1)
    # At offset, first 8 bytes are length field (redundant with index)
    stored_len = struct.unpack('>Q', body[offset:offset+8])[0]
    if stored_len != length:
        print(f"Warning: index length and stored length differ for {name}", file=sys.stderr)
    payload_bytes = body[offset+8:offset+8+length]
    # Write file (avoid overwriting existing files without notice)
    outpath = name
    if os.path.exists(outpath):
        outpath = name + ".extracted"
    with open(outpath, "wb") as out:
        out.write(payload_bytes)
    file_sha = hashlib.sha256(payload_bytes).hexdigest()
    print(f"Extracted: {outpath}  size={len(payload_bytes)}  sha256={file_sha}")

print("All done")
