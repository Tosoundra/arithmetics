import { FC, useEffect, useState } from 'react';
import './Main.css';
import { Operator } from '../../assets/utils/InterfaceMathOperationDependsNumber/InterfaceMathOperationDependsNumber';
import { titleForButtonRus } from '../../assets/utils/titleForButton/titleForButton';
import { Button } from '../Button/Button';
import { MathOperations } from '../../assets/utils/MathOperations/MathOperations';
import { Form } from '../Form/Form';
import { CounterComponents } from '../CounterComponents/CounterComponents';
import { isAnswerCorrect } from '../../assets/utils/isAnswerCorrect/isAnswerCorrect';
import { getRandomNumbers } from '../../assets/utils/getRandomNumbers/getRandomNumbers';
import { generateNextQuestion } from '../../assets/utils/generateNextQuestion/generateNextQuestion';

export const Main: FC = () => {
  const [counterOfOverallQuestions, setCounterOfOverallQuestions] = useState<number>(0);
  const [counterOfCorrectAnswers, setCounterOfCorrectAnswers] = useState<number>(0);
  const [currentArithmeticAction, setCurrentArithmeticAction] = useState<Operator>('+');
  const [maxAvailableValue, setMaxAvailableValue] = useState<number>(10);
  const [message, setMessage] = useState<string>('');
  const [numberA, setNumberA] = useState<number>(0);
  const [numberB, setNumberB] = useState<number>(0);

  const handleSubmitClick = (userAnswer: string): void => {
    setCounterOfOverallQuestions((state) => state + 1);

    const isCorrect = isAnswerCorrect(numberA, numberB, userAnswer, currentArithmeticAction);
    if (isCorrect) {
      setCounterOfCorrectAnswers((state) => state + 1);
      setMessage(() => {
        return 'Правильный ответ';
      });

      generateNextQuestion([setNumberA, setNumberB], maxAvailableValue, currentArithmeticAction);
    } else {
      setMessage(() => {
        return 'Неправильный ответ';
      });
    }
  };

  useEffect(() => {
    const [numberA, numberB] = getRandomNumbers(maxAvailableValue, currentArithmeticAction);

    setNumberA(numberA);
    setNumberB(numberB);
  }, [maxAvailableValue, currentArithmeticAction]);

  return (
    <main className="main">
      <select
        onChange={(e) => {
          setMaxAvailableValue(Number(e.target.value));
        }}>
        {currentArithmeticAction === '+' || currentArithmeticAction === '-' ? (
          <>
            <option value={10}>числа в пределах 20</option>
            <option value={100}>числа в пределах 100</option>
            <option value={1000}>числа в пределах 1000</option>
          </>
        ) : (
          <option value={10}>Стандартная таблица {currentArithmeticAction}</option>
        )}
      </select>
      <nav>
        {titleForButtonRus.map((title, index) => {
          return (
            <Button
              title={title}
              onClick={setCurrentArithmeticAction}
              MathOperator={MathOperations[index]}
              currentArithmeticAction={currentArithmeticAction}
              key={index}
            />
          );
        })}
      </nav>
      <Form
        currentArithmeticAction={currentArithmeticAction}
        numberA={numberA}
        numberB={numberB}
        handleSubmitClick={handleSubmitClick}
        message={message}
        setMessage={setMessage}
      />
      <CounterComponents
        counterOfOverallQuestions={counterOfOverallQuestions}
        counterOfCorrectAnswers={counterOfCorrectAnswers}
      />
      <button
        onClick={() => {
          setCounterOfOverallQuestions(0);
          setCounterOfCorrectAnswers(0);
        }}>
        Сбросить статистику
      </button>
    </main>
  );
};
