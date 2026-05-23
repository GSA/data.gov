certificate = generate_fixity_certificate(
    envelope_id=envelope_id,
    fields=fields,
    fixity=fixity,
    schema_validation=validation,
)

print("\nFIXITY CERTIFICATE:\n")
print(certificate)
