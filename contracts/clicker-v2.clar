;; clicker-v2
;; Core contract for the Clicker dApp on Stacks

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_COOLDOWN (err u101))
(define-constant COOLDOWN_BLOCKS u1)

(define-data-var total-clicks uint u0)
(define-data-var game-active bool true)

(define-map user-clicks principal
  {
    clicks: uint,
    last-click: uint,
    streak: uint,
    best-streak: uint,
  }
)

(define-map leaderboard uint
  {
    who: principal,
    clicks: uint,
  }
)

(define-read-only (get-total-clicks)
  (ok (var-get total-clicks))
)

(define-read-only (get-user-clicks (user principal))
  (ok (default-to
    { clicks: u0, last-click: u0, streak: u0, best-streak: u0 }
    (map-get? user-clicks user)
  ))
)

(define-read-only (is-active)
  (ok (var-get game-active))
)

(define-public (click)
  (let (
    (clicker tx-sender)
    (current (default-to
      { clicks: u0, last-click: u0, streak: u0, best-streak: u0 }
      (map-get? user-clicks clicker)
    ))
    (new-clicks (+ (get clicks current) u1))
    (blocks-since (- block-height (get last-click current)))
    (new-streak (if (<= blocks-since (+ COOLDOWN_BLOCKS u5))
      (+ (get streak current) u1)
      u1
    ))
    (new-best (if (> new-streak (get best-streak current)) new-streak (get best-streak current)))
  )
    (asserts! (var-get game-active) ERR_NOT_AUTHORIZED)
    (asserts! (> (- block-height (get last-click current)) COOLDOWN_BLOCKS) ERR_COOLDOWN)

    (var-set total-clicks (+ (var-get total-clicks) u1))

    (map-set user-clicks clicker {
      clicks: new-clicks,
      last-click: block-height,
      streak: new-streak,
      best-streak: new-best,
    })

    (ok { clicks: new-clicks, streak: new-streak })
  )
)

(define-public (set-active (active bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set game-active active)
    (ok true)
  )
)
