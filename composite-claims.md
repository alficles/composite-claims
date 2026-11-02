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

A token may authorize access to different resources under different
conditions. For example, access to one resource may expire before access to
another. Composite claims allow each resource restriction to be grouped with
its expiration and the alternatives to be combined in a single token.
The Common Access Token authorization scheme for Media over QUIC
[@?I-D.ietf-moq-c4m] uses this approach to associate permissions with
different expiration times.

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

Within a claim set nested in a composite claim, a claim validation failure that
would require rejection of a token instead makes that claim set unacceptable.
This includes violations of claim-specific type, structure, or value
constraints.
Requirements for validating the enclosing token's encoding and cryptographic
protection still apply.

Some applications use tokens to convey information. For example, a token might
have a subject claim that identifies the bearer and the recipient
uses that as information, not necessarily as a means by which to provide
or deny access or make some other kind of decision. In this context, the token
simply describes all situations in which the token would accurately describe
that situation.

Composite claims may be nested. The primary claim set is at nesting depth 0.
A claim set nested within a composite claim is at a depth one greater than the
claim set containing that composite claim. Implementations **SHOULD** impose
a finite, implementation-defined nesting-depth limit and **MAY** reject tokens
exceeding that limit. The limit **MUST NOT** be less than 4.

## Logical Claims

These claims identify one or more sets of claims in a logical relation. The
type of these claims is array and the elements of the array are maps that are
themselves sets of claims.

In CWTs, the value is a CBOR array of CBOR maps. In JWTs, the value is a JSON
array of JSON objects.

The following CDDL fragments describe the claims defined here. `Claims-Set`
denotes a claim set as defined by CWT [@!RFC8392] or JWT [@!RFC7519]. The
fragments use the `$$Claims-Set-Claims` group socket from the informative
CDDL model in [@?RFC9711], Appendix D.
The `JC<J,C>` generic denotes the JSON (`J`) and CBOR (`C`) alternatives
using the `.feature` control operator [@!RFC9165], Section 4.

```cddl
JC<J,C> = J .feature "json" / C .feature "cbor"
```

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
or-claim-label = JC<"or", TBD_OR>
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
nor-claim-label = JC<"nor", TBD_NOR>
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
and-claim-label = JC<"and", TBD_AND>
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

A recipient that receives this token knows that the bearer claims to be
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

The "and" claim can be used to combine multiple instances of the same claim.
The "catgeocoord" claim [@?CTA5007B] describes one or more circular
geographical regions and accepts a location within any of them. For example,
consider the following claim set, carried in an encrypted CWT:

```
{
  /and/ TBD_AND: [
    { /catgeocoord/ 317: [[37.77, -122.42, 1000]] },
    { /catgeocoord/ 317: [[37.77, -122.40, 1000]] }
  ]
}
```

For a recipient that supports "catgeocoord", this token describes the
intersection of two circular regions, each with a radius of 1000 meters.
A single "catgeocoord" claim containing both regions would describe their
union instead. The "and" claim allows both constraints to apply, because
a single claim set cannot contain the same claim twice.

## crit (Critical) Claim

The "crit" (Critical) claim identifies claims within the same claim set that a
recipient **MUST** understand and process for that claim set to be acceptable.
Unlike the logical claims above, its value is a list of claim identifiers
rather than a set of claim sets, so it is not itself a composite claim; it is
defined here because it is used together with them.

The semantics of the JWT claim name "crit" are defined by OpenID Federation 1.0
[@!OpenID-Federation]. This specification defines the CWT representation of
"crit" and the CWT-specific processing rules below.

The value of this claim is an array.

In CWTs, elements are integers or text strings identifying claim keys.

An issuer producing a "crit" claim **MUST** ensure that the "crit" array is not
empty, that each element identifies a claim that is present in the claim set
that directly contains the "crit" claim, and that the elements are unique.

Claims that recipients are required to understand and process under the
applicable profile, as described in [@!RFC7519], Section 4, are considered to
be the claims specified for use in the token type. An issuer **MUST NOT**
include such claims in the "crit" array. As noted in [@!OpenID-Federation],
Section 13.4, any profile that requires correct processing of the "crit" claim
**MUST** specify that the "crit" claim itself MUST be understood and processed.

A recipient **MUST** reject the containing claim set if any listed claim is
absent from that set, not understood, or cannot be processed.

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

A "crit" claim can be used with logical claims to require processing of at
least one of two claims:

```
{
  /or/ TBD_OR: [
    { /geohash/ 282: "9q8yy", /crit/ TBD_CRIT: [ 282 ] },
    { /private/ -524289: "sf", /crit/ TBD_CRIT: [ -524289 ] }
  ]
}
```

This example assumes a private claim that some recipients do not understand.
The token is acceptable if the recipient understands and processes either the
"geohash" claim or the private claim, and that claim is acceptable. The
recipient need not understand and process both claims.

# Security Considerations

All security considerations relevant to CWTs and JWTs in general will apply to
tokens that use composite claims.

Additionally, recipients of tokens with composite claims will need to be aware
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

<reference anchor='CTA5007B' target='https://shop.cta.tech/products/cta-5007-b'>
    <front>
        <title>CTA-5007-B: Common Access Token</title>
        <author>
            <organization>Consumer Technology Association</organization>
        </author>
        <date month='April' year='2025'/>
    </front>
</reference>

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
