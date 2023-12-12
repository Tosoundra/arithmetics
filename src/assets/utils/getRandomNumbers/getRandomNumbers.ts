import { Operator } from '../InterfaceMathOperationDependsNumber/InterfaceMathOperationDependsNumber';
import {
  generateRandomNumberA,
  generateRandomNumberB,
} from '../generateRandomNumber/generateRandomNumber';

type TypeGetRandomNumbers = (
  maxAvailableValue: number,
  currentArithmeticAction: Operator,
) => number[];

export const getRandomNumbers: TypeGetRandomNumbers = (
  maxAvailableValue,
  currentArithmeticAction,
) => {
  const numberA = generateRandomNumberA(maxAvailableValue, currentArithmeticAction);
  const numberB = generateRandomNumberB(maxAvailableValue, numberA, currentArithmeticAction);

  return [numberA, numberB];
};
