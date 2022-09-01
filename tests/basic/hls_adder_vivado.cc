#include "hls_adder_vivado.h"

namespace cruxml {
namespace examples {

void adder(fixed &a, fixed &b, fixed &c) {
#pragma HLS pipeline II = 1
  c = a + b;
}

} // namespace examples
} // namespace cruxml