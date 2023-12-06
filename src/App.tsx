import { FC, useEffect, useState } from 'react';
import './App.css';
import { Form } from './components/Form/Form';
import { isAnswerCorrect } from './assets/isAnswerCorrect/isAnswerCorrect';
import {
  generateRandomNumberA,
  generateRandomNumberB,
} from './assets/getRandomNumber/getRandomNumber';

export const App: FC = () => {
  const [currentArithmeticAction, setCurrentArithmeticAction] = useState<string>('+');

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
      nextQuestion();
    } else {
      setMessage(() => {
        return 'Неправильный ответ';
      });
    }
  };

  const nextQuestion = (): void => {
    const numberA = generateRandomNumberA(maxAvailableValue, currentArithmeticAction);
    setNumberA(() => {
      return numberA;
    });

    const numberB = generateRandomNumberB(maxAvailableValue, numberA, currentArithmeticAction);
    setNumberB(() => {
      return numberB;
    });
  };

  useEffect(() => {
    const numberA = generateRandomNumberA(maxAvailableValue, currentArithmeticAction);
    const numberB = generateRandomNumberB(maxAvailableValue, numberA, currentArithmeticAction);

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
          onChange={(e) => {
            setMaxAvailableValue(Number(e.target.value));
          }}>
          <option value={10}>числа в пределах 10</option>
          <option value={100}>числа в пределах 100</option>
          <option value={1000}>числа в пределах 1000</option>
        </select>
        <nav>
          <button
            onClick={() => {
              setCurrentArithmeticAction(() => {
                return '+';
              });
            }}
            className="button"
            type="button">
            Сложение
          </button>
          <button
            onClick={() => {
              setCurrentArithmeticAction(() => {
                return '-';
              });
            }}
            className="button"
            type="button">
            Вычитание
          </button>
          <button
            onClick={() => {
              setCurrentArithmeticAction(() => {
                return '×';
              });
            }}
            className="button"
            type="button">
            Умножение
          </button>
          <button
            onClick={() => {
              setCurrentArithmeticAction(() => {
                return '÷';
              });
            }}
            className="button"
            type="button">
            Деление
          </button>
        </nav>
        <Form
          operator={currentArithmeticAction}
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
