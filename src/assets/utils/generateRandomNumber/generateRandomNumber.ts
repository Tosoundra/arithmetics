import {
  InterfaceMathOperationDependsNumber,
  Operator,
} from '../InterfaceMathOperationDependsNumber/InterfaceMathOperationDependsNumber';

export const generateRandomNumberA = (
  maxAvailableValue: number,
  currentMathAction: Operator,
): number => {
  const getNumberDependedOfOperator: InterfaceMathOperationDependsNumber = {
    // создать функцию генерирующую 2 случ числа
    '+': Math.floor(
      Math.random() * (maxAvailableValue - maxAvailableValue / 10) + maxAvailableValue / 10,
    ),
    '-': Math.floor(
      Math.random() * (maxAvailableValue - maxAvailableValue / 10) + maxAvailableValue / 10 + 1,
    ),
    '×': Math.floor(Math.random() * (maxAvailableValue - maxAvailableValue / 10) + 1),
    '÷': Math.floor(Math.random() * 9 + 2) * Math.floor(Math.random() * 9 + 1),
  };

  return getNumberDependedOfOperator[currentMathAction];
};

export const generateRandomNumberB = (
  maxAvailableValue: number,
  numberA: number,
  currentMathAction: Operator,
): number => {
  const getNumberDependedOfOperator: InterfaceMathOperationDependsNumber = {
    '+': Math.floor(Math.random() * (maxAvailableValue - numberA) + 1),
    '-': Math.floor((Math.random() * numberA) / 2 + (Math.random() * numberA) / 2 + 1),
    '×': Math.floor(Math.random() * 9 + 1),
    '÷': generateRandomDivisor(numberA),
  };

  return getNumberDependedOfOperator[currentMathAction];
};

const generateRandomDivisor = (numberA: number): number => {
  const arrayOfDivisors: number[] = [];

  for (let index: number = 2; index <= 10; index++) {
    if (numberA % index === 0 && numberA / index <= 10) {
      arrayOfDivisors.push(index);
    }
  }

  const randomDivisor = Math.floor(Math.random() * arrayOfDivisors.length);
  return arrayOfDivisors[randomDivisor];
};
