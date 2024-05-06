%%%
title = "Composite Token Claims"
abbrev = "Composite Token Claims"
ipr= "trust200902"
area = "Security"
workgroup = "COSE WG"
submissiontype = "IETF"
keyword = [""]
updates = [ ]
#date = 2003-04-01T00:00:00Z

[seriesInfo]
name = "Internet-Draft"
value = "draft-lemmons-cose-composite-claims-02"
stream = "IETF"
status = "standard"

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

# Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 [@!RFC2119] [@!RFC8174] when,
and only when, they appear in all capitals, as shown here.

This document reuses terminology from CWT [@!RFC7519] and COSE [@!RFC9052].

This term is defined by this specification:

Composition Claim
: A composition claim is a CWT claim that contains, as part of its value, one
or more CWT claim sets.

# Claims

Composition claims identify claim sets and define how the acceptability of the
claim sets affects the acceptability of the composition claim.

In CWTs without composition claims, there is exactly one set of claims, so the
acceptability of the claim set decides the acceptability of the CWT. However,
this document defines multiple sets of claims, so it instead refers to
accepting or rejecting claim sets. If the primary claim set is unacceptable,
the CWT is unacceptable and **MUST** be rejected.

Composition claims can be nested to an arbitrary level of depth.
Implementations **MAY** limit the depth of composition nesting by rejecting
CWTs with too many levels but **MUST** support at least four levels of nesting.

## Logical Claims

These claims allow multiple claim sets to be evaluated. This claim identifies
one or more sets of claims in a logical relation. The type of these claims is
array and the elements of the array are maps that are themselves sets of
claims.

For the following CDDL, `cwt-claims` is a map of claims as defined in
[@!RFC8392]. It is described informatively in [draft-ietf-rats-eat] Appendix D.

### or (Or) Claim

The "or" (Or) claim identifies one or more sets of claims of which at least one
is valid. If every set of claims in an "or" claim would, when considered with
all the other relevant claims, result in the claim set being rejected, the
claim set containing the "or" claim **MUST** be rejected.

Use of this claim is **OPTIONAL**. The Claim Key [add key number] is used to
identify this claim.

The "or" (OR) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( or-claim-label => or-claim-value )
or-claim-label = TBD
or-claim-value = [ + Claims-Set ]
```

### nor (Not Or) Claim

The "nor" (Nor) claim identifies one or more sets of claims of which none are
valid. If any set of claims in a "nor" claim would, when considered with all
other relevant claims, result in the claim set being accepted, the claim set
containing the "nor" **MUST** be rejected.

This is the logical negation of the "or" claim.

Use of this claim is **OPTIONAL**. The Claim Key [add key number] is used to
identify this claim.

The "nor" (NOR) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( nor-claim-label => nor-claim-value )
nor-claim-label = TBD
nor-claim-value = [ + Claims-Set ]
```

### and (And) Claim

The "and" (And) claim idenfies one or more sets of claims of which all are
valid. If any claim in an "and" claim would, when considered with all other
relevant claims, result in the claim set being rejected, the claim set
containing the "and" claim **MUST** be rejected.

The "and" claim is often unnecessary because a given claim set is only accepted
when all its claims are acceptable. However, CBOR maps cannot have duplicate
keys, so claims cannot be repeated more than once. The "and" claim is useful
for claims that may be claimed multiple times, including the "or" and "nor"
claims.

Use of this claim is **OPTIONAL**. The Claim Key [add key number] is used to
identify this claim.

The "and" (AND) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( and-claim-label => and-claim-value )
and-claim-label = TBD
and-claim-value = [ + Claims-Set ]
```

### Examples

These logical claims can be used to describe to claim more complex
relationships between claims. For example, the following claim set describes a
token with multiple subject claims. This token describes a situation where either
of the two subjects must be true, but the issuer is not disclosing which one
must be true or even whether the two subjects are genuinely different.

```
{
  /or/ TBD: [
    { /sub/ 2: "george@example.net" },
    { /sub/ 2: "harriet@example.net" }
  ]
}
```

A relying party that receives this token does not know if the bearer is George
or Harriet, but it knows that the bearer is one of them.

The "nor" claim is useful both as a logical negation, even when only one claim is present. For example, consider the following claim set:

```
{
  /nor/ TBD: [
    { /aud/ 3: "https://example.com" }
  ]
}
```

This token is intended for any audience except "example.com".

And if a truly complex relationship is required, the "and" claim can be used to combine multiple claims. For example, consider the following claim set:

```
{
  /and/ TBD: [
    {
      /or/ TBD: [
        { /sub/ 2: "george@example.net" },
        { /sub/ 2: "harriet@example.net" }
      ]
    },
    {
      /or/ TBD: [
        { /aud/ 3: "https://example.com" },
        { /aud/ 3: "https://example.net" }
      ]
    }
  ]
}
```

This admittedly contrived example describes a token that is valid for either
George or Harriet and is intended for either https://example.com or
https://example.net. It is a bit contrived because the "aud" claim already
describes a list of acceptable audiences. The use of the "and" claim is
required in order to effectively repeat the "or" claim, because a single claim
set cannot contain the same claim twice.

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
    Message in its value is an array with the cardinality equal to or larger
    than the array of claim keys. Each member of the array in the plaintext
    corresponds with the member in the array in the key with the same index.
    Elements of the value array with indexes that do not correspond with
    elements of the key array MUST be ignored. The members of the array in the
    plaintext are CBOR data items that are appropriate as values for the
    corresponding claim.

These claims described in the "env" claim **MAY** be processed exactly as
though the "env" claim were replaced with the decrypted claims, including the
limitation that a map of claims is invalid if it contains a claim more than
once. The "env" claim is removed from the map before looking for duplicates, so
an "env" claim that contains an "env" claim may potentially be accepted. An
invalid claim set **MUST** be rejected. A claim set that contains
duplicate claims **MUST** be rejected, even if the duplicates are not
decrypted.

Since claims are optionally decrypted and added as sibling claims, issuers can
ensure that this occurs by adding them to the "crit" claim. In the absence of a
"crit" claim, the relying party **MAY** choose not to decrypt the claims.
Indeed, a relying party may not even have the decryption key for claims that
are not relevant to its processing.

Use of this claim is **OPTIONAL**. The Claim Key [add key number] is used to
identify this claim.

### crit (Critical) Claim

The "crit" (Critical) claim lists the claims required to process this token.

The type of this claim is array and the elements of the array are strings,
negative integers, or unsigned integers. The elements of the array correspond
to claims that may be present in the token.

If a claim listed in the "crit" claim is present in a claim set and the
processor cannot understand or process the claim, the claim set **MUST** be
rejected.

If a claim listed in the "crit" claim is not present in a claim set, the claim
set **MUST** be rejected.

If a claim listed in the "crit" claim is present in a claim set as part of a
"env" claim (and, should it be decrypted, be processed as a sibling of that
"env" claim), if the value of the claim is not decrypted (for any reason) and
processed and any possible value of the claim would result in the request being
rejected, the claim set **MUST** be rejected. Since any processor **MAY**
decrypt or not decrypt claim values in a "env" claim, this means a processor
**MAY** reject any claim set that contains a claim that could have a value that
would require rejection.

If a "crit" claim is present in a claim set, a processor **SHOULD** consider
claims it does not understand to be acceptable if they are not present in the
"crit" claim. That is, when a "crit" claim is present, any claims not listed
may be assumed to be non-critical.

Use of this claim is **OPTIONAL**. The Claim Key [add key number] is used to
identify this claim.

### Example

Consider a very simple token that might be passed like this:

```
{
  /iss/ 1: "https://example.com",
  /sub/ 2: "george@example.net",
  /aud/ 3: "https://example.com"
}
```
The identity of George is present and clear in the token. Some parties
receiving this token might need to know that George is the subject. However,
some may not. For example:

- An intermediary proxy that only needs to know that the issuer is
  https://example.com and the audience is https://example.com.
- An origin behind the proxy that needs to know that George is the subject as
  well, so that it can customize its response.

The intermediary is a relying party but does not need to know George's
identity. The origin, however does. A token that permits this might look like
this:

```
{
  /iss/ 1: "https://example.com",
  /aud/ 3: "https://example.com",
  /env/ TBD: {
    [/sub/ 2]: [
      h'<cose-protected-header>',
      h'<cose-unprotected-header>',
      h'<cose-ciphertext>'
    ]
  }
}
```

And the contents of the ciphertext might be:

```
["george@example.net", h'b73814740f877e8aa691fdab6cda']
```

The intermediary can process the token without decrypting the "env" claim. The
origin can decrypt the "env" claim and learn that George is the subject. The
issuer used additional padding in the plaintext in order to avoid disclosing
the length of the subject value.

### Other methods of selectively disclosing claims

The "env" claim is only suitable for protecting claims under the following circumstances:

- The issuer is the one that decides which claims are disclosed and to whom.
- The issuer can reasonably pad the plaintext to avoid revealing the length of
  the claim. This requires the issuer to know the maximum length of claims that might be present.
- The bearer does not need to control which claims are disclosed.
- The claim labels are not sensitive information.

If these are not the case, the "env" claim is not suitable. If the bearer is
the one that controls selective disclosure,
[draft-ietf-oauth-selective-disclosure-08] may be more appropriate. SD-JWTs
also protect the claim labels, which the "env" claim does not.

When the claims for different audiences are significantly different, multiple
encrypted tokens can be used. This is likely to lead to larger sets of tokens
in general, but is a very flexible approach. This protects the entire contents
of each token from all parties that do not possess the decryption key for that
token.

# Security Considerations

All security considerations relevant to CWTs in general will apply to CWTs that
use composition claims.

Additionally, processors of CWTs with composition claims will need to be aware
of the possibility of receiving highly nested tokens. Excessive nesting can
lead to overflows or other processing errors.

The security of the "env" claim is subject to all the considerations detailed
for COSE objects in [@!RFC9052, section 12]. Particular attention is required
to length attacks. If the length of the Enveloped Claims is revealing as to its
contents, as it most often will be in this context, issuers MUST pad the
content appropriately in order to maintain the secrecy of its contents. "env"
claims permit additional elements to be added after arrays of claim keys that
can be used for padding when it is required.

Additionally, since the "env" claim only encrypts the contents of the claim and
not its key, it discloses the presence of a given claim. When this is
undesirable, another composite claim like "and", "or", or even potentially
"env" can be be used to mask the presence of the claim within.

# IANA Considerations

This specification requests that IANA register the following claim keys in the
"CBOR Web Token (CWT) Claims" registry established by [@!RFC8392]:

Claim Name: or
Claim Description: Logical OR
JWT Claim Name: N/A
Claim Key: TBD (greater than 285)
Claim Value Type(s): array
Change Controller: IETF

Claim Name: nor
Claim Description: Logical NOR
JWT Claim Name: N/A
Claim Key: TBD (greater than 285)
Claim Value Type(s): array
Change Controller: IETF

Claim Name: and
Claim Description: Logical AND
JWT Claim Name: N/A
Claim Key: TBD (greater than 285)
Claim Value Type(s): array
Change Controller: IETF

Claim Name: enc
Claim Description: Logical AND
JWT Claim Name: N/A
Claim Key: TBD (greater than 285)
Claim Value Type(s): array
Change Controller: IETF

Claim Name: crit
Claim Description: Logical AND
JWT Claim Name: N/A
Claim Key: TBD (between 41 and 255)
Claim Value Type(s): array
Change Controller: IETF

{backmatter}
