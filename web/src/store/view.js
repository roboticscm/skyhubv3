import { getMenuNameFromPath, getViewTitleFromMenuPath } from 'src/lib/url-util';
import { StringUtil } from 'src/lib/string-util';
import { BehaviorSubject, of, forkJoin } from 'rxjs';
import { skip, catchError, first } from 'rxjs/operators';
import { App } from 'src/lib/constants';
import { TableUtilStore } from 'src/store/table-util';
import { T } from 'src/lib/locale';
import { errorSection } from 'src/lib/debug';
import { ButtonPressed } from 'src/components/ui/button/types';
import { getDiffFieldsObject, SObject } from 'src/lib/sobject';
import { MenuControlStore } from 'src/store/menu-control';
import { SDate } from 'src/lib/sdate';
import { SkyLogStore } from 'src/store/skylog';
import { Authentication } from 'src/lib/authentication';

export class ViewStore {
  tableName = undefined;
  columns = ['name'];
  orderBy = ['sort nulls last'];
  trashRestoreColumns = ['name'];
  page = 1;
  pageSize = App.DEFAULT_PAGE_SIZE;
  onlyMe = false;
  includeDisabled = false;
  fullCount$ = new BehaviorSubject();
  loading$ = new BehaviorSubject(false);
  saveRunning$ = new BehaviorSubject(false);
  deleteRunning$ = new BehaviorSubject(false);
  isReadOnlyMode$ = new BehaviorSubject(false); // true: form can edit, false form disable
  isUpdateMode$ = new BehaviorSubject(false); // true: update mode, false: save mode
  dataList$ = new BehaviorSubject([]);
  hasAnyDeletedRecord$ = new BehaviorSubject(false);
  roleControls = [];
  fullControl = false;
  needSelectId$ = new BehaviorSubject();
  needHighlightId$ = new BehaviorSubject();
  selectedData$ = new BehaviorSubject();

  customFindList = undefined;
  customWorkListColumns = undefined;

  constructor(menuPath) {
    this.menuPath = menuPath;
  }

  completeLoading$ = forkJoin([
    this.dataList$.pipe(
      skip(1),
      catchError((error) => of([])),
      first(),
    ),
  ]);

  getMenuNameFromPath = () => {
    return getMenuNameFromPath(this.menuPath);
  };

  getViewTitle = () => {
    return getViewTitleFromMenuPath(this.menuPath);
  };

  getViewName = () => {
    return StringUtil.replaceAll(
      StringUtil.toTitleCase(StringUtil.replaceAll(this.getMenuNameFromPath(), '-', '')),
      ' ',
      '',
    );
  };

  findSimpleList = (textSearch = '') => {
    TableUtilStore.findSimpleList({
      tableName: this.tableName,
      columns: this.columns.join(','),
      orderBy: this.orderBy.join(','),
      page: this.page,
      pageSize: this.pageSize,
      onlyMe: this.onlyMe,
      includeDisabled: this.includeDisabled,
    }).subscribe((res) => {
      const data = res.data;
      if (data.payload.length === 0 && this.page > 1) {
        this.page--;
        this.findSimpleList(textSearch);
      } else {
        this.dataList$.next(data.payload);
        this.fullCount$.next(data.fullCount);
      }
      this.dataList$.next(data.payload);
      this.fullCount$.next(data.fullCount);
    });
  };

  createWorkListColumns = () => {
    return this.columns.map((it) => {
      return {
        type: ['id', 'sort', 'code'].indexOf(it) >= 0 ? 'hidden' : 'text',
        name: it,
        title: T(`SYS.LABEL.${it.toUpperCase()}`),
      };
    });
  };

  getOneById = (id) => {
    return TableUtilStore.getOneById(this.tableName, id);
  };

  doDelete = (id, snackbarRef, doAddNew) => {
    this.deleteRunning$.next(true);
    TableUtilStore.softDeleteMany(this.tableName, [id]).subscribe({
      next: (res) => {
        const payload = {
          ...this.selectedData$.value,
          deletedBy: Authentication.getUsername(),
          deletedAt: SDate.newDateInMilli(),
        };
        SkyLogStore.save(this.selectedData$.value.name, {
          action: 'DELETE',
          payload,
        }).subscribe();
        snackbarRef.showDeleteSuccess(res.data.deletedRows + ' ' + T('SYS.LABEL.RECORD'));
      },
      error: (err) => {
        snackbarRef.show(err.message);
      },
      complete: () => {
        doAddNew();
        this.deleteRunning$.next(false);
      },
    });
  };

  isDisabled = (controlCode, hasError = false) => {
    if (hasError) {
      return true;
    }
    if (this.fullControl) {
      return false;
    } else {
      if (!this.roleControls) return true;
      return (
        this.roleControls.filter((item) => item.controlCode === controlCode && item.disableControl === false).length ===
        0
      );
    }
  };

  isRendered = (controlCode, isRendered = true) => {
    if (!isRendered) {
      return false;
    }

    if (this.fullControl) {
      return true;
    } else {
      if (!this.roleControls) return false;

      return (
        this.roleControls.filter((item) => item.controlCode === controlCode && item.renderControl === true).length > 0
      );
    }
  };

  hasPermission = (event) => {
    let eleId = null;
    if (typeof event === 'object') {
      if (StringUtil.isEmpty(event.currentTarget.id)) {
        errorSection('hasPermission', `ID of ${event.currentTarget} was not set`);
        return false;
      }
      eleId = event.currentTarget.id;
    } else {
      eleId = event;
    }
    return !this.isDisabled(eleId);
  };

  checkControlProperty = (event, property) => {
    let eleId = null;
    if (typeof event === 'object') {
      if (StringUtil.isEmpty(event.currentTarget.id)) {
        errorSection(property, `ID of ${event.currentTarget} was not set`);
        return false;
      }
      eleId = event.currentTarget.id;
    } else {
      eleId = event;
    }

    if (!this.fullControl) {
      if (this.roleControls.filter((item) => item.controlCode === eleId && item[property] === false).length > 0) {
        return false;
      }
    } else {
      return false;
    }

    return true;
  };

  requirePassword = (event) => {
    return this.checkControlProperty(event, 'requirePassword');
  };

  confirm = (event) => {
    return this.checkControlProperty(event, 'confirm');
  };

  verifyAction = (id, confirmCallback, passwordConfirmModal, disabled = false) => {
    if (disabled) {
      return new Promise((resolve, reject) => {
        reject('fail');
      });
    }

    return new Promise((resolve, reject) => {
      if (StringUtil.isEmpty(id)) {
        errorSection('Verify Action', 'ID not defined');
        reject('fail');
      }
      // check permission
      if (!this.hasPermission(id)) {
        reject('fail');
      }

      // confirm
      if (confirmCallback && this.confirm(id)) {
        confirmCallback().then((confirmButtonPressed) => {
          if (confirmButtonPressed === ButtonPressed.ok) {
            if (this.requirePassword(id)) {
              passwordConfirmModal &&
                passwordConfirmModal.show().then((buttonPressed) => {
                  if (buttonPressed === ButtonPressed.ok) {
                    resolve('ok');
                  } else {
                    reject('fail');
                  }
                });
            } else {
              resolve('ok');
            }
          } else {
            reject('fail');
          }
        });
      } else {
        // no confirm
        if (this.requirePassword(id)) {
          passwordConfirmModal &&
            passwordConfirmModal.show().then((buttonPressed) => {
              if (buttonPressed === ButtonPressed.ok) {
                resolve('ok');
              } else {
                reject('fail');
              }
            });
        } else {
          resolve('ok');
        }
      }
    });
  };

  verifySimpleAction = (
    buttonId,
    confirmModalRef,
    confirmPasswordModalRef,
    msg,
    extraMessage = '',
    disabled = false,
  ) => {
    return this.verifyAction(
      buttonId,
      () => confirmModalRef.show(`${T(`SYS.MSG.${msg}`)} <b>${extraMessage}</b>. ${T('SYS.MSG.ARE_YOU_SURE')}?`),
      confirmPasswordModalRef,
      disabled,
    );
  };

  verifyAddNewAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'ADD_NEW',
      extraMessage,
      disabled,
    );
  };

  verifySaveAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'SAVE',
      extraMessage,
      disabled,
    );
  };

  verifyEditAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'EDIT',
      extraMessage,
      disabled,
    );
  };

  verifyUpdateAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'UPDATE',
      extraMessage,
      disabled,
    );
  };

  verifyDeleteAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'DELETE',
      extraMessage,
      disabled,
    );
  };

  verifySubmitAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'SUBMIT',
      extraMessage,
      disabled,
    );
  };

  verifyCancelSubmitAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'CANCEL_SUBMIT',
      extraMessage,
      disabled,
    );
  };

  verifyAssignAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'ASSIGN',
      extraMessage,
      disabled,
    );
  };

  verifyUnAssignAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'UN_ASSIGN',
      extraMessage,
      disabled,
    );
  };

  verifyHoldAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'HOLD',
      extraMessage,
      disabled,
    );
  };

  verifyUnHoldAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'UN_HOLD',
      extraMessage,
      disabled,
    );
  };

  verifyCompleteAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'COMPLETE',
      extraMessage,
      disabled,
    );
  };

  verifyUnCompleteAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'UN_COMPLETE',
      extraMessage,
      disabled,
    );
  };

  checkObjectArrayChange = (beforeData, currentData, snackbar = undefined) => {
    let changedObject = SObject.getDiffRowObjectArray(beforeData, currentData);

    if (SObject.isEmptyField(changedObject)) {
      if (snackbar) {
        snackbar.showNoDataChange();
      }

      return null;
    }
    return changedObject;
  };

  checkObjectChange = (beforeData, currentData, snackbar = undefined) => {
    let changedObject = getDiffFieldsObject(beforeData, currentData);

    if (SObject.isEmptyField(changedObject)) {
      if (snackbar) {
        snackbar.showNoDataChange();
      }
      return null;
    }
    return changedObject;
  };

  checkObjectArrayChange2 = (beforeData, currentData, keyFields, snackbar = undefined) => {
    let changedObject = SObject.getDiffRowObjectArray2(beforeData, currentData, keyFields);

    if (SObject.isEmptyField(changedObject)) {
      snackbar && snackbar.showNoDataChange();
      return null;
    }

    return changedObject;
  };

  showViewConfigModal = (buttonId, scRef) => {
    const confirmCallback = () => {
      return scRef.confirmModalRef().show(`${T('SYS.MSG.SHOW_VIEW_CONFIG')}. ${T('SYS.MSG.ARE_YOU_SURE')}?`);
    };

    this.verifyAction(buttonId, confirmCallback, scRef.confirmPasswordModalRef()).then((_) => {
      MenuControlStore.findMenuControl(this.menuPath).subscribe((res) => {
        const data = SObject.convertArrayFieldsToCamelCase(res.data);
        scRef
          .configModalRef()
          .show(data)
          .then((buttonPressed) => {
            if (buttonPressed === ButtonPressed.ok) {
              const newData = scRef.configModalRef().getData();
              let dataChanged = this.checkObjectArrayChange(data, newData, scRef.snackbarRef());
              if (dataChanged) {
                dataChanged = dataChanged.filter(
                  (item) => item.code !== 'btnConfig' || (item.code === 'btnConfig' && item.checked),
                );

                if (dataChanged.length > 0) {
                  MenuControlStore.saveOrDelete({
                    menuPath: this.menuPath,
                    menuControls: dataChanged,
                  }).subscribe((_) => {
                    // location.reload();
                  });
                }
              }
            }
          });
      });
    });
  };

  showViewLogModal = (buttonId, scRef) => {
    const confirmCallback = () => {
      return scRef.confirmModalRef().show(`${T('SYS.MSG.SHOW_VIEW_LOG_MODAL')}. ${T('SYS.MSG.ARE_YOU_SURE')}?`);
    };

    this.verifyAction(buttonId, confirmCallback, scRef.confirmPasswordModalRef()).then((_) => {
      SkyLogStore.findLog(this.menuPath).subscribe((res) => {
        const data = res.data ? res.data.map((row) => {
          row.date = row.date ? SDate.convertMillisecondToDateTimeString(parseInt(row.date)) : '';
          row.action = JSON.parse(row.description).action;
          row.view = T('SYS.LABEL.VIEW');
          return row;
        }) : [];
        scRef
          .viewLogModalRef()
          .show(data)
          .then((buttonPressed) => {});
      });
    });
  };

  checkDeletedRecord = (onlyMe) => {
    TableUtilStore.hasAnyDeletedRecord(this.tableName, onlyMe).subscribe((res) => {
      const data = res.data;
      if (data.length > 0) {
        this.hasAnyDeletedRecord$.next(data[0].exists);
      }
    });
  };

  showTrashRestoreModal = (buttonId, onlyMe, scRef) => {
    this.verifyAction(
      buttonId,
      () => {
        scRef.confirmModalRef().show(`${T('SYS.MSG.SHOW_TRUSH_RESTORE')}. ${T('SYS.MSG.ARE_YOU_SURE')}?`);
      },
      scRef.confirmPasswordModalRef(),
    ).then(() => {
      this.doShowTrashRestoreModal(onlyMe, scRef.trashRestoreModalRef(), scRef.snackbarRef());
    });
  };

  doShowTrashRestoreModal = (onlyMe, trashRestoreModalRef, snackbarRef) => {
    TableUtilStore.findDeletedRecords(this.tableName, this.trashRestoreColumns, onlyMe).subscribe((res) => {
      const newData = res.data
        ? res.data.map((item, index) => {
            item.restore = false;
            item.foreverDelete = false;
            item.deletedDate = SDate.convertMillisecondToDateTimeString(item.deletedDate);
            return item;
          })
        : [];

      trashRestoreModalRef.show(newData).then((buttonPressed) => {
        if (buttonPressed === ButtonPressed.ok) {
          const newData = trashRestoreModalRef.getData();

          if (newData && newData.length > 0) {
            const filter = newData
              .filter((item) => item.restore === true || item.foreverDelete === true)
              .map((item) => {
                delete item.deletedBy;
                delete item.deletedDate;
                return item;
              });
            if (filter && filter.length > 0) {
              const deletedIds = filter
                .filter((item) => item.foreverDelete === true)
                .map((it) => it.id)
                .join(',');

              const restoreIds = filter
                .filter((item) => item.restore === true)
                .map((it) => it.id)
                .join(',');

              TableUtilStore.restoreOrForeverDeleteWithLog(this.tableName, deletedIds, restoreIds).subscribe(() => {
                if (deletedIds && deletedIds.split(',').length === newData.length) {
                  snackbarRef.showTrashEmpty();
                } else {
                  if (restoreIds) {
                    snackbarRef.showTrashRestoreSuccess();
                  }
                }
              });
            } else {
              snackbarRef.showNoDataChange();
            }
          }
        }
      });
    });
  };

  doNotifyConflictData = async (form, data, selectedId, isReadOnlyMode, scRef) => {
    const changedObj = SObject.convertFieldsToCamelCase(data);
    delete changedObj.id;
    delete changedObj.password;
    delete changedObj.updatedBy;
    delete changedObj.updatedAt;
    delete changedObj.deletedBy;
    delete changedObj.deletedAt;

    const obj = SObject.clone(form);
    const formObj = {};

    for (const field in changedObj) {
      formObj[field] = obj[field];
    }

    const changed = this.checkObjectChange(formObj, changedObj);
    if (changed) {
      if (!isReadOnlyMode) {
        const editedUser = await this._getEditedUserDetail(changedObj.updatedBy);
        scRef
          .confirmConflictDataModalRef()
          .show(this._getChangedDataMessage(changed), editedUser, changedObj.updatedAt)
          .then((buttonPressed) => {
            if (buttonPressed === ButtonPressed.ok) {
              this.needSelectId$.next(selectedId);
              setTimeout(() => {
                this.isReadOnlyMode$.next(false);
              }, 2000);
            } else {
              this.needHighlightId$.next(selectedId);
            }
          });
      } else {
        this.needSelectId$.next(selectedId);
      }
    }
  };

  _getEditedUserDetail = async (userId) => {
    // const user = await HumanOrOrgStore.sysGetUserInfoById(userId);
    // return `${user[0].lastName} ${user[0].firstName} - <b>${user[0].username} </b>`;
    return 'abc';
  };

  _getChangedDataMessage = (changedData) => {
    const result = [];
    for (let field in changedData) {
      result.push({
        field: T('SYS.LABEL.' + StringUtil.toUpperCaseWithUnderscore(field)),
        oldValue: field.toLowerCase().includes('date')
          ? SDate.convertMillisecondToDateTimeString(changedData[field].oldValue)
          : changedData[field].oldValue,
        newValue: field.toLowerCase().includes('date')
          ? SDate.convertMillisecondToDateTimeString(changedData[field].newValue)
          : changedData[field].newValue,
      });
    }

    return result;
  };
}
