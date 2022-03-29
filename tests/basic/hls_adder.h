#ifdef VITIS
#include <ap_fixed.h>
#else
#include "vitis/v2021_2/ap_fixed.h"
#endif

namespace cruxml {
namespace examples {

typedef ap_fixed<16, 9> fixed;

void adder(fixed &a, fixed &b, fixed &c);

} // namespace examples
} // namespace cruxml