; Dylan Pederson
; matrix of rods

; This is a test case for a wave incident perpendicularly on a periodic
; dielectric line of material

; Some parameters to describe the geometry:
(define-param eps 13) ; dielectric constant of rod
(define-param rrod 0.4) ; radius of rod
(define-param rodspace 1) ; center-to-center distance between rods
(define-param Nrows 10) ; number of rods in a column
(define-param wlen (* 2 rodspace)) ; wavelength of the source

; The computational cell dimensions
(define-param sy (+ (* Nrows rodspace) (* rrod))) ; size of cell in y dir
(define-param sx 20) ; size of cell in x dir
(define-param dpml 1) ; size of pml

; build the cell
(set! geometry-lattice (make lattice (size sx sy no-size)))

; build the geometry
(set! geometry
    (append

	   ;/----------------- column 1 -----------------------------------------
       (geometric-object-duplicates (vector3 0 rodspace 0) 0 (- Nrows 1) 
			(make cylinder (center (* rodspace 0) (+ (- 0 (/ sy 2)) rrod)) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))

		;/----------------- defect column low -----------------------------------
       (geometric-object-duplicates (vector3 0 rodspace 0) 0 (- (/ Nrows 2) 1) 
			(make cylinder (center (* rodspace 1) (+ (- 0 (/ sy 2)) rrod)) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))
		(geometric-object-duplicates (vector3 0 rodspace 0) 0 (- (/ Nrows 2) 2) 
			(make cylinder (center (* rodspace 1) (+ rodspace (/ rrod 2))) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))

		;/----------------- column 3 -----------------------------------------
       (geometric-object-duplicates (vector3 0 rodspace 0) 0 (- Nrows 1) 
			(make cylinder (center (* rodspace 2) (+ (- 0 (/ sy 2)) rrod)) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))

		;/----------------- double defect column -----------------------------
       (geometric-object-duplicates (vector3 0 rodspace 0) 0 (- (/ Nrows 2) 1) 
			(make cylinder (center (* rodspace 3) (+ (- 0 (/ sy 2)) rrod)) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))
		(list 
			(make cylinder (center (* rodspace 3) (+ (* 1 rodspace) (/ rrod 2))) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))
		(geometric-object-duplicates (vector3 0 rodspace 0) 0 1 
			(make cylinder (center (* rodspace 3) (+ (* 3 rodspace) (/ rrod 2))) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))

		;/----------------- column 5 -----------------------------------------
       (geometric-object-duplicates (vector3 0 rodspace 0) 0 (- Nrows 1) 
			(make cylinder (center (* rodspace 4) (+ (- 0 (/ sy 2)) rrod)) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))

		;/----------------- defect column high -----------------------------------
       (geometric-object-duplicates (vector3 0 rodspace 0) 0 (+ (/ Nrows 2) 1) 
			(make cylinder (center (* rodspace 5) (+ (- 0 (/ sy 2)) rrod)) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))
		(geometric-object-duplicates (vector3 0 rodspace 0) 0 (- (/ Nrows 2) 4) 
			(make cylinder (center (* rodspace 5) (+ (* 3 rodspace) (/ rrod 2))) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))

		;/----------------- column 7 -----------------------------------------
       (geometric-object-duplicates (vector3 0 rodspace 0) 0 (- Nrows 1) 
			(make cylinder (center (* rodspace 6) (+ (- 0 (/ sy 2)) rrod)) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))

		;/----------------- defect column high -----------------------------------
       (geometric-object-duplicates (vector3 0 rodspace 0) 0 (+ (/ Nrows 2) 1) 
			(make cylinder (center (* rodspace 7) (+ (- 0 (/ sy 2)) rrod)) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))
		(geometric-object-duplicates (vector3 0 rodspace 0) 0 (- (/ Nrows 2) 4) 
			(make cylinder (center (* rodspace 7) (+ (* 3 rodspace) (/ rrod 2))) (radius rrod) (height infinity) (material (make dielectric (epsilon eps)))))
			
			))

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