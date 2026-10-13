/// Calculator mode tabs
enum CalcMode {
  standard('Standard', 'Basic arithmetic operations'),
  scientific('Scientific', 'Advanced math functions'),
  calculus('Calculus', 'Derivatives, integrals, limits'),
  matrix('Linear Algebra', 'Matrix operations'),
  complex('Complex Numbers', 'Complex arithmetic'),
  stats('Statistics', 'Data analysis & probability'),
  programmer('Programmer', 'Number bases & bitwise ops'),
  unitConverter('Converter', 'Unit conversions'),
  currency('Currency', 'Live exchange rates');

  final String displayName;
  final String description;

  const CalcMode(this.displayName, this.description);
}
