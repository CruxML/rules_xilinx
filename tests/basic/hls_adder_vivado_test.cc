#include "hls_adder_vivado.h"

#include "gtest/gtest.h"
#include <glog/logging.h>

namespace cruxml {
namespace examples {

TEST(hls_adder_test, one_plus_one) {
  fixed a = 1;
  fixed b = 1;
  fixed c;
  adder_vivado(a, b, c);
  EXPECT_EQ(c, 2);
}

} // namespace examples
} // namespace cruxml

int main(int argc, char **argv) {
  FLAGS_logtostderr = 1;
  google::InitGoogleLogging(argv[0]);
  testing::InitGoogleTest(&argc, argv);

  CHECK_EQ(RUN_ALL_TESTS(), 0);
}