import { useEffect, useRef, useState } from 'react';
import './App.css';

export const App = () => {
  const inputRef = useRef(null);

  const [maxAvailableValue, setMaxAvailableValue] = useState<number>(10);
  const [resultInputValue, setResultInputValue] = useState<string>('');
  const [message, setMessage] = useState<string>('');

  const [numberA, setNumberA] = useState<number>(0);
  const [numberB, setNumberB] = useState<number>(0);

  const getRandomNumber = (max: number): number => {
    return Math.floor(Math.random() * (max - max / 10) + 1);
  };

  const getRandomNumberB = (max: number, a: number): number => {
    return Math.floor(Math.random() * (max - a) + 1);
  };

  const checkInputLength = () => {
    if (inputRef.current.value.length === 0) {
      setMessage(() => {
        return 'Введите число';
      });
    } else {
      nextQuestion(checkAnswer());
    }
  };

  const checkAnswer = (): boolean => {
    const isCorrect: boolean = numberA + numberB === Number(resultInputValue);

    setMessage(() => {
      return isCorrect ? 'Правильный ответ' : 'Неправильный ответ';
    });

    setResultInputValue(() => {
      return '';
    });
    return isCorrect;
  };

  const nextQuestion = (isCorrect: boolean) => {
    if (isCorrect) {
      const a = getRandomNumber(maxAvailableValue);
      setNumberA(() => {
        return a;
      });
      setNumberB(() => {
        return getRandomNumberB(maxAvailableValue, a);
      });

      setResultInputValue('');
    }
    return;
  };

  useEffect(() => {
    const randomNumberA = getRandomNumber(maxAvailableValue);
    const randomNumberB = getRandomNumberB(maxAvailableValue, randomNumberA);

    setNumberA(randomNumberA);
    setNumberB(randomNumberB);
  }, [maxAvailableValue]);

  return (
    <>
      <header>
        <h1>Арифметические задачи</h1>
      </header>
      <main>
        <select
          onChange={(e) => {
            setMaxAvailableValue(Number(e.target.value));
          }}>
          <option value={10}>результатом будет число меньшее или равное 10</option>
          <option value={100}>результатом будет число меньшее или равное 100</option>
          <option value={1000}>результатом будет число меньшее или равное 1000</option>
        </select>
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
        <span>{message}</span>

        <form
          onSubmit={(e) => {
            e.preventDefault();
            checkInputLength();
          }}>
          <label htmlFor="result">
            {numberA} + {numberB}
            <input
              ref={inputRef}
              autoFocus
              value={resultInputValue}
              onChange={(e) => {
                setResultInputValue(() => {
                  return e.target.value;
                });
              }}
              type="number"
              name="result"
              id="result"
            />
          </label>
          <button type="submit">Принять</button>
        </form>
      </main>
    </>
  );
};
