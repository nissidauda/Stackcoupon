(define-data-var admin principal tx-sender)

;; Approved merchants allowed to create vouchers
(define-map merchants {merchant: principal} {approved: bool})

;; Voucher structure
(define-map vouchers
  {id: uint}
  {
    creator: principal,
    discount: uint,
    is-percent: bool,
    max-uses: uint,
    used: uint,
    valid-from: uint,
    valid-until: uint,
    allowed-user: (optional principal)
  }
)

;; Tracks voucher redemption per user
(define-map redemptions
  {id: uint, user: principal}
  {count: uint}
)

;; Ensure only admin
(define-private (only-admin)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u401))
    (ok true)
  )
)

;; Ensure merchant is approved
(define-private (only-merchant)
  (let ((merch (unwrap! (map-get? merchants {merchant: tx-sender}) (err u403))))
    (asserts! (get approved merch) (err u403))
    (ok true)
  )
)

;; Add approved merchant
(define-public (approve-merchant (m principal))
  (begin
    (try! (only-admin))
    (map-set merchants {merchant: m} {approved: true})
    (ok true)
  )
)

;; Create a new voucher
(define-public (create-voucher
    (id uint)
    (discount uint)
    (is-percent bool)
    (max-uses uint)
    (valid-from uint)
    (valid-until uint)
    (allowed-user (optional principal))
  )
  (begin
    (try! (only-merchant))
    (asserts! (<= valid-from valid-until) (err u400))
    (map-set vouchers
      {id: id}
      {
        creator: tx-sender,
        discount: discount,
        is-percent: is-percent,
        max-uses: max-uses,
        used: u0,
        valid-from: valid-from,
        valid-until: valid-until,
        allowed-user: allowed-user
      }
    )
    (ok true)
  )
)

;; Redeem voucher
(define-public (redeem-voucher (id uint))
  (let ((v (map-get? vouchers {id: id})))
    (match v
      voucher
        (begin
          ;; Time checks
          (asserts! (>= stacks-block-height (get valid-from voucher)) (err u100))
          (asserts! (<= stacks-block-height (get valid-until voucher)) (err u101))

          ;; Fixed match type error by ensuring both branches return (response bool uint)
          (try! (match (get allowed-user voucher)
            user
              (if (is-eq user tx-sender)
                (ok true)
                (err u102)
              )
            (ok true)
          ))

          ;; Usage limit check
          (asserts! (< (get used voucher) (get max-uses voucher)) (err u103))

          ;; Record redemption
          (let ((new-count (+ (get used voucher) u1)))
            (map-set vouchers {id: id} (merge voucher {used: new-count}))
          )

          ;; Update per-user redemption
          (let (
                (user-key {id: id, user: tx-sender})
                (existing (map-get? redemptions user-key))
               )
            (match existing
              e (map-set redemptions user-key {count: (+ (get count e) u1)})
              (map-set redemptions user-key {count: u1})
            )
          )

          (ok {
            discount: (get discount voucher),
            is-percent: (get is-percent voucher)
          })
        )
      (err u404)
    )
  )
)

;; Admin can invalidate voucher
(define-public (invalidate-voucher (id uint))
  (begin
    (try! (only-admin))
    (map-delete vouchers {id: id})
    (ok true)
  )
)
