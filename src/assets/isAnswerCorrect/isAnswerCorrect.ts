import { InterfaceMathOperationDependsNumber } from '../InterfaceMathOperationDependsNumber/InterfaceMathOperationDependsNumber';

export const isAnswerCorrect = (
  numberA: number,
  numberB: number,
  userAnswer: string,
  currentMathAction: keyof InterfaceMathOperationDependsNumber,
): boolean => {
  const mathActions: InterfaceMathOperationDependsNumber = {
    '+': numberA + numberB,
    '-': numberA - numberB,
    '×': numberA * numberB,
    '÷': numberA / numberB,
  };

  return mathActions[currentMathAction] === Number(userAnswer);
};
