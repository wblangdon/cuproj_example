# cuproj_example
Use nvidia CUDA cpp rapidsai/cuspatial/cuproj to convert UK zip code coordinates

Nvidia's rapidsai/cuspatial/cupro is a CUDA port of the PROJ https://github.com/OSGeo/PROJ 
coordinate transformation tool for use with nVidia graphics cards (GPUs). 
cuproj heavily uses thrust and can give huge speedups.
postcode.cu is an example which converts 2.6 million coordinates using cuproj.
It compares cuproj's answers with those given by proj and calculates the speed up.
With a GeForce RTX 4070 it gives on average a 361 fold speedup.

Usage:
* Ensure have compatible GPU https://github.com/rapidsai/cuspatial/#using-cuspatial
* Ensure have compatible version of CUDA installed
* Install cuspatial

* Use ./postcode.bat to compile and link postcode.cu

  postcode.bat assumes linux tcsh shell, it starts by including /opt/cuda/cuda-12.6 in the path
  (you may need to adjust these for your CUDA installation).
  It also assumes that your installation of cuspatial is in directory ../cuspatial
  and cuspatial is using libproj.so.25.9.2.0
  (For newer versions of cuspatial you may need to update the libproj.so version number)
* Ensure have copy of postcode.in (postcode.cu has a few sanity checks to make sure it has read
postcode.in correctly -- disable these if you want to use your own data file).
* run ./postcode

Anticipated output:
```
./postcode
Start $Revision: 1.23 $
run_proj_test   done run_proj_test 0.433269
proj->transform done proj->transform 0.00124691
Speedup 347.474
tolerance: 10
CUSPATIAL_EXPECT_VECTORS_EQUIVALENT done CUSPATIAL_EXPECT_VECTORS_EQUIVALENT 1.78355
end main().
```
