;; Medical Records Contract - Enhanced Version

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-not-found (err u101))
(define-constant err-expired-access (err u102))
(define-constant err-invalid-status (err u103))
(define-constant err-invalid-purpose (err u104))

;; Events
(define-data-var last-event-id uint u0)
(define-map events 
  { id: uint }
  {
    event-type: (string-ascii 20),
    patient: principal,
    actor: principal,
    timestamp: uint
  }
)

;; Data structures
(define-map medical-records 
  { patient: principal, record-id: uint }
  { 
    data-hash: (buff 32),
    timestamp: uint,
    doctor: principal,
    metadata: (string-utf8 256),
    status: (string-ascii 10),  ;; active or revoked
    version: uint
  }
)

(define-map record-access
  { patient: principal, accessor: principal }
  { 
    can-read: bool, 
    expiry: uint,
    last-access: uint,
    purpose: (string-utf8 100)
  }
)

(define-map access-history
  { patient: principal, record-id: uint }
  { 
    accesses: (list 10 {
      accessor: principal,
      timestamp: uint,
      purpose: (string-utf8 100)
    })
  }
)

;; Private functions
(define-private (emit-event (event-type (string-ascii 20)) (patient principal) (actor principal))
  (let ((event-id (+ (var-get last-event-id) u1)))
    (var-set last-event-id event-id)
    (map-set events
      { id: event-id }
      {
        event-type: event-type,
        patient: patient,
        actor: actor,
        timestamp: block-height
      }
    )
  )
)

;; Public functions
(define-public (add-record (patient principal) (record-id uint) (data-hash (buff 32)) (metadata (string-utf8 256)))
  (let ((caller tx-sender))
    (asserts! (is-verified-doctor caller) err-unauthorized)
    (emit-event "RECORD_ADDED" patient caller)
    (ok (map-set medical-records 
      { patient: patient, record-id: record-id }
      { 
        data-hash: data-hash,
        timestamp: block-height,
        doctor: caller,
        metadata: metadata,
        status: "active",
        version: u1
      })))
)

[... rest of the contract with similar enhancements ...]
