/*   Program read_bcpnts_unst_NR   */
/*

c   *** This method, although accepted, is not recommended ***
c   *** As of V3.1.3, use of ElementRange and ElementList
c   *** has been deprecated.
c   *** See program write_bcpnts_unst instead ***

Opens an existing CGNS file that contains a simple 3-D 
unstructured grid + BCs (in ElementList format), and reads the BCs

The CGNS grid file 'grid_c.cgns' must already exist
(created using write_grid_unst.c), and the BCs must also
already have been written (using write_bcpnts_unst.c).  Note: whether the
existing CGNS file has a flow solution in it already or
not is irrelevant.

Example compilation for this program is (change paths!):

cc -I ../CGNS_CVS/cgnslib_2.5 -c read_bcpnts_unst_NR.c
cc -o read_bcpnts_unst_NR_c read_bcpnts_unst_NR.o -L ../CGNS_CVS/cgnslib_2.5/LINUX -lcgns

(../CGNS_CVS/cgnslib_2.5/LINUX/ is the location where the compiled
library libcgns.a is located)
*/

#include <stdio.h>
/* cgnslib.h file must be located in directory specified by -I during compile: */
#include "cgnslib.h"

#if CGNS_VERSION < 3100
# define cgsize_t int
#else
# if CG_BUILD_SCOPE
#  error enumeration scoping needs to be off
# endif
#endif

#define maxpnts 960

int main()
{
    int index_file,index_base,index_zone,nbocos,ib;
    int normalindex[3],ndataset;
    int i,normallist;
    char boconame[33];
    BCType_t ibocotype;
    PointSetType_t iptset;
    DataType_t normaldatatype;
    cgsize_t npts,normallistflag;
    cgsize_t ipnts[maxpnts];

/* READ BOUNDARY CONDITIONS FROM EXISTING CGNS FILE */
/* open CGNS file for read-only */
    if (cg_open("grid_c.cgns",CG_MODE_READ,&index_file)) cg_error_exit();
/* we know there is only one base (real working code would check!) */
    index_base=1;
/* we know there is only one zone (real working code would check!) */
    index_zone=1;
/* find out number of BCs that exist under this zone */
    cg_nbocos(index_file,index_base,index_zone,&nbocos);
/* do loop over the total number of BCs */
    for (ib=1; ib <= nbocos; ib++)
    {
/* get BC info */
      cg_boco_info(index_file,index_base,index_zone,ib,boconame,&ibocotype,
                   &iptset,&npts,normalindex,&normallistflag,&normaldatatype,&ndataset);
      if (iptset != ElementList)
      {
        printf("\nError.  For this program, BCs must be set up as ElementList type %s\n",
            PointSetTypeName[iptset]);
        return 1;
      }
      printf("\nBC number: %i\n",ib);
      printf("   name= %s\n",boconame);
      printf("   type= %s\n",BCTypeName[ibocotype]);
      printf("   no of elements= %i\n",(int)npts);
      if (npts > maxpnts)
      {
        printf("\nError.  Must increase maxpnts to at least %i\n",(int)npts);
        return 1;
      }
/* read point list in here (nothing done with them in this program) */
      cg_boco_read(index_file,index_base,index_zone,ib,ipnts,&normallist);
      printf("      (these elements read here, but only some printed out:)\n");
      for (i=0; i < 10; i++)
      {
        printf("    ipnts[%i]=%i\n",i,(int)ipnts[i]);
      }
    }
/* close CGNS file */
    cg_close(index_file);
    printf("\nSuccessfully read BCs (ElementList format) from file grid_c.cgns\n");
    return 0;
}
