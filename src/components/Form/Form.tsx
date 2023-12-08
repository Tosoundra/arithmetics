import { FC, useRef, useState } from 'react';
import { association } from '../../assets/correspondenceObject/correspondenceObject';

type checkAnswer = (answer: string) => void;
type setMessage = (message: string) => void;

interface Props {
  currentArithmeticAction: string;
  numberA: number;
  numberB: number;
  message: string;
  handleSubmitClick: checkAnswer;
  setMessage: setMessage;
}

export const Form: FC<Props> = ({
  currentArithmeticAction,
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
        {numberA} {association[currentArithmeticAction]} {numberB}
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
          min={0}
          name="result"
          id="result"
        />
      </label>
      <button type="submit">Принять</button>
    </form>
  );
};
