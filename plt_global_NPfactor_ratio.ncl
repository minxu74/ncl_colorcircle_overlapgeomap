load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  ; read csv file
  print ("read csv")
  str_array = asciiread("new.dat", -1, "string")
  temp = dimsizes(str_split_csv(str_array(0), ",", 0))
  ncols = temp(1)
  nrows = dimsizes(str_array)

  print (nrows)
  print (ncols)
  print (str_array(0))
  print (str_split_csv(str_array(0), ",", 0))
  array_2d = onedtond(asciiread("new.dat", -1, "float"), (/nrows, ncols/))
  slon = array_2d(:, 0)
  slat = array_2d(:, 1)
  sval = array_2d(:, 2)

  print (slat)

  CasNam1= "/compyfs/yang954/e3sm_scratch/20190912_hcru_hcru_ICB20TRCNPRDCTCBC/run/20190912_hcru_hcru_ICB20TRCNPRDCTCBC.clm2.h0."

  AvgVars = (/"TOTVEGP","FPG","FPG_P","TOTSOMP","TOTECOSYSP"/)
;  AvgScal = (/ 1., 1., 1.,1.,1.,1./)
;  AvgOffs = (/ 0., 0., 0.,0.,0.,0./)

;  AvgMaxs = (/ 1., 1., 1.,60000.,15000.,75000./)
;  AvgMins = (/ 0., 0., 0.,0.,0.,0./)
;  AvgIncs = (/ .1, .1, .1,5000.,5000.,5000./)

  SumVars = (/"GPP", "AR","NPP","GROSS_PMIN","NET_PMIN"/)
  SumScal = (/86400., 86400.,86400.,86400.,86400./)
  SumOffs = (/ 0., 0.,0.,0.,0./)
  SumMaxs = (/5200., 3000., 2400.,10.,5./)
  SumMins = (/   0.,    0.,    0.,0., 0./)
  SumIncs = (/ 400.,  200.,  200.,1.,0.5/)

  SdfMaxs = (/ 500.,  300.,  200.,5.,5./)
  SdfMins = (/-500., -300., -200.,-5.,-5./) 
  SdfIncs = (/ 100.,   50.,   20., 0.5,0.5/)

;  landpts = 4530

  BgnYear = 2000
  EndYear = 2009
; for CLM model each month is fixed for all years
  dayinmonth = (/31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/)


  BgnMonth = 1
  EndMonth = 12


  do iy = BgnYear, EndYear

     print (iy)
     cy = sprinti("%04d", iy)
     do im = BgnMonth, EndMonth
        print(im)
        cm = sprinti("%02d", im)
        f = addfile(CasNam1 + cy + "-" + cm + ".nc", "r")

        xo = f->lon
        yo = f->lat
        nx = dimsizes(f->lon)
        ny = dimsizes(f->lat)
        ns = dimsizes(SumVars)
        na = dimsizes(AvgVars)

        if(iy .eq. BgnYear .and. im .eq. BgnMonth) then

           svars_y1 = new((/ns, ny, nx/), typeof(f->$SumVars(0)$))
           avars_y1 = new((/na, ny, nx/), typeof(f->$AvgVars(0)$))

           do iv = 0, ns - 1
              svars_y1(iv,:,:) = f->$SumVars(iv)$(0,:,:)
           end do

           do iv = 0, na - 1
              avars_y1(iv,:,:) = f->$AvgVars(iv)$(0,:,:)
           end do
        else
           do iv = 0, ns - 1
              svars_y1(iv,:,:) = ( f->$SumVars(iv)$(0,:,:) * SumScal(iv)*dayinmonth(im-1) + svars_y1(iv,:,:) )
           end do

           do iv = 0, na - 1
              avars_y1(iv,:,:) = f->$AvgVars(iv)$(0,:,:) + avars_y1(iv,:,:)
           end do
        end if

;        delete(f)
     end do
  end do 

  do iv = 0, na - 1
     avars_y1(iv,:,:) = avars_y1(iv,:,:) / ((EndYear - BgnYear + 1) * (EndMonth - BgnMonth + 1))
  end do 

  svars_y2 = svars_y1
  avars_y2 = avars_y1

  svars_yd = svars_y2 - svars_y1
  avars_yd = avars_y2 - avars_y1

  print(AvgVars(1))
  print(AvgVars(2))

  avars_y1=where(avars_y1.ne.0,avars_y1,avars_y1@_FillValue)
  z0 = avars_y2(2,:,:)/avars_y1(1,:,:)
 

;  z0 = where(avars_y1(1,:,:) .lt. avars_y2(2,:,:), avars_y1(1,:,:)-1, 1-avars_y1(2,:,:))
;  z0 = avars_y1(1,:,:)
  z0!0   = "lat"      ; name the dimension
  z0!1   = "lon"      ; name the dimension
  z0&lat = f->lat
  z0&lon = f->lon


   ;sz0 = sval

   ;slat@_FillValue = -9999.
   ;slon@_FillValue = -9999.

   ;xlat = slat
   ;xlon = xlon

   ;slat  = where((sval .gt. 0.16 .and. sz0 .gt. 1) .or. (sval .lt. -0.16 .and. sz0 .lt. 1), slat, slat_FillValue)
   ;slon  = where((sval .gt. 0.16 .and. sz0 .gt. 1) .or. (sval .lt. -0.16 .and. sz0 .lt. 1), slon, slon_FillValue)

   ;xlat  = where(.not. (sval .gt. 0.16 .and. sz0 .gt. 1) .and. .not. (sval .lt. -0.16 .and. sz0 .lt. 1), slat, slat_FillValue)
   ;xlon  = where(.not. (sval .gt. 0.16 .and. sz0 .gt. 1) .and. .not. (sval .lt. -0.16 .and. sz0 .lt. 1), slon, slon_FillValue)


   print ((/nrows, ncols/))

   print (slat)


  ; plotting

  wks = gsn_open_wks("ps","NPfactor_ratio")
  ;gsn_define_colormap(wks,"WhViBlGrYeOrRe")
  ;gsn_reverse_colormap(wks)
  gsn_merge_colormaps(wks,"WhViBlGrYeOrRe","BlWhRe")
  gsn_define_colormap(wks,"BlueDarkRed18")

  cmap = read_colormap_file("BlueDarkRed18")


  res                             = True
  res@gsnMaximize                 = True
  res@gsnDraw                     = False
  res@gsnFrame                    = False


  res@gsnSpreadColors             = True

  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = 0.6        	; 15.25
  res@cnMaxLevelValF              = 1.5         ; 49.75
  res@cnLevelSpacingF             = 0.1

  res@cnFillOn                    = True
  res@cnLinesOn                   = False

;  res@sfXArray                    = f->lon
;  res@sfYArray                    = f->lat

  res@mpFillOn                    = False
  res@mpOutlineBoundarySets       = "National"
  res@mpOutlineDrawOrder          = "PostDraw"
  res@mpFillDrawOrder             = "PreDraw"

;  res@sfXArray                    = xo
;  res@sfYArray                    = yo


     res@gsnSpreadColorStart                       = 2         ; start at 4
     res@gsnSpreadColorEnd                         = 19       ; end at 15


   levels = (/0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5/)
     plot       = gsn_csm_contour_map(wks, z0, res)

     mkres = True

     mkid = new(dimsizes(slon), graphic)
     ckid = new(dimsizes(slon), graphic)
     do i = 0, dimsizes(slon) - 1
        mkres@gsMarkerIndex = 16
        mkres@gsMarkerSizeF = 0.012

        if (sval(i) .gt. exp(0.16) .or. sval(i) .lt. exp(-0.16))then 
            k = get_color_index("BlueDarkRed18", levels, sval(i))

            print (k)
            print (sval(i))
            print (dimsizes(cmap))
            mkres@gsMarkerColor = cmap(k-2, :)
            mkid(i) = gsn_add_polymarker(wks, plot, slon(i), slat(i), mkres)
        end if

        skres = True
        skres@gsMarkerIndex = 4
        skres@gsMarkerSizeF = 0.012
        skres@gsMarkerColor = "black"
        skres@gsMarkerThicknessF = 2.
        ckid(i) = gsn_add_polymarker(wks, plot, slon(i), slat(i), skres)

     end do

     draw(plot)
     frame(wks)

system("/bin/rm -f simple.nc")   ; remove any pre-existing file
       ncdf = addfile("simple.nc" ,"c")  ; open output netCDF file

       ncdf->z0 = z0

end
