; 2-d array of split ring resonators

; some preliminary definitions
(define split_right 0);
(define split_left 1); 
(define split_top 2);
(define split_bottom 3);

;;;;;;;;;;;;;;;;; user-defined stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; geometry
(define-param nrows 2); number of rows
(define-param ncols 2); number of columns
(define-param split_loc split_bottom); 
(define-param eps 100) ; dielectric of waveguide
(define-param w 1) ; width of waveguide
(define-param r 2) ; inner radius of ring
(define-param res 10) ; grid points per unit length
(define-param pad 2) ; padding between waveguide and edge of PML
(define-param dpml 1) ; thickness of PML

; for continuous source
(define-param wlen (* 5 r)) ; wavelength

; for gaussian pulse
(define-param fcen 0.25) ; center frequency
(define-param df 0.1) ; frequency spread
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define sxy (+ (* 2 (+ r w pad dpml)) 2)) ; cell size
(set! geometry-lattice (make lattice (size (* 2 ncols sxy) (* 2 nrows sxy) no-size)))

; Create a ring waveguide by two overlapping cylinders - later objects
; take precedence over earlier objects, so we put the outer cylinder first.
; and the inner (air) cylinder second.
; then create the ring air gap
(if (= split_loc split_left)
	(set! geometry (list
		(make cylinder (center 0 0) (height infinity)
		      (radius (+ r w)) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		      (radius r) (material air))
		(make block (center (- 0 (+ r (/ w 2))) 0 ) (size (* 2 w) w infinity) (material air))
		

		(make cylinder (center 0 0) (height infinity)
		      (radius (- r (/ w 4))) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		      (radius (- r (* 5 (/ w 4)))) (material air))
		(make block (center (+ 0 (- r (* 3 (/ w 4)))) 0) (size w (* 1  w) infinity)
                      (material air))
		)
	)
)
(if (= split_loc split_right)
	(set! geometry (list
		(make cylinder (center 0 0) (height infinity)
		      (radius (+ r w)) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		      (radius r) (material air))
		(make block (center (+ 0 (+ r (/ w 2))) 0 ) (size (* 2 w) w infinity)
                      (material air))
		

		(make cylinder (center 0 0) (height infinity)
		      (radius (- r (/ w 4))) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		      (radius (- r (* 5 (/ w 4)))) (material air))
		(make block (center (- 0 (- r (* 3 (/ w 4)))) 0) (size w (* 1  w) infinity)
			(material air))
		)
	)
)
(if (= split_loc split_top)
	(set! geometry (list
		(make cylinder (center 0 0) (height infinity)
		      (radius (+ r w)) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		      (radius r) (material air))
		(make block (center 0  (+ 0 (+ r (/ w 2)))) (size w (* 2 w) infinity)
                      (material air))
		

		(make cylinder (center 0 0) (height infinity)
		      (radius (- r (/ w 4))) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		      (radius (- r (* 5 (/ w 4)))) (material air))
		(make block (center 0 (- 0 (- r (* 3 (/ w 4))))) (size w (* 1.1  w) infinity)
                      (material air))
		)
	)
)
(if (= split_loc split_bottom)
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
