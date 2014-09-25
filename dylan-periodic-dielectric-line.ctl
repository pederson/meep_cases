; Dylan Pederson
; line of a periodic dielectric material

; This is a test case for a wave incident perpendicularly on a periodic
; dielectric line of material

; Some parameters to describe the geometry:
(define-param eps1 13) ; dielectric constant of material 1
(define-param eps2 5) ; dielectric constant of material 2
(define-param w 1.2) ; width of line
(define-param sz1 2) ; size of eps1 segments
(define-param sz2 2) ; size of eps2 segments
(define-param Nseg 8) ; number of each segment (2*N total segments)
(define-param wlen sz1) ; wavelength of the source

; The computational cell dimensions
(define-param sy (+ (* Nseg sz1) (* Nseg sz2))) ; size of cell in y direction (parallel to dielectric strip)
(define-param sx 16) ; size of cell in x direction (perp to dielectric strip)
(define-param dpml 1) ; size of pml

; build the cell
(set! geometry-lattice (make lattice (size sx sy no-size)))

; build the geometry
(set! geometry
    (append
    	; dielectric 1
       (geometric-object-duplicates (vector3 0 (+ sz1 sz2) 0) 0 (- Nseg 1) 
			(make block (center 0 (+ (- 0 (/ sy 2)) (/ sz1 2))) (size w sz1 infinity) (material (make dielectric (epsilon eps1)))))
		; dielectric 2
       (geometric-object-duplicates (vector3 0 (+ sz1 sz2) 0) 0 (- Nseg 1) 
			(make block (center 0 (+ (- 0 (/ sy 2)) (/ sz2 2) sz1)) (size w sz2 infinity) (material (make dielectric (epsilon eps2)))))))

; set perfectly matched layer
(set! pml-layers (list (make pml (thickness dpml))))

; set resolution (pixels per unit distance)
(set-param! resolution 10)

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
	    (to-appended "ez" (at-every 0.6 output-efield-z)))
   
