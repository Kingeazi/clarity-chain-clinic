;; Medical Records Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-not-found (err u101))

;; Data structures
(define-map medical-records 
  { patient: principal, record-id: uint }
  { 
    data-hash: (buff 32),
    timestamp: uint,
    doctor: principal,
    metadata: (string-utf8 256)
  }
)

(define-map record-access
  { patient: principal, accessor: principal }
  { can-read: bool, expiry: uint }
)

;; Public functions
(define-public (add-record (record-id uint) (data-hash (buff 32)) (metadata (string-utf8 256)))
  (let ((caller tx-sender))
    (if (is-doctor caller)
      (ok (map-set medical-records 
        { patient: tx-sender, record-id: record-id }
        { 
          data-hash: data-hash,
          timestamp: block-height,
          doctor: caller,
          metadata: metadata
        }))
      err-unauthorized))
)

(define-public (grant-access (to principal) (expiry uint))
  (ok (map-set record-access
    { patient: tx-sender, accessor: to }
    { can-read: true, expiry: expiry }))
)

(define-read-only (can-access-records (patient principal) (accessor principal))
  (let ((access (map-get? record-access { patient: patient, accessor: accessor })))
    (if (and (is-some access)
             (< block-height (get expiry (unwrap-panic access))))
        (ok true)
        (ok false)))
)
