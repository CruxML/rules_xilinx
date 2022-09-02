#include "hls_adder_vivado.h"

#ifndef __SYNTHESIS__
namespace cruxml {
namespace examples {
#endif

void adder_vivado(fixed &a, fixed &b, fixed &c) {
#pragma HLS pipeline II = 1
  c = a + b;
}
#ifndef __SYNTHESIS__
} // namespace examples
} // namespace cruxml
#endif