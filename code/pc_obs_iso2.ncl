; ==============================================================
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

 begin
  
   
   diri1="./"
   diri2="./"
   diri3="./"
   
   var1="olr"
   var2="u"
   var3="u"
   
   file1="olr.day.1979-2022.15s15n.iso.new.nc"
   file2="u850_obs_iso_eq_new.nc"
   file3="u200_obs_iso_eq_new.nc"
   
   f1=addfile(diri1+file1, "r")
   f2=addfile(diri2+file2, "r")
   f3=addfile(diri3+file3, "r")
   
   x1=f1->$var1$
   x2=f2->$var2$
   x3=f3->$var3$
   
   time=f1->time
   
   dims=dimsizes(x1)
   
   print(dims)
   ;exit
   
   ;print(x2(365,:))
   ;exit
   
   ;printVarSummary(x1)
  ; printVarSummary(x2)
  ; printVarSummary(x3)
   ;exit
   
   nt=dims(0)
   nlon=dims(1)
   
   ;x1=dim_rmvmean_n(x1,0)
   ;x2=dim_rmvmean_n(x2,0)
   ;x3=dim_rmvmean_n(x3,0)
   
   x=new((/nt,3,nlon/),"float")
   
   nn=10099
   
   std1=sqrt(avg(dim_variance_n(x1,0)));14.89886
   std2=sqrt(avg(dim_variance_n(x2,0)));1.686287
   std3=sqrt(avg(dim_variance_n(x3,0)));5.169846
   
   
   print(std1)
   print(std2)
   print(std3)
   
   x(:,0,:)=x1/std1
   x(:,1,:)=x2/std2
   x(:,2,:)=x3/std3
   
   ;printVarSummary(x)
   ;exit
   
   ;print(x(100,:,:))
   ;exit
      
   ;eof1=asciiread("eof1.txt",(/3,nlon/),"float")
   ;eof2=asciiread("eof2.txt",(/3,nlon/),"float")
   
   ;pc1=new((/nt/),"float")
   ;pc2=new((/nt/),"float")
   
   ;do i=0,nt-1
   ; pc1(i)=sum(x(i,:,:)*eof1)
   ; pc2(i)=sum(x(i,:,:)*eof2)
   ;end do
   
   ;=========
   
   x!0="time"
   x!1="var"
   x!2="lon"
  
   neof   = 6        ; number of EOFs
   optEOF = True       
   optEOF@jopt = 0   ; This is the default; most commonly used; no need to specify.
  
   optETS = False
  
   eof    = eofunc_n_Wrap(x(0:nn,:,:), neof, optEOF, 0)
   
   eof(0,:,:)=eof(0,:,:);*-1.0
   eof(1,:,:)=eof(1,:,:)*-1.0
   
   eof_ts = eofunc_ts_n_Wrap (x(:,:,:), eof, optETS, 0)
  
   printVarSummary( eof )      
   printVarSummary( eof_ts )
  
  ;
  ;print(eof(0,:,:))
  
  
  
   print(avg(eof_ts(0,:)))
   print(avg(eof_ts(1,:)))
   
   
   pc1=(eof_ts(0,:)+eof_ts@ts_mean(0))/stddev(eof_ts(0,0:nn))
   ;pc2=(eof_ts(1,:)+eof_ts@ts_mean(1))/stddev(eof_ts(1,:))
   pc2=(eof_ts(1,:)+eof_ts@ts_mean(1))/stddev(eof_ts(0,0:nn))
   
   print(stddev(eof_ts(0,0:nn)))
   print(stddev(eof_ts(1,0:nn)))
   
   print(avg(pc1(:)))
   print(avg(pc2(:)))
   
   print(eof_ts@ts_mean(0))
   print(eof_ts@ts_mean(1))
   
   
   print(stddev(pc1(:)))
   print(stddev(pc2(:)))
   
   
   ;pc2=pc2*-1.0
   ;exit
   
   
   ;system("rm eof1.txt")
   ;system("rm eof2.txt")
  
   ;asciiwrite("eof1.txt",eof(0,:,:))
   ;asciiwrite("eof2.txt",eof(1,:,:))
   
   ;==================
   pc1!0="time"
   ;pc1!1="lat"
   ;pc1!2="lon"
   pc1&time=time
   ;pc1&lat=0.0
   ;pc1&lon=0.0
   
   copy_VarCoords(pc1,pc2)
   
   filo1="pc1_obs_iso_new2.nc"
   filo2="pc2_obs_iso_new2.nc"
   
   diro1="./"
   diro2="./"
   
   system("rm "+diro1+filo1)
   system("rm "+diro2+filo2)
   
   var_o="pc"
   
   fo1 = addfile(diro1+filo1,"c")
   fo1->$var_o$ = pc1
   
   fo2 = addfile(diro2+filo2,"c")
   fo2->$var_o$ = pc2
  
   ;print(pc1(365:415))
   
   ;system("rm pc1_obs.txt")
   ;system("rm pc2_obs.txt")
   
   
   ;asciiwrite("pc1_obs.txt",pc1)
   ;asciiwrite("pc2_obs.txt",pc2)
   
   
   ;==============
   ;phase
   dim_pc=dimsizes(pc1)
   phase=new((/dim_pc/),"integer")
   
   do i=100,dim_pc-101
   	if(pc1(i).ge.0.0)then
   		if(pc2(i).ge.0.0)then
   			if(pc2(i).ge.pc1(i))then
   				phase(i)=4
   			else
   				phase(i)=3
   			end if
   		else
   			if(abs(pc2(i)).ge.pc1(i))then
   				phase(i)=1
   			else
   				phase(i)=2
   			end if
   		end if
   	else
   		if(pc2(i).ge.0.0)then
   			if(pc2(i).ge.abs(pc1(i)))then
   				phase(i)=5
   			else
   				phase(i)=6
   			end if
   		else
   			if(abs(pc2(i)).ge.abs(pc1(i)))then
   				phase(i)=8
   			else
   				phase(i)=7
   			end if
   		
   		end if
   	end if
   	
   end do
   
   
   phase!0="time"
   phase&time=time
   
   filo3="phase_obs_iso_new2.nc"
   
   diro3="./"
   
   system("rm "+diro3+filo3)
   
   var_o="p"
   
   fo1 = addfile(diro3+filo3,"c")
   fo1->$var_o$ = phase
   
   
   filo4="amp_obs_iso_new2.nc"
   amp=sqrt(pc1^2+pc2^2)
   var_o="a"
   diro4="./"
   
   system("rm "+diro4+filo4)
   fo1 = addfile(diro4+filo4,"c")
   fo1->$var_o$ = amp
   ;============
   
   lon=fspan(0,357.5,nlon)
 
  

   lon@long_name="longitude"
   lon@units="degrees_east"
  
   ;eof(0,:,:)=eof(0,:,:);*eof@eval(0)
   ;eof(1,:,:)=eof(1,:,:);*eof@eval(1)
   
   ;=======
  wks   = gsn_open_wks ("pdf","eof_spatial_iso_new_partial")                 ; send graphics to PNG file

;---Set plotting parameters

 res                   = True                      ; plot mods desired
 res@gsnDraw  = False                          ; don't draw
 res@gsnFrame = False
 res@xyLineThicknesses = (/  3.0,   3.0, 3.0/)          ; make second line thicker
 res@xyLineColors      = (/"green","red", "blue"/)          ; change line color
 res@xyDashPattern      = 1 
 res@vpWidthF    = 0.6
 res@vpHeightF   = 0.3
 
 res@trXMaxF = 360
 res@trXMinF = 0
 
 res@trYMaxF = 0.2
 res@trYMinF = -0.2
 
 plot=new(2,graphic)
 
  
 res@pmLegendDisplayMode    = "Always"   ; Display a legend.
  res@lgPerimOn              = False      ; No legend perimeter.
  ;res@pmLegendOrthogonalPosF = -0.2      ; Move closer to plot
 res@xyExplicitLegendLabels = (/"olr","u850","u200"/)
  res@lgItemOrder  = (/ 2,1,0 /)   ; Reorder the legends
  res@pmLegendSide           = "Top"               ; Change location of 
  res@pmLegendParallelPosF   = .8                  ; move units right
  res@pmLegendOrthogonalPosF = -0.5                ; move units down
  
  res@pmLegendWidthF = 0.15
  res@pmLegendHeightF = 0.12

 res@gsnLeftString = "(a) EOF1"
 plot(0)  = gsn_csm_xy (wks,lon,eof(0,:,:),res) ; create plot
 
 
  res@pmLegendDisplayMode    = "Never"   ; Display a legend.
  
 res@gsnLeftString = "(b) EOF2"
 plot(1)  = gsn_csm_xy (wks,lon,eof(1,:,:),res) ; create plot
 
 gsn_panel(wks,plot(:),(/2,1/),False)
 exit
 end