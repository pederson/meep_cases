; Dylan Pederson
; line of a periodic dielectric material

; This is a test case for a wave incident perpendicularly on a periodic
; dielectric line of material

; Some parameters to describe the geometry:
(define-param eps1 13) ; dielectric constant of material 1
(define-param eps2 1) ; dielectric constant of material 2
(define-param w 1.2) ; width of line
(define-param sz1 1) ; size of eps1 segments
(define-param sz2 1) ; size of eps2 segments
(define-param Nseg 4) ; number of each segment (2*N total segments)

; The simulation cell dimensions
(define-param sy 10) ; size of cell in y direction (parallel to dielectric strip)
(define-param sx 6) ; size of cell in x direction (perp to dielectric strip)

; build the cell
(set! geometry-lattice (make lattice (size sx sy no-size)))

; build the geometry
(set! geometry
      (append ; combine lists of objects:
       (list (make block (center 0 0) (size infinity w infinity)
		   (material (make dielectric (epsilon eps1)))))
       (geometric-object-duplicates (vector3 1 0) 0 (- N 1)
	(make cylinder (center (/ d 2) 0) (radius r) (height infinity)
	      (material air)))
       (geometric-object-duplicates (vector3 -1 0) 0 (- N 1)
	(make cylinder (center (/ d -2) 0) (radius r) (height infinity)
	      (material air)))))

; do other stuff
(set! pml-layers (list (make pml (thickness dpml))))
(set-param! resolution 20)

(define-param fcen 0.25) ; pulse center frequency                            
(define-param df 0.2)  ; pulse width (in frequency) 

(define-param nfreq 500) ; number of frequencies at which to compute flux

; false = transmission spectrum, true = resonant modes:
(define-param compute-mode? false)

(if compute-mode?
    (begin
      (set! sources (list
		     (make source
		       (src (make gaussian-src (frequency fcen) (fwidth df)))
		       (component Hz) (center 0 0))))

      (set! symmetries
	    (list (make mirror-sym (direction Y) (phase -1))
		  (make mirror-sym (direction X) (phase -1))))

      (run-sources+ 400
		    (at-beginning output-epsilon)
		    (after-sources (harminv Hz (vector3 0) fcen df)))
      (run-until (/ 1 fcen) (at-every (/ 1 fcen 20) output-hfield-z))      
      )
    (begin
      (set! sources (list
		     (make source
		       (src (make gaussian-src (frequency fcen) (fwidth df)))
		       (component Ey)
		       (center (+ dpml (* -0.5 sx)) 0)
		       (size 0 w))))

      (set! symmetries (list (make mirror-sym (direction Y) (phase -1))))
      
      (define-param trans ; transmitted flux
	(add-flux fcen df nfreq
		  (make flux-region
		    (center (- (* 0.5 sx) dpml 0.5) 0) (size 0 (* w 2)))))
      
      (run-sources+ (stop-when-fields-decayed 
		     50 Ey
		     (vector3 (- (* 0.5 sx) dpml 0.5) 0)
		     1e-3)
		    (at-beginning output-epsilon)
		    (during-sources
                     (in-volume (volume (center 0 0) (size sx 0))
                     (to-appended "hz-slice" (at-every 0.4 output-hfield-z)))))
      
      (display-fluxes trans) ; print out the flux spectrum
      ))
