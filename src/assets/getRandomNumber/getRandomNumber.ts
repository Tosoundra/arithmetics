export const generateRandomNumberA = (maxValue: number): number => {
  return Math.floor(Math.random() * (maxValue - maxValue / 10) + 1);
};

export const generateRandomNumberB = (
  maxValue: number,
  numberA: number,
  currentMathAction: string,
): number => {
  const getNumberDependedOfOperator = {
    '+': Math.floor(Math.random() * (maxValue - numberA) + 1),
    '-': Math.floor(Math.random() * numberA),
    '×': Math.floor(Math.random() * numberA),
    '÷': generateRandomDivisor(numberA),
  };

  return getNumberDependedOfOperator[currentMathAction];
};

const generateRandomDivisor = (numberA: number): number => {
  const arrayOfDivisors = [];

  for (let index = 1; index <= numberA; index++) {
    if (numberA % index === 0) {
      arrayOfDivisors.push(index);
    }
  }

  const randomDivisor = Math.floor(Math.random() * arrayOfDivisors.length);
  return arrayOfDivisors[randomDivisor];
};
