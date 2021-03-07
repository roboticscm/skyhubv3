<script>
  import { CommonValidation } from 'src/lib/common-validation';
  import { StringUtil } from 'src/lib/string-util';
  import { ModalType } from 'src/components/ui/modal/types';

  import ConfirmModal from 'src/components/ui/modal/base';
  import ConfirmDeleteModal from 'src/components/ui/modal/base';
  import ConfirmPasswordModal from 'src/components/ui/modal/base';
  import ConfirmConflictDataModal from 'src/components/ui/modal/conflict-data-confirm';
  import ConfigModal from 'src/components/ui/modal/view-config';
  import ViewLogModal from 'src/components/ui/modal/view-log';
  import TrashRestoreModal from 'src/components/ui/modal/trash-restore';
  import Snackbar from 'src/components/ui/snackbar';
  import { Authentication } from 'src/lib/authentication';
  // Props
  export let view;
  export let menuPath;

  // external
  let _confirmModalRef;
  let _confirmDeleteModalRef;
  let _confirmPasswordModalRef;
  let _snackbarRef;
  let _configModalRef;
  let _viewLogModalRef;
  let _trashRestoreModalRef;
  let _confirmConflictDataModalRef;

  export const confirmModalRef = () => {
    return _confirmModalRef;
  };

  export const confirmDeleteModalRef = () => {
    return _confirmDeleteModalRef;
  };

  export const confirmPasswordModalRef = () => {
    return _confirmPasswordModalRef;
  };

  export const snackbarRef = () => {
    return _snackbarRef;
  };

  export const configModalRef = () => {
    return _configModalRef;
  };

  export const viewLogModalRef = () => {
    return _viewLogModalRef;
  };

  export const trashRestoreModalRef = () => {
    return _trashRestoreModalRef;
  };

  export const confirmConflictDataModalRef = () => {
    return _confirmConflictDataModalRef;
  };

  const validatePassword = () => {
    return new Promise((resolve, reject) => {
      if (StringUtil.isEmpty(_confirmPasswordModalRef.getPassword())) {
        _confirmPasswordModalRef.raisePasswordError(CommonValidation.REQUIRED_VALUE.t());
        reject(false);
      } else {
         Authentication.verifyPassword(Authentication.getUsername(), _confirmPasswordModalRef.getPassword())
        .then(() => {
          resolve(true);
        })
        .catch((e) => {
          console.log(e.message)
          _confirmPasswordModalRef.raisePasswordError(e.message.t());
          reject(false);
        });
        
      }
    });
  };

  
</script>

<!--Invisible Element-->
<Snackbar bind:this={_snackbarRef} />
<ConfirmConflictDataModal
  {menuPath}
  id={'conflictData' + view.getViewName() + 'Modal'}
  bind:this={_confirmConflictDataModalRef} />
<ConfirmModal id={'confirm' + view.getViewName() + 'Modal'} modalType={ModalType.confirm} {menuPath} bind:this={_confirmModalRef} />
<ConfirmDeleteModal
  id="mdConfirmDeleteModal"
  title={'SYS.LABEL.DELETE'.t()}
  modalType={ModalType.confirm}
  {menuPath}
  bind:this={_confirmDeleteModalRef} />
<ConfirmPasswordModal beforeOK={validatePassword} id={'confirmPassword' + view.getViewName() + 'Modal'} modalType={ModalType.confirmPassword} {menuPath} bind:this={_confirmPasswordModalRef} />
<ConfigModal
  {menuPath}
  subTitle={view.getViewTitle()}
  id={'configModal' + view.getViewName()}
  bind:this={_configModalRef}
  containerWidth="500px" />
<TrashRestoreModal
  columns={view.trashRestoreColumns}
  {menuPath}
  subTitle={view.getViewTitle()}
  id={'trashRestoreModal' + view.getViewName()}
  bind:this={_trashRestoreModalRef}
  containerWidth="600px" />

<ViewLogModal
  {menuPath}
  subTitle={view.getViewTitle()}
  id={'viewLogModal' + view.getViewName()}
  bind:this={_viewLogModalRef}
  containerWidth="500px" />
<!--//Invisible Element-->
