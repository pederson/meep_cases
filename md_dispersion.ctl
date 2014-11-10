(define-param resl 50) ;resolution of the simulation
(define-param sz 2); Size of the domain in z axis 
(define-param epsinf 1); High frequency dielectric of drude model
(define-param eps_d 1); Dielectric fo the surrounding medium
(define-param dpml 0.50) ; PML thickness 
(define-param fcen 0.25) ; central frequency of gaussian pulse, chossen such that it is between 0 and plasma frequency(=1)                    
(define-param df 4); bandwidth of the gaussian pulse.



; set the simulation domain, one dimension problem metal-dielectric interface along z axis
(set! geometry-lattice (make lattice (size no-size no-size (+ sz (* 2 dpml))))) 

; set the geometry of our structure, half is metal and half is dielectric.
(set! geometry
         (list 
         (make block (center 0 0 0) (size infinity infinity sz) ((material (make dielectric (epsilon 1)
         (E-susceptibilities 
         (make drude-susceptibility
         (frequency 1) (gamma 0) (sigma 1)))))))
         (make block (center 0 0 (* 0.25 sz)) (size infinity infinity (* 0.5 sz)) (material (make dielectric (epsilon eps_d)))) ; Dielectric
         )
)

; Sets the pml layers along z axis 
(set! pml-layers (list (make pml (direction Z) (thickness dpml))))

   
(set! sources 
  	(list
          (make source
     		(src (make gaussian-src (frequency fcen) (fwidth df))) (component Ez) (center 0 0 0)) ; polarization TM mode, Ez or Hy, some where in dielectric.
	     )
) 

(set! eps-averaging? false); disable sub-pixel averaging
(set! resolution resl) ;set the resolution of the simulation domain



;Applies Bloch-periodic boundary conditions along x axis
(define-param k-points 
	(list 
		(vector3 0 0 0)     ; Gamma
        	(vector3 2.0 0 0)   ; X # Dont forget ".0" decimal behind 2 so that scheme calculates arbitrary precision rather than fractions in the ouput
        )
)   

; define a series of k-points
(define-param k-interp 20) 
(set! k-points (interpolate k-interp k-points))

; calculates frequencies for these k-points
(run-k-points 300 k-points)
  

