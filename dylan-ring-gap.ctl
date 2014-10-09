; 2-d ring resonator modes with an air gap

; some preliminary definitions
(define split_right 0);
(define split_left 1); 
(define split_top 2);
(define split_bottom 3);

; user-defined stuff
(define-param split_loc split_top); 
(define-param n 3.4) ; index of waveguide
(define-param w 1) ; width of waveguide
(define-param r 2) ; inner radius of ring
(define-param fcen 0.25) ; center frequency
(define-param df 0.1) ; frequency spread
(define-param wlen (* 3 r)) ; wavelength
(define-param continuoussrc? false) ; continuous or gaussian source?

(define-param pad 2) ; padding between waveguide and edge of PML
(define-param dpml 1) ; thickness of PML

(define sxy (* 2 (+ r w pad dpml))) ; cell size
(set! geometry-lattice (make lattice (size sxy sxy no-size)))

; Create a ring waveguide by two overlapping cylinders - later objects
; take precedence over earlier objects, so we put the outer cylinder first.
; and the inner (air) cylinder second.
; then create the ring air gap
(set! geometry (list
		(make cylinder (center 0 0) (height infinity)
		      (radius (+ r w)) (material (make dielectric (index n))))
		(make cylinder (center 0 0) (height infinity)
		      (radius r) (material air))
		
		(if (equal? split_loc split_left)
		(make block (center (- 0 (+ r (/ w 2))) 0 ) (size (* 2 w) w infinity)
			(material air))
		
		)
		(if (equal? split_loc split_right)
		(make block (center (+ 0 (+ r (/ w 2))) 0 ) (size (* 2 w) w infinity)
                        (material air))
                
		)
		(if (equal? split_loc split_top)
                (make block (center 0  (+ 0 (+ r (/ w 2)))) (size (* 2 w) w infinity)
                        (material air))
                
		)
		(if (equal? split_loc split_bottom)
                (make block (center 0 (- 0 (+ r (/ w 2)))) (size (* 2 w) w infinity)
                        (material air))
                
		)
		)
)

(set! pml-layers (list (make pml (thickness dpml))))
(set-param! resolution 30)

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
