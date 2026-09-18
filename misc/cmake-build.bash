#!/bin/bash
# build script for ESM4.5 using cmake within FMScoupler

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $SCRIPT_DIR/..
mkdir -p build_cmake
cd build_cmake
srcdir="${SCRIPT_DIR}/../src"

# set paths, pre-processor macros and flags for building
# fms
# TODO, these aren't actually being used
paths_fms="$srcdir/FMS/"
macros_fms="use_libMPI;use_netCDF;use_yaml;MAXFIELDMETHODS_=600;MAXXGRID=1e9"
flags_fms="-I../FMS;-I$srcdir/FMS/include"
# ocean
paths_ocean=( "$srcdir/MOM6/"{config_src/infra/FMS2,config_src/memory/dynamic_nonsymmetric,config_src/drivers/FMS_cap,config_src/external/ODA_hooks,config_src/external/database_comms,config_src/external/stochastic_physics,config_src/external/MARBL,config_src/external/drifters,pkg/GSW-Fortran/{modules,toolbox}/,src/{*,*/*}/} "$srcdir/FMS/"{coupler,include} "$srcdir/"{ocean_BGC/generic_tracers,ocean_BGC/mocsy/src} )
macros_ocean="MAX_FIELDS_=600;NOT_SET_AFFINITY;_USE_MOM6_DIAG;_USE_GENERIC_TRACER;USE_PRECISION=2"
flags_ocean="-I../FMS;-I../mom6;-I$srcdir/MOM6/src/framework/"
# ice
macros_ice='USE_FMS2_IO'
paths_ice=( "$srcdir/SIS2/"{config_src/dynamic,config_src/external/Icepack_interfaces,src} "$srcdir/icebergs/src" "$srcdir/ice_param" )
flags_ice="-I../FMS;-I../mom6;-I$srcdir/MOM6/src/framework/"
# land 
paths_land=( "$srcdir/lm4p" )
macros_land=""
flags_land="-I../FMS;-I$srcdir/FMS/include;-fdefault-double-8"
# atmos
paths_atmos=( "$srcdir/GFDL_atmos_cubed_sphere/"{driver/GFDL,model,GFDL_tools,tools} "$srcdir/atmos_drivers/coupled" )
macros_atmos="CLIMATE_NUDGE;SPMD"
flags_atmos="-I../FMS;-I$srcdir/FMS/include;-I$srcdir/GFDL_atmos_cubed_sphere/tools/;-fno-range-check"
# atmos phy
paths_atmos_phys=( "$srcdir/atmos_phys" )
macros_atmos_phys=""
flags_atmos_phys="-I../FMS;-I$srcdir/FMS/include;-fdefault-double-8"

# TODO, set build type according to mkmf template
# build_type = "intel-prod"

# this replaces spaces with semicolons when outputting bash arrays
# cmake expects lists to be semicolon-separated
IFS=";"
  
cmake -S $srcdir/coupler \
  -DCOUPLER_TYPE="full" \
  -Dfms_paths="$paths_fms" \
  -Dfms_macros="$macros_fms" \
  -Dfms_flags="$flags_fms" \
  -Docean_model_paths="${paths_ocean[*]}" \
  -Docean_model_macros="$macros_ocean" \
  -Docean_model_flags="$flags_ocean" \
  -Datmos_model_paths="${paths_atmos[*]}" \
  -Datmos_model_macros="$macros_atmos" \
  -Datmos_model_flags="$flags_atmos" \
  -Dland_model_paths="${paths_land[*]}" \
  -Dland_model_macros="$macros_land" \
  -Dland_model_flags="$flags_land" \
  -Dice_model_paths="${paths_ice[*]}" \
  -Dice_model_macros="$macros_ice" \
  -Dice_model_flags="$flags_ice" \
  -Datmos_physics_library_paths="${paths_atmos_phys[*]}" \
  -Datmos_physics_library_macros="$macros_atmos_phys" \
  -Datmos_physics_library_flags="$flags_atmos_phys"
  
make -j
make