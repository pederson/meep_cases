; template for MEEP runs

;;;;;;;;;;;;;;;;; user-defined stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; type of simulation to run
(define-param do_tdomain false); run a time-domain simulation
(define-param do_Tx false); find the transmission spectrum
(define-param do_Rx false); find the reflection spectrum
(define-param do_modes false); find the modes of the geometry
(define-param do_bands false); get data for band diagram

; simulation cell
(define-param xpad 3); extra space on the left and right sides
(define-param ypad 3); extra space on the top and bottom sides

; geometry
(define-param nrows 2); number of rows
(define-param ncols 2); number of columns
(define-param eps 100) ; dielectric of waveguide
(define-param w 1) ; width of waveguide
(define-param r 2) ; inner radius of ring
(define-param res 10) ; grid points per unit length
(define-param pad 2) ; padding between waveguide and edge of PML
(define-param dpml 1) ; thickness of PML

; plasma variables
(define-param w_plasma 0.4) ; plasma frequency
(define-param gamma_plasma) ; plasma damping rate


; for continuous source
(define-param wlen (* 5 r)) ; wavelength

; for gaussian pulse
(define-param fcen 0.25) ; center frequency
(define-param df 0.1) ; frequency spread

; for transmission/reflection spectrum
(define-param nfreq 500) ; number of frequencies within the range to store
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t) ; these are here for debugging

;;;;;;;;;;;;;;;;;;;;; CELL BUILDING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This will depend on the specific geometry that you build
; but should be computable from the above user-defined items

(define sx (+ (* 2 (+ r w pad dpml)) 2)) ; cell size in x-direction
(define sy (+ (* 2 r))) ; cell size in y-direction

(set! geometry-lattice (make lattice (size sx sy no-size)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t)

;;;;;;;;;;;;;;;;;;;;; GEOMETRY BUILDING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description can go here

; list of items
	(set! geometry (list
		(make cylinder (center 0 0) (height infinity)
		      (radius (+ r w)) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		))
	)

; geometric duplicates
	(set! geometry (append
		(geometric-object-duplicates (vector3 (* 3 r) 0 0) 0 ncols
		(geometric-object-duplicates (vector3 0 (* 3 r) 0) 0 nrows
		(list
		(make cylinder (center 0 0) (height infinity)
		      (radius (+ r w)) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		      (radius r) (material air))
		(make block (center 0 (- 0 (+ r (/ w 2)))) (size w (* 2 w) infinity)
                      (material air))
		

		(make cylinder (center 0 0) (height infinity)
		      (radius (- r (/ w 4))) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		      (radius (- r (* 5 (/ w 4)))) (material air))
		(make block (center 0 (+ 0 (- r (* 3 (/ w 4))))) (size w (* 1.1  w) infinity)
                      (material air))
		)
		)
		)
		)
	)	

; geometric lattice
	(set! geometry (append 
	(geometric-objects-lattice-duplicates
		(list
		(make cylinder (center 0 0) (height infinity) (radius r) (material metal))
		(make cylinder (center 0 0) (height infinity) (radius (- r w)) (material none))
		)
	) [(* r nrows) (* r ncols) 0]
	)
	)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t)	

;;;;;;;;;;;;;;;;;;;;;;;;;; SPECIFY BOUNDARIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Perfectly Matched Layer (open boundary)
(set! pml-layers (list (make pml (thickness dpml))))

; absorber
;(set! pml-layers (list (make absorber (thickness dpml))))

; bloch-periodic
;(set-param! kpoint (vector3 sx sy )) 
;(ensure-periodicity true)


(set-param! resolution res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

(display #t)

;;;;;;;;;;;;;;;;;;;;;;;;; CURRENT SOURCES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; continuous source
(set! sources (list
             (make source
               (src (make continuous-src (wavelength wlen) (width 20)))
               (component Ez) (center (+ 0.5 (/ sxy -2)) 0) (size 0 1))))

; Gaussian source
;(set! sources (list
		(make source
		(src (make gaussian-src (frequency fcen) (fwidth df)))
		(component Ez) (center src_loc_x src_loc_y) )))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display #t)

;;;;;;;;;;;;;;;;;;;;;;;;;;; SYMMETRIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exploit the mirror symmetry in structure+source:
;(set! symmetries (list (make mirror-sym (direction Y))))
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

	(define trans; transmitted flux
		(add-flux fcen df nfreq
			(make flux-region
				(center ()))))

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
	
	(define refl ; reflected flux
		(add-flux fcen df nfreq
			(make flux-region
				(center (+ (* -0.5 sx) 1.5) (size 0 (* w 2))))))

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
