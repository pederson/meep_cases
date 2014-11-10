(define-param resl 20) ;resolution of the simulation
(define-param sz 8); Size of the domain in z axis 
(define-param sx 20) ; size of cell in x direction 
(define-param epsinf 1); High frequency dielectric of drude model
(define-param eps_d 1.001); Dielectric fo the surrounding medium
(define-param dpml 0.5) ; PML thickness 
(define-param fcen 0.666715342) ; central frequency of singlg frequency pulse, chossen such that it is between 0 and plasma frequency(=1)                    
(define-param df 0.0001); bandwidth of the gaussian pulse.


; ;defines metal with dielectric function that follows drude model with epsinf, omega_p=1, gamma=0
; (define mydrude_metal
; 	(make dielectric (epsilon epsinf)
; 		(polarizations (make polarizability (omega 1e-20) (gamma 0) (sigma 1e+40))	
; 		)
; 	)
; )

; set the simulation domain, one dimension problem metal-dielectric interface along z axis
(set! geometry-lattice (make lattice (size (+ sx (* 2 dpml)) no-size (+ sz (* 2 dpml))))) 

; set the geometry of our structure, half is metal and half is dielectric.
(set! geometry
         (list 
         (make block (center 0 0 0) (size sx infinity sz)
         (material (make dielectric (epsilon 1)
         (E-susceptibilities 
         (make drude-susceptibility
         (frequency 1) (gamma 0) (sigma 1))))))
         
         (make block (center 0 0 (* 0.25 sz)) (size sx infinity (* 0.5 sz)) 
         (material (make dielectric (epsilon 1)
         (E-susceptibilities 
         (make drude-susceptibility
         (frequency 1) (gamma 0) (sigma 1)))))) ; Dielectric
         )
)

(set! pml-layers (list 
			(make pml (direction Z) (thickness dpml))
			(make pml (direction X) (thickness dpml))
		)
)

   
(set! sources 
  	(list
          (make source
     		(src (make continuous-src (frequency fcen) (fwidth df))) (component Hy) 
        (center (* sx -0.375) 0 (/ sz 32))) ; polarization TM mode, Ez or Hy, some where in dielectric.
	     )
) 

; Define a monitor half the size
(define monitor-xz
	(volume 
	(center 0 0 0)(size (* 0.5 sx) 0 (* 0.75 sz))
	)
)

(set! resolution resl) ;set the resolution of the simulation domain

(run-until 250
           (at-beginning output-epsilon)
           (at-every 1 (output-png Hz "-Zc bluered")))

  

