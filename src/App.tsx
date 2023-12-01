import { useEffect, useState } from 'react';
import './App.css';

export const App = () => {
  const [resultInputValue, setResultInputValue] = useState<string>('');
  const [isAnswerCorrect, setIsAnswerCorrect] = useState<boolean>(false);
  const [feedback, setFeedback] = useState('');

  const [numberA, setNumberA] = useState<number>(0);
  const [numberB, setNumberB] = useState<number>(0);

  const getRandomNumber = () => {
    return Math.floor(Math.random() * 9);
  };

  const checkAnswer = () => {
    const isCorrect = numberA + numberB === Number(resultInputValue);
    setFeedback(() => {
      return isCorrect ? 'Правильный ответ' : 'Неправильный ответ';
    });

    setIsAnswerCorrect(isCorrect);
  };

  const nextQuestion = () => {
    if (isAnswerCorrect) {
      setNumberA(() => {
        return getRandomNumber();
      });
      setNumberB(() => {
        return getRandomNumber();
      });

      setResultInputValue('');

      setIsAnswerCorrect(false);
    }
    return;
  };

  useEffect(() => {
    const randomNumberA = getRandomNumber();
    const randomNumberB = getRandomNumber();
    setNumberA(randomNumberA);
    setNumberA(randomNumberB);
  }, []);

  useEffect(() => {
    nextQuestion();
  }, [isAnswerCorrect]);
  return (
    <>
      <header>
        <h1>Арифметические задачи</h1>
      </header>
      <main>
        <nav>
          <button className="button" type="button">
            Сложение
          </button>
          <button className="button" type="button">
            Вычитание
          </button>
          <button className="button" type="button">
            Умножение
          </button>
          <button className="button" type="button">
            Деление
          </button>
        </nav>
        <form
          onSubmit={(e) => {
            e.preventDefault();
            checkAnswer();
          }}>
          <label htmlFor="result">
            {numberA} + {numberB}
            <input
              autoFocus
              value={resultInputValue}
              onChange={(e) => {
                setResultInputValue(() => {
                  return e.target.value;
                });
              }}
              type="text"
              name="result"
              id="result"
            />
          </label>
          <span>{feedback}</span>
          <button type="submit">Принять</button>
        </form>
      </main>
    </>
  );
};
