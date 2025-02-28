;; Medical Records Contract - Enhanced Version

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-not-found (err u101))
(define-constant err-expired-access (err u102))
(define-constant err-invalid-status (err u103))

;; Data structures
(define-map medical-records 
  { patient: principal, record-id: uint }
  { 
    data-hash: (buff 32),
    timestamp: uint,
    doctor: principal,
    metadata: (string-utf8 256),
    status: (string-ascii 10)  ;; active or revoked
  }
)

(define-map record-access
  { patient: principal, accessor: principal }
  { 
    can-read: bool, 
    expiry: uint,
    last-access: uint
  }
)

(define-map access-history
  { patient: principal, record-id: uint }
  { 
    accesses: (list 10 {
      accessor: principal,
      timestamp: uint
    })
  }
)

;; Public functions
(define-public (add-record (patient principal) (record-id uint) (data-hash (buff 32)) (metadata (string-utf8 256)))
  (let ((caller tx-sender))
    (asserts! (is-verified-doctor caller) err-unauthorized)
    (ok (map-set medical-records 
      { patient: patient, record-id: record-id }
      { 
        data-hash: data-hash,
        timestamp: block-height,
        doctor: caller,
        metadata: metadata,
        status: "active"
      })))
)

(define-public (revoke-record (patient principal) (record-id uint))
  (let ((record (unwrap! (map-get? medical-records { patient: patient, record-id: record-id }) err-not-found)))
    (asserts! (or (is-eq tx-sender patient) (is-eq tx-sender contract-owner)) err-unauthorized)
    (ok (map-set medical-records
      { patient: patient, record-id: record-id }
      (merge record { status: "revoked" }))))
)

(define-public (grant-access (to principal) (expiry uint))
  (begin
    (asserts! (> expiry block-height) err-expired-access)
    (ok (map-set record-access
      { patient: tx-sender, accessor: to }
      { 
        can-read: true, 
        expiry: expiry,
        last-access: u0 
      })))
)

(define-public (revoke-access (from principal))
  (ok (map-delete record-access { patient: tx-sender, accessor: from }))
)

(define-read-only (can-access-records (patient principal) (accessor principal))
  (let ((access (map-get? record-access { patient: patient, accessor: accessor })))
    (if (and 
          (is-some access)
          (get can-read (unwrap-panic access))
          (< block-height (get expiry (unwrap-panic access))))
        (ok true)
        (ok false)))
)

(define-read-only (get-record (patient principal) (record-id uint))
  (let ((caller tx-sender)
       (record (unwrap! (map-get? medical-records { patient: patient, record-id: record-id }) err-not-found)))
    (asserts! (or 
      (is-eq caller patient)
      (unwrap! (can-access-records patient caller) err-unauthorized)) err-unauthorized)
    (asserts! (is-eq (get status record) "active") err-invalid-status)
    (ok record))
)
