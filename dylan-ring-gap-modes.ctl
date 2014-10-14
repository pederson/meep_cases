; ring with gap mode calculation

;;;;;;;;;;;;;;;;; user-defined stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; geometry
(define-param eps 11.56) ; dielectric const
(define-param w 1) ; width of ring
(define-param r 4); inner radius of ring
(define-param res 10) ; grid points per unit length
(define-param pad 4) ; padding between waveguide and edge of PML
(define-param dpml 2) ; thickness of PML

; for gaussian pulse
(define-param fcen 0.15) ; center frequency
(define-param df 0.1) ; frequency spread
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t) ; first

;;;;;;;;;;;;;;;;;;;;; CELL BUILDING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This will depend on the specific geometry that you build
; but should be computable from the above user-defined items

(define sx (+ (* 3 r) (* w 2) (* 2 (+ pad dpml)))) ; cell size in x-direction
(define sy (+ (* 3 r) (* w 2) (* 2 (+ pad dpml)))) ; cell size in y-direction

(set! geometry-lattice (make lattice (size sx sy no-size)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t) ; second

;;;;;;;;;;;;;;;;;;;;; GEOMETRY BUILDING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ring resonator with split at the top
(set! geometry (list
	(make cylinder (center 0 0) (height infinity)
	      (radius (+ r w)) (material (make dielectric (index 3.4))))
	(make cylinder (center 0 0) (height infinity)
	      (radius r) (material air))
	(make block (center 0  (+ 0 (+ r (/ w 2)))) (size w (* 2 w) infinity)
                  (material air))
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
(display #t) ; third

;;;;;;;;;;;;;;;;;;;;;;;;;; SPECIFY BOUNDARIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Perfectly Matched Layer (open boundary)
(set! pml-layers (list (make pml (thickness dpml))))

(set-param! resolution res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

(display #t) ; fourth

;;;;;;;;;;;;;;;;;;;;;;;;; CURRENT SOURCES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Gaussian source
(set! sources (list
		(make source
		(src (make gaussian-src (frequency fcen) (fwidth df)))
		(component Ez) (center (+ r (/ w 2)) 0) )
		)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;; SYMMETRIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NO SYMMETRIES :(
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t) ; fifth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; OUTPUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; resonant modes
(run-sources+ 300
	    (at-beginning output-epsilon)
	    (after-sources (harminv Ez (vector3 (+ r (/ w 2)) 0) fcen df)))

; field patterns
(run-until (/ 1 fcen) (at-every (/ 1 fcen 20) output-efield-z))

; transmission Tx and reflection Rx


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
