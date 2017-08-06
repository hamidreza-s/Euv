/* euv */

#include <stdio.h>
#include "erl_driver.h"
#include "ei.h"

typedef struct {
  ErlDrvPort port;
} euv_data;

static ErlDrvData euv_start(ErlDrvPort port, char *buff)
{
  euv_data* d = (euv_data*)driver_alloc(sizeof(euv_data));
  d->port = port;
  return (ErlDrvData) d;
}

static void euv_stop(ErlDrvData handle)
{
  driver_free((char*) handle);
}

static void euv_output(ErlDrvData handle, char *buff, ErlDrvSizeT bufflen)
{
  euv_data* d = (euv_data*) handle;
  char res[] = {131, 107, 0, 4, 112, 111, 110, 103};
  driver_output(d->port, res, sizeof(res)/sizeof(res[0]));
}

static ErlDrvEntry euv_entry = {
    NULL,
    euv_start,
    euv_stop,
    euv_output,
    NULL,
    NULL,
    "euv",
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    ERL_DRV_EXTENDED_MARKER,
    ERL_DRV_EXTENDED_MAJOR_VERSION,
    ERL_DRV_EXTENDED_MINOR_VERSION,
    0,
    NULL,
    NULL,
    NULL
};

DRIVER_INIT(euv)
{
  return &euv_entry;
}
