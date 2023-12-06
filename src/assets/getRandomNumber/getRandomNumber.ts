interface OperatorNumbers {
  addition: number;
  subtraction: number;
  multiply: number;
  // '÷': number; // Если нужно добавить деление
}

export const generateRandomNumberA = (
  maxValue: number,
  currentMathAction: OperatorNumbers,
): number => {
  const [operator] = Object.keys(currentMathAction) as Array<keyof OperatorNumbers>;

  const getNumberDependedOfOperator = {
    addition: Math.floor(Math.random() * (maxValue - maxValue / 10) + 1),
    subtraction: Math.floor(Math.random() * 9 + 1),
    multiply: Math.floor(Math.random() * 9 + 1),
    // '÷': generateRandomDivisor(numberA),
  };

  return getNumberDependedOfOperator[operator];
};

export const generateRandomNumberB = (
  maxValue: number,
  numberA: number,
  currentMathAction: OperatorNumbers,
): number => {
  const [operator] = Object.keys(currentMathAction) as Array<keyof OperatorNumbers>;

  const getNumberDependedOfOperator = {
    addition: Math.floor(Math.random() * (maxValue - numberA) + 1),
    subtraction: Math.floor(Math.random() * numberA),
    multiply: Math.floor(Math.random() * 9 + 1),
    '÷': generateRandomDivisor(numberA),
  };

  return getNumberDependedOfOperator[operator];
};

const generateRandomDivisor = (numberA: number): number => {
  const arrayOfDivisors: number[] = [];

  for (let index: number = 1; index <= 10; index++) {
    if (numberA % index === 0) {
      arrayOfDivisors.push(index);
    }
  }

  const randomDivisor = Math.floor(Math.random() * arrayOfDivisors.length);
  return arrayOfDivisors[randomDivisor];
};
