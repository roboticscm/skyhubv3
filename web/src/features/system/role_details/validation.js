import { CommonValidation } from 'src/lib/common-validation';

export const validation = (form) => {
  const error = {};

  if (CommonValidation.isEmptyString(form.roleId)) {
    error.roleId = CommonValidation.SELECT_AT_LEAST_ONE_LEAF_NODE;
  }

  if (!form.filterOrgIds || form.filterOrgIds.length === 0) {
    error.filterOrgIds = CommonValidation.CHECK_AT_LEAST_ONE_NODE;
  }

  if (!form.checkedRoleOrgMenu || form.checkedRoleOrgMenu.length === 0) {
    error.checkedRoleOrgMenu = CommonValidation.CHECK_AT_LEAST_ONE_NODE;
  }

  return error;
};