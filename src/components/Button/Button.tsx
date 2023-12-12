import React, { FC, SetStateAction } from 'react';
import { Operator } from '../../assets/utils/InterfaceMathOperationDependsNumber/InterfaceMathOperationDependsNumber';
import './Button.css';

interface Props {
  title: string;
  onClick: React.Dispatch<SetStateAction<Operator>>;
  MathOperator: Operator;
  currentArithmeticAction: Operator;
}

export const Button: FC<Props> = ({ title, onClick, MathOperator, currentArithmeticAction }) => {
  return (
    <button
      onClick={() => {
        return onClick(MathOperator);
      }}
      className={`${MathOperator === currentArithmeticAction && 'button_active'}`}>
      {title}
    </button>
  );
};
