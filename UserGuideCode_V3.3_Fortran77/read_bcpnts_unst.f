      program read_bcpnts_unst
      use cgns
c
c   Opens an existing CGNS file that contains a simple 3-D
c   unstructured grid + BCs (in PointList+GridLocation=FaceCenter
c   format), and reads the BCs
c
c   The CGNS grid file 'grid.cgns' must already exist
c   (created using write_grid_unst.f), and the BCs must also
c   already have been written (using write_bcpnts_unst.f).  Note: whether the
c   existing CGNS file has a flow solution in it already or
c   not is irrelevant.
c
c   This program uses the fortran convention that all
c   variables beginning with the letters i-n are integers,
c   by default, and all others are real
c
c   Example compilation for this program is (change paths if needed!):
c   Note: when using the cgns module file, you must use the SAME fortran compiler
c   used to compile CGNS (see make.defs file)
c   ...or change, for example, via environment "setenv FC ifort"
c
c   ifort -I ../.. -c read_bcpnts_unst.f
c   ifort -o read_bcpnts_unst read_bcpnts_unst.o -L ../../lib -lcgns
c
c   (../../lib is the location where the compiled
c   library libcgns.a is located)
c
c   The following is no longer supported; now superceded by "use cgns":
c     include 'cgnslib_f.h'
c   Note Windows machines need to include cgnswin_f.h
c
      parameter (maxpnts=960)
      integer(cgsize_t) ipnts(maxpnts),npts,normallistflag
      dimension normalindex(3)
      character boconame*32
c
c  READ BOUNDARY CONDITIONS FROM EXISTING CGNS FILE
c  open CGNS file for read-only
      call cg_open_f('grid.cgns',CG_MODE_READ,index_file,ier)
      if (ier .ne. CG_OK) call cg_error_exit_f
c  we know there is only one base (real working code would check!)
      index_base=1
c  we know there is only one zone (real working code would check!)
      index_zone=1
c  find out number of BCs that exist under this zone
      call cg_nbocos_f(index_file,index_base,index_zone,nbocos,ier)
c  do loop over the total number of BCs
      do ib=1,nbocos
c  find out what BC grid location is (expecting FaceCenter)
        call cg_goto_f(index_file,index_base,ier,'Zone_t',1,
     +    'ZoneBC_t',1,'BC_t',ib,'end')
        call cg_gridlocation_read_f(igr,ier)
        if (igr .eq. FaceCenter) then
          write(6,'('' GridLocation=FaceCenter means BC data refers'',
     +      '' to elements, not nodes'')')
        end if
c  get BC info
        call cg_boco_info_f(index_file,index_base,index_zone,ib,
     +    boconame,ibocotype,iptset,npts,normalindex,normallistflag,
     +    normaldatatype,ndataset,ier)
        if (iptset .ne. PointList) then
          write(6,'('' Error.  For this program, BCs must be set'',
     +     ''  up as PointList type'',a32)') PointSetTypeName(iptset)
          stop
        end if
        write(6,'('' BC number: '',i5)') ib
        write(6,'(''    name='',a32)') boconame
        write(6,'(''    type='',a32)') BCTypeName(ibocotype)
        write(6,'(''    no of elements='',i5)') npts
        if (npts .gt. maxpnts) then
          write(6,'('' Error.  Must increase maxpnts to at least '',
     +     i5)') npts
          stop
        end if
c  read point list in here (nothing done with them in this program)
        call cg_boco_read_f(index_file,index_base,index_zone,ib,
     +    ipnts,normallist,ier)
        write(6,'(''      (these elements read here, but only some'',
     +    '' printed out:)'')')
        do i=1,10
          write(6,'('' ipnts('',i2,'')='',i4)') i,ipnts(i)
        enddo
      enddo
c  close CGNS file
      call cg_close_f(index_file,ier)
      write(6,'('' Successfully read BCs (PointList format)'',
     + '' from file grid.cgns'')')
      stop
      end
