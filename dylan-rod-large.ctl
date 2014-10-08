; Dylan Pederson
; matrix of rods

; This is a test case for a wave incident perpendicularly on a periodic
; dielectric line of material

; Some parameters to describe the geometry:
(define-param eps 6) ; dielectric constant of rod
(define-param rrod 5) ; radius of rod
(define-param rodspace 3) ; center-to-center distance between rods
(define-param Nrows 1) ; number of rods in a column
(define-param wlen 2) ; wavelength of the source

; The computational cell dimensions
(define-param sy (+ (* Nrows rodspace) (* rrod 2))) ; size of cell in y dir
(define-param sx 20) ; size of cell in x dir
(define-param dpml 1) ; size of pml

; build the cell
(set! geometry-lattice (make lattice (size sx sy no-size)))

; build the geometry
(set! geometry
    (append

	   ;/----------------- column 1 -----------------------------------------
       (geometric-object-duplicates (vector3 0 rodspace 0) 0 (- Nrows 1) 
			(make cylinder (center (* rodspace 0) 0) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))

			))

; set perfectly matched layer
(set! pml-layers (list (make pml (thickness dpml))))

; set resolution (pixels per unit distance)
(set-param! resolution 20)

; define parameters related to the input pulse
(define-param freq 0.25) ; pulse center frequency
;(define-param df 0.2)  ; pulse width (in frequency) 

;(define-param nfreq 500) ; number of frequencies at which to compute flux


; set a continuous source
(set! sources (list
	     (make source
	       (src (make continuous-src (wavelength wlen) (width 20)))
	       (component Ez) (center (+ 0.5 (/ sx -2)) 0) (size 0 1))))

;(set! symmetries
;    (list (make mirror-sym (direction Y) (phase -1))
;	  (make mirror-sym (direction X) (phase -1))))

(run-until 200
	    (at-beginning output-epsilon)
	    (to-appended "ez" (at-every 0.3 output-efield-z)))
