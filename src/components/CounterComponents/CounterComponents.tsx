import { FC } from 'react';
interface Props {
  counterOfOverallQuestions: number;
  counterOfCorrectAnswers: number;
}
type transformToPercentType = (
  counterOfOverallQuestions: number,
  counterOfCorrectAnswers: number,
) => number;

const transformToPercent: transformToPercentType = (
  counterOfOverallQuestions,
  counterOfCorrectAnswers,
) => Math.floor((counterOfCorrectAnswers / counterOfOverallQuestions) * 100);

export const CounterComponents: FC<Props> = ({
  counterOfOverallQuestions,
  counterOfCorrectAnswers,
}) => {
  return (
    <div>
      {/* <span>{`Количество вопросов ${counterOfOverallQuestions + 1}`}</span> */}
      <span>{`Правильные ответы, ${
        counterOfOverallQuestions &&
        transformToPercent(counterOfOverallQuestions, counterOfCorrectAnswers)
      }%`}</span>
    </div>
  );
};
