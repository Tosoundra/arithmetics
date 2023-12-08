import React, { FC, SetStateAction } from 'react';
import { Operator } from '../../assets/InterfaceMathOperationDependsNumber/InterfaceMathOperationDependsNumber';

interface Props {
  title: string;
  onClick: React.Dispatch<SetStateAction<Operator>>;
  MathOperations: Operator;
}

export const Button: FC<Props> = ({ title, onClick, MathOperations }) => {
  return (
    <button
      onClick={() => {
        return onClick(MathOperations);
      }}>
      {title}
    </button>
  );
};
