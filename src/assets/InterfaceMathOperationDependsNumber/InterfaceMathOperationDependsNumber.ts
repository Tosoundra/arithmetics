export interface InterfaceMathOperationDependsNumber {
  '+': number;
  '-': number;
  '×': number;
  '÷': number;
}

export type Operator = keyof InterfaceMathOperationDependsNumber;
