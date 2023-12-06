import { FC, useRef, useState } from 'react';

type checkAnswer = (answer: string) => void;
type setMessage = (message: string) => void;

interface Props {
  operator: string;
  numberA: number;
  numberB: number;
  message: string;
  handleSubmitClick: checkAnswer;
  setMessage: setMessage;
}

export const Form: FC<Props> = ({
  operator,
  numberA,
  numberB,
  message,
  handleSubmitClick,
  setMessage,
}) => {
  const inputRef = useRef<HTMLInputElement>(null);
  const [resultInputValue, setResultInputValue] = useState<string>('');

  const isInputFill = () => {
    const isFill: boolean = !!inputRef.current?.value.length;

    if (isFill) {
      handleSubmitClick(resultInputValue);
      setResultInputValue('');
    } else {
      setMessage('Введите число');
    }
  };

  return (
    <form
      className="form"
      onSubmit={(e) => {
        e.preventDefault();
        isInputFill();
      }}>
      <span>{message}</span>
      <label htmlFor="result">
        {numberA} {operator} {numberB}
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
  );
};
