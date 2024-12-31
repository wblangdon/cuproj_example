#WBL 29 Dec 2024 based on example.bat r1.9

#Modifications

#from setup_paths.bat

setenv PATH /opt/cuda/cuda-12.6/bin/:"$PATH"
setenv LD_LIBRARY_PATH /opt/cuda/cuda-12.6/lib64:"$LD_LIBRARY_PATH"

nvcc --version |& grep ^Cuda
if($status) exit $status
echo ""

nvcc \
  -g \
  --Wno-deprecated-declarations \
  -DLIBCUDACXX_ENABLE_EXPERIMENTAL_MEMORY_RESOURCE \
  --expt-extended-lambda \
  --expt-relaxed-constexpr \
  -I../cuspatial/include \
  -I../cuspatial/cpp/include \
  -I../cuspatial/cpp/cuproj/include \
  -I../cuspatial/cpp/build/_deps/gtest-src/googlemock/include/ \
  -I../cuspatial/cpp/build/_deps/gtest-src/googletest/include/ \
  -c postcode.cu

setenv save $status
if($save) then
  echo "nvcc status $save"
  exit $save
endif

#from ../script_cuspatial_1-dec-2024.txt
#88% Building CUDA object cuproj/tests/CMakeFiles/WGS_TO_UTM_TEST.dir/wgs_to_utm_test.cu.o
#cd /cs/research/crest/projects2/ucacbbl/assugi/cuproj/cuspatial/cpp/build/cuproj/tests && /opt/cuda/cuda-12.6/bin/nvcc -forward-unknown-to-host-compiler -DFMT_HEADER_ONLY=1 -DLIBCUDACXX_ENABLE_EXPERIMENTAL_MEMORY_RESOURCE -DSPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_INFO -DSPDLOG_FMT_EXTERNAL -DTHRUST_DEVICE_SYSTEM=THRUST_DEVICE_SYSTEM_CUDA -DTHRUST_DISABLE_ABI_NAMESPACE -DTHRUST_HOST_SYSTEM=THRUST_HOST_SYSTEM_CPP -DTHRUST_IGNORE_ABI_NAMESPACE_ERROR --options-file CMakeFiles/WGS_TO_UTM_TEST.dir/includes_CUDA.rsp -O3 -DNDEBUG -std=c++17 --generate-code=arch=compute_89,code=[sm_89] -Xcompiler=-fPIE -Xcompiler=-Wno-parentheses --expt-extended-lambda --expt-relaxed-constexpr -Werror=all-warnings -Xcompiler=-Wall,-Werror,-Wno-error=deprecated-declarations -Xfatbin=-compress-all -Xcompiler=-Wno-deprecated-declarations -MD -MT cuproj/tests/CMakeFiles/WGS_TO_UTM_TEST.dir/wgs_to_utm_test.cu.o -MF CMakeFiles/WGS_TO_UTM_TEST.dir/wgs_to_utm_test.cu.o.d -x cu -c /cs/research/crest/projects2/ucacbbl/assugi/cuproj/cuspatial/cpp/cuproj/tests/wgs_to_utm_test.cu -o CMakeFiles/WGS_TO_UTM_TEST.dir/wgs_to_utm_test.cu.o
#88% Linking CXX executable ../gtests/WGS_TO_UTM_TEST
#cd /cs/research/crest/projects2/ucacbbl/assugi/cuproj/cuspatial/cpp/build/cuproj/tests && /usr/bin/cmake -E cmake_link_script CMakeFiles/WGS_TO_UTM_TEST.dir/link.txt --verbose=1
#/usr/bin/c++ -O3 -DNDEBUG CMakeFiles/WGS_TO_UTM_TEST.dir/wgs_to_utm_test.cu.o -o ../gtests/WGS_TO_UTM_TEST   -L/opt/cuda/cuda-12.6/targets/x86_64-linux/lib/stubs  -L/opt/cuda/cuda-12.6/targets/x86_64-linux/lib  -Wl,-rpath,/cs/research/crest/projects2/ucacbbl/assugi/cuproj/cuspatial/cpp/build/_deps/proj-build/lib:/opt/cuda/cuda-12.6/targets/x86_64-linux/lib: ../../lib/libgtest_main.a ../../lib/libgmock_main.a ../../_deps/proj-build/lib/libproj.so.25.9.2.0 ../../lib/libgmock.a ../../lib/libgtest.a /opt/cuda/cuda-12.6/targets/x86_64-linux/lib/libcudart.so -ldl -lcudadevrt -lcudart
#gmake[2]: Leaving directory '/cs/research/crest/projects2/ucacbbl/assugi/cuproj/cuspatial/cpp/build'
#88% Built target WGS_TO_UTM_TEST

/usr/bin/c++ -g postcode.o -o postcode \
  -L/opt/cuda/cuda-12.6/targets/x86_64-linux/lib/stubs \
  -L/opt/cuda/cuda-12.6/targets/x86_64-linux/lib \
  -Wl,-rpath,/cs/research/crest/projects2/ucacbbl/assugi/cuproj/cuspatial/cpp/build/_deps/proj-build/lib:/opt/cuda/cuda-12.6/targets/x86_64-linux/lib: \
  ../cuspatial/cpp/build/lib/libgtest_main.a \
  ../cuspatial/cpp/build/lib/libgmock_main.a \
  ../cuspatial/cpp/build/_deps/proj-build/lib/libproj.so.25.9.2.0 \
  ../cuspatial/cpp/build/lib/libgmock.a \
  ../cuspatial/cpp/build/lib/libgtest.a \
  /opt/cuda/cuda-12.6/targets/x86_64-linux/lib/libcudart.so \
  -ldl -lcudadevrt -lcudart

setenv save $status
if($save) then
  echo "link status $save"
  exit $save
endif

ls -ltr ./postcode.o ./postcode

echo $0 '$Revision: 1.7 $' "status $status done" `date`
exit
