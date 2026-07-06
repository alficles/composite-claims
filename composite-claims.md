%%%
title = "Composite Token Claims"
ipr = "trust200902"
area = "Security"
workgroup = "COSE"
submissiontype = "IETF"
keyword = ["CBOR", "CWT", "COSE", "JWT", "JSON"]
updates = [ ]

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

Composite claims are claims for CBOR Web Tokens (CWTs) and JSON Web Tokens
(JWTs) that define logical relationships between sets of claims. This document
also defines a CWT representation of the "crit" (Critical) claim.

{mainmatter}

# Introduction

Composite claims are claims defined for CBOR Web Tokens (CWTs) [@!RFC8392]
and JSON Web Tokens (JWTs) [@!RFC7519].

This document defines the CWT and JWT representations of the composite claims
named "or", "nor", and "and". It also defines a CWT representation of the "crit"
claim.

# Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 [@!RFC2119] [@!RFC8174] when,
and only when, they appear in all capitals, as shown here.

This document reuses terminology from CBOR [@!RFC8949], CWT [@!RFC8392], and
JWT [@!RFC7519].

The following terms are defined by this specification:

Composite Claim
: A claim whose value contains one or more claim sets.

Claim Set
: A set of claims. For CWTs this is a CBOR map. For JWTs
this is a JSON object.

Acceptable
: A claim is acceptable if what it asserts is either true or not relevant to
the recipient. A claim set is acceptable if and only if every claim in it is
acceptable. A recipient determines acceptability according to the application
or profile.

# Claims

Composite claims contain one or more claim sets.

In tokens without composite claims, there is exactly one set of claims, so
the acceptability of the claim set determines the acceptability of the token.
Because composite claims allow a token to contain multiple, nested claim sets,
this specification defines acceptability at the level of individual claim sets.
The top-level claim set of a token is its primary claim set. If the primary
claim set is unacceptable, the token is unacceptable and **MUST** be rejected.

Some applications use tokens to convey information. For example, a token might
have a subject claim that identifies the bearer and the relying party
uses that as information, not necessarily as a means by which to provide
or deny access or make some other kind of decision. In this context, the token
simply describes all situations in which the token would accurately describe
that situation.

Composite claims may be nested. This specification places no inherent limit on
nesting depth. For the purpose of this requirement, the primary claim set is at
nesting depth 0, and a claim set nested within a composite claim is at a depth
one greater than the composite claim that contains it. Implementations **MAY**
reject tokens whose nesting depth exceeds an implementation-defined limit, but
that limit **MUST NOT** be less than 4.

## Logical Claims

These claims identify one or more sets of claims in a logical relation. The
type of these claims is array and the elements of the array are maps that are
themselves sets of claims.

In CWTs, the value is a CBOR array of CBOR maps. In JWTs, the value is a JSON
array of JSON objects.

In the following CDDL, `Claims-Set` is a claim set: a CBOR map for CWTs
[@!RFC8392] or a JSON object for JWTs [@!RFC7519]. The CDDL extends the
`$$Claims-Set-Claims` group socket introduced by the Entity Attestation Token
(EAT) [@?RFC9711].

### or (Or) Claim

The "or" (Or) claim identifies one or more claim sets of which at least one is
acceptable. If none of the claim sets in an "or" claim is acceptable, the
claim set containing the "or" claim is also unacceptable.

The "or" array **MUST NOT** be empty.

Use of this claim by a token issuer is **OPTIONAL**.

In CWTs, the Claim Key is TBD_OR (to be registered in the "CBOR Web Token (CWT)
Claims" registry) and the Claim Value is a CBOR array of CBOR maps.

In JWTs, the Claim Name is "or" and the Claim Value is a JSON array of JSON
objects.

The "or" (Or) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( or-claim-label => or-claim-value )
or-claim-label = TBD_OR
or-claim-value = [ + Claims-Set ]
```

### nor (Nor) Claim

The "nor" (Nor) claim identifies one or more claim sets of which none is
acceptable. If any claim set in a "nor" claim is acceptable, the claim set
containing the "nor" claim is also unacceptable.

This is the logical negation of the "or" claim.

The "nor" array **MUST NOT** be empty.

Use of this claim by a token issuer is **OPTIONAL**.

In CWTs, the Claim Key is TBD_NOR (to be registered in the "CBOR Web Token (CWT)
Claims" registry) and the Claim Value is a CBOR array of CBOR maps.

In JWTs, the Claim Name is "nor" and the Claim Value is a JSON array of JSON
objects.

The "nor" (Nor) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( nor-claim-label => nor-claim-value )
nor-claim-label = TBD_NOR
nor-claim-value = [ + Claims-Set ]
```

### and (And) Claim

The "and" (And) claim identifies one or more claim sets of which all are
acceptable. If any claim set in an "and" claim is not acceptable, the
claim set containing the "and" claim is also unacceptable.

The "and" claim is often unnecessary because a claim set is only accepted when
all its claims are acceptable. However, neither a CBOR map nor a JSON object may contain duplicate keys, so
claims cannot be repeated. The "and" claim is useful when a claim needs to
appear multiple times, like when using the "or" and "nor" claims.

The "and" array **MUST NOT** be empty.

Use of this claim by a token issuer is **OPTIONAL**.

In CWTs, the Claim Key is TBD_AND (to be registered in the "CBOR Web Token (CWT)
Claims" registry) and the Claim Value is a CBOR array of CBOR maps.

In JWTs, the Claim Name is "and" and the Claim Value is a JSON array of JSON
objects.

The "and" (And) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( and-claim-label => and-claim-value )
and-claim-label = TBD_AND
and-claim-value = [ + Claims-Set ]
```

### Examples

The examples in this document use CBOR diagnostic notation [@!RFC8949], in
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
  /or/ TBD_OR: [
    { /sub/ 2: "george@example.net" },
    { /sub/ 2: "harriet@example.net" }
  ]
}
```

A relying party that receives this token knows that the bearer claims to be
George or Harriet, and if either subject is acceptable, the token is
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

The "nor" claim is useful as a logical negation, even when only one claim set
is present. For example, consider the following claim set:

```
{
  /nor/ TBD_NOR: [
    { /aud/ 3: "https://example.com" }
  ]
}
```

This token is intended for any audience except "https://example.com".

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
  /nor/ TBD_NOR: [
    { /geohash/ 282: ["9q8yy9", "9q8yyd"] }
  ]
}
```

This token describes an audience of "https://example.com" and a region
described by the geohash "9q8yy", excluding the regions "9q8yy9" and "9q8yyd".

If a more complex relationship is required, the "and" claim can be used to
combine multiple claims. For example, consider the following claim set:

```
{
  /and/ TBD_AND: [
    {
      /or/ TBD_OR: [
        { /sub/ 2: "george@example.net" },
        { /sub/ 2: "harriet@example.net" }
      ]
    },
    {
      /or/ TBD_OR: [
        { /aud/ 3: "https://example.com" },
        { /aud/ 3: "https://example.net" }
      ]
    }
  ]
}
```

This example describes a token that is valid for either
George or Harriet and is intended for either "https://example.com" or
"https://example.net". This repetition is unnecessary in practice because the "aud" claim already
describes a list of acceptable audiences. The use of the "and" claim is
required in order to effectively repeat the "or" claim, because a single claim
set cannot contain the same claim twice.

## crit (Critical) Claim

The "crit" (Critical) claim identifies claims within the same claim set that a
recipient must be able to process and verify for that claim set to be
acceptable. Unlike the logical claims above, its value is a list of claim
identifiers rather than a set of claim sets, so it is not itself a composite
claim; it is defined here because it is used together with them.

The semantics of the JWT claim name "crit" are defined by OpenID Federation 1.0
[@!OpenID-Federation]. This specification defines the CWT representation of
"crit" and the CWT-specific processing rules below.

The value of this claim is an array.

In CWTs, elements are integers or text strings identifying claim keys.

An issuer producing a "crit" claim **MUST** ensure that the "crit" array is not
empty, that each element identifies a claim that is present in the claim set
that directly contains the "crit" claim, and that the elements are unique.

An issuer **MUST NOT** include in the "crit" array any claim that is already
required to be understood and processed for the token. Which claims are required
to be understood and processed varies by application profile, as described in
[@!RFC7519], Section 4. As noted in [@!OpenID-Federation], Section 13.4, any
profile that requires correct processing of the "crit" claim **MUST** specify
that the "crit" claim itself MUST be understood and processed.

A recipient **MUST** reject the claim set that directly contains a "crit" claim
if any claim listed in that "crit" array is not present in that claim set. If a
claim listed in the "crit" array is present but the recipient cannot process it
for any reason, the recipient **MUST** reject that claim set.

Use of this claim by a token issuer is **OPTIONAL**.

In CWTs, the Claim Key is TBD_CRIT (to be registered in the "CBOR Web Token (CWT)
Claims" registry).

The "crit" (Critical) claim is described by the following CDDL:

```cddl
$$Claims-Set-Claims //= ( crit-claim-label => crit-claim-value )
crit-claim-label = TBD_CRIT
crit-claim-value = [ + (int / tstr) ]
```

### Example

A "crit" claim can be used in conjunction with logical claims to condition a
portion of the token on the ability to process a claim:

```
{
  /or/ TBD_OR: [
    { /geohash/ 282: "9q8yy", /crit/ TBD_CRIT: [ 282 ] },
    { /private/ -524289: "sf", /crit/ TBD_CRIT: [ -524289 ] }
  ]
}
```

This example assumes the existence of some kind of claim in the private space
that a relying party may or may not be able to process and verify. Because the
two claim sets are combined with "or", the token is acceptable if the relying
party can process and verify at least one of them: the "geohash" claim or the
private claim. It does not need to be able to process and verify both.

# Security Considerations

All security considerations relevant to CWTs and JWTs in general will apply to
tokens that use composite claims.

Additionally, processors of tokens with composite claims will need to be aware
of the possibility of receiving highly nested tokens. Excessive nesting can
lead to overflows or other processing errors.

# IANA Considerations

RFC Editor: Upon assignment of the CWT Claim Keys requested below, please
replace the placeholders "TBD_OR", "TBD_NOR", "TBD_AND", and "TBD_CRIT"
throughout this document, including in the CDDL and examples, with the
respective assigned values.

This specification requests that IANA register the following claim keys in the
"CBOR Web Token (CWT) Claims" registry established by [@!RFC8392]:

Claim Name: or  
Claim Description: Logical OR  
JWT Claim Name: or  
Claim Key: TBD_OR  
Claim Value Type(s): array  
Change Controller: IESG

Claim Name: nor  
Claim Description: Logical NOR  
JWT Claim Name: nor  
Claim Key: TBD_NOR  
Claim Value Type(s): array  
Change Controller: IESG

Claim Name: and  
Claim Description: Logical AND  
JWT Claim Name: and  
Claim Key: TBD_AND  
Claim Value Type(s): array  
Change Controller: IESG

Claim Name: crit  
Claim Description: Critical Claims  
JWT Claim Name: crit  
Claim Key: TBD_CRIT  
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
    <date day='17' month='February' year='2026'/>
  </front>
  <refcontent>Final Specification</refcontent>
</reference>

{backmatter}
