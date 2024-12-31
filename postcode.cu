/*WBL 19 Dec 2025 Based on my example.cu r1.10
  https://github.com/rapidsai/cuspatial/tree/branch-24.12/cpp/cuproj#example

Modifications:
WBL 31 Dec 2024 revert r1.15, cf https://github.com/rapidsai/cuspatial/issues/1510#issuecomment-2566227767, speed up with 4e6 coords 494
#   read data created by make_tests.bat r1.5 from postcode.in
WBL 30 Dec 2024 add calling run_proj_test
WBL 29 Dec 2024 try 4 inputs, add run_proj_test
*/

/* UK post codes in oops/h3/open_postcode_geo.csv.gz
 * NB some post do not have lat and long, so take care of defaults or clean
 */

using namespace std;

#include <cuproj_test/convert_coordinates.hpp>
#include <cuproj_test/coordinate_generator.cuh>
#include <cuspatial_test/vector_equality.hpp>

#include <cuproj/error.hpp>
#include <cuproj/projection_factories.cuh>
#include <cuproj/vec_2d.hpp>

#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

#include <proj.h>

#include <fstream>
#include <iostream>
//https://stackoverflow.com/questions/997946/how-to-get-current-time-and-date-in-c
#include <chrono>
#include <ctime>

template <typename T>
using coordinate = typename cuspatial::vec_2d<T>;

//#include <iomanip>

//run_proj_test() etc from cuspatial-branch-24.12 wgs_to_utm_test.cu
// run a test using the proj library for comparison
void run_proj_test(thrust::host_vector<PJ_COORD>& coords,
                   char const* epsg_src,
                   char const* epsg_dst)
{
  PJ_CONTEXT* C = proj_context_create();
  PJ* P         = proj_create_crs_to_crs(C, epsg_src, epsg_dst, nullptr);
  proj_trans_array(P, PJ_FWD, coords.size(), coords.data());

  proj_destroy(P);
  proj_context_destroy(C);
}

int main() {                            
  cout << "Start $Revision: 1.23 $\n";

  using T = float;

  //https://forums.developer.nvidia.com/t/using-thrust-copy-to-copy-from-a-file-to-a-device-vector/25956/3
  ifstream ifile("postcode.in");
  if (!ifile) {throw std::runtime_error("ifile postcode.in error");}
  const int num = 2589831;
  thrust::host_vector<T> H(num*2);
  istream_iterator<T> beg(ifile), end;
  thrust::copy(beg, end, H.begin());
  assert(std::abs(H[2*num-1] - (-1.307578)) < 1e-5);//check last value
  //ofstream ofile("postcode.out");
  //thrust::copy(H.begin(),H.end(),
  //	       ostream_iterator<T>(ofile, "\n"));
  ifile.close();
  //ofile.close();
  //return 0;
  
  //cuproj::vec_2d<T> sydney{-33.858700, 151.214000};  // Sydney, NSW, Australia
  thrust::host_vector<cuspatial::vec_2d<T>> input(num);
  for(int i = 0; i < input.size(); i++){
    input[i] = {H[i*2],H[i*2+1]}; //{sydney.x+float(i/400000.0),sydney.y};
  }
  assert(std::abs(input[num-1].x - (59.887104)) < 1e-5);//check last x value
  assert(std::abs(input[num-1].y - (-1.307578)) < 1e-5);//check last y value

  thrust::host_vector<coordinate<T>> h_input(input.begin(), input.end());
  thrust::host_vector<PJ_COORD> pj_input{input.size()};
  cuproj_test::convert_coordinates(h_input, pj_input);
  thrust::host_vector<PJ_COORD> pj_expected(pj_input);

  char const* epsg_src = "EPSG:4326";
  char const* epsg_dst = "EPSG:32756"; //"utm_epsg.c_str();
/*for(int i = 0; i <input.size(); i++) {
    cout << "input: " << std::setprecision(20) <<
      pj_expected[i].v[0] << "," <<
      pj_expected[i].v[1] << "," <<
      pj_expected[i].v[2] << "," <<
      pj_expected[i].v[3] << endl;
  }*/
  std::chrono::duration<double> pj_elapsed_seconds;
  {cout << "run_proj_test "<<flush;
  auto start = std::chrono::system_clock::now();
  run_proj_test(pj_expected, epsg_src, epsg_dst);
  auto end = std::chrono::system_clock::now();
  pj_elapsed_seconds = end-start;
  cout << "  done run_proj_test " << pj_elapsed_seconds.count() << endl;}
  
/*for(int i = 0; i <input.size(); i++) {
    cout << "pj_expected: " << std::setprecision(20) <<
      pj_expected[i].v[0] << "," <<
      pj_expected[i].v[1] << "," <<
      pj_expected[i].v[2] << "," <<
      pj_expected[i].v[3] << endl;
  }*/
  
  // Make a projection to convert WGS84 (lat, lon) coordinates to UTM zone 56S (x, y) coordinates
  auto* proj = cuproj::make_projection<cuproj::vec_2d<T>>("EPSG:4326", "EPSG:32756");

  /*https://docs.nvidia.com/cuda/archive/9.0/pdf/Thrust_Quick_Start_Guide.pdf
  // H has storage for 4 integers
  thrust::host_vector<T> H(4);
  // initialize individual elements
  H[0] = 14;
  H[1] = 20;
  H[2] = 38;
  H[3] = 46;

  // H.size() returns the size of vector H
  std::cout << "H has size " << H.size() << std::endl;
  // print contents of H
  for(int i = 0; i < H.size(); i++)
    std::cout << "H[" << i << "] = " << H[i] << std::endl;
  // resize H
  H.resize(2);
  std::cout << "H now has size " << H.size() << std::endl;
  // Copy host_vector H to device_vector D
  thrust::device_vector<int> D = H;
  // elements of D can be modified
  D[0] = 99;
  D[1] = 88;
  // print contents of D
  for(int i = 0; i < D.size(); i++)
    std::cout << "D[" << i << "] = " << D[i] << std::endl;
  // H and D are automatically deleted when the function returns
  return 0;
  */
  thrust::host_vector<cuproj::vec_2d<T>> h_in(input.size());
  for(int i = 0; i <h_in.size(); i++) {
    h_in[i] = {input[i].x,input[i].y};
  }
  thrust::device_vector<cuproj::vec_2d<T>> d_in = h_in; //transfer to GPU
  thrust::device_vector<cuproj::vec_2d<T>> d_out(d_in.size());

  // Convert the coordinates. Works the same with a vector of many coordinates.
  {cout << "proj->transform "<<flush;
  auto start = std::chrono::system_clock::now();
  proj->transform(d_in.begin(), d_in.end(), d_out.begin(), cuproj::direction::FORWARD);
  auto end = std::chrono::system_clock::now();
  std::chrono::duration<double> elapsed_seconds = end-start;
  cout << "done proj->transform " << elapsed_seconds.count() << endl;
  cout << "Speedup "<<pj_elapsed_seconds.count()/elapsed_seconds.count()<<endl;}

  //Check answer (based on wgs_to_utm_test.cu run_cuproj_test)
/*for(int i = 0; i < d_out.size(); i++) {
    cout << "pj_expected: " << std::setprecision(20) <<
      pj_expected[i].v[0] << "," <<
      pj_expected[i].v[1] << "," <<
      pj_expected[i].v[2] << "," <<
      pj_expected[i].v[3] << endl;
    cout << "Device:     "  << std::setprecision(20) << d_out[i] << endl;
  }*/


  // We can expect nanometer accuracy with double precision. The precision ratio of
  // double to single precision is 2^53 / 2^24 == 2^29 ~= 10^9, then we should
  // expect meter (10^9 nanometer) accuracy with single precision.
  //T tolerance = std::is_same_v<T, double> ? T{1e-9} : T{1.0};
  // We can expect nanometer accuracy with double precision. The precision ratio of
  // double to single precision is 2^53 / 2^24 == 2^29 ~= 10^9, then we should
  // expect meter (10^9 nanometer) accuracy with single precision.
  // For large arrays seem to need to relax the tolerance a bit to match PROJ results.
  // 1um for double and 10m for float seems like reasonable accuracy while not allowing excessive
  // variance from PROJ results.
  T tolerance = std::is_same_v<T, double> ? T{1e-6} : T{10};
  cout << "tolerance: " << tolerance << endl;
  thrust::device_vector<cuspatial::vec_2d<T>> expected(pj_input.size());
  for(int i = 0; i < pj_input.size(); i++){
    expected[i] = {float(pj_expected[i].v[0]),float(pj_expected[i].v[1])};
  }
  thrust::device_vector<cuspatial::vec_2d<T>> c_out(d_out.size());
  for(int i = 0; i < d_out.size(); i++){
    cuproj::vec_2d<T> c = d_out[i];
    //cout << (d_out[i]).x <<endl; https://stackoverflow.com/questions/8638839/thrust-vector-of-type-uint2-has-no-member-x-compiler-error
    //cout << c <<endl;
    //cout << " " << c.x << "," << c.y << endl;
    c_out[i] = {c.x,c.y}; //{1,2}; //{float(d_out[i].x),float(d_out[i].y)};
  }
  {cout << "CUSPATIAL_EXPECT_VECTORS_EQUIVALENT "<<flush;
  auto start = std::chrono::system_clock::now();
  CUSPATIAL_EXPECT_VECTORS_EQUIVALENT(expected, c_out, tolerance);
  auto end = std::chrono::system_clock::now();
  std::chrono::duration<double> elapsed_seconds = end-start;
  cout << "done CUSPATIAL_EXPECT_VECTORS_EQUIVALENT " << elapsed_seconds.count() << endl;}
  
  cout << "end main().\n";
}
