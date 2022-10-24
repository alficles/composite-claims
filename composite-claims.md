%%%
title = "Composite Token Claims"
abbrev = "Composite Token Claims"
ipr= "trust200902"
area = "Security"
workgroup = "TBD WG"
submissiontype = "IETF"
keyword = [""]
updates = [ ]
#date = 2003-04-01T00:00:00Z

[seriesInfo]
name = "Internet-Draft"
value = "draft-lemmons-composite-claims-00"
stream = "IETF"
status = "informational"

[[author]]
initials = "C."
surname = "Lemmons"
fullname = "Chris Lemmons"
#role = "author"
organization = "Comcast"
  [author.address]
  email = "chris_lemmons@comcast.com"
%%%

.# Abstract

Composition claims are CBOR Web Token claims that define logical relationships
between sets of claims and provide for private claim values via encryption.

{mainmatter}

# Introduction

Composition claims are claims defined for CBOR Web Tokens (CWTs) [@!RFC7519].
These claims include logical operators "or", "nor", and "and" as well as a
wrapper that encrypts the values, but not the keys, of some claims.

## Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 [@!RFC2119] [@!RFC8174] when,
and only when, they appear in all capitals, as shown here.

# Terminology

[Identify terminology used and cite references here.]

# Claims

Composition claims identify claim sets and define how the acceptability of the
claim sets affects the acceptability of the composition claim.

In CWTs without composition claims, there is exactly one set of claims, so the
acceptability of the claim set decides the acceptability of the CWT. However,
this document defines multiple sets of claims, so it instead refers to
accepting or rejecting claim sets. If the primary claim set is unacceptable,
the CWT is unacceptable and MUST be rejected.

Composition claims can be nested to an arbitrary level of depth.
Implementations MAY limit the depth of composition nesting by rejecting CWTs
with too many levels but MUST support at least four levels of nesting.

## Logical Claims

These claims allow multiple claim sets to be evaluated. This claim identifies
one or more sets of claims in a logical relation. The type of these claims is
array and the elements of the array are maps that are themselves sets of
claims.

### or (Or) Claim

The "or" (Or) claim identifies one or more sets of claims of which at least one
is valid. If every set of claims in an "or" claim would, when considered with
all the other relevant claims, result in the claim set being rejected, the
claim set containing the "or" claim MUST be rejected.

Use of this claim is OPTIONAL. The Claim Key [add key number] is used to
identify this claim.

### nor (Not Or) Claim

The "nor" (Nor) claim identifies one or more sets of claims of which none are
valid. If any set of claims in a "nor" claim would, when considered with all
other relevant claims, result in the claim set being accepted, the claim set
containing the "nor" MUST be rejected.

This is the logical negation of the "or" claim.

Use of this claim is OPTIONAL. The Claim Key [add key number] is used to
identify this claim.

### and (And) Claim

The "and" (And) claim idenfies one or more sets of claims of which all are
valid. If any claim in an "and" claim would, when considered with all other
relevant claims, result in the claim set being rejected, the claim set
containing the "and" claim MUST be rejected.

The "and" claim is often unnecessary because a given claim set is only accepted
when all its claims are acceptable. However, CBOR maps cannot have duplicate
keys, so claims cannot be repeated more than once. The "and" claim is useful
for claims that may be claimed multiple times, including the "or" and "nor"
claims.

Use of this claim is OPTIONAL. The Claim Key [add key number] is used to
identify this claim.

## Enveloped Claims

Eveloped claims identify a set of claims that should be considered as part of a
set of claims, but that require decryption before they can be processed. This
is sometimes useful when some processors do not need to evaluate some claims in
order to determine if a claim set is acceptable.

### env (Enveloped) Claim

The "env" (Enveloped) claim allows an issuer to make private claims that cannot
be read by a processor that does not possess the decryption key. The type of
this claim is a map; the keys of the map are either claim keys (string,
unsigned integer, or negative integer) or arrays of claim keys; the values of
the map are COSE_Encrypt or COSE_Encrypt0 objects, as defined by
[@!RFC9052, section 5]. The plaintext of the Enveloped Message is either a CBOR
data item or a CBOR array of data items.

Each element of the map is interpreted as follows:
  - If the key is a claim key, the plaintext of the Enveloped Message in its
    value is a CBOR data item that is appropriate as a value for that claim.
  - If the key is an array of claim keys, the plaintext of the Enveloped
    Message in its value is an array with the same cardinality as the array of
    claim keys. Each member of the array in the plaintext corresponds with the
    member in the array in the key with the same index. The members of the
    array in the plaintext are CBOR data items that are appropriate as values
    for the corresponding claim.

For each claim described in the "env" claim that the processor can decrypt,
the claim MAY be processed exactly as though it were a sibling claim to the
"env" claim, including the limitation that a map of claims is invalid if it
contains a claim more than once. An invalid claim set MUST be rejected. A claim
set that contains duplicate claims MUST be rejected, even if the duplicates are
not decrypted.

Since claims are optionally decrypted and added as sibling claims, issuers can
ensure that this occurs by adding them to the "crit" claim.

Use of this claim is OPTIONAL. The Claim Key [add key number] is used to
identify this claim.

### crit (Critical) Claim

The "crit" (Critical) claim lists the claims required to process this token.

The type of this claim is array and the elements of the array are strings,
negative integers, or unsigned integers. The elements of the array correspond
to claims that may be present in the token.

If a claim listed in the "crit" claim is present in a claim set and the
processor cannot understand or process the claim, the claim set MUST be
rejected.

If a claim listed in the "crit" claim is not present in a claim set, the claim
set MUST be rejected.

If a claim listed in the "crit" claim is present in a claim set as part of a
"env" claim (and, should it be decrypted, be processed as a sibling of that
"env" claim), if the value of the claim is not decrypted (for any reason) and
processed and any possible value of the claim would result in the request being
rejected, the claim set MUST be rejected. Since any processor MAY decrypt or
not decrypt claim values in a "env" claim, this means a processor MAY reject
any claim set that contains a claim that could have a value that would require
rejection.

If a "crit" claim is present in a claim set, a processor SHOULD consider claims
it does not understand to be acceptable if they are not present in the "crit"
claim. That is, when a "crit" claim is present, any claims not listed may be
assumed to be non-critical.

Use of this claim is OPTIONAL. The Claim Key [add key number] is used to
identify this claim.

{backmatter}
