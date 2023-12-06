type Props = {
  numberA: number;
  numberB: number;
  userAnswer: number;
  currentMathAction: string;
};

export const isAnswerCorrect = (
  numberA: number,
  numberB: number,
  userAnswer: string,
  currentMathAction: string,
): boolean => {
  const mathActions = {
    '+': numberA + numberB === Number(userAnswer),
    '-': numberA - numberB === Number(userAnswer),
    '×': numberA * numberB === Number(userAnswer),
    '÷': numberA / numberB === Number(userAnswer),
  };
  return mathActions[currentMathAction];
};
