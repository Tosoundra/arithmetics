import { FC, useEffect, useState } from 'react';
import './App.css';
import { Form } from './components/Form/Form';
import { isAnswerCorrect } from './assets/isAnswerCorrect/isAnswerCorrect';
import { Button } from './components/Button/Button';
import { titleForButtonRus } from './assets/titleForButton/titleForButton';
import { generateNextQuestion } from './assets/generateNextQuestion/generateNextQuestion';
import { getRandomNumbers } from './assets/getRandomNumbers/getRandomNumbers';
import { Operator } from './assets/InterfaceMathOperationDependsNumber/InterfaceMathOperationDependsNumber';
import { MathOperations } from './assets/MathOperations/MathOperations';

export const App: FC = () => {
  const [currentArithmeticAction, setCurrentArithmeticAction] = useState<Operator>('+');
  const [maxAvailableValue, setMaxAvailableValue] = useState<number>(10);
  const [message, setMessage] = useState<string>('');
  const [numberA, setNumberA] = useState<number>(0);
  const [numberB, setNumberB] = useState<number>(0);

  const handleSubmitClick = (userAnswer: string): void => {
    const isCorrect = isAnswerCorrect(numberA, numberB, userAnswer, currentArithmeticAction);
    if (isCorrect) {
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
    <>
      <header>
        <h1>Онлайн тренажер арифметических задач</h1>
      </header>
      <main>
        <select
          disabled={currentArithmeticAction !== '+' && currentArithmeticAction !== '-'}
          onChange={(e) => {
            setMaxAvailableValue(Number(e.target.value));
          }}>
          <option value={10}>числа в пределах 10</option>
          <option value={100}>числа в пределах 100</option>
          <option value={1000}>числа в пределах 1000</option>
        </select>
        <nav>
          {titleForButtonRus.map((title, index) => {
            return (
              <Button
                title={title}
                onClick={setCurrentArithmeticAction}
                MathOperations={MathOperations[index]}
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
      </main>
    </>
  );
};
