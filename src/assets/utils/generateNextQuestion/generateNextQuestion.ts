import { SetStateAction } from 'react';

import { getRandomNumbers } from '../getRandomNumbers/getRandomNumbers';
import { Operator } from '../InterfaceMathOperationDependsNumber/InterfaceMathOperationDependsNumber';

type TypeGetNextQuestion = (
  setNumbers: React.Dispatch<SetStateAction<number>>[],
  maxAvailableValue: number,
  currentArithmeticAction: Operator,
) => void;

export const generateNextQuestion: TypeGetNextQuestion = (
  setNumbers,
  maxAvailableValue,
  currentArithmeticAction,
): void => {
  const [numberA, numberB] = getRandomNumbers(maxAvailableValue, currentArithmeticAction);
  const [setNumberA, setNumberB] = setNumbers;

  setNumberA(() => {
    return numberA;
  });

  setNumberB(() => {
    return numberB;
  });
};
