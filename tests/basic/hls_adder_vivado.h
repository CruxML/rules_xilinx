#ifdef VITIS
#include <ap_fixed.h>
#else
#include "vivado/v2020_1/ap_fixed.h"
#endif

namespace cruxml {
namespace examples {

typedef ap_fixed<16, 9> fixed;

void adder(fixed &a, fixed &b, fixed &c);

} // namespace examples
} // namespace cruxml