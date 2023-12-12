import React, { FC, SetStateAction } from 'react';
import './Popup.css';
import info from '../../assets/images/info.png';
import technical from '../../assets/images/customer-support.png';
import howToUse from '../../assets/images/thinking.png';

interface Props {
  isPopupActive: boolean;
  setIsPopupActive: React.Dispatch<SetStateAction<boolean>>;
}

export const Popup: FC<Props> = ({ isPopupActive, setIsPopupActive }) => {
  return (
    <dialog open={isPopupActive} className="popup">
      <article className="popup__container">
        <div className="popup__question">
          <span>Что это?</span>&nbsp;
          <img src={info} width={20} height={20} alt="icon" />
        </div>
        <p className="popup__answer">
          Это простой и удобный(что прости?🤨) онлайн тренажер для решения базовых математических
          операций. В нынешней реализации действия деления/умножения ограничиваются стандартным
          набором (как в тетрадках в школе, помните?)
        </p>
        <div className="popup__question">
          <span>Как пользоваться?</span>&nbsp;
          <img src={howToUse} width={20} height={20} alt="icon" />
        </div>
        <p className="popup__answer">
          Ну уж если я разобрался🤯, то и вы без труда разберетесь😉. <br /> Алгоритм простой:
          выбираете математическое действие, выбираете границу результирующего значения и начинаете
          жоска прокачивать свои мозги.
        </p>
        <div className="popup__question">
          <span>Известные проблемы</span>&nbsp;
          <img src={technical} width={20} height={20} alt="icon" />
        </div>
        <p className="popup__answer">
          На данный момент замечены проблемы при вычитании, а именно частая генерация числа,
          результатом которого будет 0. <br /> Проблема при умножении: часто числа умножаются 1х1.
          Если столкнулись с проблемой - дайте (только не по жопе) обратную связь.
        </p>
        <span className="popup__question">Что будет дальше?</span>
        <p className="popup__answer">
          Добавлю возможность выбирать значения помимо стандартного набора для деления/умножения.
        </p>
        <button
          onClick={() => {
            setIsPopupActive(false);
          }}
          className="popup__button"
          type="button">
          Да понятно всё
        </button>
      </article>
    </dialog>
  );
};
