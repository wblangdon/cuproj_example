# cuproj_example
Use nvidia CUDA cpp rapidsai/cuspatial/cuproj to convert UK zip code coordinates

Nvidia's rapidsai/cuspatial/cupro is a CUDA port of the PROJ https://github.com/OSGeo/PROJ 
coordinate transformation tool for use with nVidia graphics cards (GPUs). 
cuproj heavily uses thrust and can give huge speedups.
postcode.cu is an example which converts 2.6 million coordinates using cuproj
It compares cuproj's answers with those given by proj and calculates the speed up.
With a GeForce RTX 4070 it gives on average a 361 fold speedup.

Usage:
Ensure have compatible GPU https://github.com/rapidsai/cuspatial/#using-cuspatial
Ensure have compatible version of CUDA installed
Install cuspatial

Use postcode.bat to compile and link postcode.cu
Ensure have copy of postcode.in (postcode.cu has a few sanity checks to make sure it has read
postcode.in correctly -- dsiable these if you want to use your own data file).
run ./postcode
