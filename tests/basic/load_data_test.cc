
#include <memory>

#include "gtest/gtest.h"
#include <glog/logging.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vload_data.h"

namespace cruxml {
namespace examples {

TEST(load_data_test, check_values) {
  std::unique_ptr<Vload_data> v_load_data = std::make_unique<Vload_data>();
  v_load_data->eval();
}

} // namespace examples
} // namespace cruxml

int main(int argc, char **argv) {
  FLAGS_logtostderr = 1;
  google::InitGoogleLogging(argv[0]);
  testing::InitGoogleTest(&argc, argv);

  CHECK_EQ(RUN_ALL_TESTS(), 0);
}
