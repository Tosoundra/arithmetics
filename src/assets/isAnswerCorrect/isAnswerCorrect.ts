// interface OperatorNumbers {
//   addition: boolean;
//   subtraction: boolean;
//   multiply: boolean;
//   divide: boolean;
// }

import { InterfaceMathOperationDependsNumber } from '../InterfaceMathOperationDependsNumber/InterfaceMathOperationDependsNumber';

export const isAnswerCorrect = (
  numberA: number,
  numberB: number,
  userAnswer: string,
  currentMathAction: keyof InterfaceMathOperationDependsNumber,
): boolean => {
  const mathActions: InterfaceMathOperationDependsNumber = {
    // addition: numberA + numberB === Number(userAnswer),
    // subtraction: numberA - numberB === Number(userAnswer),
    // multiply: numberA * numberB === Number(userAnswer),
    // divide: numberA / numberB === Number(userAnswer),
    '+': numberA + numberB,
    '-': numberA - numberB,
    '×': numberA * numberB,
    '÷': numberA / numberB,
  };

  return mathActions[currentMathAction] === Number(userAnswer);
};
