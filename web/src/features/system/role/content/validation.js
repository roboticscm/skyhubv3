import { CommonValidation } from 'src/lib/common-validation';

export const validation = (form) => {
  const error = {};

  if (CommonValidation.isEmptyString(form.name)) {
    error.name = CommonValidation.REQUIRED_VALUE;
  }

  if (!CommonValidation.isIntegerNumber(form.sort)) {
    error.sort = CommonValidation.INTEGER_NUMBER;
  }

  if (CommonValidation.isEmptyString(form.orgId)) {
    error.orgId = CommonValidation.SELECT_AT_LEAST_ONE_NODE;
  }

  return error;
};
