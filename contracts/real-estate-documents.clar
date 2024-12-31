;; Storage Variables and Mappings
(define-data-var document-count uint u0)

(define-map real-estate-documents
  { document-id: uint }
  {
    document-title: (string-ascii 64),
    document-owner: principal,
    document-size: uint,
    upload-date: uint,
    document-description: (string-ascii 128),
    document-tags: (list 10 (string-ascii 32))
  }
)

(define-map document-permissions
  { document-id: uint, user: principal }
  { has-access: bool }
)

;; Error Codes
(define-constant error-document-not-found (err u301))
(define-constant error-duplicate-document (err u302))
(define-constant error-invalid-title (err u303))
(define-constant error-invalid-size (err u304))
(define-constant error-access-denied (err u305))
(define-constant error-unauthorized-action (err u306))
(define-constant error-admin-only (err u300))
(define-constant error-unauthorized-view (err u307))
(define-constant error-invalid-tag (err u308))

;; Contract Administrator
(define-constant admin tx-sender)

;; Private Helper Functions

;; Check if document exists
(define-private (is-document-present (document-id uint))
  (is-some (map-get? real-estate-documents { document-id: document-id }))
)

;; Verify if the caller is the document owner
(define-private (is-document-owner (document-id uint) (user principal))
  (match (map-get? real-estate-documents { document-id: document-id })
    document-data (is-eq (get document-owner document-data) user)
    false
  )
)

;; Retrieve the document size
(define-private (get-document-size (document-id uint))
  (default-to u0
    (get document-size
      (map-get? real-estate-documents { document-id: document-id })
    )
  )
)

;; Validate a single tag
(define-private (is-valid-tag (tag (string-ascii 32)))
  (and
    (> (len tag) u0)
    (< (len tag) u33)
  )
)

;; Validate all tags in a list
(define-private (validate-tags (tags (list 10 (string-ascii 32))))
  (and
    (> (len tags) u0)
    (<= (len tags) u10)
    (is-eq (len (filter is-valid-tag tags)) (len tags))
  )
)

