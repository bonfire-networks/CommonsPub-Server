// as per Zendesk Garden TextField validation types
export enum ValidationType {
  error = 'error',
  warning = 'warning',
  success = 'success'
}

export enum ValidationField {
  email,
  password
}

export type ValidationObject = {
  type: ValidationType;
  field: ValidationField | null;
  message: string;
};
