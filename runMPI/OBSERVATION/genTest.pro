@../../IDL_routines/gen_netcdf
pro test
	dat = ddread('prominence_ApJ_642_554.prof',offset=1,/count,/double)
	dat = congrid(dat,9,100)
	
	nlambda = n_elements(dat[0,*])
	npixel = 4
	map = dblarr(npixel,8,nlambda)
	lambda = reform(dat[0,*])
	for i = 0, npixel-1 do begin
		map[i,*,*] = dat[1:*,*]
	endfor
	
	mu = [1.d0, 0.3d0, 1.d0, 0.3d0]
	obs_theta = acos(mu) * 180.d0 / !DPI
 	boundary = dblarr(npixel,4)
 	boundary[0,*] = i0_allen(10830.d0, mu)
 	height = [3.d0, 5.d0, 3.d0, 5.d0]
 	obs_gamma = replicate(90.d0,npixel)
	mask = replicate(1.d0,2,2)

; Initial parameters, depending on the radiative transfer option:
; 1-component (vector of size 8): B, thetaB, chiB, tau, vdop, a, vmac, beta
; 2-component 1+1 with same field (vector of size 11): B, thetaB, chiB, tau1, tau2, vdop, a, vmac1, vmac2, beta, beta2
; 2-component 1+1 with different field (vector of size 15): B1, thetaB1, chiB1, B2, thetaB2, chiB2, tau1, tau2, vdop1, vdop2, a, vmac1, vmac2, beta, beta2
; 2-component 2 with different field with ff (vector of size 16): B1, thetaB1, chiB1, B2, thetaB2, chiB2, tau1, tau2, vdop1, vdop2, a, vmac1, vmac2, ff, beta, beta2

	pars = dblarr(8,npixel)
	
; B
	pars[0,*] = [10.d0, 10.d0, 20.d0, 30.d0]

; thB
	pars[1,*] = replicate(0.d0,npixel)

; chiB
	pars[2,*] = replicate(0.d0,npixel)

; tau
	pars[3,*] = replicate(1.d0,npixel)

; vdop
	pars[4,*] = replicate(6.d0,npixel)

; damp
	pars[5,*] = replicate(0.2d0,npixel)

; vmac
	pars[6,*] = replicate(0.d0,npixel)
	
; beta
	pars[7,*] = replicate(1.d0,npixel)

	normalization = 'continuum'
 	
	gen_netcdf, lambda, reform(map[*,0,*]), reform(map[*,1,*]), reform(map[*,2,*]), reform(map[*,3,*]), $
		reform(map[*,4,*]), reform(map[*,5,*]), reform(map[*,6,*]), reform(map[*,7,*]), boundary,$
		height, obs_theta, obs_gamma, mask, pars, normalization, 'test.nc'
	stop
end

pro test2
	dat = ddread('emission2.prof',offset=1,/count,/double)
	
	nlambda = n_elements(dat[0,*])
	npixel = 2
	map = replicate(1.0 / sqrt(1000.), npixel,8,nlambda)	
	lambda = reform(dat[0,*])
	for i = 0, npixel-1 do begin
		map[i,0:3,*] = dat[1:4,*]
	endfor	
	
	mu = [1.d0, 1.d0]
	obs_theta = acos(mu) * 180.d0 / !DPI
 	boundary = dblarr(npixel,4)
 	boundary[*,0] = i0_allen(10830.d0, mu)
 	height = [3.d0, 5.d0]
 	obs_gamma = replicate(90.d0,npixel)
	mask = replicate(1.d0,2,2)

; Initial parameters, depending on the radiative transfer option:
; 1-component (vector of size 8): B, thetaB, chiB, tau, vdop, a, vmac, beta
; 2-component 1+1 with same field (vector of size 11): B, thetaB, chiB, tau1, tau2, vdop, a, vmac1, vmac2, beta, beta2
; 2-component 1+1 with different field (vector of size 15): B1, thetaB1, chiB1, B2, thetaB2, chiB2, tau1, tau2, vdop1, vdop2, a, vmac1, vmac2, beta, beta2
; 2-component 2 with different field with ff (vector of size 16): B1, thetaB1, chiB1, B2, thetaB2, chiB2, tau1, tau2, vdop1, vdop2, a, vmac1, vmac2, ff, beta, beta2

	pars = dblarr(15,npixel)
	
; B1
	pars[0,*] = [0.d0, 0.d0]

; thB1
	pars[1,*] = replicate(0.d0,npixel)

; chiB1
	pars[2,*] = replicate(0.d0,npixel)

; B2
	pars[3,*] = [0.d0, 0.d0]

; thB2
	pars[4,*] = replicate(0.d0,npixel)

; chiB2
	pars[5,*] = replicate(0.d0,npixel)

; tau1
	pars[6,*] = replicate(1.d0,npixel)

; tau2
	pars[7,*] = replicate(1.d0,npixel)

; vdop1
	pars[8,*] = replicate(6.d0,npixel)

; vdop2
	pars[9,*] = replicate(12.d0,npixel)

; damp
	pars[10,*] = replicate(0.d0,npixel)

; vmac1
	pars[11,*] = replicate(0.d0,npixel)

; vmac2
	pars[12,*] = replicate(0.d0,npixel)
	
; beta1
	pars[13,*] = replicate(1.d0,npixel)

; beta2
	pars[14,*] = replicate(1.d0,npixel)

	normalization = 'continuum'
 	
	gen_netcdf, lambda, reform(map[*,0,*]), reform(map[*,1,*]), reform(map[*,2,*]), reform(map[*,3,*]), $
		reform(map[*,4,*]), reform(map[*,5,*]), reform(map[*,6,*]), reform(map[*,7,*]), boundary,$
		height, obs_theta, obs_gamma, mask, pars, normalization, 'testEmission.nc'
	stop
end