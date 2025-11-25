StackCoupon Smart Contract

StackCoupon is an on-chain coupon and voucher management system built on the Stacks blockchain using the Clarity smart contract language. It enables decentralized applications, marketplaces, and incentive-driven platforms to issue, redeem, and track digital coupons securely and transparently.

Features

- **On-chain Coupon Issuance**  
  Create unique coupon codes with metadata such as issuer, expiry date, and usage limits.

- **Secure Redemption**  
  Prevent double-use, expired coupon use, or unauthorized redemptions.

- **Single-Use or Multi-Use Coupons**  
  Configure each coupon's usage rules to fit promotional or reward systems.

- **Transparent Tracking**  
  Anyone can query coupon status, issuer, expiration, and redemption history.

- **Event Logging**  
  Emitted events provide on-chain transparency for coupon creation and redemption.

Contract Functions

Public Functions
- `create-coupon` — Issue a new coupon with usage parameters and expiry date.  
- `redeem-coupon` — Redeem a valid coupon while enforcing rules and protections.

Read-Only Functions
- `get-coupon` — Retrieve stored coupon data.  
- `is-valid` — Check if a coupon is active and eligible for redemption.  
- `has-expired` — Determine whether a coupon has passed its expiry time.

Use Cases

- E-commerce discounts  
- Loyalty and reward programs  
- DApp promotional events  
- Token-gated voucher systems  
- Event tickets or access passes

Requirements

- Stacks Blockchain  
- Clarinet (for compiling, testing, and deploying)  
- Clarity Language (v2 syntax recommended)


