# ibookk Privacy Policy (DRAFT — have a licensed attorney review before publishing)

_Last updated: [DATE]. Mount at `/privacy`._

## Who we are
ibookk ("we", "us") provides bookkeeping and tax-preparation software for US small
businesses. This policy explains what we collect, why, and your choices. For questions:
[SUPPORT EMAIL].

## Information we collect
- **Account data**: name, email, password (hashed; we never see it), organization and
  business-entity details (legal name, EIN, entity type, state).
- **Financial data you connect**: bank and card transactions via **Plaid** (we receive
  transaction and balance data; we do not receive your bank credentials), Shopify order
  data if you connect a store, invoices, bills, receipts you upload.
- **Tax data**: shareholder/owner information including taxpayer identification numbers
  (**stored encrypted at rest — we enforce this at the database level**), payroll data,
  IRS notices you upload, and the figures needed to prepare returns (1120-S/1065, K-1,
  Form 7203).
- **Usage data**: log and device information needed to operate and secure the service.

## How we use it
To operate the service: categorize transactions, keep your ledger, prepare tax forms,
compute deadlines, detect anomalies (e.g., duplicate charges), and answer your questions
in-product. We do **not** sell your personal or financial information.

## AI features
Some features use large-language-model providers (currently Google and/or Anthropic) to
classify transactions, analyze documents you upload, and answer tax questions grounded in
your ledger. Data sent for these features is limited to what the feature needs, is
transmitted encrypted, and is governed by our agreements with those providers; we use
API tiers that do **not** use your data to train their models. AI outputs are suggestions
and always subject to your review.

## Service providers (subprocessors)
Supabase (database & authentication), Railway (application hosting), Plaid (bank
connections), Stripe (billing), Google / Anthropic (AI features), [EMAIL PROVIDER].
Each processes data only to provide their service to us.

## Security
Encryption in transit (TLS) and at rest; sensitive identifiers (TINs, bank routing
numbers) are additionally application-encrypted with database-level enforcement;
row-level security isolates each customer's data; access is least-privilege and logged.
We maintain a written information-security program consistent with the FTC Safeguards
Rule and IRS Publication 4557 guidance for handlers of tax information.

## Retention & deletion
Your books belong to you: export is available at any time in standard formats. On account
deletion we delete or de-identify personal data within [30] days, except records we must
retain for legal, tax, or audit obligations (e.g., IRC §6107 return-copy requirements).

## Your rights
Depending on your state (e.g., CCPA/CPRA for California residents), you may have rights
to access, correct, delete, or port your data, and to opt out of "sharing" as defined by
law. Contact [SUPPORT EMAIL]; we respond within the statutory window.

## Federal tax-information consent (IRC §7216)
Where we use or disclose tax-return information for purposes other than preparing your
return, we will request your consent in the form required by Treas. Reg. §301.7216-3.

## Children
The service is for businesses and users 18+.

## Changes
We will notify account owners of material changes by email and in-product before they
take effect.
