/// Mathematical constants
class MathConstants {
  MathConstants._();

  // Mathematical constants
  static const double pi = 3.14159265358979323846;
  static const double e = 2.71828182845904523536;
  static const double phi = 1.61803398874989484820; // Golden ratio
  static const double sqrt2 = 1.41421356237309504880;
  static const double sqrt3 = 1.73205080756887729352;
  static const double sqrt5 = 2.23606797749978969640;
  static const double ln2 = 0.69314718055994530941;
  static const double ln10 = 2.30258509299404568401;
  static const double log2e = 1.44269504088896340735;
  static const double log10e = 0.43429448190325182765;
  static const double eulerMascheroni = 0.57721566490153286060;
  static const double apery = 1.20205690315959428539; // ζ(3)
  static const double catalan = 0.91596559417721901505;
  
  // Factorials for quick lookup
  static const List<double> factorials = [
    1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880,
    3628800, 39916800, 479001600, 6227020800, 87178291200,
    1307674368000, 20922789888000, 355687428096000,
  ];
}

/// Physical constants (NIST 2018 values)
class PhysicalConstants {
  PhysicalConstants._();

  // SI units
  static const double speedOfLight = 299792458.0; // m/s
  static const double planckConstant = 6.62607015e-34; // J·s
  static const double reducedPlanck = 1.054571817e-34; // J·s
  static const double gravitationalConstant = 6.67430e-11; // m³/(kg·s²)
  static const double boltzmannConstant = 1.380649e-23; // J/K
  static const double elementaryCharge = 1.602176634e-19; // C
  static const double electronMass = 9.1093837015e-31; // kg
  static const double protonMass = 1.67262192369e-27; // kg
  static const double neutronMass = 1.67492749804e-27; // kg
  static const double avogadroNumber = 6.02214076e23; // 1/mol
  static const double gasConstant = 8.314462618; // J/(mol·K)
  static const double faradayConstant = 96485.33212; // C/mol
  static const double stefanBoltzmann = 5.670374419e-8; // W/(m²·K⁴)
  static const double wienDisplacement = 2.897771955e-3; // m·K
  static const double rydbergConstant = 10973731.568160; // 1/m
  static const double bohrRadius = 5.29177210903e-11; // m
  static const double vacuumPermittivity = 8.8541878128e-12; // F/m
  static const double vacuumPermeability = 1.25663706212e-6; // H/m

  // Derived/other
  static const double earthMass = 5.9722e24; // kg
  static const double earthRadius = 6371000.0; // m
  static const double sunMass = 1.98892e30; // kg
  static const double astronomicalUnit = 1.495978707e11; // m
  static const double lightYear = 9.4607e15; // m
  static const double parsec = 3.0857e16; // m
  static const double standardGravity = 9.80665; // m/s²

  static const Map<String, Map<String, dynamic>> constantsTable = {
    'Speed of Light': {'value': speedOfLight, 'unit': 'm/s', 'symbol': 'c'},
    'Planck Constant': {'value': planckConstant, 'unit': 'J·s', 'symbol': 'h'},
    'Reduced Planck': {'value': reducedPlanck, 'unit': 'J·s', 'symbol': 'ℏ'},
    'Gravitational Constant': {'value': gravitationalConstant, 'unit': 'm³/(kg·s²)', 'symbol': 'G'},
    'Boltzmann Constant': {'value': boltzmannConstant, 'unit': 'J/K', 'symbol': 'kB'},
    'Elementary Charge': {'value': elementaryCharge, 'unit': 'C', 'symbol': 'e'},
    'Electron Mass': {'value': electronMass, 'unit': 'kg', 'symbol': 'me'},
    'Proton Mass': {'value': protonMass, 'unit': 'kg', 'symbol': 'mp'},
    'Avogadro Number': {'value': avogadroNumber, 'unit': '1/mol', 'symbol': 'NA'},
    'Gas Constant': {'value': gasConstant, 'unit': 'J/(mol·K)', 'symbol': 'R'},
    'Faraday Constant': {'value': faradayConstant, 'unit': 'C/mol', 'symbol': 'F'},
    'Stefan-Boltzmann': {'value': stefanBoltzmann, 'unit': 'W/(m²·K⁴)', 'symbol': 'σ'},
    'Rydberg Constant': {'value': rydbergConstant, 'unit': '1/m', 'symbol': 'R∞'},
    'Bohr Radius': {'value': bohrRadius, 'unit': 'm', 'symbol': 'a₀'},
    'Standard Gravity': {'value': standardGravity, 'unit': 'm/s²', 'symbol': 'g'},
    'Earth Mass': {'value': earthMass, 'unit': 'kg', 'symbol': 'M⊕'},
    'Earth Radius': {'value': earthRadius, 'unit': 'm', 'symbol': 'R⊕'},
    'Sun Mass': {'value': sunMass, 'unit': 'kg', 'symbol': 'M☉'},
    'Astronomical Unit': {'value': astronomicalUnit, 'unit': 'm', 'symbol': 'AU'},
    'Light Year': {'value': lightYear, 'unit': 'm', 'symbol': 'ly'},
    'Parsec': {'value': parsec, 'unit': 'm', 'symbol': 'pc'},
  };
}
