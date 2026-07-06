%%%
title = "Composite Token Claims"
ipr = "trust200902"
area = "Security"
workgroup = "COSE WG"
submissiontype = "IETF"
keyword = ["CBOR", "CWT", "COSE", "JWT", "JSON"]
updates = [ ]
#date = 2003-04-01T00:00:00Z

[seriesInfo]
name = "Internet-Draft"
value = "draft-lemmons-cose-composite-claims-03"
stream = "IETF"
status = "standard"

[[author]]
initials = "C."
surname = "Lemmons"
fullname = "Chris Lemmons"
organization = "Comcast"
  [author.address]
  email = "chris_lemmons@comcast.com"
%%%

.# Abstract

Composition claims are claims for CBOR Web Tokens (CWTs) and JSON Web Tokens
(JWTs) that define logical relationships between sets of claims.

{mainmatter}

# Introduction

Composition claims are claims defined for CBOR Web Tokens (CWTs) [@!RFC8392]
and JSON Web Tokens (JWTs) [@!RFC7519].

This document defines the CWT representations of the composition claims named
"and", "or", "nor". It also defines a CWT definition for "crit".

# Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 [@!RFC2119] [@!RFC8174] when,
and only when, they appear in all capitals, as shown here.

This document reuses terminology from CWT [@!RFC8392], JWT [@!RFC7519], and
COSE [@!RFC9052].

This term is defined by this specification:

Composition Claim
: A claim whose value contains one or more claim sets.

Claim Set
: A set of claims. For CWTs this is a CBOR map. For JWTs
this is a JSON object.

# Claims

Composition claims contain one or more claim sets.

In tokens without composition claims, there is exactly one set of claims, so
the acceptability of the claim set determines the acceptability of the token.
However, this document defines multiple claim sets, so it instead refers to
accepting or rejecting claim sets. If the primary claim set is unacceptable,
the token is unacceptable and **MUST** be rejected.

Some applications use tokens to convey information. For example, a token might
have a subject claim that identifies the bearer and the relying party
uses that as information, not necessarily as a means by which to provide
or deny access or make some other kind of decision. In this context, the token
simply describes all situations in which the token would accurately describe
that situation.

Composition claims may be nested arbitrarily. Implementations **MAY** reject
tokens exceeding an implementation-defined nesting depth but **MUST** support at
least four levels.

## Logical Claims

These claims identify one or more sets of claims in a logical relation. The
type of these claims is array and the elements of the array are maps that are
themselves sets of claims.

In CWTs, the value is a CBOR array of CBOR maps. In JWTs, the value is a JSON
array of JSON objects.

For the following CDDL, `Claims-Set` is a map of claims as defined in
[@!RFC8392]. It is described informatively in [@?RFC9711], Appendix D.

### or (Or) Claim

The "or" (Or) claim identifies one or more claim sets of which at least one is
acceptable. If none of the claim sets in an "or" claim is acceptable, the
claim set containing the "or" claim is also unacceptable.

Use of this claim by a token issuer is **OPTIONAL**.

In JWTs, the Claim Name is "or" and the Claim Value is a JSON array of JSON
objects.

In CWTs, the Claim Key is TBD (to be registered in the "CBOR Web Token (CWT)
Claims" registry).

The "or" (Or) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( or-claim-label => or-claim-value )
or-claim-label = TBD
or-claim-value = [ + Claims-Set ]
```

### nor (Not Or) Claim

The "nor" (Nor) claim identifies one or more claim sets of which none is
acceptable. If any claim set in a "nor" claim is acceptable, the claim set
containing the "nor" claim is also unacceptable.

This is the logical negation of the "or" claim.

Use of this claim by a token issuer is **OPTIONAL**.

In JWTs, the Claim Name is "nor" and the Claim Value is a JSON array of JSON
objects.

In CWTs, the Claim Key is TBD (to be registered in the "CBOR Web Token (CWT)
Claims" registry).

The "nor" (Nor) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( nor-claim-label => nor-claim-value )
nor-claim-label = TBD
nor-claim-value = [ + Claims-Set ]
```

### and (And) Claim

The "and" (And) claim identifies one or more claim sets of which all are
acceptable. If any claim set in an "and" claim is not acceptable, the
claim set containing the "and" claim is also unacceptable.

The "and" claim is often unnecessary because a claim set is only accepted when
all its claims are acceptable. However, a CBOR map must not contain duplicate keys, so
claims cannot be repeated. The "and" claim is useful when a claim needs to
appear multiple times, like when using the "or" and "nor" claims.

Use of this claim by a token issuer is **OPTIONAL**.

In JWTs, the Claim Name is "and" and the Claim Value is a JSON array of JSON
objects.

In CWTs, the Claim Key is TBD (to be registered in the "CBOR Web Token (CWT)
Claims" registry).

The "and" (And) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( and-claim-label => and-claim-value )
and-claim-label = TBD
and-claim-value = [ + Claims-Set ]
```

### Examples

The examples in this document use CBOR diagnostic notation [@?RFC8949], in
which each claim key is preceded by a `/comment/` naming the claim; the
corresponding JWT examples use JSON. For brevity, JWT equivalents are shown
only for the first two examples.

These logical claims can be used to describe more complex relationships between
claims. For example, the following claim set describes a token with multiple
subject claims. This token describes a situation where either of the two
subjects must be true, but the issuer is not disclosing which one must be true
or even whether the two subjects are genuinely different.

```
{
  /or/ TBD: [
    { /sub/ 2: "george@example.net" },
    { /sub/ 2: "harriet@example.net" }
  ]
}
```

A relying party that receives this token knows that bearer claims to be both
George and Harriet and if either subject is acceptable, the token is
acceptable.

The following JWT claim set example is equivalent:

```
{
  "or": [
    { "sub": "george@example.net" },
    { "sub": "harriet@example.net" }
  ]
}
```

The "nor" claim is useful both as a logical negation, even when only one claim
is present. For example, consider the following claim set:

```
{
  /nor/ TBD: [
    { /aud/ 3: "https://example.com" }
  ]
}
```

This token is intended for any audience except "example.com".

The following JWT claim set example is equivalent:

```
{
  "nor": [
    { "aud": "https://example.com" }
  ]
}
```

Complex relationships can also be described using the claims in combination.
The "geohash" claim [@?CTA5009A] describes a geographical region. For example:

```
{
  /aud/ 3: "https://example.com",
  /geohash/ 282: "9q8yy",
  /nor/ TBD: [
    { /geohash/ 282: ["9q8yy9", "9q8yyd"] }
  ]
}
```

This token describes an audience of "https://example.com" and a region
described by the geohash of "9q8yy" that does not include the region described
by "9q8yy9" or "9q8yyd".

If a more complex relationship is required, the "and" claim can be used to
combine multiple claims. For example, consider the following claim set:

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

This example describes a token that is valid for both
George and Harriet and is intended for both "https://example.com" and
"https://example.net". This repetition is unnecessary in practice because the "aud" claim already
describes a list of acceptable audiences. The use of the "and" claim is
required in order to effectively repeat the "or" claim, because a single claim
set cannot contain the same claim twice.

## crit (Critical) Claim

The "crit" (Critical) claim indicates critical extensions to this kind of claim
set.

The semantics of the JWT claim name "crit" are defined by OpenID Federation 1.0
[@!OpenID-Federation]. This specification defines only the CWT representation.

The value of this claim is an array. Each element identifies a claim within the
same claim set.

In CWTs, elements are integers or text strings identifying claim keys. The
"crit" array **MUST NOT** be empty. Each element of the "crit" array **MUST**
identify a claim that is present in the same claim set. Elements in the "crit"
array **MUST** be unique.

Elements in the "crit" array **MUST NOT** identify claims that are specified
as MANDATORY to understand for the token. This will vary by application profile
as described in [RFC7519], Section 4. As noted in [@!OpenID-Federation],
Section 13.4, any profile that requires correct processing of the "crit" claim
**MUST** specify that it is MANDATORY to understand.

If a claim listed in the "crit" array is present in a claim set and the
processor cannot process the claim for any reason, the claim set **MUST** be
rejected. If a claim listed in the "crit" array is not present in a claim set,
the claim set **MUST** be rejected. (TODO: Square this with the OpenID
definition. The OpenID definition does not explicitly require claim sets to be
rejected if the claim name rules like including duplicates, empty arrays, or
the presence of claims that are not present in the claim set.)

Use of this claim by a token issuer is **OPTIONAL**.

In CWTs, the Claim Key is TBD (to be registered in the "CBOR Web Token (CWT)
Claims" registry).

### Example

A "crit" claim can be used in conjunction with logical claims to condition a
portion of the token on the ability to process a claim:

```
{
  /or/ TBD: [
    { /geohash/ 282: "9q8yy", /crit/ TBD: [ 282 ] },
    { /private/ -524289: "sf", /crit/ TBD: [ -524289 ] }
  ]
}
```

This example assumes the existence of some kind of claim in the private space
that a relying party may or may not be able to process. This token claims that
the subject is in the described region and also that a private claim is present
and that the relying party must be able to verify at least one of those claims,
but it does not need to be able to process both.

# Security Considerations

All security considerations relevant to CWTs and JWTs in general will apply to
tokens that use composition claims.

Additionally, processors of tokens with composition claims will need to be aware
of the possibility of receiving highly nested tokens. Excessive nesting can
lead to overflows or other processing errors.

# IANA Considerations

This specification requests that IANA register the following claim keys in the
"CBOR Web Token (CWT) Claims" registry established by [@!RFC8392]:

Claim Name: or  
Claim Description: Logical OR  
JWT Claim Name: or  
Claim Key: TBD  
Claim Value Type(s): array  
Change Controller: IESG

Claim Name: nor  
Claim Description: Logical NOR  
JWT Claim Name: nor  
Claim Key: TBD  
Claim Value Type(s): array  
Change Controller: IESG

Claim Name: and  
Claim Description: Logical AND  
JWT Claim Name: and  
Claim Key: TBD  
Claim Value Type(s): array  
Change Controller: IESG

Claim Name: crit  
Claim Description: Critical Claims  
JWT Claim Name: crit  
Claim Key: TBD  
Claim Value Type(s): array  
Change Controller: IESG

This specification requests that IANA register the following claim names in the
"JSON Web Token Claims" registry established by [@!RFC7519]:

Claim Name: or  
Claim Description: Logical OR  
Change Controller: IESG  
Specification Document(s): This document

Claim Name: nor  
Claim Description: Logical NOR  
Change Controller: IESG  
Specification Document(s): This document

Claim Name: and  
Claim Description: Logical AND  
Change Controller: IESG  
Specification Document(s): This document

The JWT Claim Name "crit" is already registered in the "JSON Web Token Claims"
registry and is defined by OpenID Federation 1.0 [@!OpenID-Federation].

<reference anchor='CTA5009A' target='https://shop.cta.tech/products/fast-and-readable-geographical-hashing-cta-5009'>
    <front>
        <title>CTA 5009-A: Fast and Readable Geographical Hashing</title>
        <author>
            <organization>Consumer Technology Association</organization>
        </author>
        <date year='2024'/>
    </front>
</reference>

<reference anchor='OpenID-Federation' target='https://openid.net/specs/openid-federation-1_0.html'>
  <front>
    <title>OpenID Federation 1.0</title>
    <author>
      <organization>OpenID Foundation</organization>
    </author>
    <date/>
  </front>
</reference>

{backmatter}
