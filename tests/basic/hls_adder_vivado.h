#ifdef __SYNTHESIS__
#include <ap_fixed.h>
#else
#include "vivado/v2020_1/ap_fixed.h"
#endif

#ifndef __SYNTHESIS__
namespace cruxml {
namespace examples {
#endif
typedef ap_fixed<16, 9> fixed;

void adder_vivado(fixed &a, fixed &b, fixed &c);
#ifndef __SYNTHESIS__
} // namespace examples
} // namespace cruxml
#endif