interface Type {
  addition: string;
  subtraction: string;
  multiply: string;
  divide: string;
  [key: string]: string;
}

export const association: Type = {
  addition: '+',
  subtraction: '-',
  multiply: '×',
  divide: '÷',
};
