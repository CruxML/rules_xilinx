
#include <memory>

#include "gtest/gtest.h"
#include <glog/logging.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vadder_vivado.h"
#include "tests/basic/hls_adder_vivado.h"

namespace cruxml {
namespace examples {

constexpr int NUM_CYCLES = 100;

TEST(adder_test, add_ints) {
  std::unique_ptr<Vadder_vivado> v_adder = std::make_unique<Vadder_vivado>();
  v_adder->ap_start = 1;
  v_adder->a_V = 1 << 7;
  v_adder->b_V = 5 << 7;
  v_adder->eval();
  EXPECT_EQ(v_adder->c_V, 6 << 7);
  EXPECT_EQ(v_adder->c_V_ap_vld, 1);
}

TEST(adder_test, add_fixed) {
  std::unique_ptr<Vadder_vivado> v_adder = std::make_unique<Vadder_vivado>();
  v_adder->ap_start = 1;
  fixed a_V = 0.625;
  fixed b_V = 1.625;
  fixed c_V;
  adder_vivado(a_V, b_V, c_V);
  // Use .range() to get the bits.
  v_adder->a_V = a_V.range();
  v_adder->b_V = b_V.range();
  v_adder->eval();
  EXPECT_EQ(v_adder->c_V, c_V.range());
  EXPECT_EQ(v_adder->c_V_ap_vld, 1);
}

} // namespace examples
} // namespace cruxml

int main(int argc, char **argv) {
  FLAGS_logtostderr = 1;
  google::InitGoogleLogging(argv[0]);
  testing::InitGoogleTest(&argc, argv);

  CHECK_EQ(RUN_ALL_TESTS(), 0);
}
