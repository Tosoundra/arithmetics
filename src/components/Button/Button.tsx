import React, { FC, SetStateAction } from 'react';
import { Operator } from '../../App';

interface Props {
  title: string;
  onClick: React.Dispatch<SetStateAction<Operator>>;
  arithmeticsOperation: Operator;
}

export const Button: FC<Props> = ({ title, onClick, arithmeticsOperation }) => {
  return (
    <button
      onClick={() => {
        return onClick(arithmeticsOperation);
      }}>
      {title}
    </button>
  );
};
