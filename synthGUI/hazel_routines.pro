function set_imaginary, A, b
	return, complex(float(A),b)
end

function set_real, A, b
	return, complex(b,imaginary(A))
end

;-----------------------------------------
; Write two files containing the rho^K_Q on the vertical and the magnetic
; reference frame
;-----------------------------------------
pro rotate_refsystem, file

	thb = 10.d0 * !DPI / 180.d0
	chb = 90.d0 * !DPI / 180.d0
	n = 1
	
	openw,2,'tanti_vertical.res',width=132
	openw,3,'tanti_magnetic.res',width=132
	
	a = ddread(file,/noverb)
	ind_term = uniq(a[1,*])
	nterm = n_elements(ind_term)
	
	for term = 0, nterm-1 do begin
		ind = where(a[1,*] eq a[1,ind_term[term]])
		nrhos = n_elements(ind)
		J2max = max([a[2,ind],a[3,ind]])
		J2min = min([a[2,ind],a[3,ind]])		
		kmax = max(a[4,ind])
		kmin = min(a[4,ind])
		qmax = max(a[5,ind])
		rho = complexarr(J2max+1,J2max+1,kmax+1,2*qmax+1)
		for i = 0, nrhos-1 do begin
			loc = ind[i]
			J2tab = a[2,loc]
			J2ptab = a[3,loc]
			ktab = a[4,loc]
			qtab = qmax+a[5,loc]
			irtab = a[6,loc]
			if (irtab eq 1) then begin
				rho[J2tab,J2ptab,ktab,qtab] = set_real(rho[J2tab,J2ptab,ktab,qtab], a[7,loc])
			endif else begin
				rho[J2tab,J2ptab,ktab,qtab] = set_imaginary(rho[J2tab,J2ptab,ktab,qtab], a[7,loc])
			endelse
			if (J2tab eq J2ptab) then begin
				if (qtab eq 0) then begin
					rho[J2tab,J2ptab,ktab,qtab] = set_imaginary(rho[J2tab,J2ptab,ktab,qtab], 0.d0)
				endif else begin
					sign = 1.d0
					if (a[5,loc] mod 2 ne 0) then sign = -1.d0
					if (irtab eq 1) then begin
						rho[J2tab,J2ptab,ktab,qmax-a[5,loc]] = $
							set_real( rho[J2tab,J2ptab,ktab,qmax-a[5,loc]], sign*a[7,loc])
					endif else begin
						rho[J2tab,J2ptab,ktab,qmax-a[5,loc]] = $
							set_imaginary(rho[J2tab,J2ptab,ktab,qmax-a[5,loc]], -sign*a[7,loc])
					endelse
				endelse
			endif else begin
				sign = 1.d0
				if ((J2tab-J2ptab-2*a[5,loc]) mod 4 ne 0) then sign = -1.d0
				if (irtab eq 1) then begin
					rho[J2ptab,J2tab,ktab,qmax-a[5,loc]] = $
						set_real(rho[J2ptab,J2tab,ktab,qmax-a[5,loc]], sign*a[7,loc])
				endif else begin
					rho[J2ptab,J2tab,ktab,qmax-a[5,loc]] = $
						set_imaginary(rho[J2ptab,J2tab,ktab,qmax-a[5,loc]], -sign*a[7,loc])
				endelse
			endelse
		endfor
		
; Write rho^K_Q and also write those transformed to the magnetic field
; reference system		
		for j2 = J2min, J2max, 2 do begin
			for jp2 = J2min, J2max, 2 do begin
				kmin = abs(jp2-j2)/2
				kmax = (jp2+j2) / 2
				for k = kmin, kmax do begin
					for q = -k, k do begin
						suma = 0.d0
						for qp = -k, k do begin
							suma = suma + rho[j2,jp2,k,qp+qmax] * $
								rot_matrix(k, q, qp, 0.d0, -thb, -chb)
						endfor
						
						printf,2,FORMAT='(I4,2X,I2,2X,4(1X,I3),2(1x,e15.7))',n,term+1,j2, jp2, k, q,$
							float(rho[j2,jp2,k,q+qmax]), imaginary(rho[j2,jp2,k,q+qmax])
						printf,3,FORMAT='(I4,2X,I2,2X,4(1X,I3),2(1x,e15.7))',n,term+1,j2, jp2, k, q,$
							float(suma), imaginary(suma)
						n = n + 1
					endfor
				endfor
			endfor
		endfor 
		
	endfor
	
	close,2
	close,3	
end

;-----------------------------------------
; Return the wavelength of the multiplet
;-----------------------------------------
function wavelength_atom_multiplet, file_with_atom, multiplet	
	openr,2,file_with_atom
	readf,2,I2
	readf,2,nlev
	str = ''
	for i = 0, nlev-1 do begin
		readf,2,ind,J2
		fmax = (J2+I2)
		fmin = abs(J2-I2)
		nf = fix((fmax-fmin)/2) + 1		
		for j = 0, nf-1 do readf,2,str		
	endfor
	readf,2,ntran
	for i = 0, multiplet-2 do readf,2,str
	lambda = 0.d0
	readf,2,ind,up,low,aul,lambda,fac1,fac2,fac3
	close,2
	return,lambda
end

;-----------------------------------------
; Change the value of the factors nbar, omega and J10/J00 in a given file
;-----------------------------------------
pro change_factors, file_with_atom, fac_nbar, fac_omega, j10
	line = ''
	nlines = 0
	openr,2,file_with_atom
	while (not eof(2)) do begin
		readf,2,line
		nlines = nlines + 1
	endwhile
	close,2
	
	lines = strarr(nlines)
	openr,2,file_with_atom
	tmp = ''
	for i = 0, nlines-1 do begin	 	  
		readf,2,tmp
		lines[i] = tmp
	endfor
	close,2
	
	k = 1
	openr,2,file_with_atom
	readf,2,I2
	readf,2,nlev
	str = ''
	for i = 0, nlev-1 do begin
		readf,2,ind,J2
		k = k + 1
		fmax = (J2+I2)
		fmin = abs(J2-I2)
		nf = fix((fmax-fmin)/2) + 1		
		for j = 0, nf-1 do begin
			readf,2,str
			k = k + 1
		endfor
	endfor
	
	readf,2,ntran
	k = k + 1
		
	for i = 0, 0 do begin
		line = strsplit(lines[k+i+1],/extract)
		line[5] = strtrim(string(fac_nbar),2)
		line[6] = strtrim(string(fac_omega),2)
		line[7] = strtrim(string(j10),2)		
		lines[k+i+1] = strjoin(line,'    ')
	endfor
	close,2
	
	openw,2,file_with_atom
	for i = 0, nlines-1 do begin
		printf,2,lines[i]
	endfor
	close,2		
end

function return_i0_allen, state

; Multiterm code
	 if (state.which_code eq 0) then begin
	 
; He I
	 	if (state.which_atom eq 0) then begin
	 	   file_with_atom = 'ATOMS/helium.mod'
	 	endif	 
	 
; S I
	 	if (state.which_atom eq 1) then begin
	 	  	file_with_atom = 'ATOMS/sulfur.mod'
	 	endif
	 
; Na I
	 	if (state.which_atom eq 2) then begin
	 	   file_with_atom = 'ATOMS/sodium.mod'
	 	endif
	 endif
	 
; Multilevel with HFS
	 if (state.which_code eq 1) then begin
	 
; Na I HFS
	 	if (state.which_atom eq 0) then begin
	 	  	file_with_atom = 'ATOMS/sodium_hfs.mod'
	 	endif
	 endif
	 	 	 	 
	 wl = wavelength_atom_multiplet(file_with_atom,state.Multiplet)
	 
	 mu = cos(state.thetaObs * !DPI / 180.d0)
	 ic = ddread('CLV/ic.dat',/noverb)
	 cl = ddread('CLV/cl.dat',/noverb)
	 PC = 2.99792458d10
	 PH = 6.62606876d-27
	 
; Wavelength in A	 
	 ic(0,*) = 1.d4 * ic(0,*)	 
; I_lambda to I_nu	 
	 ic(1,*) = 1.d14 * ic(1,*) * (ic(0,*)*1.d-8)^2 / PC
	 
	 cl(0,*) = 1.d4 * cl(0,*)
	 
	 u = interpol(cl(1,*),cl(0,*),wl)
	 v = interpol(cl(2,*),cl(0,*),wl)
	 
	 imu = 1.d0 - u - v + u * mu + v * mu^2
	 i0 = interpol(ic(1,*),ic(0,*),wl)
	 	 
	 return, i0*imu
end