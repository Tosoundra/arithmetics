import { FC, useState } from 'react';
import './App.css';
import './components/Popup/Popup.css';
import { Main } from './components/Main/Main';
import { Popup } from './components/Popup/Popup';

const WarnPopup = () => {
  const [isActive, setisActive] = useState(true);
  return (
    <div className={`${isActive ? 'popup' : 'popup_closed'}`}>
      <div className="popup__container">
        <h3 className="popup__question">
          Привет! Проект находится в активной стадии разработки. Дизайна пока нет, но основные
          функции работают.
        </h3>
        <button
          onClick={() => {
            setisActive(false);
          }}
          style={{ display: 'block', margin: 'auto', backgroundColor: 'Highlight' }}
          type="button">
          OK!
        </button>
      </div>
    </div>
  );
};

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
      <WarnPopup />
    </>
  );
};
