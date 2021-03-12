import { getMenuNameFromPath, getViewTitleFromMenuPath } from 'src/lib/url-util';
import { StringUtil } from 'src/lib/string-util';
import { BehaviorSubject, of, forkJoin } from 'rxjs';
import { skip, catchError, first } from 'rxjs/operators';
import { App } from 'src/lib/constants';
import { TableUtilStore } from 'src/store/table-util';
import { T } from 'src/lib/locale';
import { ButtonPressed } from 'src/components/ui/button/types';
import { getDiffFieldsObject, SObject } from 'src/lib/sobject';
import { MenuControlStore } from 'src/store/menu-control';
import { SDate } from 'src/lib/sdate';
import { SkyLogStore } from 'src/store/skylog';
import { Authentication } from 'src/lib/authentication';
import { RoleControlStore } from 'src/store/role-control';
import { LoginInfo } from 'src/store/login-info';
import { MenuStore } from 'src/features/system/menu/store';
import { PartnerService } from 'src/features/system/partner/service';

export class BaseView {
  tableName = undefined;
  columns = ['name'];
  orderBy = ['sort nulls last,name'];
  trashRestoreColumns = ['name'];
  page = 1;
  pageSize = App.DEFAULT_PAGE_SIZE;
  onlyMe = false;
  includeDisabled = false;
  fullCount$ = new BehaviorSubject();
  loading$ = new BehaviorSubject(false);
  copyRunning$ = new BehaviorSubject(false);
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
  customGetOne = undefined;
  customWorkListColumns = undefined;

  ModalContentView$ = new BehaviorSubject();
  modalFullControl$ = new BehaviorSubject();
  modalRoleControls$ = new BehaviorSubject()
  menuInfo$ = new BehaviorSubject();

  constructor(menuPath) {
    this.menuPath = menuPath;
    MenuStore.get(menuPath)
      .then((res) => {
        this.menuInfo$.next(res.toObject().data);
      });
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

  findList = (textSearch = '') => {
    if (this.customFindList) {
      return this.customFindList(this, textSearch);
    }

    return new Promise((resolve, reject) => {
      TableUtilStore.findSimpleList({
        tableName: this.tableName,
        columns: this.columns.join(','),
        filterText: textSearch,
        orderBy: this.orderBy.join(','),
        page: this.page,
        pageSize: this.pageSize,
        onlyMe: this.onlyMe,
        includeDisabled: this.includeDisabled,
      }).then((data) => {
        if (data.payload.length === 0 && this.page > 1) {
          this.page--;
          this.findList(textSearch);
        } else {
          this.dataList$.next(data.payload);
          this.fullCount$.next(data.fullCount);
        }
        this.dataList$.next(data.payload);
        this.fullCount$.next(data.fullCount);
        resolve(true);
      }).catch((err) => reject(err));
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

  getOne = (id) => {
    if (this.customGetOne) {
      return this.customGetOne(id);
    }
    return TableUtilStore.getOneById(this.tableName, id);
  };

  onAddNew = (event, scRef, doAddNewFunc) => {
    this.verifyAddNewAction(event.currentTarget.id, scRef).then((_) => {
      // if everything is OK, call the action
      if (doAddNewFunc) {
        doAddNewFunc();
      } else {
        this.doAddNew();
      }
    });
  }

  doAddNew = () => {
    this.isReadOnlyMode$.next(false);
    this.isUpdateMode$.next(false);
    this.selectedData$.next(null);
  } 

  onEdit = (event, scRef, desc, doEditFunc) => {
    // verify permission
    this.verifyEditAction(event.currentTarget.id, scRef, desc).then((_) => {
      if (doEditFunc) {
        doEditFunc();
      } else {
        this.onEdit();
      }
    });
  };

  doEdit = () => {
    // just switch to edit mode
    this.isReadOnlyMode$.next(false);
  } 

  onSave = (event, scRef, doSaveFunc) => {
    // verify permission
    this.verifySaveAction(event.currentTarget.id, scRef).then((_) => {
      // if everything is OK, call the action
      if (doSaveFunc) {
        doSaveFunc();
      } 
    });
  };

  onUpdate = (event, scRef, desc, doUpdateFunc) => {
    // verify permission
    this.verifyUpdateAction(event.currentTarget.id, scRef, desc).then((_) => {
      // if everything is OK, call the action
      if (doUpdateFunc) {
        doUpdateFunc();
      } 
    });
  };

  doSelect = (selectedData) => {
    if (selectedData) {
      selectedData.id = `${selectedData.id}`;
      isReadOnlyMode$.next(true);
      isUpdateMode$.next(true);
      form = new Form({
        ...selectedData,
      });
      orgTreeRef && orgTreeRef.checkNodeById(selectedData.orgId);
      // save init value for checking data change
      beforeForm = SObject.clone(form);
    }
  };

  onDelete = (event, scRef, id, desc, doEditFunc, postFunc) => {
    // verify permission
    this.verifyDeleteAction(event.currentTarget.id, scRef, desc).then((_) => {
      // if everything is OK, call the action
      if(doEditFunc) {
        doEditFunc();
      } else {
        this.doDelete(id, scRef.snackbarRef(), postFunc);
      }
    });
  };

  doDelete = (id, snackbarRef, postFunc) => {
    this.deleteRunning$.next(true);
    TableUtilStore.softDeleteMany(this.tableName, [id]).then((res) => {
      const payload = {
        ...this.selectedData$.value,
        deletedBy: Authentication.getUsername(),
        deletedAt: SDate.newDateInMilli(),
      };
      SkyLogStore.save(this.selectedData$.value.name, {
        action: 'DELETE',
        payload,
      });
      snackbarRef.showDeleteSuccess(res.effectedRows + ' ' + T('SYS.LABEL.RECORD'));
    }).catch((err) => {
      snackbarRef.show(err.message);
    }).finally(() => {
      if(postFunc) {
        postFunc();
      }
      
      this.deleteRunning$.next(false);
    });
  };

  onCopy = (event, scRef, id, desc, doCopyFunc, postFunc) => {
    // verify permission
    this.verifyCopyAction(event.currentTarget.id, scRef, desc).then((_) => {
      // if everything is OK, call the action
      if(doCopyFunc) {
        doCopyFunc();
      } else {
        this.doCopy(id, scRef.snackbarRef(), postFunc);
      }
    });
  };

  doCopy = (id, snackbarRef, postFunc) => {
    this.copyRunning$.next(true);
    setTimeout(()=> {
      this.copyRunning$.next(false);
      snackbarRef.showCopySuccess();
      if(postFunc) {
        postFunc();
      }
    }, 1000);
  };

  isDisabled = (controlCode, isDisabled = false) => {
    if (isDisabled) {
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
        log.errorSection('hasPermission', `ID of ${event.currentTarget} was not set`);
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
        log.errorSection(property, `ID of ${event.currentTarget} was not set`);
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
        log.errorSection('Verify Action', 'ID not defined');
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
      () => confirmModalRef.show({content: `${T(`SYS.MSG.${msg}`)} <b>${extraMessage}</b>. ${T('SYS.MSG.ARE_YOU_SURE')}?`}),
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

  verifyCopyAction = (buttonId, scRef, extraMessage = '', disabled = false) => {
    return this.verifySimpleAction(
      buttonId,
      scRef.confirmModalRef(),
      scRef.confirmPasswordModalRef(),
      'COPY',
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
      MenuControlStore.findMenuControl(this.menuPath).then((res) => {
        const data = res.toObject().dataList;
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
      SkyLogStore.findLog(this.menuPath).then((res) => {
        res = res.toObject().dataList;
        const data = res ? res.map((row) => {
          row.date = row.date ? SDate.convertMillisecondToDateTimeString(parseInt(row.date)) : '';
          row.action = JSON.parse(row.description).action;
          row.view = T('SYS.LABEL.VIEW');
          return row;
        }) : [];
        scRef
          .viewLogModalRef()
          .show(data)
          .then((buttonPressed) => { });
      });
    });
  };

  checkDeletedRecord = (onlyMe) => {
    TableUtilStore.hasAnyDeletedRecord(this.tableName, onlyMe).then((res) => {
      this.hasAnyDeletedRecord$.next(res);
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
    TableUtilStore.findDeletedRecords(this.tableName, this.trashRestoreColumns, onlyMe).then((res) => {
      const newData = res
        ? res.map((item, index) => {
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

              TableUtilStore.restoreOrForeverDeleteWithLog(this.tableName, deletedIds, restoreIds).then(() => {
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
    const updatedAt =  changedObj.updatedAt;
    const updatedBy = changedObj.updatedBy;
    delete changedObj.id;
    delete changedObj.password;
    delete changedObj.updatedBy;
    delete changedObj.updatedAt;
    delete changedObj.deletedBy;
    delete changedObj.deletedAt;
    delete changedObj.document;
    const obj = SObject.clone(form);
    const formObj = {};

    for (const field in changedObj) {
      formObj[field] = obj[field];
    }

    const changed = this.checkObjectChange(formObj, changedObj);
    if (changed) {
      if (!isReadOnlyMode) {
        const editedUser = await this._getEditedUserDetail(updatedBy);
        scRef
          .confirmConflictDataModalRef()
          .show(this._getChangedDataMessage(changed), editedUser, updatedAt)
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
    try {
      const user = await PartnerService.getOne(userId);
      return `${user.lastName} ${user.firstName} - <b>${user.username} </b>`;
    } catch (err) {
      log.error(err);
      return 'Unknown user';
    } 
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

  loadModalComponent = (menuPath) => {
    return new Promise((resolve, reject) => {
      RoleControlStore
        .findRoleControls(LoginInfo.departmentId$.value, menuPath)
        .then((res) => {
          const rc = res.toObject().dataList;
          if (rc && rc.length > 0 && rc[0].fullControl) {
            this.modalFullControl$.next(true);
          } else {
            this.modalRoleControls$.next(rc);
          }
          import('src/features/' + menuPath + '/index.svelte')
            .then((res) => {
              this.ModalContentView$.next(res.default);
              resolve('ok');
            })
            .catch((error) => reject(error));
        });
    });
  };
}
