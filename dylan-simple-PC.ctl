; template for MEEP runs

;;;;;;;;;;;;;;;;; user-defined stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; type of simulation to run
(define-param do_modes false); find the modes of the geometry
(define-param do_tdomain false); run a time-domain simulation
(define-param do_Tx false); find the transmission spectrum
(define-param do_Rx false); find the reflection spectrum
(define-param do_bands false); obtain the band diagram

; simulation cell
(define-param xpad 0); extra space on the left and right sides
(define-param ypad 0); extra space on the top and bottom sides

; geometry
(define-param lattice_spacing 4) ; spacing of the lattice
(define-param nrows 1); number of rows
(define-param ncols 1); number of columns
(define-param eps 100) ; dielectric of waveguide
(define-param w 1) ; width of waveguide
(define-param r 1) ; inner radius of ring
(define-param res 20) ; grid points per unit length
(define-param pad 2) ; padding between waveguide and edge of PML
(define-param dpml 0) ; thickness of PML

; plasma variables
(define-param w_plasma 0.4) ; plasma frequency
(define-param gamma_plasma 0.1) ; plasma damping rate


; for continuous source
(define-param wlen (* 5 r)) ; wavelength

; for gaussian pulse
(define-param fcen 0.25) ; center frequency
(define-param df 1.5) ; frequency spread

; for transmission/reflection spectrum
(define-param nfreq 200) ; number of frequencies within the range to store

; for bands
(define-param k-interp 19)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t) ; these are here for debugging

;;;;;;;;;;;;;;;;;;;;; CELL BUILDING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This will depend on the specific geometry that you build
; but should be computable from the above user-defined items

(define sx lattice_spacing) ; cell size in x-direction
(define sy lattice_spacing) ; cell size in y-direction

(set! geometry-lattice (make lattice (size sx sy no-size)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t)

;;;;;;;;;;;;;;;;;;;;; GEOMETRY BUILDING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; very simple cylinder

; list of items
(set! geometry (list
	(make cylinder (center 0 0) (height infinity)
	      (radius r) (material (make dielectric (epsilon eps))))
	)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t)	

;;;;;;;;;;;;;;;;;;;;;;;;;; SPECIFY BOUNDARIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; bloch-periodic
(set-param! k-point (vector3 sx sy )) 

(set-param! resolution res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

(display #t)

;;;;;;;;;;;;;;;;;;;;;;;;; CURRENT SOURCES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Gaussian source
(set! sources (list
		(make source
		(src (make gaussian-src (frequency fcen) (fwidth df)))
		(component Ez) (center (- 0.1 sx) 0) )))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t)

;;;;;;;;;;;;;;;;;;;;;;;;;;; SYMMETRIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exploit the mirror symmetry in structure+source:
(set! symmetries (list (make mirror-sym (direction Y))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; OUTPUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; field patterns
(if do_tdomain
	(run-until 200
	    (at-beginning output-epsilon)
	    (to-appended "ez" (at-every 0.3 output-efield-z)))
)

; transmission Tx and reflection Rx
(if do_Tx
	
	;(define trans; transmitted flux
	;	(add-flux fcen df nfreq
	;		(make flux-region
	;			(center 0 0))))

	(run-sources+ (stop-when-fields-decayed
					50 Ez
					(vector3 (- (* 0.5 sx) dpml 0.5) 0)
					 1e-3)
					 (at-beginning output-epsilon)
					 (during-sources
					  (in-volume (volume (center 0 0) (size sx 0))
					   (to-appended "ez" (at-every 0.3 output-efield-z)))))

)
(if do_Rx
	
	;(define refl ; reflected flux
	;	(add-flux fcen df nfreq
	;		(make flux-region
	;			(center (+ (* -0.5 sx) 1.5) (size 0 (* w 2))))))

	(run-sources+ (stop-when-fields-decayed
					50 Ez
					(vector3 (- (* 0.5 sx) dpml 0.5) 0)
					 1e-3)
					 (at-beginning output-epsilon)
					 (during-sources
					  (in-volume (volume (center 0 0) (size sx 0))
					   (to-appended "ez" (at-every 0.3 output-efield-z)))))


)

; resonant modes
(if do_modes

	(run-sources+ 300
	    (at-beginning output-epsilon)
	    (after-sources (harminv Ez (vector3 (+ r (/ w 2)) 0) fcen df)))
		
)

; band diagram
(if do_bands

	(run-k-points 200 (interpolate k-interp (list (vector3 0) (vector3 0.5))))

)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
