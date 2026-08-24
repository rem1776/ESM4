#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPT_DIR/../src/coupler

cmake -S . -B ../build  \
  -DCOUPLER_TYPE="full" \
  -Dfms_path="../FMS"   \
  -Dfms_macros="use_libMPI;use_netCDF;use_yaml;MAXFIELDMETHODS_=600;MAXXGRID=1e9" \
  -Dfms_flags="-fdefault-real-8" \
  -Docean_model_paths="../MOM6" \
  -Docean_model_macros="-DMAX_FIELDS_=600;-DNOT_SET_AFFINITY;-D_USE_MOM6_DIAG;-D_USE" \
  -Datmos_model_macros="-DCLIMATE_NUDGE;-DSPMD" \
  -Datmos_model_paths="../GFDL_atmos_cubed_sphere;../atmos_drivers/coupled" \
  -Dland_model_paths="../lm4p" \
  -Dland_model_macros="" \
  -Dice_model_paths="../SIS2;../icebergs;../ice_param" \
  -Dice_model_macros="-DUSE_FMS2_IO" \
  -Datmos_physics_library_paths="../atmos_phys" \
  -Datmos_physics_library_macros=""
