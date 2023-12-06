interface OperatorNumbers {
  addition: number;
  subtraction: number;
  multiply: number;
  // '÷': number; // Если нужно добавить деление
}

export const isAnswerCorrect = (
  numberA: number,
  numberB: number,
  userAnswer: string,
  currentMathAction: OperatorNumbers,
): boolean => {
  const [operator] = Object.keys(currentMathAction) as Array<keyof OperatorNumbers>;

  const mathActions = {
    addition: numberA + numberB === Number(userAnswer),
    subtraction: numberA - numberB === Number(userAnswer),
    multiply: numberA * numberB === Number(userAnswer),
    // '÷': numberA / numberB === Number(userAnswer),
  };
  return mathActions[operator];
};
