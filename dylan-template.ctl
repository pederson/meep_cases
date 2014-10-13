; template for MEEP runs

;;;;;;;;;;;;;;;;; user-defined stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; simulation cell
(define-param xpad 3); extra space on the left and right sides
(define-param ypad 3); extra space on the top and bottom sides

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


;;;;;;;;;;;;;;;;;;;;; CELL BUILDING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This will depend on the specific geometry that you build
; but should be computable from the above user-defined items

(define sx (+ (* 2 (+ r w pad dpml)) 2)) ; cell size in x-direction
(define sy (+ (* 2 r))) ; cell size in y-direction

(set! geometry-lattice (make lattice (size sx sy no-size)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;; GEOMETRY BUILDING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Description can go here

; list of items
	(set! geometry (list
		(make cylinder (center 0 0) (height infinity)
		      (radius (+ r w)) (material (make dielectric (epsilon eps))))
		(make cylinder (center 0 0) (height infinity)
		)))
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
		

;;;;;;;;;;;;;;;;;;;;;;;;;; SPECIFY BOUNDARIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Perfectly Matched Layer (open boundary)
(set! pml-layers (list (make pml (thickness dpml))))

; absorber
;(set! pml-layers (list (make absorber (thickness dpml))))

(set-param! resolution res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 


;;;;;;;;;;;;;;;;;;;;;;;;; CURRENT SOURCES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If we don't want to excite a specific mode symmetry, we can just
; put a single point source at some arbitrary place, pointing in some
; arbitrary direction.  We will only look for TM modes (E out of the plane).


; set a continuous source
(set! sources (list
             (make source
               (src (make continuous-src (wavelength wlen) (width 20)))
               (component Ez) (center (+ 0.5 (/ sxy -2)) 0) (size 0 1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;; SYMMETRIES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; exploit the mirror symmetry in structure+source:
;(set! symmetries (list (make mirror-sym (direction Y))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; OUTPUT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;(run-until (/ 1 fcen) (at-every (/ 1 fcen 20) output-efield-z))


(run-until 200
	    (at-beginning output-epsilon)
	    (to-appended "ez" (at-every 0.3 output-efield-z)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
