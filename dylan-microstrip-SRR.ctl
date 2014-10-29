; 2-d split ring resonator with microstrip (from Hopwood paper)

;;;;;;;;;;;;;;;;; user-defined stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; for continuous source
(define-param wlen 5) ; wavelength

; geometry
(define-param eps 10) ; dielectric of substrate
(define-param w 1) ; width of strip
(define-param r (/ wlen (* 4 pi)) ; inner radius of ring
(define-param res 10) ; grid points per unit length
(define-param pad 2) ; padding between stripline and edge of PML
(define-param dpml 2) ; thickness of PML
(define-param striplen (/ wlen 4) ; length of strip


; for gaussian pulse
(define-param fcen 0.25) ; center frequency
(define-param df 0.1) ; frequency spread
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define sxy (+ (* 2 (+ r w pad dpml)) 2)) ; cell size
(set! geometry-lattice (make lattice (size sxy sxy no-size)))

; Create a ring waveguide by two overlapping cylinders - later objects
; take precedence over earlier objects, so we put the outer cylinder first.
; and the inner (air) cylinder second.
; then create the ring air gap
	(set! geometry (list
		(make cylinder (center 0 0) (height infinity)
		      (radius (+ r w)) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		      (radius r) (material air))
		(make block (center 0  (+ 0 (+ r (/ w 2)))) (size w (* 2 w) infinity)
                      (material air))
		

		(make block (center 0 (- 0 (/ striplen 2) w) (height infinity)
		      (material (make dielectric (epsilon eps))))
		)
	)
		

(set! pml-layers (list (make pml (thickness dpml))))
(set-param! resolution res)

; If we don't want to excite a specific mode symmetry, we can just
; put a single point source at some arbitrary place, pointing in some
; arbitrary direction.  We will only look for TM modes (E out of the plane).


; set a continuous source
(set! sources (list
             (make source
               (src (make continuous-src (wavelength wlen) (width 20)))
               (component Ez) (center (+ 0.5 (/ sxy -2)) 0) (size 0 1))))



; exploit the mirror symmetry in structure+source:
;(set! symmetries (list (make mirror-sym (direction Y))))


; Output fields for one period at the end.  (If we output
; at a single time, we might accidentally catch the Ez field when it is
; almost zero and get a distorted view.)
;(run-until (/ 1 fcen) (at-every (/ 1 fcen 20) output-efield-z))


(run-until 200
	    (at-beginning output-epsilon)
	    (to-appended "ez" (at-every 0.3 output-efield-z)))
