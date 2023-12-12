import { FC, useState } from 'react';
import './App.css';

import { Main } from './components/Main/Main';
import { Popup } from './components/Popup/Popup';

export const App: FC = () => {
  const [isPopupActive, setIsPopupActive] = useState<boolean>(false);

  return (
    <>
      <header>
        <h1>Онлайн тренажер арифметических задач</h1>
      </header>
      <Main />
      <button
        onClick={() => {
          setIsPopupActive(true);
        }}
        type="button">
        Подробности
      </button>

      <Popup isPopupActive={isPopupActive} setIsPopupActive={setIsPopupActive} />
    </>
  );
};
