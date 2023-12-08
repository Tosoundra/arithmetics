import { SetStateAction } from 'react';

import { getRandomNumbers } from '../getRandomNumbers/getRandomNumbers';
import { Operator } from '../../App';

// type TypeGetNextQuestion=(getNumbers:()=>number)

export const generateNextQuestion = (
  setNumbers: React.Dispatch<SetStateAction<number>>[],
  maxAvailableValue: number,
  currentArithmeticAction: Operator,
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
